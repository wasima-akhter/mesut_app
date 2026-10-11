import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import 'button_enums.dart';

export 'button_enums.dart';

class AppButton extends StatelessWidget {
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

  /// Optional custom foreground/text color.
  final Color? foregroundColor;

  /// Optional custom background color when disabled.
  final Color? disabledBackgroundColor;

  /// Optional custom foreground color when disabled.
  final Color? disabledForegroundColor;

  /// Optional custom border color.
  final Color? borderColor;

  /// Optional border width.
  final double? borderWidth;

  /// Optional custom border radius.
  final double? borderRadius;

  /// Optional custom text style.
  final TextStyle? textStyle;

  /// Optional elevation.
  final double? elevation;

  /// Internal padding. If null, calculated based on [size], [verticalPadding], and [horizontalPadding].
  final EdgeInsetsGeometry? padding;

  /// Controls internal vertical padding.
  final double? verticalPadding;

  /// Controls internal horizontal padding.
  final double? horizontalPadding;

  /// Visual variant of the button.
  final AppButtonVariant variant;

  /// Size tier of the button.
  final AppButtonSize size;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.leading,
    this.leadingIcon,
    this.trailing,
    this.trailingIcon,
    this.isLoading = false,
    this.isEnabled = true,
    this.fullWidth = true,
    this.width,
    this.height,
    this.backgroundColor,
    this.foregroundColor,
    this.disabledBackgroundColor,
    this.disabledForegroundColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.textStyle,
    this.elevation,
    this.padding,
    this.verticalPadding,
    this.horizontalPadding,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
  });

  /// Convenient constructor for small/compact buttons.
  const AppButton.small({
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
    this.disabledBackgroundColor,
    this.disabledForegroundColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.textStyle,
    this.elevation,
    this.padding,
    this.verticalPadding,
    this.horizontalPadding,
    this.variant = AppButtonVariant.primary,
  }) : size = AppButtonSize.small;

  /// Convenient constructor for danger/error buttons.
  const AppButton.danger({
    super.key,
    required this.text,
    this.onPressed,
    this.leading,
    this.leadingIcon,
    this.trailing,
    this.trailingIcon,
    this.isLoading = false,
    this.isEnabled = true,
    this.fullWidth = true,
    this.width,
    this.height,
    this.backgroundColor,
    this.foregroundColor,
    this.disabledBackgroundColor,
    this.disabledForegroundColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.textStyle,
    this.elevation,
    this.padding,
    this.verticalPadding,
    this.horizontalPadding,
    this.size = AppButtonSize.medium,
  }) : variant = AppButtonVariant.danger;

  /// Convenient constructor for success (green) buttons.
  const AppButton.success({
    super.key,
    required this.text,
    this.onPressed,
    this.leading,
    this.leadingIcon,
    this.trailing,
    this.trailingIcon,
    this.isLoading = false,
    this.isEnabled = true,
    this.fullWidth = true,
    this.width,
    this.height,
    this.backgroundColor,
    this.foregroundColor,
    this.disabledBackgroundColor,
    this.disabledForegroundColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.textStyle,
    this.elevation,
    this.padding,
    this.verticalPadding,
    this.horizontalPadding,
    this.size = AppButtonSize.medium,
  }) : variant = AppButtonVariant.success;

  /// Convenient constructor for dark/black buttons.
  const AppButton.dark({
    super.key,
    required this.text,
    this.onPressed,
    this.leading,
    this.leadingIcon,
    this.trailing,
    this.trailingIcon,
    this.isLoading = false,
    this.isEnabled = true,
    this.fullWidth = true,
    this.width,
    this.height,
    this.backgroundColor,
    this.foregroundColor,
    this.disabledBackgroundColor,
    this.disabledForegroundColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.textStyle,
    this.elevation,
    this.padding,
    this.verticalPadding,
    this.horizontalPadding,
    this.size = AppButtonSize.medium,
  }) : variant = AppButtonVariant.dark;

  @override
  Widget build(BuildContext context) {
    final effectiveEnabled = isEnabled && !isLoading && onPressed != null;

    // Resolve variant colors
    Color variantBg;
    Color variantFg;
    switch (variant) {
      case AppButtonVariant.primary:
        variantBg = AppColors.primary;
        variantFg = AppColors.white;
        break;
      case AppButtonVariant.secondary:
        variantBg = AppColors.primary100;
        variantFg = AppColors.primary;
        break;
      case AppButtonVariant.success:
        variantBg = const Color(0xFF12B76A);
        variantFg = AppColors.white;
        break;
      case AppButtonVariant.danger:
        variantBg = AppColors.error;
        variantFg = AppColors.white;
        break;
      case AppButtonVariant.dark:
        variantBg = Colors.black;
        variantFg = AppColors.white;
        break;
      case AppButtonVariant.neutral:
        variantBg = AppColors.neutral200;
        variantFg = AppColors.textPrimary;
        break;
    }

    final effectiveBg = backgroundColor ?? variantBg;
    final effectiveFg = foregroundColor ?? variantFg;

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
        defaultFontSize = 17.sp;
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
          fontWeight: FontWeight.w700,
        );

    final buttonStyle = ElevatedButton.styleFrom(
      padding: effectivePadding,
      backgroundColor: effectiveBg,
      foregroundColor: effectiveFg,
      disabledBackgroundColor:
          disabledBackgroundColor ?? effectiveBg.withValues(alpha: 0.45),
      disabledForegroundColor:
          disabledForegroundColor ?? effectiveFg.withValues(alpha: 0.65),
      elevation: elevation ?? 0,
      minimumSize: Size.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: borderColor != null
            ? BorderSide(color: borderColor!, width: borderWidth ?? 1.0)
            : BorderSide.none,
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
        : _ButtonContent(
            text: text,
            leading: leading,
            leadingIcon: leadingIcon,
            trailing: trailing,
            trailingIcon: trailingIcon,
            textStyle: effectiveTextStyle,
            iconSize: defaultIconSize,
            iconColor: effectiveFg,
          );

    final button = ElevatedButton(
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

class _ButtonContent extends StatelessWidget {
  final String text;
  final Widget? leading;
  final IconData? leadingIcon;
  final Widget? trailing;
  final IconData? trailingIcon;
  final TextStyle textStyle;
  final double iconSize;
  final Color iconColor;

  const _ButtonContent({
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
