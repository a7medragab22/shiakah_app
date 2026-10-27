class RemoveItemResponseModel {
  final bool? success;
  final dynamic data;
  final String? message;
  final dynamic errors;
  final dynamic meta;

  const RemoveItemResponseModel({
    this.success,
    this.data,
    this.message,
    this.errors,
    this.meta,
  });

  factory RemoveItemResponseModel.fromJson(Map<String, dynamic> json) {
    return RemoveItemResponseModel(
      success: json['success'] as bool?,
      data: json['data'],
      message: json['message']?.toString(),
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
}
