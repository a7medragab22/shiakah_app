part of "../../auth/auth.dart";

abstract interface class RegisterDataSource {
  Future<Either<Failure, RegisterResponseModel>> register({
    required String email,
    String? userName,
    required String password,
  });
}

class RegisterDataSourceImpl implements RegisterDataSource {
  final GenericDataSource _genericDataSource;
  const RegisterDataSourceImpl(this._genericDataSource);

  @override
  Future<Either<Failure, RegisterResponseModel>> register({
    required String email,
    String? userName,
    required String password,
  }) {
    final request = RegisterRequestModel(
      email: email,
      userName: userName,
      password: password,
    );
    return _genericDataSource.postData<RegisterResponseModel>(
      endpoint: Endpoints.register,
      formData: request.toFormData(),
      fromJson: (json) => RegisterResponseModel.fromJson(json),
    );
  }
}

