import '../../../../core/http/http.dart';

class OutfitLookModel {
  final int id;
  final String top;
  final String bottom;
  final String footwear;
  final String accessories;
  final String recommendedImageUrl;
  final String searchQuery;
  final String stylingTips;
  final String summary;
  final DateTime? createdAt;

  const OutfitLookModel({
    required this.id,
    this.top = '',
    this.bottom = '',
    this.footwear = '',
    this.accessories = '',
    required this.recommendedImageUrl,
    this.searchQuery = '',
    this.stylingTips = '',
    this.summary = '',
    this.createdAt,
  });

  String get fullImageUrl {
    if (recommendedImageUrl.isEmpty) return '';
    if (recommendedImageUrl.startsWith('http://') ||
        recommendedImageUrl.startsWith('https://')) {
      return recommendedImageUrl;
    }
    final cleanBase = Endpoints.baseUrl.endsWith('/')
        ? Endpoints.baseUrl.substring(0, Endpoints.baseUrl.length - 1)
        : Endpoints.baseUrl;
    final cleanPath = recommendedImageUrl.startsWith('/')
        ? recommendedImageUrl
        : '/$recommendedImageUrl';
    return '$cleanBase$cleanPath';
  }

  factory OutfitLookModel.fromJson(Map<String, dynamic> json) {
    return OutfitLookModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      top: json['top']?.toString() ?? '',
      bottom: json['bottom']?.toString() ?? '',
      footwear: json['footwear']?.toString() ?? '',
      accessories: json['accessories']?.toString() ?? '',
      recommendedImageUrl: json['recommendedImageUrl']?.toString() ?? '',
      searchQuery: json['searchQuery']?.toString() ?? '',
      stylingTips: json['stylingTips']?.toString() ?? '',
      summary: json['summary']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'top': top,
      'bottom': bottom,
      'footwear': footwear,
      'accessories': accessories,
      'recommendedImageUrl': recommendedImageUrl,
      'searchQuery': searchQuery,
      'stylingTips': stylingTips,
      'summary': summary,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}

class MyLooksResponseModel {
  final bool? success;
  final List<OutfitLookModel> data;
  final String? message;
  final dynamic errors;
  final dynamic meta;

  const MyLooksResponseModel({
    this.success,
    this.data = const [],
    this.message,
    this.errors,
    this.meta,
  });

  factory MyLooksResponseModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final itemsList = (rawData is List)
        ? rawData
            .map((e) => OutfitLookModel.fromJson(e as Map<String, dynamic>))
            .toList()
        : <OutfitLookModel>[];

    return MyLooksResponseModel(
      success: json['success'] as bool?,
      data: itemsList,
      message: json['message'] as String?,
      errors: json['errors'],
      meta: json['meta'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.map((e) => e.toJson()).toList(),
      'message': message,
      'errors': errors,
      'meta': meta,
    };
  }
}
