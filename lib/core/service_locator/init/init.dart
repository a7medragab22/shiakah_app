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
    if (!getIt.isRegistered<ClipScanner>() ||
        !getIt.isRegistered<ScannerService>() ||
        !getIt.isRegistered<WardrobeScannerBloc>()) {
      ScannerServiceLocator.execute(getIt: getIt);
    }
    if (!getIt.isRegistered<WardrobeRemoteDataSource>()) {
      getIt.registerLazySingleton<WardrobeRemoteDataSource>(
        () => WardrobeRemoteDataSourceImpl(getIt<GenericDataSource>()),
      );
    }
    if (!getIt.isRegistered<AddToClosetCubit>()) {
      getIt.registerFactory<AddToClosetCubit>(
        () => AddToClosetCubit(getIt<WardrobeRemoteDataSource>()),
      );
    }
    if (!getIt.isRegistered<MyClosetCubit>()) {
      getIt.registerFactory<MyClosetCubit>(
        () => MyClosetCubit(getIt<WardrobeRemoteDataSource>()),
      );
    }
    if (!getIt.isRegistered<OutfitRemoteDataSource>()) {
      getIt.registerLazySingleton<OutfitRemoteDataSource>(
        () => OutfitRemoteDataSourceImpl(getIt<GenericDataSource>()),
      );
    }
    if (!getIt.isRegistered<MyLooksCubit>()) {
      getIt.registerFactory<MyLooksCubit>(
        () => MyLooksCubit(getIt<OutfitRemoteDataSource>()),
      );
    }
  }

  static Future<void> execute() async {
    executeSync();
  }

  /// Safely warms up the on-device scanner models and zero-shot prompts.
  static Future<void> warmupScanner() async {
    await ScannerServiceLocator.warmup(getIt: getIt);
  }
}