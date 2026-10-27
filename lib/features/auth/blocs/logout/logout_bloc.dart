part of "../../auth.dart";

class LogoutBloc extends Bloc<LogoutEvent, BaseState<void>> {
  final LogoutDataSource _logoutDataSource;
  final ITokenCache _tokenCache;

  LogoutBloc(
    this._logoutDataSource, {
    ITokenCache? tokenCache,
  })  : _tokenCache = tokenCache ?? HiveServiceImpl.instance,
        super(const BaseState<void>()) {
    on<LogoutSubmitted>(_onLogoutSubmitted);
    on<LogoutEvent>(_onGenericLogout);
  }

  FutureOr<void> _onLogoutSubmitted(
      LogoutSubmitted event, Emitter<BaseState<void>> emit) async {
    emit(state.copyWith(status: Status.loading));

    final token = event.refreshToken ?? _tokenCache.getRefreshToken() ?? '';
    final result = await _logoutDataSource.logout(refreshToken: token);

    // Clear local storage and caches regardless of server result
    await _tokenCache.clearAccessToken();
    await _tokenCache.clearRefreshToken();
    ClosetManager.instance.clear();
    LooksManager.instance.clear();

    emit(result.fold(
      (failure) => state.copyWith(
        status: Status.failure,
        errorMessage: failure.message,
        failure: failure,
      ),
      (data) => state.copyWith(status: Status.success),
    ));
  }

  FutureOr<void> _onGenericLogout(
      LogoutEvent event, Emitter<BaseState<void>> emit) async {
    if (event is! LogoutSubmitted) {
      await _onLogoutSubmitted(const LogoutSubmitted(), emit);
    }
  }
}
