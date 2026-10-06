import 'package:equatable/equatable.dart';

class RegisterResponseModel extends Equatable {
  final bool success;
  final String? message;
  final dynamic data;
  final dynamic errors;
  final dynamic meta;

  const RegisterResponseModel({
    required this.success,
    this.message,
    this.data,
    this.errors,
    this.meta,
  });

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    return RegisterResponseModel(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      data: json['data'],
      errors: json['errors'],
      meta: json['meta'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data,
      'errors': errors,
      'meta': meta,
    };
  }

  RegisterResponseModel copyWith({
    bool? success,
    String? message,
    dynamic data,
    dynamic errors,
    dynamic meta,
  }) {
    return RegisterResponseModel(
      success: success ?? this.success,
      message: message ?? this.message,
      data: data ?? this.data,
      errors: errors ?? this.errors,
      meta: meta ?? this.meta,
    );
  }

  @override
  List<Object?> get props => [success, message, data, errors, meta];
}
