part of "../../auth.dart";

class BodyBloc extends Bloc<BodyEvent, BaseState<BodyResponseModel>> {
  final BodyDataSource _bodyDataSource;

  BodyBloc(this._bodyDataSource) : super(const BaseState<BodyResponseModel>()) {
    on<BodySubmitted>(_onBodySubmitted);
  }

  FutureOr<void> _onBodySubmitted(
    BodySubmitted event,
    Emitter<BaseState<BodyResponseModel>> emit,
  ) async {
    emit(state.copyWith(status: Status.loading));
    final result = await _bodyDataSource.updateBody(
      height: event.height,
      weight: event.weight,
      bodyType: event.bodyType,
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
