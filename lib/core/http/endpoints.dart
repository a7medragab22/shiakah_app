part of 'http.dart';
abstract interface class Endpoints {
  static const String baseUrl = 'https://shiakah.runasp.net';
  static const String auth = '/auth';
  static const String user = '/user';
  static const String product = '/product';
  static const String order = '/order';
  static const String cart = '/cart';
  static const String payment = '/payment';
  static const String notification = '/notification';
  static const String setting = '/setting';
  static const String help = '/help';
  static const String about = '/about';
  static const String contact = '/contact';
  static const String forgetPassword = "/forget-password";
  static const String login = "/api/Auth/login";
  static const String register = "/api/Auth/register";
  static const String verifyRegistrationOtp = "/api/Auth/verify-registration-otp";
  static const String gender = "/api/Onboarding/gender";
  static const String appearance = "/api/Onboarding/appearance";
  static const String body = "/api/Onboarding/body";
  static const String preferences = "/api/Onboarding/preferences";
  static const String onboardingProfile = "/api/Onboarding/profile";
  static const String onboardingStatus = "/api/Onboarding/status";
  static const String logout = "/logout";
}