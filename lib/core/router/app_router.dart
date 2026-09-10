part of 'router.dart';

abstract interface class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: Routes.initial,
    routes: [
      GoRoute(
        path: Routes.initial,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: Routes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: Routes.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: Routes.register,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: Routes.verifyOtp,
        builder: (context, state) => const VerifyOtpScreen(),
      ),
      GoRoute(
        path: Routes.styleSetup,
        builder: (context, state) => const StyleSetupScreen(),
      ),
      GoRoute(
        path: Routes.genderSelection,
        builder: (context, state) => const GenderSelectionScreen(),
      ),
      GoRoute(
        path: Routes.personalInfo,
        builder: (context, state) => const PersonalInfoScreen(),
      ),
      GoRoute(
        path: Routes.bodyType,
        builder: (context, state) => const BodyTypeScreen(),
      ),
      GoRoute(
        path: Routes.defineStyle,
        builder: (context, state) => const DefineStyleScreen(),
      ),
      GoRoute(
        path: Routes.completeProfile,
        builder: (context, state) => const CompleteProfileScreen(),
      ),
      GoRoute(
        path: Routes.home,
        builder: (context, state) => const MainNavigationScreen(),
      ),
      GoRoute(
        path: Routes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: Routes.itemDetails,
        builder: (context, state) => const ItemDetailsScreen(),
      ),
    ],
  );

  static Widget getRootApp({
    required BuildContext context,
    required GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey,
  }) {
    final bool isIOS = Platform.isIOS || Platform.isMacOS;

    if (isIOS) {
      return CupertinoApp.router(
        routerConfig: router,
        theme: const CupertinoThemeData(brightness: Brightness.light),
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
      );
    } else {
      return MaterialApp.router(
        scaffoldMessengerKey: scaffoldMessengerKey,
        routerConfig: router,
        title: 'Flutter Demo',
        theme: ThemeData.light(),
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
      );
    }
  }
}
