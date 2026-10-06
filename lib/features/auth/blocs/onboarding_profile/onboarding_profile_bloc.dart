part of "../../auth.dart";

class OnboardingProfileBloc
    extends Bloc<OnboardingProfileEvent, BaseState<OnboardingProfileResponseModel>> {
  final OnboardingProfileDataSource _onboardingProfileDataSource;

  OnboardingProfileBloc(this._onboardingProfileDataSource)
      : super(const BaseState<OnboardingProfileResponseModel>()) {
    on<OnboardingProfileSubmitted>(_onOnboardingProfileSubmitted);
  }

  FutureOr<void> _onOnboardingProfileSubmitted(
    OnboardingProfileSubmitted event,
    Emitter<BaseState<OnboardingProfileResponseModel>> emit,
  ) async {
    emit(state.copyWith(status: Status.loading));
    final result = await _onboardingProfileDataSource.updateProfile(
      name: event.name,
      location: event.location,
    );
    result.fold(
      (failure) {
        emit(state.copyWith(
          status: Status.failure,
          errorMessage: failure.message,
          failure: failure,
        ));
      },
      (responseModel) {
        emit(state.copyWith(
          status: Status.success,
          data: responseModel,
          errorMessage: null,
        ));
      },
    );
  }
}
