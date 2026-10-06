part of "../../auth/auth.dart";

abstract interface class OnboardingStatusDataSource {
  Future<Either<Failure, OnboardingStatusResponseModel>> getStatus();
  Future<String> resolveTargetRouteAndSync();
}

class OnboardingStatusDataSourceImpl implements OnboardingStatusDataSource {
  final GenericDataSource _genericDataSource;
  const OnboardingStatusDataSourceImpl(this._genericDataSource);

  @override
  Future<Either<Failure, OnboardingStatusResponseModel>> getStatus() {
    return _genericDataSource.getData<OnboardingStatusResponseModel>(
      endpoint: Endpoints.onboardingStatus,
      fromJson: (json) => OnboardingStatusResponseModel.fromJson(json),
    );
  }

  @override
  Future<String> resolveTargetRouteAndSync() async {
    final token = HiveServiceImpl.instance.getAccessToken();
    if (token == null || token.isEmpty) {
      return Routes.welcome;
    }

    final result = await getStatus();
    return await result.fold(
      (failure) async {
        if (failure is UnauthorizedFailure || failure is AuthFailure) {
          await HiveServiceImpl.instance.clearAccessToken();
          await HiveServiceImpl.instance.clearRefreshToken();
          return Routes.welcome;
        }
        return Routes.home;
      },
      (response) async {
        final profile = response.data?.profile;
        if (profile != null) {
          try {
            final name = profile.name?.trim();
            if (name != null && name.isNotEmpty) {
              final cached = HiveServiceImpl.instance.getCachedUserModel();
              if (cached != null) {
                await HiveServiceImpl.instance.updateCachedUserModel(
                  cached.copyWith(name: name),
                );
              } else {
                await HiveServiceImpl.instance.cacheUserModel(
                  UserModel(id: 1, name: name, email: '', phone: ''),
                );
              }
            }

            final location = profile.location?.trim();
            if (location != null && location.isNotEmpty) {
              await HiveServiceImpl.put('settings_box', 'user_location', location);
            }
          } catch (_) {}
        }

        return response.data?.targetRoute ?? Routes.home;
      },
    );
  }
}
