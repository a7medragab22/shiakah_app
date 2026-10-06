import 'package:equatable/equatable.dart';

class OnboardingProfileResponseModel extends Equatable {
  final bool success;
  final dynamic data;
  final String? message;
  final dynamic errors;
  final dynamic meta;

  const OnboardingProfileResponseModel({
    required this.success,
    this.data,
    this.message,
    this.errors,
    this.meta,
  });

  factory OnboardingProfileResponseModel.fromJson(Map<String, dynamic> json) {
    return OnboardingProfileResponseModel(
      success: json['success'] as bool? ?? true,
      data: json['data'],
      message: json['message'] as String?,
      errors: json['errors'],
      meta: json['meta'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data,
      'message': message,
      'errors': errors,
      'meta': meta,
    };
  }

  OnboardingProfileResponseModel copyWith({
    bool? success,
    dynamic data,
    String? message,
    dynamic errors,
    dynamic meta,
  }) {
    return OnboardingProfileResponseModel(
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
