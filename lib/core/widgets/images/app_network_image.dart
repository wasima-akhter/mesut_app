import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radii.dart';
import '../../helpers/image_helper.dart';

class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    required this.imageUrl,
    super.key,
    this.baseUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.fallback,
    this.errorWidget,
    this.placeholder,
  });

  final String? imageUrl;
  final String? baseUrl;

  final double? width;
  final double? height;

  final BoxFit fit;
  final BorderRadius? borderRadius;

  final Widget? fallback;
  final Widget? errorWidget;
  final Widget? placeholder;

  int? _cacheDimension(double? logicalSize, double devicePixelRatio) {
    if (logicalSize == null || !logicalSize.isFinite || logicalSize <= 0) {
      return null;
    }
    return (logicalSize * devicePixelRatio).round().clamp(1, 2048);
  }

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = ImageHelper.resolveNetworkUrl(
      value: imageUrl,
      baseUrl: baseUrl,
    );
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final cacheW = _cacheDimension(width, dpr);
    final cacheH = _cacheDimension(height, dpr);

    final child = resolvedUrl == null
        ? _fallback()
        : CachedNetworkImage(
            imageUrl: resolvedUrl,
            width: width,
            height: height,
            memCacheWidth: cacheW,
            memCacheHeight: cacheH,
            maxWidthDiskCache: 1200,
            maxHeightDiskCache: 1200,
            fit: fit,
            placeholder: (_, _) => placeholder ?? _defaultPlaceholder(),
            errorWidget: (_, _, _) => errorWidget ?? _fallback(),
          );

    return ClipRRect(
      borderRadius: borderRadius ?? AppRadii.medium,
      child: SizedBox(width: width, height: height, child: child),
    );
  }

  Widget _fallback() {
    return fallback ??
        Container(
          width: width,
          height: height,
          color: AppColors.neutral100,
          alignment: Alignment.center,
          child: const Icon(Icons.image_outlined, color: AppColors.neutral400),
        );
  }

  Widget _defaultPlaceholder() {
    return Container(width: width, height: height, color: AppColors.neutral100);
  }
}
