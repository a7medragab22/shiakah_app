part of "../../auth/auth.dart";

abstract interface class VerifyOTPDataSource {
  Future<Either<Failure, VerifyOtpResponseModel>> verifyOtp({
    required String email,
    required String otp,
  });
  Future<Either<Failure, RegisterResponseModel>> resendOtp({
    required String email,
  });
}

class VerifyOTPDataSourceImpl implements VerifyOTPDataSource {
  final GenericDataSource _genericDataSource;
  const VerifyOTPDataSourceImpl(this._genericDataSource);

  @override
  Future<Either<Failure, VerifyOtpResponseModel>> verifyOtp({
    required String email,
    required String otp,
  }) {
    final request = VerifyOtpRequestModel(email: email, otp: otp);
    return _genericDataSource.postData<VerifyOtpResponseModel>(
      endpoint: Endpoints.verifyRegistrationOtp,
      data: request.toJson(),
      fromJson: (json) => VerifyOtpResponseModel.fromJson(json),
    );
  }

  @override
  Future<Either<Failure, RegisterResponseModel>> resendOtp({
    required String email,
  }) {
    final request = RegisterRequestModel(
      email: email,
      password: '',
    );
    return _genericDataSource.postData<RegisterResponseModel>(
      endpoint: Endpoints.register,
      formData: request.toFormData(),
      fromJson: (json) => RegisterResponseModel.fromJson(json),
    );
  }
}