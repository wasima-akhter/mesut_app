import 'package:construction_app/core/enums/string_extensions.dart';
import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_text_styles.dart';
import 'app_network_image.dart';

class AppAvatar extends StatelessWidget {
  const AppAvatar({super.key, this.imageUrl, this.name, this.size, this.onTap});

  final String? imageUrl;
  final String? name;
  final double? size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final avatarSize = size ?? AppDimensions.avatarMedium;

    final child = imageUrl != null && imageUrl!.trim().isNotEmpty
        ? ClipOval(
            child: AppNetworkImage(
              imageUrl: imageUrl,
              width: avatarSize,
              height: avatarSize,
              fit: BoxFit.cover,
            ),
          )
        : Container(
            width: avatarSize,
            height: avatarSize,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary100,
            ),
            child: Text(
              name.initials,
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.primary700,
              ),
            ),
          );

    if (onTap == null) {
      return child;
    }

    return GestureDetector(onTap: onTap, child: child);
  }
}
