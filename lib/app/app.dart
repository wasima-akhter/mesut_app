import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/localization/app_localization.dart';
import '../core/localization/localization_provider.dart';
import '../core/services/notification_socket_service.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import 'router/app_router.dart';
import 'theme/app_text_styles.dart';
import 'theme/app_theme.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        ref.read(authProvider).isAuthenticated) {
      ref.read(authProvider.notifier).heartbeatCheck();
      // Resume real-time notifications on foreground
      final token = ref.read(authProvider).accessToken;
      if (token != null && token.isNotEmpty) {
        ref.read(notificationSocketServiceProvider).connect(token);
      }
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      // Disconnect socket connection in background to conserve battery and bandwidth
      ref.read(notificationSocketServiceProvider).disconnect();
    }
  }

  @override
  void didHaveMemoryPressure() {
    // Release cached decodes immediately when Android OS signals low RAM
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final currentLanguage = ref.watch(appLanguageProvider);

    return ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      useInheritedMediaQuery: true,
      builder: (_, child) {
        final theme = AppTheme.light;
        AppTextStyles.initialize(theme.textTheme);
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Workforce',
          theme: theme,
          locale: currentLanguage.locale,
          supportedLocales: AppLocalization.supportedLocales,
          localizationsDelegates: const [
            AppLocalization.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routerConfig: router,
        );
      },
    );
  }
}
