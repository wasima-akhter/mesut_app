Ran check maps dependencies
Ran find Google config files
Analyzed AndroidManifest.xml:L1-61
Ran check iOS AppDelegate

Good, I now have a clear picture. Here are your answers:

---

## Answers to Your Questions

### 1. Do you need to re-download `google-services.json` / `GoogleService-Info.plist`?

**No.** The Google Maps API key is **completely separate** from Firebase. It comes from the **Google Cloud Console**, not the Firebase Console. Your Firebase config files (for FCM/APNS) don't change at all.

### 2. Permissions — anything missing?

Your project already has the right permissions:
- ✅ **Android**: `ACCESS_FINE_LOCATION` + `ACCESS_COARSE_LOCATION` already in [AndroidManifest.xml](file:///d:/WASIMA/mesut_gundogdu_app/android/app/src/main/AndroidManifest.xml)
- ✅ **iOS**: `NSLocationWhenInUseUsageDescription` already in [Info.plist](file:///d:/WASIMA/mesut_gundogdu_app/ios/Runner/Info.plist)

**No extra permissions needed.** ✅

### 3. What's missing — the API key itself + wiring it into the project

Your Android manifest is **missing** the Maps API key `<meta-data>` tag, and your iOS `AppDelegate.swift` is **missing** the `GMSServices.provideAPIKey()` call.

---

## Guide: Creating a Google Maps API Key

Follow these steps:

### Step 1 — Go to Google Cloud Console
1. Open https://console.cloud.google.com/
2. Select the **same project** that your Firebase project uses (check the project ID in your `google-services.json` to confirm)

### Step 2 — Enable the Maps SDKs
Go to **APIs & Services → Library** and enable **both**:
- **Maps SDK for Android**
- **Maps SDK for iOS**

### Step 3 — Create the API Key
1. Go to **APIs & Services → Credentials**
2. Click **+ CREATE CREDENTIALS → API key**
3. A key will be generated (e.g., `AIzaSy...`)
4. Click **Edit** on the key to restrict it:

   **For Android restriction:**
   - Application restrictions → **Android apps**
   - Add your package: `com.geruestbau.app` + your SHA-1 fingerprint

   **For iOS restriction:**
   - Application restrictions → **iOS apps**
   - Add your bundle ID: `com.geruestbau.app`

> [!TIP]
> You can create **one unrestricted key** for development, then restrict it later for production. Or create **two separate keys** (one per platform) for tighter security.

### Step 4 — Get your Android SHA-1 (you'll need this for the key restriction)
Run this on your machine:
```
cd d:\WASIMA\mesut_gundogdu_app\android
.\gradlew signingReport
```

---

Once you have the API key, give it to me and I'll wire it into both **Android** (AndroidManifest.xml) and **iOS** (AppDelegate.swift) for you.
