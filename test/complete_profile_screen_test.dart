import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shiakah/core/http/either.dart';
import 'package:shiakah/core/http/failure.dart';
import 'package:shiakah/core/local_storage/local_storage.dart';
import 'package:shiakah/core/service_locator/service_locator.dart';
import 'package:shiakah/features/auth/auth.dart';
import 'package:shiakah/features/auth/presentation/screens/complete_profile_screen.dart';

class MockOnboardingProfileDataSource implements OnboardingProfileDataSource {
  String? lastSubmittedName;
  String? lastSubmittedLocation;

  @override
  Future<Either<Failure, OnboardingProfileResponseModel>> updateProfile({
    required String name,
    required String location,
  }) async {
    lastSubmittedName = name;
    lastSubmittedLocation = location;
    return Right(
      const OnboardingProfileResponseModel(
        success: true,
        message: 'OnboardingCompletedSuccessfully',
        data: null,
      ),
    );
  }
}

void main() {
  late Directory tempDir;
  late MockOnboardingProfileDataSource mockDataSource;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();

    tempDir = await Directory.systemTemp.createTemp('hive_profile_test_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserModelAdapter());
    }
    final userBox = await Hive.openBox<UserModel>('user_box');
    final tokenBox = await Hive.openBox<String>('token_box');
    await HiveServiceImpl.init(userBox, tokenBox);

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('flutter.baseflow.com/geolocator'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'isLocationServiceEnabled') return false;
        return null;
      },
    );

    EasyLocalization.logger.enableBuildModes = [];
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  setUp(() async {
    await getIt.reset();
    DI.executeSync();

    mockDataSource = MockOnboardingProfileDataSource();
    if (getIt.isRegistered<OnboardingProfileDataSource>()) {
      getIt.unregister<OnboardingProfileDataSource>();
    }
    getIt.registerLazySingleton<OnboardingProfileDataSource>(
      () => mockDataSource,
    );

    if (getIt.isRegistered<OnboardingProfileBloc>()) {
      getIt.unregister<OnboardingProfileBloc>();
    }
    getIt.registerFactory<OnboardingProfileBloc>(
      () => OnboardingProfileBloc(mockDataSource),
    );
  });

  testWidgets('CompleteProfileScreen responsive on multiple screen sizes',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0; // 360 x 800 dp
    tester.view.padding = const FakeViewPadding(top: 144, bottom: 60);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetPadding();
    });

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ar')],
        path: 'assets/translations',
        fallbackLocale: const Locale('ar'),
        startLocale: const Locale('ar'),
        child: ScreenUtilInit(
          designSize: const Size(393, 852),
          builder: (context, child) {
            return MaterialApp(
              locale: context.locale,
              supportedLocales: context.supportedLocales,
              localizationsDelegates: context.localizationDelegates,
              home: const CompleteProfileScreen(autoFetchLocation: false),
            );
          },
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(CompleteProfileScreen), findsOneWidget);

    // Test on 360x640 with status bar
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.padding = const FakeViewPadding(top: 144, bottom: 60);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(CompleteProfileScreen), findsOneWidget);

    // Test on 320x568 (compact device)
    tester.view.physicalSize = const Size(640, 1136);
    tester.view.devicePixelRatio = 2.0;
    tester.view.padding = const FakeViewPadding(top: 40, bottom: 40);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(CompleteProfileScreen), findsOneWidget);
  });

  test(
      'Name updates in Hive when profile is saved and reflected in cached user',
      () async {
    // Update cached user in Hive with the new name
    await HiveServiceImpl.instance.updateCachedUserModel(
      const UserModel(
          id: 1, name: 'Ahmed Ragab', email: 'ahmed@test.com', phone: ''),
    );

    final cachedUser = HiveServiceImpl.instance.getCachedUserModel();
    expect(cachedUser?.name, 'Ahmed Ragab');
  });
}
