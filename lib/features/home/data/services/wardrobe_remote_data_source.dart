import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

import '../../../../core/helpers/helpers.dart';
import '../../../../core/http/http.dart';
import '../models/add_to_closet_response_model.dart';
import '../models/my_closet_response_model.dart';
import '../models/remove_item_response_model.dart';

abstract interface class WardrobeRemoteDataSource {
  Future<Either<Failure, AddToClosetResponseModel>> addToMyCloset({
    required String imagePath,
    String? category,
    String? subcategory,
    String? color,
    String? fit,
    String? style,
    String? season,
    String? pattern,
    bool addToMyCloset = true,
  });

  Future<Either<Failure, MyClosetResponseModel>> getMyCloset();

  Future<Either<Failure, RemoveItemResponseModel>> removeWardrobeItem({
    required int itemId,
  });
}

class WardrobeRemoteDataSourceImpl implements WardrobeRemoteDataSource {
  final GenericDataSource _genericDataSource;

  const WardrobeRemoteDataSourceImpl(this._genericDataSource);

  @override
  Future<Either<Failure, AddToClosetResponseModel>> addToMyCloset({
    required String imagePath,
    String? category,
    String? subcategory,
    String? color,
    String? fit,
    String? style,
    String? season,
    String? pattern,
    bool addToMyCloset = true,
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

      final mapData = <String, dynamic>{
        'Image': multipartFile,
        'AddToMyCloset': addToMyCloset ? 'true' : 'false',
      };
      final attributesMap = <String, dynamic>{};
      if (category != null && category.isNotEmpty) {
        mapData['Attributes.Category'] = category;
        mapData['Category'] = category;
        attributesMap['category'] = category;
      }
      if (subcategory != null && subcategory.isNotEmpty) {
        mapData['Attributes.Subcategory'] = subcategory;
        mapData['Subcategory'] = subcategory;
        attributesMap['subcategory'] = subcategory;
      }
      if (color != null && color.isNotEmpty) {
        mapData['Attributes.Color'] = color;
        mapData['Color'] = color;
        attributesMap['color'] = color;
      }
      if (fit != null && fit.isNotEmpty) {
        mapData['Attributes.Fit'] = fit;
        mapData['Fit'] = fit;
        attributesMap['fit'] = fit;
      }
      if (style != null && style.isNotEmpty) {
        mapData['Attributes.Style'] = style;
        mapData['Style'] = style;
        attributesMap['style'] = style;
      }
      if (season != null && season.isNotEmpty) {
        mapData['Attributes.Season'] = season;
        mapData['Season'] = season;
        attributesMap['season'] = season;
      }
      if (pattern != null && pattern.isNotEmpty) {
        mapData['Attributes.Pattern'] = pattern;
        mapData['Pattern'] = pattern;
        attributesMap['pattern'] = pattern;
      }
      if (attributesMap.isNotEmpty) {
        mapData['Attributes'] = jsonEncode(attributesMap);
      }

      final formData = FormData.fromMap(mapData);

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

  @override
  Future<Either<Failure, RemoveItemResponseModel>> removeWardrobeItem({
    required int itemId,
  }) async {
    try {
      return await _genericDataSource.deleteData<RemoveItemResponseModel>(
        endpoint: Endpoints.removeWardrobeItem(itemId),
        fromJson: (json) => RemoveItemResponseModel.fromJson(json),
      );
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
