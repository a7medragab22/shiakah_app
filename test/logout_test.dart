import 'package:flutter_test/flutter_test.dart';
import 'package:shiakah/core/bloc/paginated_bloc/exports.dart';
import 'package:shiakah/core/enum/status.dart';
import 'package:shiakah/core/http/either.dart';
import 'package:shiakah/core/http/failure.dart';
import 'package:shiakah/core/http/http.dart';
import 'package:shiakah/core/local_storage/local_storage.dart';
import 'package:shiakah/features/auth/auth.dart';

class MockLogoutDataSource implements LogoutDataSource {
  String? lastRefreshToken;
  bool shouldSucceed = true;

  @override
  Future<Either<Failure, void>> logout({required String refreshToken}) async {
    lastRefreshToken = refreshToken;
    if (shouldSucceed) {
      return const Right(null);
    } else {
      return Left(ServerFailure(message: 'Logout failed on server'));
    }
  }
}

class FakeTokenCache implements ITokenCache {
  String? access;
  String? refresh;

  FakeTokenCache({this.access = 'access_token_123', this.refresh = 'refresh_token_456'});

  @override
  Future<void> clearAccessToken() async => access = null;

  @override
  Future<void> clearRefreshToken() async => refresh = null;

  @override
  String? getAccessToken() => access;

  @override
  String? getRefreshToken() => refresh;

  @override
  Future<void> saveAccessToken(String token) async => access = token;

  @override
  Future<void> saveRefreshToken(String token) async => refresh = token;
}

void main() {
  test('Endpoints.logout is set to /api/Auth/logout', () {
    expect(Endpoints.logout, '/api/Auth/logout');
  });

  test('LogoutBloc sends stored refreshToken and clears cache upon successful logout', () async {
    final mockDataSource = MockLogoutDataSource();
    final fakeCache = FakeTokenCache(refresh: 'saved_refresh_token_abc');

    final bloc = LogoutBloc(mockDataSource, tokenCache: fakeCache);

    expect(bloc.state.status, Status.initial);

    bloc.add(const LogoutSubmitted());

    await expectLater(
      bloc.stream,
      emitsInOrder([
        predicate<BaseState<void>>((s) => s.status == Status.loading),
        predicate<BaseState<void>>((s) => s.status == Status.success),
      ]),
    );

    expect(mockDataSource.lastRefreshToken, 'saved_refresh_token_abc');
    expect(fakeCache.getAccessToken(), isNull);
    expect(fakeCache.getRefreshToken(), isNull);

    await bloc.close();
  });

  test('LogoutBloc clears local cache even when server responds with failure', () async {
    final mockDataSource = MockLogoutDataSource()..shouldSucceed = false;
    final fakeCache = FakeTokenCache(refresh: 'expired_refresh_token');

    final bloc = LogoutBloc(mockDataSource, tokenCache: fakeCache);

    bloc.add(const LogoutSubmitted());

    await expectLater(
      bloc.stream,
      emitsInOrder([
        predicate<BaseState<void>>((s) => s.status == Status.loading),
        predicate<BaseState<void>>((s) => s.status == Status.failure),
      ]),
    );

    // Cache must still be cleared so user is logged out locally
    expect(fakeCache.getAccessToken(), isNull);
    expect(fakeCache.getRefreshToken(), isNull);

    await bloc.close();
  });
}
