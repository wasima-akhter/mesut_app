Analyzed main.dart:L1-6
Analyzed bootstrap.dart:L1-80
Analyzed performance_monitor.dart:L1-53

To establish performance governance for **`mesut_gundogdu_app`**, we need a targeted framework addressing the exact bottlenecks identified in your logs (specifically the **69ms–136ms raster thread spikes**, live timer ticks, Google Maps overlays, and background GPS/socket sync).

Here is the technical blueprint tailored specifically to this codebase:

---

### 1. Performance Budgets & Governance SLAs

Establish explicit non-negotiable budgets:

| Metric | Low-End Target (< 3GB RAM, Cortex-A53) | Mid/High-End Target | Measurement Point |
| :--- | :--- | :--- | :--- |
| **Cold Start (TTFD)** | $\le 2000\text{ ms}$ | $\le 1200\text{ ms}$ | Launch intent $\to$ first interactive frame |
| **Frame Render Time** | $\le 16.6\text{ ms}$ (60 FPS) | $\le 8.3\text{ ms}$ (120 FPS) | Scrolling lists & active timer ticking |
| **Raster Thread Time** | $\le 8\text{ ms}$ (zero dropped frames) | $\le 5\text{ ms}$ | Skia/Impeller GPU pipeline |
| **Idle Memory (RAM)** | $\le 85\text{ MB}$ | $\le 120\text{ MB}$ | Home/Dashboard idle |
| **Peak Memory (RAM)** | $\le 160\text{ MB}$ | $\le 220\text{ MB}$ | Central map active + camera photo preview |
| **Crash-Free Sessions** | $\ge 99.5\%$ | $\ge 99.9\%$ | Firebase Crashlytics on low-RAM devices |

---

### 2. Startup Speed Optimization (Cold & Warm)

