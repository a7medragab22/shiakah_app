part of 'local_storage.dart';
abstract interface class ITokenCache {
  Future<void> saveAccessToken(String token);
  String? getAccessToken();
  Future<void> clearAccessToken();
  Future<void> saveRefreshToken(String token);
  String? getRefreshToken();
  Future<void> clearRefreshToken();
}