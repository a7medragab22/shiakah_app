import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:shiakah/core/bloc/paginated_bloc/exports.dart';
import 'package:shiakah/core/enum/status.dart';
import 'package:shiakah/core/helpers/helpers.dart';
import 'package:shiakah/core/http/either.dart';
import 'package:shiakah/core/http/failure.dart';
import 'package:shiakah/core/http/http.dart';
import 'package:shiakah/core/local_storage/local_storage.dart';
import 'package:shiakah/core/router/router.dart';
import 'package:shiakah/features/auth/auth.dart';

class FakeOnboardingStatusDataSource implements OnboardingStatusDataSource {
  final bool shouldSucceed;
  final String? errorMessage;
  final OnboardingStatusResponseModel? response;

  FakeOnboardingStatusDataSource({
    this.shouldSucceed = true,
    this.errorMessage,
    this.response,
  });

  @override
  Future<Either<Failure, OnboardingStatusResponseModel>> getStatus() async {
    await Future.delayed(const Duration(milliseconds: 10));
    if (shouldSucceed) {
      return Right(
        response ??
            const OnboardingStatusResponseModel(
              success: true,
              data: OnboardingStatusData(
                currentStep: 6,
                completed: true,
                profile: OnboardingProfileData(
                  gender: "Male",
                  ageRange: "From18To24",
                  skinTone: "Tan",
                  height: 180.0,
                  weight: 80.0,
                  bodyType: "Regular",
                  name: "Ahmed Ragab",
                  location: "Egypt, Cairo",
                ),
              ),
              message: "OnboardingStatusRetrievedSuccessfully",
            ),
      );
    } else {
      return Left(ServerFailure(message: errorMessage ?? 'Server Error'));
    }
  }

  @override
  Future<String> resolveTargetRouteAndSync() async {
    final result = await getStatus();
    return result.fold(
      (failure) => Routes.welcome,
      (resp) => resp.data?.targetRoute ?? Routes.home,
    );
  }
}

