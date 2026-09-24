import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_text_styles.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    required this.text,
    required this.onPressed,
    super.key,
    this.isLoading = false,
    this.isEnabled = true,
    this.leading,
    this.trailing,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
    this.height,
    this.borderRadius,
  });

  final String text;
  final VoidCallback? onPressed;

  final bool isLoading;
  final bool isEnabled;

  final Widget? leading;
  final Widget? trailing;

  final Color? backgroundColor;
  final Color? foregroundColor;

  final double? width;
  final double? height;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final enabled = isEnabled && !isLoading;

    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? AppDimensions.buttonHeight,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
          foregroundColor: foregroundColor ?? AppColors.textOnPrimary,
          disabledBackgroundColor: AppColors.neutral200,
          disabledForegroundColor: AppColors.textDisabled,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? AppRadii.lg),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20.r,
                height: 20.r,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (leading != null) ...[leading!, SizedBox(width: 8.w)],
                  Flexible(
                    child: Text(
                      text,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.button.copyWith(
                        color: foregroundColor ?? AppColors.textOnPrimary,
                      ),
                    ),
                  ),
                  if (trailing != null) ...[SizedBox(width: 8.w), trailing!],
                ],
              ),
      ),
    );
  }
}
