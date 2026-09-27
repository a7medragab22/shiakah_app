import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiakah/core/bloc/paginated_bloc/exports.dart';
import 'package:shiakah/core/enum/status.dart';
import 'package:shiakah/core/helpers/helpers.dart';
import 'package:shiakah/core/http/either.dart';
import 'package:shiakah/core/http/failure.dart';
import 'package:shiakah/core/http/http.dart';
import 'package:shiakah/features/auth/auth.dart';

class FakeAppearanceDataSource implements AppearanceDataSource {
  final bool shouldSucceed;
  final String? errorMessage;

  FakeAppearanceDataSource({this.shouldSucceed = true, this.errorMessage});

  @override
  Future<Either<Failure, AppearanceResponseModel>> updateAppearance({
    required int ageRange,
    required int skinTone,
  }) async {
    if (shouldSucceed) {
      return Right(
        AppearanceResponseModel(
          success: true,
          data: null,
          message: 'AppearanceUpdatedSuccessfully',
          errors: null,
          meta: null,
        ),
      );
    } else {
      return Left(
        ServerFailure(message: errorMessage ?? 'Failed to update appearance'),
      );
    }
  }
}

void main() {
  group('Appearance Models & Enum Mapping Tests', () {
    test('SkinTone enum matches backend values', () {
      expect(SkinTone.veryLight.value, 1);
      expect(SkinTone.light.value, 2);
      expect(SkinTone.medium.value, 3);
      expect(SkinTone.tan.value, 4);
      expect(SkinTone.brown.value, 5);
      expect(SkinTone.dark.value, 6);
    });

    test('AgeRange enum matches backend values', () {
      expect(AgeRange.from1To17.value, 1);
      expect(AgeRange.from18To24.value, 2);
      expect(AgeRange.from25To34.value, 3);
      expect(AgeRange.from35To44.value, 4);
      expect(AgeRange.from45AndAbove.value, 5);
    });

    test('AppearanceRequestModel serializes JSON correctly', () {
      const model = AppearanceRequestModel(
        ageRange: 5,
        skinTone: 2,
      );

      final json = model.toJson();
      expect(json, {
        'ageRange': 5,
        'skinTone': 2,
      });

      final parsed = AppearanceRequestModel.fromJson(json);
      expect(parsed.ageRange, 5);
      expect(parsed.skinTone, 2);
    });

    test('AppearanceResponseModel deserializes backend response correctly', () {
      final jsonResponse = {
        "success": true,
        "data": null,
        "message": "AppearanceUpdatedSuccessfully",
        "errors": null,
        "meta": null,
      };

      final model = AppearanceResponseModel.fromJson(jsonResponse);
      expect(model.success, isTrue);
      expect(model.message, 'AppearanceUpdatedSuccessfully');
      expect(model.data, isNull);
    });

    test('AppearanceBloc emits loading then success on AppearanceSubmitted', () async {
      final bloc = AppearanceBloc(FakeAppearanceDataSource(shouldSucceed: true));

      expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<BaseState<AppearanceResponseModel>>(
            (state) => state.status == Status.loading,
          ),
          predicate<BaseState<AppearanceResponseModel>>(
            (state) =>
                state.status == Status.success &&
                state.data?.message == 'AppearanceUpdatedSuccessfully',
          ),
        ]),
      );

      bloc.add(const AppearanceSubmitted(ageRange: 5, skinTone: 2));
    });

    test('AppearanceBloc emits loading then failure on error', () async {
      final bloc = AppearanceBloc(
        FakeAppearanceDataSource(
          shouldSucceed: false,
          errorMessage: 'Server Error',
        ),
      );

      expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<BaseState<AppearanceResponseModel>>(
            (state) => state.status == Status.loading,
          ),
          predicate<BaseState<AppearanceResponseModel>>(
            (state) =>
                state.status == Status.failure &&
                state.errorMessage == 'Server Error',
          ),
        ]),
      );

      bloc.add(const AppearanceSubmitted(ageRange: 3, skinTone: 1));
    });
  });

  group('Appearance API Live Integration Test', () {
    late Dio dio;
    late ApiConsumer apiConsumer;
    late GenericDataSource genericDataSource;
    late LoginDataSource loginDataSource;
    late AppearanceDataSource appearanceDataSource;

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
      appearanceDataSource = AppearanceDataSourceImpl(genericDataSource);
    });

    test('Login and update appearance on real backend with ageRange=5, skinTone=2', () async {
      final loginResult = await loginDataSource.login(
        email: 'muhvmd.anwerr24@gmail.com',
        password: 'Muhvmd_44',
      );

      String? token;
      loginResult.fold(
        (failure) => null,
        (response) => token = response.data?.accessToken,
      );

      if (token != null) {
        dio.options.headers['Authorization'] = 'Bearer $token';

        final result = await appearanceDataSource.updateAppearance(
          ageRange: 5,
          skinTone: 2,
        );

        result.fold(
          (failure) => fail('Appearance update failed: ${failure.message}'),
          (response) {
            expect(response.success, isTrue);
            expect(response.message, 'AppearanceUpdatedSuccessfully');
          },
        );
      }
    });
  });
}
