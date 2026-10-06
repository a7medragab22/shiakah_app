class AddToClosetResponseModel {
  final bool? success;
  final int? data;
  final String? message;
  final dynamic errors;
  final dynamic meta;

  const AddToClosetResponseModel({
    this.success,
    this.data,
    this.message,
    this.errors,
    this.meta,
  });

  factory AddToClosetResponseModel.fromJson(Map<String, dynamic> json) {
    int? parsedId;
    if (json['data'] is int) {
      parsedId = json['data'] as int;
    } else if (json['data'] != null) {
      parsedId = int.tryParse(json['data'].toString());
    }

    return AddToClosetResponseModel(
      success: json['success'] as bool?,
      data: parsedId,
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
}
