import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiakah/core/bloc/paginated_bloc/exports.dart';
import 'package:shiakah/core/enum/status.dart';
import 'package:shiakah/core/helpers/helpers.dart';
import 'package:shiakah/core/http/http.dart';
import 'package:shiakah/core/local_storage/local_storage.dart';
import 'package:shiakah/features/auth/auth.dart';

class MockTokenCache implements ITokenCache {
  String? savedAccessToken;
  String? savedRefreshToken;

  @override
  Future<void> saveAccessToken(String token) async {
    savedAccessToken = token;
  }

  @override
  String? getAccessToken() => savedAccessToken;

  @override
  Future<void> clearAccessToken() async {
    savedAccessToken = null;
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    savedRefreshToken = token;
  }

  @override
  String? getRefreshToken() => savedRefreshToken;

  @override
  Future<void> clearRefreshToken() async {
    savedRefreshToken = null;
  }
}

void main() {
  group('Verify OTP Feature Tests', () {
    late Dio dio;
    late ApiConsumer apiConsumer;
    late GenericDataSource genericDataSource;
    late VerifyOTPDataSource verifyOtpDataSource;
    late MockTokenCache tokenCache;

    setUp(() {
      dio = Dio(BaseOptions(
        baseUrl: Endpoints.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ));
      apiConsumer = BaseApiConsumer(dio: dio);
      genericDataSource = GenericDataSource(apiConsumer);
      verifyOtpDataSource = VerifyOTPDataSourceImpl(genericDataSource);
      tokenCache = MockTokenCache();
    });

    test('VerifyOTPDataSource returns failure on invalid OTP', () async {
      final result = await verifyOtpDataSource.verifyOtp(
        email: 'nonexistent_test_user@gmail.com',
        otp: '000000',
      );

      result.fold(
        (failure) {
          expect(failure.message, isNotEmpty);
        },
        (response) {
          // If server returns false
          expect(response.success, isFalse);
        },
      );
    });

    test('VerifyOTPBloc emits loading then failure on invalid OTP', () async {
      final bloc = VerifyOTPBloc(verifyOtpDataSource, tokenCache: tokenCache);

      final expectedStates = [
        predicate<BaseState<VerifyOtpResponseModel>>((s) => s.status == Status.loading),
        predicate<BaseState<VerifyOtpResponseModel>>((s) => s.status == Status.failure),
      ];

      expectLater(bloc.stream, emitsInOrder(expectedStates));

      bloc.add(const VerifyOtpSubmitted(
        email: 'invalid_email@gmail.com',
        otp: '000000',
      ));
    });
  });
}
