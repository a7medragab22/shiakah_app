part of '../service_locator.dart';
final GetIt getIt = GetIt.instance;
abstract interface class DI {
  static void executeSync() {
    if (!getIt.isRegistered<HiveServiceImpl>()) {
      HiveServiceLocator.execute(getIt: getIt);
    }
    if (!getIt.isRegistered<GenericDataSource>()) {
      SharedServiceLocator.execute(getIt: getIt);
    }
    if (!getIt.isRegistered<LoginBloc>() ||
        !getIt.isRegistered<RegisterBloc>() ||
        !getIt.isRegistered<VerifyOTPBloc>() ||
        !getIt.isRegistered<GenderBloc>() ||
        !getIt.isRegistered<AppearanceBloc>() ||
        !getIt.isRegistered<BodyBloc>() ||
        !getIt.isRegistered<PreferencesBloc>() ||
        !getIt.isRegistered<OnboardingProfileBloc>() ||
        !getIt.isRegistered<OnboardingStatusBloc>()) {
      AuthServiceLocator.execute(getIt: getIt);
    }
  }

  static Future<void> execute() async {
    executeSync();
  }
}