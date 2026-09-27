part of "../../auth.dart";

class PreferencesBloc
    extends Bloc<PreferencesEvent, BaseState<PreferencesResponseModel>> {
  final PreferencesDataSource _preferencesDataSource;

  PreferencesBloc(this._preferencesDataSource)
      : super(const BaseState<PreferencesResponseModel>()) {
    on<PreferencesSubmitted>(_onPreferencesSubmitted);
  }

  FutureOr<void> _onPreferencesSubmitted(
    PreferencesSubmitted event,
    Emitter<BaseState<PreferencesResponseModel>> emit,
  ) async {
    emit(state.copyWith(status: Status.loading));
    final result = await _preferencesDataSource.updatePreferences(
      styles: event.styles,
      preferredColors: event.preferredColors,
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
