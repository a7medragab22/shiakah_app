part of "../../auth/auth.dart";

abstract interface class GenderDataSource {
  Future<Either<Failure, GenderResponseModel>> updateGender({
    required int gender,
  });
}

class GenderDataSourceImpl implements GenderDataSource {
  final GenericDataSource _genericDataSource;
  const GenderDataSourceImpl(this._genericDataSource);

  @override
  Future<Either<Failure, GenderResponseModel>> updateGender({
    required int gender,
  }) {
    final request = GenderRequestModel(gender: gender);
    return _genericDataSource.postData<GenderResponseModel>(
      endpoint: Endpoints.gender,
      data: request.toJson(),
      fromJson: (json) => GenderResponseModel.fromJson(json),
    );
  }
}
