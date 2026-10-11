import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';

class AppBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final double? size;
  final double? iconSize;
  final IconData icon;
  final bool isCircle;

  const AppBackButton({
    super.key,
    this.onPressed,
    this.backgroundColor = Colors.white,
    this.foregroundColor,
    this.borderColor,
    this.size,
    this.iconSize,
    this.icon = Icons.arrow_back_rounded,
    this.isCircle = true,
  });

  @override
  Widget build(BuildContext context) {
    final dimension = size ?? 40.r;
    final effectiveIconSize = iconSize ?? 20.r;
    final fg = foregroundColor ?? AppColors.textPrimary;
    final bg = backgroundColor ?? Colors.white;
    final border = Border.all(color: borderColor ?? AppColors.border);

    return SizedBox(
      width: dimension,
      height: dimension,
      child: Material(
        color: bg,
        shape: isCircle
            ? const CircleBorder()
            : RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        child: InkWell(
          onTap: onPressed ?? () {
            if (Navigator.of(context).canPop()) {
              context.pop();
            }
          },
          customBorder: isCircle
              ? const CircleBorder()
              : RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
          child: Container(
            decoration: BoxDecoration(
              shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
              borderRadius: isCircle ? null : BorderRadius.circular(8.r),
              border: border,
            ),
            child: Icon(
              icon,
              size: effectiveIconSize,
              color: fg,
            ),
          ),
        ),
      ),
    );
  }
}
