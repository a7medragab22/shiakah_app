import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiakah/features/auth/presentation/screens/gender_selection_screen.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('GenderSelectionScreen responsive on multiple screen sizes', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0; // 360 x 800 dp
    tester.view.padding = const FakeViewPadding(top: 144, bottom: 60); // 48dp top, 20dp bottom
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetPadding();
    });

    EasyLocalization.logger.enableBuildModes = [];

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
              home: const GenderSelectionScreen(),
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(GenderSelectionScreen), findsOneWidget);

    // Test on 360x640 with status bar
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.padding = const FakeViewPadding(top: 144, bottom: 60);
    await tester.pumpAndSettle();
    expect(find.byType(GenderSelectionScreen), findsOneWidget);

    // Test on 320x568 (compact device)
    tester.view.physicalSize = const Size(640, 1136);
    tester.view.devicePixelRatio = 2.0;
    tester.view.padding = const FakeViewPadding(top: 40, bottom: 40);
    await tester.pumpAndSettle();
    expect(find.byType(GenderSelectionScreen), findsOneWidget);
  });
}
