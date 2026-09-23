import 'dart:convert';

/// Represents the specific clothing items identified in the image.
class FashionItems {
  final String top;
  final String bottom;
  final String footwear;
  final String accessories;

  const FashionItems({
    this.top = '',
    this.bottom = '',
    this.footwear = '',
    this.accessories = '',
  });

  /// Evaluates whether the detected items represent valid clothing.
  /// According to validation rules:
  /// If all clothing items (top, bottom, footwear) are empty, consider the image invalid (not clothes).
  bool get isClothes =>
      top.trim().isNotEmpty ||
      bottom.trim().isNotEmpty ||
      footwear.trim().isNotEmpty ||
      accessories.trim().isNotEmpty;

  /// Specifically checks if any primary apparel piece (top, bottom, footwear) is present.
  bool get hasMainApparel =>
      top.trim().isNotEmpty ||
      bottom.trim().isNotEmpty ||
      footwear.trim().isNotEmpty;

  factory FashionItems.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const FashionItems();
    return FashionItems(
      top: json['top']?.toString() ?? '',
      bottom: json['bottom']?.toString() ?? '',
      footwear: json['footwear']?.toString() ?? '',
      accessories: json['accessories']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'top': top,
        'bottom': bottom,
        'footwear': footwear,
        'accessories': accessories,
      };

  @override
  String toString() =>
      'FashionItems(top: "$top", bottom: "$bottom", footwear: "$footwear", accessories: "$accessories")';
}

/// Structured response received from the Flask `/api/chat-image` backend endpoint.
class FashionAnalysisResponse {
  final String status;
  final String summary;
  final FashionItems items;
  final String stylingTips;
  final String searchQuery;
  final String recommendedImageUrl;
  final bool isClothes;
  final String? errorMessage;

  const FashionAnalysisResponse({
    this.status = '',
    this.summary = '',
    this.items = const FashionItems(),
    this.stylingTips = '',
    this.searchQuery = '',
    this.recommendedImageUrl = '',
    required this.isClothes,
    this.errorMessage,
  });

  /// True if the HTTP call succeeded and no error was flagged.
  bool get isSuccess =>
      status.toLowerCase() == 'success' && errorMessage == null;

  /// Returns the explanation message when the image does NOT contain clothing.
  String get rejectionReason => !isClothes ? summary : '';

  factory FashionAnalysisResponse.fromJson(Map<String, dynamic> json) {
    final status = json['status']?.toString() ?? '';
    final responseMap = json['response'] is Map<String, dynamic>
        ? json['response'] as Map<String, dynamic>
        : <String, dynamic>{};

    final summary = responseMap['summary']?.toString() ?? '';
    final itemsMap = responseMap['items'] is Map<String, dynamic>
        ? responseMap['items'] as Map<String, dynamic>
        : null;

    final items = FashionItems.fromJson(itemsMap);

    // Validation rule:
    // If the image does not show clothes, top, bottom, footwear (and accessories) are empty strings.
    // If all clothing items are empty, consider the image invalid (not clothes).
    final bool isClothes = items.isClothes;

    return FashionAnalysisResponse(
      status: status,
      summary: summary,
      items: items,
      stylingTips: responseMap['styling_tips']?.toString() ?? '',
      searchQuery: responseMap['search_query']?.toString() ?? '',
      recommendedImageUrl:
          responseMap['recommended_image_url']?.toString() ?? '',
      isClothes: isClothes,
    );
  }

  factory FashionAnalysisResponse.fromStringJson(String jsonString) {
    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
    return FashionAnalysisResponse.fromJson(decoded);
  }

  factory FashionAnalysisResponse.failure(String message) {
    return FashionAnalysisResponse(
      status: 'error',
      summary: message,
      items: const FashionItems(),
      isClothes: false,
      errorMessage: message,
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'isClothes': isClothes,
        'response': {
          'summary': summary,
          'items': items.toJson(),
          'styling_tips': stylingTips,
          'search_query': searchQuery,
          'recommended_image_url': recommendedImageUrl,
        },
        if (errorMessage != null) 'errorMessage': errorMessage,
      };

  @override
  String toString() =>
      'FashionAnalysisResponse(status: $status, isClothes: $isClothes, summary: "$summary")';
}
