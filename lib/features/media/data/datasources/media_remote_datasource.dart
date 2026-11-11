import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../dtos/media_dtos.dart';

abstract class MediaRemoteDataSource {
  Future<MediaUploadResponseDto> uploadMedia({
    required List<File> files,
    void Function(int sent, int total)? onProgress,
  });

  Future<void> deleteMedia({required List<String> urls});
}

class MediaRemoteDataSourceImpl implements MediaRemoteDataSource {
  MediaRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<MediaUploadResponseDto> uploadMedia({
    required List<File> files,
    void Function(int sent, int total)? onProgress,
  }) async {
    final formData = FormData();

    for (final file in files) {
      final fileName = file.path.split(Platform.pathSeparator).last;
      formData.files.add(
        MapEntry(
          'files',
          await MultipartFile.fromFile(file.path, filename: fileName),
        ),
      );
    }

    final response = await _apiClient.dio.post(
      ApiConstants.media,
      data: formData,
      onSendProgress: onProgress,
      options: Options(headers: {'Content-Type': 'multipart/form-data'}),
    );

    final rawData = response.data;
    if (rawData is Map<String, dynamic>) {
      return MediaUploadResponseDto.fromJson(rawData);
    }
    throw ApiException(
      message: 'Unexpected response from media upload',
      statusCode: response.statusCode ?? 400,
    );
  }

  @override
  Future<void> deleteMedia({required List<String> urls}) async {
    await _apiClient.delete(ApiConstants.media, data: {'urls': urls});
  }
}
