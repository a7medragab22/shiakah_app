import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

import '../../../../core/helpers/helpers.dart';
import '../../../../core/http/http.dart';
import '../models/add_to_closet_response_model.dart';
import '../models/my_closet_response_model.dart';

abstract interface class WardrobeRemoteDataSource {
  Future<Either<Failure, AddToClosetResponseModel>> addToMyCloset({
    required String imagePath,
  });

  Future<Either<Failure, MyClosetResponseModel>> getMyCloset();
}

class WardrobeRemoteDataSourceImpl implements WardrobeRemoteDataSource {
  final GenericDataSource _genericDataSource;

  const WardrobeRemoteDataSourceImpl(this._genericDataSource);

  @override
  Future<Either<Failure, AddToClosetResponseModel>> addToMyCloset({
    required String imagePath,
  }) async {
    try {
      MultipartFile multipartFile;
      final file = File(imagePath);

      if (await file.exists()) {
        final rawFileName =
            file.path.split(Platform.pathSeparator).last.split('/').last;
        final fileName =
            rawFileName.contains('.') ? rawFileName : '$rawFileName.jpg';
        multipartFile = await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        );
      } else if (imagePath.startsWith('assets/')) {
        final byteData = await rootBundle.load(imagePath);
        final bytes = byteData.buffer.asUint8List(
          byteData.offsetInBytes,
          byteData.lengthInBytes,
        );
        final rawFileName = imagePath.split('/').last;
        final fileName =
            rawFileName.contains('.') ? rawFileName : '$rawFileName.jpg';
        multipartFile = MultipartFile.fromBytes(
          bytes,
          filename: fileName,
        );
      } else {
        final rawFileName =
            imagePath.split(Platform.pathSeparator).last.split('/').last;
        final fileName =
            rawFileName.contains('.') ? rawFileName : '$rawFileName.jpg';
        multipartFile = await MultipartFile.fromFile(
          imagePath,
          filename: fileName,
        );
      }

      final formData = FormData.fromMap({
        'Image': multipartFile,
      });

      return await _genericDataSource.postData<AddToClosetResponseModel>(
        endpoint: Endpoints.addToMyCloset,
        formData: formData,
        fromJson: (json) => AddToClosetResponseModel.fromJson(json),
      );
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, MyClosetResponseModel>> getMyCloset() async {
    try {
      return await _genericDataSource.getData<MyClosetResponseModel>(
        endpoint: Endpoints.myCloset,
        fromJson: (json) => MyClosetResponseModel.fromJson(json),
      );
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
