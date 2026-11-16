import 'package:flutter/material.dart';

import '../../../app/theme/app_dimensions.dart';

class AppNetworkImage extends StatelessWidget {
  final String? url;

  final double? width;
  final double? height;

  final BoxFit fit;
  final BorderRadiusGeometry? borderRadius;

  final Widget? placeholder;
  final Widget? errorWidget;

  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  int? _cacheDimension(double? logicalSize, double dpr) {
    if (logicalSize == null || !logicalSize.isFinite || logicalSize <= 0) {
      return null;
    }
    return (logicalSize * dpr).round().clamp(1, 2048);
  }

  @override
  Widget build(BuildContext context) {
    final radius =
        borderRadius ?? BorderRadius.circular(AppDimensions.radiusMd);

    if (url == null || url!.trim().isEmpty) {
      return _buildFallback(radius);
    }

    final dpr = MediaQuery.devicePixelRatioOf(context);

    return ClipRRect(
      borderRadius: radius,
      child: Image.network(
        url!,
        width: width,
        height: height,
        cacheWidth: _cacheDimension(width, dpr),
        cacheHeight: _cacheDimension(height, dpr),
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return placeholder ?? _buildPlaceholder();
        },
        errorBuilder: (_, _, _) {
          return errorWidget ?? _buildError();
        },
      ),
    );
  }

  Widget _buildFallback(BorderRadiusGeometry radius) {
    return ClipRRect(borderRadius: radius, child: errorWidget ?? _buildError());
  }

  Widget _buildPlaceholder() {
    return SizedBox(
      width: width,
      height: height,
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildError() {
    return SizedBox(
      width: width,
      height: height,
      child: const Center(child: Icon(Icons.image_not_supported_outlined)),
    );
  }
}
