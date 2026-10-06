import '../../../../core/helpers/helpers.dart';
import '../../../../core/http/http.dart';
import '../models/my_looks_response_model.dart';

abstract interface class OutfitRemoteDataSource {
  Future<Either<Failure, MyLooksResponseModel>> getMyLooks();
}

class OutfitRemoteDataSourceImpl implements OutfitRemoteDataSource {
  final GenericDataSource _genericDataSource;

  const OutfitRemoteDataSourceImpl(this._genericDataSource);

  @override
  Future<Either<Failure, MyLooksResponseModel>> getMyLooks() async {
    try {
      return await _genericDataSource.getData<MyLooksResponseModel>(
        endpoint: Endpoints.myLooks,
        fromJson: (json) => MyLooksResponseModel.fromJson(json),
      );
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
