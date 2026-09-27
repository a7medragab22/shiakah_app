part of "../../auth/auth.dart";

abstract interface class OnboardingProfileDataSource {
  Future<Either<Failure, OnboardingProfileResponseModel>> updateProfile({
    required String name,
    required String location,
  });
}

class OnboardingProfileDataSourceImpl implements OnboardingProfileDataSource {
  final GenericDataSource _genericDataSource;
  const OnboardingProfileDataSourceImpl(this._genericDataSource);

  @override
  Future<Either<Failure, OnboardingProfileResponseModel>> updateProfile({
    required String name,
    required String location,
  }) {
    final request = OnboardingProfileRequestModel(
      name: name,
      location: location,
    );
    return _genericDataSource.postData<OnboardingProfileResponseModel>(
      endpoint: Endpoints.onboardingProfile,
      data: request.toJson(),
      fromJson: (json) => OnboardingProfileResponseModel.fromJson(json),
    );
  }
}
