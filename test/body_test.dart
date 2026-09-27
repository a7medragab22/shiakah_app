import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiakah/core/bloc/paginated_bloc/exports.dart';
import 'package:shiakah/core/enum/status.dart';
import 'package:shiakah/core/helpers/helpers.dart';
import 'package:shiakah/core/http/either.dart';
import 'package:shiakah/core/http/failure.dart';
import 'package:shiakah/core/http/http.dart';
import 'package:shiakah/features/auth/auth.dart';

class FakeBodyDataSource implements BodyDataSource {
  final bool shouldSucceed;
  final String? errorMessage;

  FakeBodyDataSource({this.shouldSucceed = true, this.errorMessage});

  @override
  Future<Either<Failure, BodyResponseModel>> updateBody({
    required double height,
    required double weight,
    required int bodyType,
  }) async {
    if (shouldSucceed) {
      return Right(
        BodyResponseModel(
          success: true,
          data: null,
          message: 'BodyUpdatedSuccessfully',
          errors: null,
          meta: null,
        ),
      );
    } else {
      return Left(
        ServerFailure(message: errorMessage ?? 'Failed to update body'),
      );
    }
  }
}

void main() {
  group('Body Models & Enum Mapping Tests', () {
    test('BodyType enum matches required values', () {
      expect(BodyType.slim.value, 1);
      expect(BodyType.regular.value, 2);
      expect(BodyType.athletic.value, 3);
      expect(BodyType.stocky.value, 4);
      expect(BodyType.plusSized.value, 5);

      expect(BodyType.fromString('slim').value, 1);
      expect(BodyType.fromString('regular').value, 2);
      expect(BodyType.fromString('athletic').value, 3);
      expect(BodyType.fromString('stocky').value, 4);
      expect(BodyType.fromString('plus_size').value, 5);
      expect(BodyType.fromString('plus sized').value, 5);
    });

    test('BodyRequestModel serializes JSON correctly', () {
      const model = BodyRequestModel(
        height: 400.0,
        weight: 400.0,
        bodyType: 3,
      );

      final json = model.toJson();
      expect(json, {
        'height': 400.0,
        'weight': 400.0,
        'bodyType': 3,
      });

      final parsed = BodyRequestModel.fromJson(json);
      expect(parsed.height, 400.0);
      expect(parsed.weight, 400.0);
      expect(parsed.bodyType, 3);
    });

    test('BodyResponseModel deserializes backend response correctly', () {
      final jsonResponse = {
        "success": true,
        "data": null,
        "message": "BodyUpdatedSuccessfully",
        "errors": null,
        "meta": null,
      };

      final model = BodyResponseModel.fromJson(jsonResponse);
      expect(model.success, isTrue);
      expect(model.message, 'BodyUpdatedSuccessfully');
      expect(model.data, isNull);
    });

    test('BodyBloc emits loading then success on BodySubmitted', () async {
      final bloc = BodyBloc(FakeBodyDataSource(shouldSucceed: true));

      expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<BaseState<BodyResponseModel>>(
            (state) => state.status == Status.loading,
          ),
          predicate<BaseState<BodyResponseModel>>(
            (state) =>
                state.status == Status.success &&
                state.data?.message == 'BodyUpdatedSuccessfully',
          ),
        ]),
      );

      bloc.add(const BodySubmitted(height: 183.0, weight: 76.0, bodyType: 3));
    });

    test('BodyBloc emits loading then failure on error', () async {
      final bloc = BodyBloc(
        FakeBodyDataSource(
          shouldSucceed: false,
          errorMessage: 'Server Error',
        ),
      );

      expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<BaseState<BodyResponseModel>>(
            (state) => state.status == Status.loading,
          ),
          predicate<BaseState<BodyResponseModel>>(
            (state) =>
                state.status == Status.failure &&
                state.errorMessage == 'Server Error',
          ),
        ]),
      );

      bloc.add(const BodySubmitted(height: 175.0, weight: 68.0, bodyType: 1));
    });
  });

  group('Body API Live Integration Test', () {
    late Dio dio;
    late ApiConsumer apiConsumer;
    late GenericDataSource genericDataSource;
    late LoginDataSource loginDataSource;
    late BodyDataSource bodyDataSource;

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
      bodyDataSource = BodyDataSourceImpl(genericDataSource);
    });

    test('Login and update body on real backend with height=183, weight=76, bodyType=3', () async {
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

        final result = await bodyDataSource.updateBody(
          height: 183.0,
          weight: 76.0,
          bodyType: 3,
        );

        result.fold(
          (failure) => fail('Body update failed: ${failure.message}'),
          (response) {
            expect(response.success, isTrue);
            expect(response.message, 'BodyUpdatedSuccessfully');
          },
        );
      }
    });
  });
}
