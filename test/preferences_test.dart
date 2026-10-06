import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiakah/core/bloc/paginated_bloc/exports.dart';
import 'package:shiakah/core/enum/status.dart';
import 'package:shiakah/core/helpers/helpers.dart';
import 'package:shiakah/core/http/either.dart';
import 'package:shiakah/core/http/failure.dart';
import 'package:shiakah/core/http/http.dart';
import 'package:shiakah/features/auth/auth.dart';

class FakePreferencesDataSource implements PreferencesDataSource {
  final bool shouldSucceed;
  final String? errorMessage;

  FakePreferencesDataSource({this.shouldSucceed = true, this.errorMessage});

  @override
  Future<Either<Failure, PreferencesResponseModel>> updatePreferences({
    required List<int> styles,
    required List<int> preferredColors,
  }) async {
    if (shouldSucceed) {
      return Right(
        PreferencesResponseModel(
          success: true,
          data: null,
          message: 'PreferencesUpdatedSuccessfully',
          errors: null,
          meta: null,
        ),
      );
    } else {
      return Left(
        ServerFailure(message: errorMessage ?? 'Failed to update preferences'),
      );
    }
  }
}

void main() {
  group('Preferences Models & Enum Mapping Tests', () {
    test('StyleType enum matches backend values', () {
      expect(StyleType.casual.value, 1);
      expect(StyleType.smartCasual.value, 2);
      expect(StyleType.streetwear.value, 3);
      expect(StyleType.businessFormal.value, 4);
      expect(StyleType.minimalist.value, 5);
      expect(StyleType.classic.value, 6);
      expect(StyleType.sportswear.value, 7);

      expect(StyleType.fromString('Casual').value, 1);
      expect(StyleType.fromString('Smart Casual').value, 2);
      expect(StyleType.fromString('Streetwear').value, 3);
      expect(StyleType.fromString('Business Formal').value, 4);
      expect(StyleType.fromString('Minimalist').value, 5);
      expect(StyleType.fromString('Classic').value, 6);
      expect(StyleType.fromString('Sportswear').value, 7);
    });

    test('PreferredColorType enum matches backend values', () {
      expect(PreferredColorType.black.value, 1);
      expect(PreferredColorType.white.value, 2);
      expect(PreferredColorType.gray.value, 3);
      expect(PreferredColorType.mustard.value, 4);
      expect(PreferredColorType.beige.value, 5);
      expect(PreferredColorType.burgundy.value, 6);
      expect(PreferredColorType.navy.value, 7);
      expect(PreferredColorType.blue.value, 8);
      expect(PreferredColorType.olive.value, 9);
      expect(PreferredColorType.brown.value, 10);
      expect(PreferredColorType.camel.value, 11);
      expect(PreferredColorType.forestGreen.value, 12);
      expect(PreferredColorType.darkGray.value, 13);
      expect(PreferredColorType.lightOlive.value, 14);
      expect(PreferredColorType.coral.value, 15);
      expect(PreferredColorType.burntBrown.value, 16);
      expect(PreferredColorType.purple.value, 17);
      expect(PreferredColorType.pink.value, 18);

      expect(PreferredColorType.fromString('light_olive').value, 14);
      expect(PreferredColorType.fromString('purple').value, 17);
    });

    test('PreferencesRequestModel serializes JSON correctly', () {
      const model = PreferencesRequestModel(
        styles: [5, 3],
        preferredColors: [14, 17],
      );

      final json = model.toJson();
      expect(json, {
        'styles': [5, 3],
        'preferredColors': [14, 17],
      });

      final parsed = PreferencesRequestModel.fromJson(json);
      expect(parsed.styles, [5, 3]);
      expect(parsed.preferredColors, [14, 17]);
    });

    test('PreferencesResponseModel deserializes backend response correctly', () {
      final jsonResponse = {
        "success": true,
        "data": null,
        "message": "PreferencesUpdatedSuccessfully",
        "errors": null,
        "meta": null,
      };

      final model = PreferencesResponseModel.fromJson(jsonResponse);
      expect(model.success, isTrue);
      expect(model.message, 'PreferencesUpdatedSuccessfully');
      expect(model.data, isNull);
    });

    test('PreferencesBloc emits loading then success on PreferencesSubmitted', () async {
      final bloc = PreferencesBloc(FakePreferencesDataSource(shouldSucceed: true));

      expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<BaseState<PreferencesResponseModel>>(
            (state) => state.status == Status.loading,
          ),
          predicate<BaseState<PreferencesResponseModel>>(
            (state) =>
                state.status == Status.success &&
                state.data?.message == 'PreferencesUpdatedSuccessfully',
          ),
        ]),
      );

      bloc.add(const PreferencesSubmitted(
        styles: [5, 3],
        preferredColors: [14, 17],
      ));
    });

    test('PreferencesBloc emits loading then failure on error', () async {
      final bloc = PreferencesBloc(
        FakePreferencesDataSource(
          shouldSucceed: false,
          errorMessage: 'Server Error',
        ),
      );

      expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<BaseState<PreferencesResponseModel>>(
            (state) => state.status == Status.loading,
          ),
          predicate<BaseState<PreferencesResponseModel>>(
            (state) =>
                state.status == Status.failure &&
                state.errorMessage == 'Server Error',
          ),
        ]),
      );

      bloc.add(const PreferencesSubmitted(
        styles: [1],
        preferredColors: [2],
      ));
    });
  });

  group('Preferences API Live Integration Test', () {
    late Dio dio;
    late ApiConsumer apiConsumer;
    late GenericDataSource genericDataSource;
    late LoginDataSource loginDataSource;
    late PreferencesDataSource preferencesDataSource;

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
      preferencesDataSource = PreferencesDataSourceImpl(genericDataSource);
    });

    test('Login and update preferences on real backend with styles=[5, 3] and preferredColors=[14, 17]', () async {
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

        final result = await preferencesDataSource.updatePreferences(
          styles: [5, 3],
          preferredColors: [14, 17],
        );

        result.fold(
          (failure) => fail('Preferences update failed: ${failure.message}'),
          (response) {
            expect(response.success, isTrue);
            expect(response.message, 'PreferencesUpdatedSuccessfully');
          },
        );
      }
    });
  });
}
