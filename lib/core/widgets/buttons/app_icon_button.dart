import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';

class AppIconButton extends StatelessWidget {
  /// The icon to display. Can be either [IconData] or a [Widget].
  final dynamic icon;

  /// Optional [IconData] if [icon] was not provided.
  final IconData? iconData;

  /// Callback when the button is tapped.
  final VoidCallback? onPressed;

  /// Optional tooltip message.
  final String? tooltip;

  /// Button background color.
  final Color? backgroundColor;

  /// Icon / text color.
  final Color? foregroundColor;

  /// Alias for [foregroundColor].
  final Color? iconColor;

  /// Explicit border.
  final BoxBorder? border;

  /// Border color if [border] is not specified.
  final Color? borderColor;

  /// Border width if [borderColor] is specified.
  final double? borderWidth;

  /// Corner radius for non-circular buttons.
  final double? borderRadius;

  /// Whether the button shape is a circle.
  final bool isCircle;

  /// Inner padding.
  final EdgeInsetsGeometry? padding;

  /// Outer dimension (width and height).
  final double? size;

  /// Icon size.
  final double? iconSize;

  /// Shows loading spinner.
  final bool isLoading;

  /// Whether button is enabled.
  final bool isEnabled;

  const AppIconButton({
    super.key,
    this.icon,
    this.iconData,
    required this.onPressed,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.iconColor,
    this.border,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.isCircle = false,
    this.padding,
    this.size,
    this.iconSize,
    this.isLoading = false,
    this.isEnabled = true,
  }) : assert(
          icon != null || iconData != null,
          'Either icon or iconData must be provided',
        );

  /// Circular icon button with border (commonly used for back, action, and filter buttons).
  const AppIconButton.circle({
    super.key,
    this.icon,
    this.iconData,
    required this.onPressed,
    this.tooltip,
    this.backgroundColor = Colors.transparent,
    this.foregroundColor,
    this.iconColor,
    this.border,
    this.borderColor,
    this.borderWidth,
    this.padding,
    this.size,
    this.iconSize,
    this.isLoading = false,
    this.isEnabled = true,
  })  : isCircle = true,
        borderRadius = null,
        assert(
          icon != null || iconData != null,
          'Either icon or iconData must be provided',
        );

  @override
  Widget build(BuildContext context) {
    final effectiveEnabled = isEnabled && !isLoading && onPressed != null;
    final fg = iconColor ?? foregroundColor ?? AppColors.textPrimary;
    final bg = backgroundColor ?? Colors.transparent;
    final dimension = size ?? 40.r;
    final effectiveIconSize = iconSize ?? 20.r;

    final shape = isCircle
        ? const CircleBorder()
        : RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 8.r),
          );

    final effectiveBorder = border ??
        (borderColor != null
            ? Border.all(color: borderColor!, width: borderWidth ?? 1.0)
            : null);

    Widget childWidget;
    if (isLoading) {
      childWidget = SizedBox(
        width: effectiveIconSize * 0.8,
        height: effectiveIconSize * 0.8,
        child: CircularProgressIndicator(strokeWidth: 2.w, color: fg),
      );
    } else if (icon is IconData) {
      childWidget = Icon(icon as IconData, size: effectiveIconSize, color: fg);
    } else if (icon is Widget) {
      childWidget = icon as Widget;
    } else if (iconData != null) {
      childWidget = Icon(iconData, size: effectiveIconSize, color: fg);
    } else {
      childWidget = const SizedBox.shrink();
    }

    Widget content = Material(
      color: bg,
      shape: shape,
      child: InkWell(
        onTap: effectiveEnabled ? onPressed : null,
        customBorder: shape,
        child: Container(
          width: dimension,
          height: dimension,
          alignment: Alignment.center,
          padding: padding,
          decoration: BoxDecoration(
            shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
            borderRadius:
                isCircle ? null : BorderRadius.circular(borderRadius ?? 8.r),
            border: effectiveBorder,
          ),
          child: childWidget,
        ),
      ),
    );

    if (tooltip != null) {
      content = Tooltip(message: tooltip!, child: content);
    }

    return content;
  }
}
