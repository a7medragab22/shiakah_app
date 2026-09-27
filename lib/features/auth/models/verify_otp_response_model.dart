import 'package:equatable/equatable.dart';
import 'login_response_model.dart';

class VerifyOtpResponseModel extends Equatable {
  final bool success;
  final AuthDataModel? data;
  final String? message;
  final dynamic errors;
  final dynamic meta;

  const VerifyOtpResponseModel({
    required this.success,
    this.data,
    this.message,
    this.errors,
    this.meta,
  });

  factory VerifyOtpResponseModel.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponseModel(
      success: json['success'] as bool? ?? false,
      data: json['data'] != null
          ? AuthDataModel.fromJson(json['data'] as Map<String, dynamic>)
          : (json.containsKey('accessToken')
              ? AuthDataModel.fromJson(json)
              : null),
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

  VerifyOtpResponseModel copyWith({
    bool? success,
    AuthDataModel? data,
    String? message,
    dynamic errors,
    dynamic meta,
  }) {
    return VerifyOtpResponseModel(
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
