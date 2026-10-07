import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/localization/localization_provider.dart';
import 'router/app_router.dart';
import 'theme/app_text_styles.dart';
import 'theme/app_theme.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    ref.watch(appLanguageProvider);

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
          routerConfig: router,
        );
      },
    );
  }
}
