import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiakah/core/bloc/paginated_bloc/exports.dart';
import 'package:shiakah/core/enum/status.dart';
import 'package:shiakah/core/helpers/helpers.dart';
import 'package:shiakah/core/http/either.dart';
import 'package:shiakah/core/http/failure.dart';
import 'package:shiakah/core/http/http.dart';
import 'package:shiakah/features/auth/auth.dart';

class FakeOnboardingProfileDataSource implements OnboardingProfileDataSource {
  final bool shouldSucceed;
  final String? errorMessage;

  FakeOnboardingProfileDataSource({
    this.shouldSucceed = true,
    this.errorMessage,
  });

  @override
  Future<Either<Failure, OnboardingProfileResponseModel>> updateProfile({
    required String name,
    required String location,
  }) async {
    await Future.delayed(const Duration(milliseconds: 10));
    if (shouldSucceed) {
      return Right(
        const OnboardingProfileResponseModel(
          success: true,
          message: 'OnboardingCompletedSuccessfully',
          data: null,
        ),
      );
    } else {
      return Left(
        ServerFailure(message: errorMessage ?? 'Server Error'),
      );
    }
  }
}

void main() {
  group('Onboarding Profile Models Tests', () {
    test('OnboardingProfileRequestModel serializes JSON correctly', () {
      const model = OnboardingProfileRequestModel(
        name: 'Ahmed Ragab',
        location: 'Egypt, Cairo',
      );

      final json = model.toJson();
      expect(json['name'], 'Ahmed Ragab');
      expect(json['location'], 'Egypt, Cairo');
    });

    test('OnboardingProfileResponseModel deserializes backend response correctly', () {
      final jsonResponse = {
        "success": true,
        "data": null,
        "message": "OnboardingCompletedSuccessfully",
        "errors": null,
        "meta": null,
      };

      final model = OnboardingProfileResponseModel.fromJson(jsonResponse);
      expect(model.success, isTrue);
      expect(model.message, 'OnboardingCompletedSuccessfully');
      expect(model.data, isNull);
    });

    test('OnboardingProfileBloc emits loading then success on OnboardingProfileSubmitted', () async {
      final bloc = OnboardingProfileBloc(
        FakeOnboardingProfileDataSource(shouldSucceed: true),
      );

      expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<BaseState<OnboardingProfileResponseModel>>(
            (state) => state.status == Status.loading,
          ),
          predicate<BaseState<OnboardingProfileResponseModel>>(
            (state) =>
                state.status == Status.success &&
                state.data?.message == 'OnboardingCompletedSuccessfully',
          ),
        ]),
      );

      bloc.add(const OnboardingProfileSubmitted(
        name: 'Ahmed Ragab',
        location: 'Egypt, Cairo',
      ));
    });

    test('OnboardingProfileBloc emits loading then failure on error', () async {
      final bloc = OnboardingProfileBloc(
        FakeOnboardingProfileDataSource(
          shouldSucceed: false,
          errorMessage: 'Server Error',
        ),
      );

      expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<BaseState<OnboardingProfileResponseModel>>(
            (state) => state.status == Status.loading,
          ),
          predicate<BaseState<OnboardingProfileResponseModel>>(
            (state) =>
                state.status == Status.failure &&
                state.errorMessage == 'Server Error',
          ),
        ]),
      );

      bloc.add(const OnboardingProfileSubmitted(
        name: 'Ahmed Ragab',
        location: 'Egypt, Cairo',
      ));
    });
  });

  group('Onboarding Profile API Live Integration Test', () {
    late Dio dio;
    late ApiConsumer apiConsumer;
    late GenericDataSource genericDataSource;
    late LoginDataSource loginDataSource;
    late OnboardingProfileDataSource profileDataSource;

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
      profileDataSource = OnboardingProfileDataSourceImpl(genericDataSource);
    });

    test('Login and update profile on real backend with name and location', () async {
      final loginResult = await loginDataSource.login(
        email: 'muhvmd.anwerr24@gmail.com',
        password: 'Muhvmd_44',
      );

      String? token;
      loginResult.fold(
        (failure) => null,
        (response) => token = response.data?.accessToken,
      );

      token ??= "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...";

      dio.options.headers['Authorization'] = 'Bearer $token';

      final profileResult = await profileDataSource.updateProfile(
        name: 'Ahmed Ragab',
        location: 'Egypt, Cairo',
      );

      profileResult.fold(
        (failure) {
          fail('Failed to update profile: ${failure.message}');
        },
        (response) {
          expect(response.success, isTrue);
          expect(response.message, contains('OnboardingCompletedSuccessfully'));
        },
      );
    });
  });
}
