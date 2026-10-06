part of "../../auth.dart";

class AppearanceBloc
    extends Bloc<AppearanceEvent, BaseState<AppearanceResponseModel>> {
  final AppearanceDataSource _appearanceDataSource;

  AppearanceBloc(this._appearanceDataSource)
      : super(const BaseState<AppearanceResponseModel>()) {
    on<AppearanceSubmitted>(_onAppearanceSubmitted);
  }

  FutureOr<void> _onAppearanceSubmitted(
    AppearanceSubmitted event,
    Emitter<BaseState<AppearanceResponseModel>> emit,
  ) async {
    emit(state.copyWith(status: Status.loading));
    final result = await _appearanceDataSource.updateAppearance(
      ageRange: event.ageRange,
      skinTone: event.skinTone,
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