void main() {
  late Directory tempDir;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    tempDir = await Directory.systemTemp.createTemp('hive_status_test_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserModelAdapter());
    }
    final userBox = await Hive.openBox<UserModel>('user_box');
    final tokenBox = await Hive.openBox<String>('token_box');
    await Hive.openBox('settings_box');
    await HiveServiceImpl.init(userBox, tokenBox);
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });
  group('Onboarding Status Models Tests', () {
    test('OnboardingStatusResponseModel deserializes exact user response correctly', () {
      final jsonResponse = {
        "success": true,
        "data": {
          "currentStep": 6,
          "completed": true,
          "profile": {
            "gender": "Male",
            "ageRange": "From18To24",
            "skinTone": "Tan",
            "height": 180.00,
            "weight": 80.00,
            "bodyType": "Regular",
            "name": "Ahmed Ragab",
            "location": "Egypt, Cairo"
          }
        },
        "message": "OnboardingStatusRetrievedSuccessfully",
        "errors": null,
        "meta": null
      };

      final model = OnboardingStatusResponseModel.fromJson(jsonResponse);

      expect(model.success, isTrue);
      expect(model.message, 'OnboardingStatusRetrievedSuccessfully');
      expect(model.data, isNotNull);
      expect(model.data!.currentStep, 6);
      expect(model.data!.completed, isTrue);
      expect(model.data!.targetRoute, Routes.home);

      final profile = model.data!.profile!;
      expect(profile.gender, 'Male');
      expect(profile.ageRange, 'From18To24');
      expect(profile.skinTone, 'Tan');
      expect(profile.height, 180.0);
      expect(profile.weight, 80.0);
      expect(profile.bodyType, 'Regular');
      expect(profile.name, 'Ahmed Ragab');
      expect(profile.location, 'Egypt, Cairo');
    });

    test('OnboardingStatusData targetRoute maps all steps accurately', () {
      expect(
        const OnboardingStatusData(currentStep: 1, completed: false).targetRoute,
        Routes.genderSelection,
      );
      expect(
        const OnboardingStatusData(currentStep: 2, completed: false).targetRoute,
        Routes.personalInfo,
      );
      expect(
        const OnboardingStatusData(currentStep: 3, completed: false).targetRoute,
        Routes.bodyType,
      );
      expect(
        const OnboardingStatusData(currentStep: 4, completed: false).targetRoute,
        Routes.defineStyle,
      );
      expect(
        const OnboardingStatusData(currentStep: 5, completed: false).targetRoute,
        Routes.completeProfile,
      );
      expect(
        const OnboardingStatusData(currentStep: 6, completed: false).targetRoute,
        Routes.home,
      );
      // Completed flag overrides step
      expect(
        const OnboardingStatusData(currentStep: 2, completed: true).targetRoute,
        Routes.home,
      );
      // Fallback for step 0
      expect(
        const OnboardingStatusData(currentStep: 0, completed: false).targetRoute,
        Routes.genderSelection,
      );
    });

    test('toJson produces valid map structure', () {
      const data = OnboardingStatusData(
        currentStep: 3,
        completed: false,
        profile: OnboardingProfileData(
          name: "Test User",
          location: "Cairo",
          gender: "Male",
        ),
      );

      final json = data.toJson();
      expect(json['currentStep'], 3);
      expect(json['completed'], isFalse);
      expect(json['profile']['name'], 'Test User');
      expect(json['profile']['location'], 'Cairo');
      expect(json['profile']['gender'], 'Male');
    });
  });

  group('OnboardingStatusBloc Tests', () {
    test('emits loading then success when data source returns success', () async {
      final fakeDataSource = FakeOnboardingStatusDataSource(shouldSucceed: true);
      final bloc = OnboardingStatusBloc(fakeDataSource);

      final expectedStates = [
        const BaseState<OnboardingStatusResponseModel>(status: Status.loading),
        predicate<BaseState<OnboardingStatusResponseModel>>((state) {
          return state.status == Status.success &&
              state.data?.data?.currentStep == 6 &&
              state.data?.data?.completed == true &&
              state.data?.data?.profile?.name == 'Ahmed Ragab';
        }),
      ];

      expectLater(bloc.stream, emitsInOrder(expectedStates));

      bloc.add(const OnboardingStatusRequested());
    });

    test('emits loading then failure when data source returns failure', () async {
      final fakeDataSource = FakeOnboardingStatusDataSource(
        shouldSucceed: false,
        errorMessage: 'Unauthorized',
      );
      final bloc = OnboardingStatusBloc(fakeDataSource);

      final expectedStates = [
        const BaseState<OnboardingStatusResponseModel>(status: Status.loading),
        predicate<BaseState<OnboardingStatusResponseModel>>((state) {
          return state.status == Status.failure &&
              state.errorMessage == 'Unauthorized';
        }),
      ];

      expectLater(bloc.stream, emitsInOrder(expectedStates));

      bloc.add(const OnboardingStatusRequested());
    });
  });

  group('Endpoints and DataSource Tests', () {
    test('Endpoints.onboardingStatus has correct path', () {
      expect(Endpoints.onboardingStatus, '/api/Onboarding/status');
    });

    test('OnboardingStatusDataSourceImpl calls genericDataSource with proper endpoint', () async {
      final dio = Dio(
        BaseOptions(
          baseUrl: 'https://shiakah.runasp.net',
          headers: {'Authorization': 'Bearer test_token'},
        ),
      );

      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.path, '/api/Onboarding/status');
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  "success": true,
                  "data": {
                    "currentStep": 4,
                    "completed": false,
                    "profile": {
                      "gender": "Male",
                      "bodyType": "Regular",
                      "name": "Ahmed",
                      "location": "Cairo"
                    }
                  },
                  "message": "OnboardingStatusRetrievedSuccessfully",
                  "errors": null,
                  "meta": null
                },
              ),
            );
          },
        ),
      );

      final apiConsumer = BaseApiConsumer(dio: dio);
      final genericDataSource = GenericDataSource(apiConsumer);
      final dataSource = OnboardingStatusDataSourceImpl(genericDataSource);

      final result = await dataSource.getStatus();

      result.fold(
        (failure) => fail('Expected right but got $failure'),
        (response) {
          expect(response.success, isTrue);
          expect(response.data?.currentStep, 4);
          expect(response.data?.completed, isFalse);
          expect(response.data?.targetRoute, Routes.defineStyle);
          expect(response.data?.profile?.name, 'Ahmed');
        },
      );
    });
  });
}
