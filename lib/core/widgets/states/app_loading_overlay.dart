import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../loading/app_loader.dart';

class AppLoadingOverlay extends StatelessWidget {
  const AppLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });

  final bool isLoading;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: ColoredBox(
              color: AppColors.overlay,
              child: Center(child: AppLoader()),
            ),
          ),
      ],
    );
  }
}
