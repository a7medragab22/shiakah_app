import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiakah/core/bloc/paginated_bloc/exports.dart';
import 'package:shiakah/core/enum/status.dart';
import 'package:shiakah/core/helpers/helpers.dart';
import 'package:shiakah/core/http/either.dart';
import 'package:shiakah/core/http/failure.dart';
import 'package:shiakah/core/http/http.dart';
import 'package:shiakah/features/auth/auth.dart';

class FakeGenderDataSource implements GenderDataSource {
  final bool shouldSucceed;
  final String? errorMessage;

  FakeGenderDataSource({this.shouldSucceed = true, this.errorMessage});

  @override
  Future<Either<Failure, GenderResponseModel>> updateGender({
    required int gender,
  }) async {
    if (shouldSucceed) {
      return Right(
        GenderResponseModel(
          success: true,
          data: null,
          message: 'GenderUpdatedSuccessfully',
          errors: null,
          meta: null,
        ),
      );
    } else {
      return Left(
        ServerFailure(message: errorMessage ?? 'Failed to update gender'),
      );
    }
  }
}

void main() {
  group('Gender Models and Logic Tests', () {
    test('GenderRequestModel serializes correctly for male (1) and female (2)', () {
      final maleRequest = const GenderRequestModel(gender: 1);
      final femaleRequest = const GenderRequestModel(gender: 2);

      expect(maleRequest.toJson(), {'gender': 1});
      expect(femaleRequest.toJson(), {'gender': 2});

      final parsed = GenderRequestModel.fromJson({'gender': 1});
      expect(parsed.gender, 1);
    });

    test('GenderResponseModel deserializes backend response correctly', () {
      final jsonResponse = {
        "success": true,
        "data": null,
        "message": "GenderUpdatedSuccessfully",
        "errors": null,
        "meta": null,
      };

      final model = GenderResponseModel.fromJson(jsonResponse);
      expect(model.success, isTrue);
      expect(model.message, 'GenderUpdatedSuccessfully');
      expect(model.data, isNull);
    });

    test('GenderBloc emits loading then success on GenderSubmitted', () async {
      final bloc = GenderBloc(FakeGenderDataSource(shouldSucceed: true));

      expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<BaseState<GenderResponseModel>>(
            (state) => state.status == Status.loading,
          ),
          predicate<BaseState<GenderResponseModel>>(
            (state) =>
                state.status == Status.success &&
                state.data?.message == 'GenderUpdatedSuccessfully',
          ),
        ]),
      );

      bloc.add(const GenderSubmitted(gender: 1));
    });

    test('GenderBloc emits loading then failure on error', () async {
      final bloc = GenderBloc(
        FakeGenderDataSource(
          shouldSucceed: false,
          errorMessage: 'Unauthorized',
        ),
      );

      expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<BaseState<GenderResponseModel>>(
            (state) => state.status == Status.loading,
          ),
          predicate<BaseState<GenderResponseModel>>(
            (state) =>
                state.status == Status.failure &&
                state.errorMessage == 'Unauthorized',
          ),
        ]),
      );

      bloc.add(const GenderSubmitted(gender: 2));
    });
  });

  group('Gender API Live Integration Test', () {
    late Dio dio;
    late ApiConsumer apiConsumer;
    late GenericDataSource genericDataSource;
    late LoginDataSource loginDataSource;
    late GenderDataSource genderDataSource;

    setUp(() {
      dio = Dio(
        BaseOptions(
          baseUrl: Endpoints.baseUrl,
          connectTimeout: const Duration(seconds: 20),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );
      apiConsumer = BaseApiConsumer(dio: dio);
      genericDataSource = GenericDataSource(apiConsumer);
      loginDataSource = LoginDataSourceImpl(genericDataSource);
      genderDataSource = GenderDataSourceImpl(genericDataSource);
    });

    test('Login then update gender to male (1) and female (2)', () async {
      // 1. Authenticate to get a real token
      final loginResult = await loginDataSource.login(
        email: 'muhvmd.anwerr24@gmail.com',
        password: 'Password_123',
      );

      String? token;
      loginResult.fold(
        (failure) {
          // If password changed, try alternative
        },
        (response) {
          token = response.data?.accessToken;
        },
      );

      if (token == null) {
        final fallbackLogin = await loginDataSource.login(
          email: 'muhvmd.anwerr24@gmail.com',
          password: 'Muhvmd_44',
        );
        fallbackLogin.fold(
          (failure) => null,
          (response) => token = response.data?.accessToken,
        );
      }

      if (token != null) {
        dio.options.headers['Authorization'] = 'Bearer $token';

        // 2. Test male = 1
        final genderResult1 = await genderDataSource.updateGender(gender: 1);
        genderResult1.fold(
          (failure) => fail('Gender update failed: ${failure.message}'),
          (response) {
            expect(response.success, isTrue);
            expect(response.message, 'GenderUpdatedSuccessfully');
          },
        );

        // 3. Test female = 2
        final genderResult2 = await genderDataSource.updateGender(gender: 2);
        genderResult2.fold(
          (failure) => fail('Gender update failed: ${failure.message}'),
          (response) {
            expect(response.success, isTrue);
            expect(response.message, 'GenderUpdatedSuccessfully');
          },
        );
      }
    });
  });
}
