import 'dart:io';

abstract class MediaRepository {
  Future<List<String>> uploadMedia({
    required List<File> files,
    void Function(int sent, int total)? onProgress,
  });

  Future<void> deleteMedia({required List<String> urls});
}
