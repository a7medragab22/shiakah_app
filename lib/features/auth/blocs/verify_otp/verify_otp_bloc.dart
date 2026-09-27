part of "../../auth.dart";

class VerifyOTPBloc extends Bloc<VerifyOtpEvent, BaseState<VerifyOtpResponseModel>> {
  final VerifyOTPDataSource _verifyDataSource;
  final ITokenCache _tokenCache;

  VerifyOTPBloc(
    this._verifyDataSource, {
    ITokenCache? tokenCache,
  })  : _tokenCache = tokenCache ?? HiveServiceImpl.instance,
        super(const BaseState<VerifyOtpResponseModel>()) {
    on<VerifyOtpSubmitted>(_onVerifySubmitted);
  }

  FutureOr<void> _onVerifySubmitted(
    VerifyOtpSubmitted event,
    Emitter<BaseState<VerifyOtpResponseModel>> emit,
  ) async {
    emit(state.copyWith(status: Status.loading));
    final result = await _verifyDataSource.verifyOtp(
      email: event.email,
      otp: event.otp,
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
