part of "../../auth/auth.dart";

abstract interface class AppearanceDataSource {
  Future<Either<Failure, AppearanceResponseModel>> updateAppearance({
    required int ageRange,
    required int skinTone,
  });
}

class AppearanceDataSourceImpl implements AppearanceDataSource {
  final GenericDataSource _genericDataSource;
  const AppearanceDataSourceImpl(this._genericDataSource);

  @override
  Future<Either<Failure, AppearanceResponseModel>> updateAppearance({
    required int ageRange,
    required int skinTone,
  }) {
    final request = AppearanceRequestModel(
      ageRange: ageRange,
      skinTone: skinTone,
    );
    return _genericDataSource.postData<AppearanceResponseModel>(
      endpoint: Endpoints.appearance,
      data: request.toJson(),
      fromJson: (json) => AppearanceResponseModel.fromJson(json),
    );
  }
}
