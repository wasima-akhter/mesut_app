import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import 'button_enums.dart';

class AppOutlinedButton extends StatelessWidget {
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

  /// Whether the button is enabled. If false, [onPressed] is ignored.
  final bool isEnabled;

  /// Whether the button should take the available width. Defaults to true.
  final bool fullWidth;

  /// Optional custom width.
  final double? width;

  /// Deprecated: Buttons use vertical and horizontal padding to adapt to content.
  @Deprecated('Use padding or size instead to avoid fixed heights.')
  final double? height;

  /// Optional custom background color.
  final Color? backgroundColor;

  /// Optional custom text/icon color. Defaults to [AppColors.primary].
  final Color? foregroundColor;

  /// Optional custom border color. Defaults to [foregroundColor] or [AppColors.primary].
  final Color? borderColor;

  /// Optional border width.
  final double? borderWidth;

  /// Optional custom border radius.
  final double? borderRadius;

  /// Optional custom text style.
  final TextStyle? textStyle;

  /// Internal padding. If null, calculated based on [size], [verticalPadding], and [horizontalPadding].
  final EdgeInsetsGeometry? padding;

  /// Controls internal vertical padding.
  final double? verticalPadding;

  /// Controls internal horizontal padding.
  final double? horizontalPadding;

  /// Size tier of the button.
  final AppButtonSize size;

  const AppOutlinedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.leading,
    this.leadingIcon,
    this.trailing,
    this.trailingIcon,
    this.isLoading = false,
    this.isEnabled = true,
    this.fullWidth = false,
    this.width,
    this.height,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.textStyle,
    this.padding,
    this.verticalPadding,
    this.horizontalPadding,
    this.size = AppButtonSize.medium,
  });

  /// Convenient constructor for small/compact outlined buttons.
  const AppOutlinedButton.small({
    super.key,
    required this.text,
    this.onPressed,
    this.leading,
    this.leadingIcon,
    this.trailing,
    this.trailingIcon,
    this.isLoading = false,
    this.isEnabled = true,
    this.fullWidth = false,
    this.width,
    this.height,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.textStyle,
    this.padding,
    this.verticalPadding,
    this.horizontalPadding,
  }) : size = AppButtonSize.small;

  @override
  Widget build(BuildContext context) {
    final effectiveEnabled = isEnabled && !isLoading && onPressed != null;

    final effectiveFg = foregroundColor ?? AppColors.primary;
    final effectiveBorderColor = borderColor ?? effectiveFg;

    // Sizing: padding, font size, and icon size
    double defaultVPad;
    double defaultHPad;
    double defaultFontSize;
    double defaultIconSize;

    switch (size) {
      case AppButtonSize.small:
        defaultVPad = 7.h;
        defaultHPad = 12.w;
        defaultFontSize = 15.sp;
        defaultIconSize = 16.sp;
        break;
      case AppButtonSize.medium:
        defaultVPad = 12.h;
        defaultHPad = 16.w;
        defaultFontSize = 16.5.sp;
        defaultIconSize = 18.sp;
        break;
      case AppButtonSize.large:
        defaultVPad = 15.h;
        defaultHPad = 20.w;
        defaultFontSize = 18.sp;
        defaultIconSize = 20.sp;
        break;
    }

    final effectivePadding =
        padding ??
        EdgeInsets.symmetric(
          vertical: (verticalPadding ?? defaultVPad),
          horizontal: (horizontalPadding ?? defaultHPad),
        );

    final radius = borderRadius ?? 8.r;

    final effectiveTextStyle =
        textStyle ??
        TextStyle(
          fontSize: defaultFontSize,
          color: effectiveFg,
          fontWeight: FontWeight.w600,
        );

    final buttonStyle = OutlinedButton.styleFrom(
      padding: effectivePadding,
      backgroundColor: backgroundColor ?? Colors.transparent,
      foregroundColor: effectiveFg,
      disabledForegroundColor: effectiveFg.withValues(alpha: 0.45),
      elevation: 0,
      minimumSize: Size.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      side: BorderSide(
        color: effectiveEnabled
            ? effectiveBorderColor
            : effectiveBorderColor.withValues(alpha: 0.35),
        width: borderWidth ?? 1.0,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
    );

    final buttonChild = isLoading
        ? SizedBox(
            width: defaultIconSize,
            height: defaultIconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2.w,
              color: effectiveFg,
            ),
          )
        : _OutlinedButtonContent(
            text: text,
            leading: leading,
            leadingIcon: leadingIcon,
            trailing: trailing,
            trailingIcon: trailingIcon,
            textStyle: effectiveTextStyle,
            iconSize: defaultIconSize,
            iconColor: effectiveFg,
          );

    final button = OutlinedButton(
      onPressed: effectiveEnabled ? onPressed : null,
      style: buttonStyle,
      child: buttonChild,
    );

    if (fullWidth) {
      return SizedBox(width: width ?? double.infinity, child: button);
    }

    if (width != null) {
      return SizedBox(width: width, child: button);
    }

    return button;
  }
}

class _OutlinedButtonContent extends StatelessWidget {
  final String text;
  final Widget? leading;
  final IconData? leadingIcon;
  final Widget? trailing;
  final IconData? trailingIcon;
  final TextStyle textStyle;
  final double iconSize;
  final Color iconColor;

  const _OutlinedButtonContent({
    required this.text,
    required this.leading,
    required this.leadingIcon,
    required this.trailing,
    required this.trailingIcon,
    required this.textStyle,
    required this.iconSize,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final leadingWidget =
        leading ??
        (leadingIcon != null
            ? Icon(leadingIcon, size: iconSize, color: iconColor)
            : null);

    final trailingWidget =
        trailing ??
        (trailingIcon != null
            ? Icon(trailingIcon, size: iconSize, color: iconColor)
            : null);

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leadingWidget != null) ...[leadingWidget, SizedBox(width: 8.w)],
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textStyle,
            textAlign: TextAlign.center,
          ),
        ),
        if (trailingWidget != null) ...[SizedBox(width: 8.w), trailingWidget],
      ],
    );
  }
}
