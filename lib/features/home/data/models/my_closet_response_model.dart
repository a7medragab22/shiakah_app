import 'dart:convert';
import '../../../../core/http/http.dart';

class ItemAttributesModel {
  final String? category;
  final String? color;
  final String? fit;
  final String? style;
  final String? season;
  final String? pattern;

  const ItemAttributesModel({
    this.category,
    this.color,
    this.fit,
    this.style,
    this.season,
    this.pattern,
  });

  factory ItemAttributesModel.fromJson(dynamic rawJson) {
    dynamic json = rawJson;
    if (json is String && json.trim().startsWith('{')) {
      try {
        json = jsonDecode(json);
      } catch (_) {}
    }
    if (json == null || json is! Map) {
      return const ItemAttributesModel();
    }
    return ItemAttributesModel(
      category: json['category']?.toString() ??
          json['Category']?.toString() ??
          json['subcategory']?.toString() ??
          json['Subcategory']?.toString(),
      color: json['color']?.toString() ??
          json['Color']?.toString() ??
          json['dominantColor']?.toString() ??
          json['DominantColor']?.toString(),
      fit: json['fit']?.toString() ?? json['Fit']?.toString(),
      style: json['style']?.toString() ?? json['Style']?.toString(),
      season: json['season']?.toString() ?? json['Season']?.toString(),
      pattern: json['pattern']?.toString() ?? json['Pattern']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'category': category,
        'color': color,
        'fit': fit,
        'style': style,
        'season': season,
        'pattern': pattern,
      };
}

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

  ItemAttributesModel get parsedAttributes =>
      ItemAttributesModel.fromJson(attributes);

  bool get isTop {
    final cat = (parsedAttributes.category ?? '').toLowerCase().trim();
    const topKeywords = [
      't-shirt',
      'shirt',
      'tee',
      'top',
      'sweater',
      'polo',
      'henley',
      'tank',
      'hoodie',
      'blouse',
      'cardigan',
      'sweatshirt',
      'jacket',
      'coat',
      'blazer',
      'pullover',
      'تيشيرت',
      'قميص',
      'بلوزة',
      'سويت شيرت',
      'هودي',
      'توب',
      'جاكيت',
      'بلوفر',
    ];

    if (topKeywords.any((kw) => cat.contains(kw))) {
      return true;
    }

    const bottomKeywords = [
      'pant',
      'trouser',
      'jean',
      'short',
      'skirt',
      'bottom',
      'chino',
      'jogger',
      'cargo',
      'legging',
      'slack',
      'sweatpant',
      'wide-leg',
      'straight-leg',
      'بنطلون',
      'بنطال',
      'جينز',
      'شورت',
      'سروال',
      'برمودا',
      'تنورة',
      'جيبة',
    ];

    if (bottomKeywords.any((kw) => cat.contains(kw))) {
      return false;
    }

    final url = imageUrl.toLowerCase().trim();
    final rawAttr = attributes?.toString().toLowerCase() ?? '';
    return topKeywords.any((kw) => url.contains(kw) || rawAttr.contains(kw));
  }

  bool get isBottom {
    final cat = (parsedAttributes.category ?? '').toLowerCase().trim();
    const bottomKeywords = [
      'pant',
      'trouser',
      'jean',
      'short',
      'skirt',
      'bottom',
      'chino',
      'jogger',
      'cargo',
      'legging',
      'slack',
      'sweatpant',
      'wide-leg',
      'straight-leg',
      'بنطلون',
      'بنطال',
      'جينز',
      'شورت',
      'سروال',
      'برمودا',
      'تنورة',
      'جيبة',
    ];

    if (bottomKeywords.any((kw) => cat.contains(kw))) {
      return true;
    }

    const topKeywords = [
      't-shirt',
      'shirt',
      'tee',
      'top',
      'sweater',
      'polo',
      'henley',
      'tank',
      'hoodie',
      'blouse',
      'cardigan',
      'sweatshirt',
      'jacket',
      'coat',
      'blazer',
      'pullover',
      'تيشيرت',
      'قميص',
      'بلوزة',
      'سويت شيرت',
      'هودي',
      'توب',
      'جاكيت',
      'بلوفر',
    ];

    if (topKeywords.any((kw) => cat.contains(kw))) {
      return false;
    }

    final url = imageUrl.toLowerCase().trim();
    final rawAttr = attributes?.toString().toLowerCase() ?? '';
    return bottomKeywords.any((kw) => url.contains(kw) || rawAttr.contains(kw));
  }

  bool get isFootwear {
    final cat = (parsedAttributes.category ?? '').toLowerCase();
    final url = imageUrl.toLowerCase();
    return cat.contains('shoe') ||
        cat.contains('sneaker') ||
        cat.contains('boot') ||
        cat.contains('loafer') ||
        cat.contains('footwear') ||
        cat.contains('حذاء') ||
        cat.contains('كوتشي') ||
        url.contains('shoe') ||
        url.contains('sneaker');
  }

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
      imageUrl: json['imageUrl']?.toString() ??
          json['ImageUrl']?.toString() ??
          json['image']?.toString() ??
          json['Image']?.toString() ??
          '',
      attributes: json['attributes'] ?? json['Attributes'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : (json['CreatedAt'] != null
              ? DateTime.tryParse(json['CreatedAt'].toString())
              : null),
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
