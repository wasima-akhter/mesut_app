import 'dart:io';

import 'package:image_picker/image_picker.dart';

/// Battery- and bandwidth-conscious image picker compressing photos before upload.
abstract final class AppImageService {
  static final ImagePicker _picker = ImagePicker();

  static Future<File?> pickCompressedImage({
    ImageSource source = ImageSource.gallery,
    double maxWidth = 1600,
    double maxHeight = 1600,
    int imageQuality = 80,
  }) async {
    final xFile = await _picker.pickImage(
      source: source,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
    );
    if (xFile == null) return null;
    return File(xFile.path);
  }

  static Future<List<File>> pickMultipleCompressedImages({
    double maxWidth = 1600,
    double maxHeight = 1600,
    int imageQuality = 80,
    int? limit = 10,
  }) async {
    final files = await _picker.pickMultiImage(
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
      limit: limit,
    );
    return files.map((x) => File(x.path)).toList();
  }
}
