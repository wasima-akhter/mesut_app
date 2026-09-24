import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';

class AppTextButton extends StatelessWidget {
  const AppTextButton({required this.text, required this.onPressed, super.key});

  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(foregroundColor: AppColors.primary),
      child: Text(
        text,
        style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
      ),
    );
  }
}
