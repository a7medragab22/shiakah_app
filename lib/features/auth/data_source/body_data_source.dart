part of "../../auth/auth.dart";

abstract interface class BodyDataSource {
  Future<Either<Failure, BodyResponseModel>> updateBody({
    required double height,
    required double weight,
    required int bodyType,
  });
}

class BodyDataSourceImpl implements BodyDataSource {
  final GenericDataSource _genericDataSource;
  const BodyDataSourceImpl(this._genericDataSource);

  @override
  Future<Either<Failure, BodyResponseModel>> updateBody({
    required double height,
    required double weight,
    required int bodyType,
  }) {
    final request = BodyRequestModel(
      height: height,
      weight: weight,
      bodyType: bodyType,
    );
    return _genericDataSource.postData<BodyResponseModel>(
      endpoint: Endpoints.body,
      data: request.toJson(),
      fromJson: (json) => BodyResponseModel.fromJson(json),
    );
  }
}
