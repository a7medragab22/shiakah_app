part of "../../auth.dart";

class RegisterBloc extends Bloc<RegisterEvent, BaseState<RegisterResponseModel>> {
  final RegisterDataSource _registerDataSource;

  RegisterBloc(this._registerDataSource)
      : super(const BaseState<RegisterResponseModel>()) {
    on<RegisterSubmitted>(_onRegisterSubmitted);
  }

  FutureOr<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<BaseState<RegisterResponseModel>> emit,
  ) async {
    emit(state.copyWith(status: Status.loading));
    final result = await _registerDataSource.register(
      email: event.email,
      userName: event.userName,
      password: event.password,
    );
    result.fold(
      (failure) => emit(state.copyWith(
        status: Status.failure,
        errorMessage: failure.message,
        failure: failure,
      )),
      (responseModel) => emit(state.copyWith(
        status: Status.success,
        data: responseModel,
        errorMessage: null,
      )),
    );
  }
}
