import 'package:equatable/equatable.dart';

class AppearanceResponseModel extends Equatable {
  final bool success;
  final dynamic data;
  final String? message;
  final dynamic errors;
  final dynamic meta;

  const AppearanceResponseModel({
    required this.success,
    this.data,
    this.message,
    this.errors,
    this.meta,
  });

  factory AppearanceResponseModel.fromJson(Map<String, dynamic> json) {
    return AppearanceResponseModel(
      success: json['success'] as bool? ?? false,
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

  @override
  List<Object?> get props => [success, data, message, errors, meta];
}
