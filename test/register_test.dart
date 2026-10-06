import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiakah/core/bloc/paginated_bloc/exports.dart';
import 'package:shiakah/core/enum/status.dart';
import 'package:shiakah/core/helpers/helpers.dart';
import 'package:shiakah/core/http/http.dart';
import 'package:shiakah/features/auth/auth.dart';

void main() {
  group('Register Feature Integration Tests', () {
    late Dio dio;
    late ApiConsumer apiConsumer;
    late GenericDataSource genericDataSource;
    late RegisterDataSource registerDataSource;

    setUp(() {
      dio = Dio(BaseOptions(
        baseUrl: Endpoints.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
        },
      ));
      apiConsumer = BaseApiConsumer(dio: dio);
      genericDataSource = GenericDataSource(apiConsumer);
      registerDataSource = RegisterDataSourceImpl(genericDataSource);
    });

    test('RegisterDataSource calls real API and returns success with message', () async {
      final testEmail = 'test_user_${DateTime.now().millisecondsSinceEpoch}@gmail.com';
      final result = await registerDataSource.register(
        email: testEmail,
        password: 'Password_123',
      );

      result.fold(
        (failure) {
          fail('Registration failed with error: ${failure.message}');
        },
        (response) {
          expect(response.success, isTrue);
          expect(response.message, isNotNull);
          expect(response.message, contains('كود التحقق'));
        },
      );
    });

    test('RegisterBloc emits loading then success', () async {
      final bloc = RegisterBloc(registerDataSource);
      final testEmail = 'test_user_bloc_${DateTime.now().millisecondsSinceEpoch}@gmail.com';

      final expectedStates = [
        predicate<BaseState<RegisterResponseModel>>((s) => s.status == Status.loading),
        predicate<BaseState<RegisterResponseModel>>((s) => s.status == Status.success && s.data?.success == true),
      ];

      expectLater(bloc.stream, emitsInOrder(expectedStates));

      bloc.add(RegisterSubmitted(
        email: testEmail,
        password: 'Password_123',
      ));
    });
  });
}
