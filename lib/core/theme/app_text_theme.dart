part of 'theme.dart';


mixin AppThemeData on ThemeData {
  static ThemeData light(BuildContext context) => ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: Colors.white,
      error: AppColors.notificationDot,

      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.textPrimary,
      onError: Colors.white,
      outlineVariant: AppColors.divider,
      onInverseSurface: Colors.grey[200],
    ),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme:  AppBarTheme(
        backgroundColor: Colors.white,

        titleTextStyle: AppTextTheme.headlineLarge,
        surfaceTintColor: Colors.white,
        elevation: 0
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: Colors.teal,
      selectionColor: Colors.teal,
      selectionHandleColor: Colors.teal,
    ),
    fontFamily: 'Montserrat',
    textTheme: TextTheme(
      bodyLarge: AppTextTheme.bodyLarge,
      bodyMedium: AppTextTheme.bodyMedium,
      bodySmall: AppTextTheme.bodySmall,
      labelLarge: AppTextTheme.labelLarge,
      labelMedium: AppTextTheme.labelMedium,
      labelSmall: AppTextTheme.labelSmall,
      titleLarge: AppTextTheme.titleLarge,
      titleMedium: AppTextTheme.titleMedium,
      titleSmall: AppTextTheme.titleSmall,
      displayLarge: AppTextTheme.displayLarge,
      displayMedium: AppTextTheme.displayMedium,
      displaySmall: AppTextTheme.displaySmall,
      headlineLarge: AppTextTheme.headlineLarge,
      headlineMedium: AppTextTheme.headlineMedium,
      headlineSmall: AppTextTheme.headlineSmall,
    )..apply(
      bodyColor: Colors.black,
      displayColor: Colors.black,
      fontFamilyFallback: ['Arial', 'sans-serif'],
      fontFamily: 'Montserrat',
    ),

    inputDecorationTheme: InputDecorationTheme(
      errorStyle: AppTextTheme.bodyMedium.copyWith(color: Colors.red,fontSize: 20.sp),
    ),
    // textSelectionTheme: ,
    iconTheme: const IconThemeData(
      color: Colors.white,
    ),

  );
}