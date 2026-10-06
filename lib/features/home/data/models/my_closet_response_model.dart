import '../../../../core/http/http.dart';

class WardrobeItemModel {
  final int id;
  final String imageUrl;
  final dynamic attributes;
  final DateTime? createdAt;

  const WardrobeItemModel({
    required this.id,
    required this.imageUrl,
    this.attributes,
    this.createdAt,
  });

  String get fullImageUrl {
    if (imageUrl.isEmpty) return '';
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }
    final cleanBase = Endpoints.baseUrl.endsWith('/')
        ? Endpoints.baseUrl.substring(0, Endpoints.baseUrl.length - 1)
        : Endpoints.baseUrl;
    final cleanPath = imageUrl.startsWith('/') ? imageUrl : '/$imageUrl';
    return '$cleanBase$cleanPath';
  }

  factory WardrobeItemModel.fromJson(Map<String, dynamic> json) {
    return WardrobeItemModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      imageUrl: json['imageUrl']?.toString() ?? '',
      attributes: json['attributes'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'attributes': attributes,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}

class MyClosetDataModel {
  final int id;
  final List<WardrobeItemModel> items;

  const MyClosetDataModel({
    required this.id,
    required this.items,
  });

  factory MyClosetDataModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final itemsList = (rawItems is List)
        ? rawItems
            .map((e) => WardrobeItemModel.fromJson(e as Map<String, dynamic>))
            .toList()
        : <WardrobeItemModel>[];

    return MyClosetDataModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      items: itemsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}

class MyClosetResponseModel {
  final bool? success;
  final MyClosetDataModel? data;
  final String? message;
  final dynamic errors;
  final dynamic meta;

  const MyClosetResponseModel({
    this.success,
    this.data,
    this.message,
    this.errors,
    this.meta,
  });

  factory MyClosetResponseModel.fromJson(Map<String, dynamic> json) {
    return MyClosetResponseModel(
      success: json['success'] as bool?,
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? MyClosetDataModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
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
}
