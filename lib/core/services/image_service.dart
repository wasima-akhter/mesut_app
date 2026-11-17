import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

/// Battery- and bandwidth-conscious image picker supporting device storage and camera.
abstract final class AppImageService {
  static final ImagePicker _picker = ImagePicker();

  /// Picks a single image.
  /// If [source] is [ImageSource.camera], it uses the camera.
  /// If [source] is [ImageSource.gallery], it uses device storage file picker
  /// so users can browse device storage and folders properly.
  static Future<File?> pickCompressedImage({
    ImageSource source = ImageSource.gallery,
    double maxWidth = 1600,
    double maxHeight = 1600,
    int imageQuality = 80,
  }) async {
    if (source == ImageSource.camera) {
      final xFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );
      if (xFile == null) return null;
      return File(xFile.path);
    }

    return pickImageFromDeviceStorage();
  }

  /// Picks a single image from device storage using the system file picker.
  static Future<File?> pickImageFromDeviceStorage() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'heic'],
      );
      if (result.isEmpty) return null;
      final path = result.first.path;
      if (path == null) return null;
      return File(path);
    } catch (_) {
      final xFile = await _picker.pickImage(source: ImageSource.gallery);
      if (xFile == null) return null;
      return File(xFile.path);
    }
  }

  /// Picks multiple images from device storage using the system file picker.
  static Future<List<File>> pickMultipleCompressedImages({
    double maxWidth = 1600,
    double maxHeight = 1600,
    int imageQuality = 80,
    int? limit = 10,
  }) async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'heic'],
      );
      if (result.isEmpty) return [];
      final files = result.whereType<String>().map((p) => File(p)).toList();
      if (limit != null && files.length > limit) {
        return files.take(limit).toList();
      }
      return files;
    } catch (_) {
      final xFiles = await _picker.pickMultiImage(
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
        limit: limit,
      );
      return xFiles.map((x) => File(x.path)).toList();
    }
  }
}
