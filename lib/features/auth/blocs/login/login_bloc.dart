part of "../../auth.dart";

class LoginBloc extends Bloc<LoginEvent, BaseState<LoginResponseModel>> {
  final LoginDataSource _loginDataSource;
  final ITokenCache _tokenCache;

  LoginBloc(
    this._loginDataSource, {
    ITokenCache? tokenCache,
  })  : _tokenCache = tokenCache ?? HiveServiceImpl.instance,
        super(const BaseState<LoginResponseModel>()) {
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  FutureOr<void> _onLoginSubmitted(
      LoginSubmitted event, Emitter<BaseState<LoginResponseModel>> emit) async {
    emit(state.copyWith(status: Status.loading));
    final result = await _loginDataSource.login(
      email: event.email,
      password: event.password,
    );
    await result.fold(
      (failure) async {
        emit(state.copyWith(
          status: Status.failure,
          errorMessage: failure.message,
          failure: failure,
        ));
      },
      (responseModel) async {
        if (responseModel.data != null) {
          final accessToken = responseModel.data!.accessToken;
          final refreshToken = responseModel.data!.refreshToken;
          if (accessToken.isNotEmpty) {
            await _tokenCache.saveAccessToken(accessToken);
          }
          if (refreshToken.isNotEmpty) {
            await _tokenCache.saveRefreshToken(refreshToken);
          }
        }
        emit(state.copyWith(
          status: Status.success,
          data: responseModel,
          errorMessage: null,
        ));
      },
    );
  }
}
