import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';

class AppTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  /// Optional widget displayed before the text.
  final Widget? leading;

  /// Optional icon displayed before the text.
  final IconData? leadingIcon;

  /// Optional widget displayed after the text.
  final Widget? trailing;

  /// Optional icon displayed after the text.
  final IconData? trailingIcon;

  /// Shows a loading indicator instead of the button content.
  final bool isLoading;

  /// Whether the button is enabled.
  final bool isEnabled;

  /// Text and icon color. Defaults to [AppColors.primary].
  final Color? foregroundColor;

  /// Custom text style.
  final TextStyle? textStyle;

  /// Custom padding.
  final EdgeInsetsGeometry? padding;

  const AppTextButton({
    super.key,
    required this.text,
    this.onPressed,
    this.leading,
    this.leadingIcon,
    this.trailing,
    this.trailingIcon,
    this.isLoading = false,
    this.isEnabled = true,
    this.foregroundColor,
    this.textStyle,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveEnabled = isEnabled && !isLoading && onPressed != null;
    final color = foregroundColor ?? AppColors.primary;

    final leadingWidget = leading ??
        (leadingIcon != null ? Icon(leadingIcon, size: 18.sp, color: color) : null);
    final trailingWidget = trailing ??
        (trailingIcon != null ? Icon(trailingIcon, size: 18.sp, color: color) : null);

    final style = textStyle ??
        TextStyle(
          fontSize: 16.5.sp,
          color: color,
          fontWeight: FontWeight.w600,
        );

    return TextButton(
      onPressed: effectiveEnabled ? onPressed : null,
      style: TextButton.styleFrom(
        foregroundColor: color,
        padding: padding ?? EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: isLoading
          ? SizedBox(
              width: 16.sp,
              height: 16.sp,
              child: CircularProgressIndicator(strokeWidth: 2.w, color: color),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (leadingWidget != null) ...[
                  leadingWidget,
                  SizedBox(width: 6.w),
                ],
                Text(text, style: style),
                if (trailingWidget != null) ...[
                  SizedBox(width: 6.w),
                  trailingWidget,
                ],
              ],
            ),
    );
  }
}
