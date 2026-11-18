import 'package:construction_app/core/enums/string_extensions.dart';
import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_text_styles.dart';
import 'app_network_image.dart';

class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size,
    this.onTap,
    this.fallbackIcon = Icons.person,
    this.backgroundColor,
  });

  final String? imageUrl;
  final String? name;
  final double? size;
  final VoidCallback? onTap;
  final IconData fallbackIcon;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final avatarSize = size ?? AppDimensions.avatarMedium;

    Widget fallbackContent() {
      if (name != null && name!.trim().isNotEmpty) {
        return Text(
          name.initials,
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.primary700,
            fontSize: (avatarSize * 0.4).clamp(11.0, 22.0),
            fontWeight: FontWeight.w700,
          ),
        );
      }
      return Icon(
        fallbackIcon,
        size: avatarSize * 0.52,
        color: AppColors.textSecondary,
      );
    }

    final fallbackWidget = Container(
      width: avatarSize,
      height: avatarSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor ?? AppColors.primary100,
      ),
      child: fallbackContent(),
    );

    final child = imageUrl != null && imageUrl!.trim().isNotEmpty
        ? ClipOval(
            child: AppNetworkImage(
              imageUrl: imageUrl,
              width: avatarSize,
              height: avatarSize,
              fit: BoxFit.cover,
              fallback: fallbackWidget,
              errorWidget: fallbackWidget,
            ),
          )
        : fallbackWidget;

    if (onTap == null) {
      return child;
    }

    return GestureDetector(onTap: onTap, child: child);
  }
}
