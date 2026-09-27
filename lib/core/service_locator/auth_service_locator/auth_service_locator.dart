part of '../service_locator.dart';

class AuthServiceLocator{
  static Future<void> execute({required GetIt getIt})async {
    //data sources
    getIt.registerLazySingleton<RegisterDataSource>(()=> RegisterDataSourceImpl(getIt<GenericDataSource>()));
    getIt.registerLazySingleton<LoginDataSource>(()=> LoginDataSourceImpl(getIt<GenericDataSource>()));
    getIt.registerLazySingleton<ForgetPasswordDataSource>(()=> ForgetPasswordDataSourceImpl(getIt<GenericDataSource>()));
    getIt.registerLazySingleton<LogoutDataSource>(()=> LogoutDataSourceImpl(getIt<GenericDataSource>()));
    getIt.registerLazySingleton<ResetPasswordDataSource>(()=> ResetPasswordDataSourceImpl(getIt<GenericDataSource>()));
    getIt.registerLazySingleton<SocialAuthDataSource>(()=> SocialAuthDataSourceImpl(getIt<GenericDataSource>()));
    getIt.registerLazySingleton<VerifyOTPDataSource>(()=> VerifyOTPDataSourceImpl(getIt<GenericDataSource>()));
    getIt.registerLazySingleton<GenderDataSource>(()=> GenderDataSourceImpl(getIt<GenericDataSource>()));
    getIt.registerLazySingleton<AppearanceDataSource>(()=> AppearanceDataSourceImpl(getIt<GenericDataSource>()));
    getIt.registerLazySingleton<BodyDataSource>(()=> BodyDataSourceImpl(getIt<GenericDataSource>()));
    getIt.registerLazySingleton<PreferencesDataSource>(()=> PreferencesDataSourceImpl(getIt<GenericDataSource>()));
    getIt.registerLazySingleton<OnboardingProfileDataSource>(()=> OnboardingProfileDataSourceImpl(getIt<GenericDataSource>()));
    getIt.registerLazySingleton<OnboardingStatusDataSource>(()=> OnboardingStatusDataSourceImpl(getIt<GenericDataSource>()));
    //blocs
    getIt.registerFactory<RegisterBloc>(()=> RegisterBloc(getIt<RegisterDataSource>()));
    getIt.registerFactory<LoginBloc>(()=> LoginBloc(getIt<LoginDataSource>()));
    getIt.registerFactory<ForgetPasswordBloc>(()=> ForgetPasswordBloc(getIt<ForgetPasswordDataSource>()));
    getIt.registerFactory<LogoutBloc>(()=> LogoutBloc(getIt<LogoutDataSource>()));
    getIt.registerFactory<ResetPasswordBloc>(()=> ResetPasswordBloc(getIt<ResetPasswordDataSource>()));
    getIt.registerFactory<SocialAuthBloc>(()=> SocialAuthBloc(getIt<SocialAuthDataSource>()));
    getIt.registerFactory<VerifyOTPBloc>(()=> VerifyOTPBloc(getIt<VerifyOTPDataSource>()));
    getIt.registerFactory<GenderBloc>(()=> GenderBloc(getIt<GenderDataSource>()));
    getIt.registerFactory<AppearanceBloc>(()=> AppearanceBloc(getIt<AppearanceDataSource>()));
    getIt.registerFactory<BodyBloc>(()=> BodyBloc(getIt<BodyDataSource>()));
    getIt.registerFactory<PreferencesBloc>(()=> PreferencesBloc(getIt<PreferencesDataSource>()));
    getIt.registerFactory<OnboardingProfileBloc>(()=> OnboardingProfileBloc(getIt<OnboardingProfileDataSource>()));
    getIt.registerFactory<OnboardingStatusBloc>(()=> OnboardingStatusBloc(getIt<OnboardingStatusDataSource>()));
  }
}