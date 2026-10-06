part of "../../auth/auth.dart";
abstract interface class LoginDataSource {
  Future<Either<Failure, LoginResponseModel>> login({
    required String email,
    required String password,
  });
}

class LoginDataSourceImpl implements LoginDataSource {
  final GenericDataSource _genericDataSource;
  const LoginDataSourceImpl(this._genericDataSource);

  @override
  Future<Either<Failure, LoginResponseModel>> login({
    required String email,
    required String password,
  }) {
    return _genericDataSource.postData<LoginResponseModel>(
      endpoint: Endpoints.login,
      data: LoginRequestModel(
        email: email,
        password: password,
      ).toJson(),
      fromJson: (json) => LoginResponseModel.fromJson(json),
    );
  }
}
