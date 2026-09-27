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
        !getIt.isRegistered<VerifyOTPBloc>()) {
      AuthServiceLocator.execute(getIt: getIt);
    }
  }

  static Future<void> execute() async {
    executeSync();
  }
}