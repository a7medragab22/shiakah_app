import 'package:equatable/equatable.dart';

class LoginResponseModel extends Equatable {
  final bool success;
  final AuthDataModel? data;
  final String? message;
  final dynamic errors;
  final dynamic meta;

  const LoginResponseModel({
    required this.success,
    this.data,
    this.message,
    this.errors,
    this.meta,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      success: json['success'] as bool? ?? true,
      data: json['data'] != null
          ? AuthDataModel.fromJson(json['data'] as Map<String, dynamic>)
          : (json.containsKey('accessToken') ? AuthDataModel.fromJson(json) : null),
      message: json['message'] as String?,
      errors: json['errors'],
      meta: json['meta'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data?.toJson(),
      'message': message,
      'errors': errors,
      'meta': meta,
    };
  }

  LoginResponseModel copyWith({
    bool? success,
    AuthDataModel? data,
    String? message,
    dynamic errors,
    dynamic meta,
  }) {
    return LoginResponseModel(
      success: success ?? this.success,
      data: data ?? this.data,
      message: message ?? this.message,
      errors: errors ?? this.errors,
      meta: meta ?? this.meta,
    );
  }

  @override
  List<Object?> get props => [success, data, message, errors, meta];
}

class AuthDataModel extends Equatable {
  final String accessToken;
  final String refreshToken;
  final List<String> userRoles;

  const AuthDataModel({
    required this.accessToken,
    required this.refreshToken,
    required this.userRoles,
  });

  factory AuthDataModel.fromJson(Map<String, dynamic> json) {
    return AuthDataModel(
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
      userRoles: (json['userRoles'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'userRoles': userRoles,
    };
  }

  AuthDataModel copyWith({
    String? accessToken,
    String? refreshToken,
    List<String>? userRoles,
  }) {
    return AuthDataModel(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      userRoles: userRoles ?? this.userRoles,
    );
  }

  @override
  List<Object?> get props => [accessToken, refreshToken, userRoles];
}
