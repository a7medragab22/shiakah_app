part of "../../auth/auth.dart";
abstract interface class LogoutDataSource {
  Future<Either<Failure, void>> logout({required String refreshToken});
}

class LogoutDataSourceImpl implements LogoutDataSource {
  final GenericDataSource _genericDataSource;
  const LogoutDataSourceImpl(this._genericDataSource);

  @override
  Future<Either<Failure, void>> logout({required String refreshToken}) {
    return _genericDataSource.postData(
      endpoint: Endpoints.logout,
      data: {'refreshToken': refreshToken},
    );
  }
}