In [bootstrap.dart](file:///d:/WASIMA/mesut_gundogdu_app/lib/core/app/bootstrap.dart), critical initialization blocks the first paint:
```dart
// CURRENT BLOCKER in bootstrap.dart:
await pushService.initialize().timeout(const Duration(seconds: 4)); // Blocks UI launch
```

#### Action Items:
1. **Two-Stage Deferred Bootstrapping**:
   - **Stage 1 (Pre-`runApp`)**: Only load what is strictly necessary to render the initial frame (`SharedPreferences`, stored language code, and auth token check).
   - **Stage 2 (Post-`runApp`)**: Defer FCM token registration, Socket.IO handshake, and remote config sync until after `addPostFrameCallback` or via `Future.microtask`.
2. **Android Native Splash Seamless Handoff**:
   - Ensure `drawable/launch_background.xml` matches the Flutter theme background color exactly so there is zero white flash before the Flutter engine attaches.
3. **App Size & Class Pre-warming**:
   - Build Android release artifacts with AOT split per ABI (`flutter build appbundle` or `flutter build apk --split-per-abi`) to avoid loading unnecessary 32/64-bit native libraries into memory.

---

### 3. Frame Rate & Raster Thread Bottlenecks (Eliminating 70–140ms Janks)

The logs indicated **`build=0.9ms, raster=136.6ms`**. This proves the Dart CPU thread is fast, but the **GPU rasterizer is heavily choked**.

#### Action Items:
1. **Eliminate Blurred Shadows in Scrollable Lists**:
   - `BoxShadow(blurRadius: 8, spreadRadius: ...)` forces off-screen GPU render passes for every item on screen.
   - Replace blurred drop shadows on list items ([schedule_phase_card.dart](file:///d:/WASIMA/mesut_gundogdu_app/lib/features/site_manager/schedule/widgets/schedule_phase_card.dart), `_InspectionCard`, `MobileTimeLogCard`) with crisp 1px borders (`Border.all(color: AppColors.border, width: 1)`).
2. **Isolate Animated & Ticking Widgets with `RepaintBoundary`**:
   - The live stopwatch timer (`EmployeeTimerControlCard`) fires every second. Without an isolated boundary, the **entire screen layer tree re-rasters**.
   - Wrap ticking cards and map preview containers in `RepaintBoundary` so only that sub-layer is invalidated on the GPU.
3. **Riverpod Micro-Rebuilds (`select`)**:
   - Never write `ref.watch(employeeTimerProvider)`. Always isolate:
     ```dart
     final isRunning = ref.watch(employeeTimerProvider.select((s) => s.isTimerRunning));
     final elapsed = ref.watch(employeeTimerProvider.select((s) => s.formattedElapsed));
     ```
4. **Lazy Scrolling**:
   - Ensure all list views use `ListView.builder` or `CustomScrollView` with `SliverList.builder`. Set `addAutomaticKeepAlives: false` and `addRepaintBoundaries: true` on dynamic lists.

---

### 4. Memory Usage & Low-RAM Stability (Preventing OOM)

Low-end Android devices (Android Go / 2GB–3GB RAM) kill background apps aggressively when memory spikes.

#### Action Items:
1. **Downsample Network & Camera Images**:
   - Never load raw resolution images directly into memory. A 12MP camera photo consumes ~48MB uncompressed RAM in memory ($4000 \times 3000 \times 4\text{ bytes}$).
   - Set `cacheWidth` and `cacheHeight` on `Image.network` / `CachedNetworkImage`:
     ```dart
     Image.network(url, cacheWidth: 300, cacheHeight: 300);
     ```
2. **Map Lifecycle Management**:
   - [central_map_screen.dart](file:///d:/WASIMA/mesut_gundogdu_app/lib/features/map/presentation/screens/central_map_screen.dart): Ensure `GoogleMapController` is explicitly disposed when navigating away from the Map tab. Multiple retained map instances will cause immediate OOM crashes on low-end devices.
3. **Trim Memory on Low-Memory Signals**:
   - Register a `WidgetsBindingObserver` in `App`:
     ```dart
     @override
     void didHaveMemoryPressure() {
       PaintingBinding.instance.imageCache.clear();
       PaintingBinding.instance.imageCache.clearLiveImages();
     }
     ```

---

### 5. Battery Efficiency & Background Processing

1. **GPS Throttling for Time Tracking**:
   - Do not stream high-frequency GPS continuously during a shift.
   - Record **single-point high-accuracy fixes** on **Start Timer** and **Stop Timer** (`LocationAccuracy.high`), and power down the GPS chip in between.
2. **Socket.IO Lifecycle Pausing**:
   - When the app transitions to `AppLifecycleState.paused` or `detached`, immediately pause the Socket.IO connection and rely strictly on Firebase Cloud Messaging (FCM) high-priority data pushes. Reconnect on `resumed`.

---

### 6. Android Platform-Level Tuning

1. **R8 Full Mode & Code Shrinking**:
   - Ensure `android/app/build.gradle.kts` has `isMinifyEnabled = true` and `isShrinkResources = true` in release builds to strip dead code and reduce DEX size.
2. **Enable Impeller (if Android Vulkan is available)**:
   - On Flutter 3.22+, Impeller is default or opt-in on Vulkan-capable devices, eliminating Skia shader compilation jank.
3. **Android Baseline Profiles**:
   - Generate baseline profiles using Android Macrobenchmark to pre-compile critical execution paths (cold start $\to$ dashboard login) ahead of time.

---

### 7. Governance Workflow & CI Gate Checklist

Before merging any new feature or screen:
1. **Local Profiling Check**:
   - Run with `flutter run --profile` on a physical low-end Android device.
   - Verify zero console logs from [performance_monitor.dart](file:///d:/WASIMA/mesut_gundogdu_app/lib/core/utils/performance_monitor.dart) (`[PERF] Slow frame detected`).
2. **DevTools Timeline Audit**:
   - Check Flutter DevTools **Performance** tab: CPU build $< 4\text{ms}$, Raster $< 8\text{ms}$.
3. **CI Size Gate**:
   - Enforce an APK/AAB size delta threshold in GitHub Actions / CI (e.g. max $+1.5\text{MB}$ per PR).
