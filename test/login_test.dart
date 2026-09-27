import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:shiakah/core/bloc/paginated_bloc/exports.dart';
import 'package:shiakah/core/enum/status.dart';
import 'package:shiakah/core/helpers/helpers.dart';
import 'package:shiakah/core/http/either.dart';
import 'package:shiakah/core/http/failure.dart';
import 'package:shiakah/core/http/http.dart';
import 'package:shiakah/core/local_storage/local_storage.dart';
import 'package:shiakah/features/auth/auth.dart';

class MockTokenCache implements ITokenCache {
  String? accessToken;
  String? refreshToken;

  @override
  Future<void> saveAccessToken(String token) async {
    accessToken = token;
  }

  @override
  String? getAccessToken() => accessToken;

  @override
  Future<void> clearAccessToken() async {
    accessToken = null;
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    refreshToken = token;
  }

  @override
  String? getRefreshToken() => refreshToken;

  @override
  Future<void> clearRefreshToken() async {
    refreshToken = null;
  }
}

void main() {
  late Dio dio;
  late ApiConsumer apiConsumer;
  late GenericDataSource genericDataSource;
  late LoginDataSource loginDataSource;
  late MockTokenCache mockTokenCache;

  setUp(() {
    dio = Dio(
      BaseOptions(
        baseUrl: Endpoints.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );
    apiConsumer = BaseApiConsumer(dio: dio);
    genericDataSource = GenericDataSource(apiConsumer);
    loginDataSource = LoginDataSourceImpl(genericDataSource);
    mockTokenCache = MockTokenCache();
  });

  group('Login Feature Integration Tests', () {
    test('LoginDataSource returns success with tokens on valid credentials', () async {
      final result = await loginDataSource.login(
        email: 'muhvmd.anwerr24@gmail.com',
        password: 'Muhvmd_44',
      );

      expect(result, isA<Right<Failure, LoginResponseModel>>());
      result.fold(
        (failure) => fail('Expected success but got failure: ${failure.message}'),
        (response) {
          expect(response.success, isTrue);
          expect(response.data, isNotNull);
          expect(response.data!.accessToken, isNotEmpty);
          expect(response.data!.refreshToken, isNotEmpty);
          expect(response.data!.userRoles, contains('User'));
          expect(response.message, contains('تم تسجيل الدخول بنجاح'));
        },
      );
    });

    test('LoginDataSource returns ServerFailure on invalid credentials', () async {
      final result = await loginDataSource.login(
        email: 'wrong.email@test.com',
        password: 'WrongPassword123!',
      );

      expect(result, isA<Left<Failure, LoginResponseModel>>());
      result.fold(
        (failure) {
          expect(failure.message, isNotEmpty);
        },
        (response) => fail('Expected failure but got success'),
      );
    });

    test('LoginBloc emits loading then success, and saves tokens', () async {
      final bloc = LoginBloc(loginDataSource, tokenCache: mockTokenCache);

      final expectedStates = [
        const BaseState<LoginResponseModel>(status: Status.loading),
        isA<BaseState<LoginResponseModel>>()
            .having((s) => s.status, 'status', Status.success)
            .having((s) => s.data?.success, 'success', isTrue)
            .having((s) => s.data?.data?.accessToken, 'accessToken', isNotEmpty),
      ];

      expectLater(bloc.stream, emitsInOrder(expectedStates));

      bloc.add(const LoginSubmitted(
        email: 'muhvmd.anwerr24@gmail.com',
        password: 'Muhvmd_44',
      ));

      await Future.delayed(const Duration(seconds: 4));
      expect(mockTokenCache.accessToken, isNotNull);
      expect(mockTokenCache.refreshToken, isNotNull);
      await bloc.close();
    });
  });
}
