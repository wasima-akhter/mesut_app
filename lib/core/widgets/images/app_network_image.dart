import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../helpers/image_helper.dart';

/// Production-grade cached network image widget with local disk caching,
/// local File support, and graceful fallback icons when offline or unavailable.
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

  /// Returns a disk-cached [ImageProvider] for use with [CircleAvatar] or [DecorationImage].
  static ImageProvider? provider(String? url, {String? baseUrl}) {
    if (url == null || url.trim().isEmpty) return null;
    final isNetwork = url.startsWith('http://') || url.startsWith('https://');
    if (!isNetwork && !url.startsWith('assets/')) {
      final file = File(url);
      if (file.existsSync()) return FileImage(file);
    }
    final resolved = ImageHelper.resolveNetworkUrl(value: url, baseUrl: baseUrl);
    if (resolved != null) {
      return CachedNetworkImageProvider(resolved);
    }
    return null;
  }

  int? _cacheDimension(double? logicalSize, double devicePixelRatio) {
    if (logicalSize == null || !logicalSize.isFinite || logicalSize <= 0) {
      return null;
    }
    return (logicalSize * devicePixelRatio).round().clamp(1, 2048);
  }

  @override
  Widget build(BuildContext context) {
    final raw = imageUrl?.trim();
    if (raw == null || raw.isEmpty) {
      return _buildContainer(child: _fallback());
    }

    // Check if it's a local file path (avoid disk syscalls on network URLs)
    final isNetworkUrl =
        raw.startsWith('http://') || raw.startsWith('https://');
    if (!isNetworkUrl && !raw.startsWith('assets/')) {
      final file = File(raw);
      if (file.existsSync()) {
        return _buildContainer(
          child: Image.file(
            file,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (_, _, _) => _fallback(),
          ),
        );
      }
    }

    final resolvedUrl = ImageHelper.resolveNetworkUrl(
      value: raw,
      baseUrl: baseUrl,
    );

    if (resolvedUrl == null) {
      return _buildContainer(child: _fallback());
    }

    final dpr = MediaQuery.devicePixelRatioOf(context);
    final cacheW = _cacheDimension(width, dpr);
    final cacheH = _cacheDimension(height, dpr);

    return _buildContainer(
      child: CachedNetworkImage(
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
      ),
    );
  }

  Widget _buildContainer({required Widget child}) {
    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: SizedBox(width: width, height: height, child: child),
      );
    }
    return SizedBox(width: width, height: height, child: child);
  }

  Widget _fallback() {
    return fallback ??
        errorWidget ??
        Container(
          width: width,
          height: height,
          color: AppColors.neutral100,
          alignment: Alignment.center,
          child: const Icon(
            Icons.image_outlined,
            color: AppColors.neutral400,
            size: 24,
          ),
        );
  }

  Widget _defaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: AppColors.neutral100,
      alignment: Alignment.center,
      child: SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.primary.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}
