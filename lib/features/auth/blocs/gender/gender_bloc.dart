part of "../../auth.dart";

class GenderBloc extends Bloc<GenderEvent, BaseState<GenderResponseModel>> {
  final GenderDataSource _genderDataSource;

  GenderBloc(this._genderDataSource)
      : super(const BaseState<GenderResponseModel>()) {
    on<GenderSubmitted>(_onGenderSubmitted);
  }

  FutureOr<void> _onGenderSubmitted(
    GenderSubmitted event,
    Emitter<BaseState<GenderResponseModel>> emit,
  ) async {
    emit(state.copyWith(status: Status.loading));
    final result = await _genderDataSource.updateGender(gender: event.gender);
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
