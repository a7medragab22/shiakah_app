import 'package:shiakah/database/models/attribute_source.dart';

/// Attribute key for the dominant color; matches `wardrobe_item.dominant_color`
/// and the `item_attribute.attribute_key` row written for it.
const String kDominantColorKey = 'dominantColor';

/// Minimum acceptable per-field confidence. Any attribute whose recorded
/// confidence drops strictly below this value flags the scan result via
/// [ItemAttributes.isLowConfidence], telling the UI to prompt the user for
/// confirmation.
///
/// **Single config knob.** This is the one value that controls the promotion
/// of the confirmation screen; change it here and only here.
const double kLowConfidenceThreshold = 0.20;

/// The scanner's attribute output for a single photo.
///
/// A plain value object (no database dependency) so it can flow straight to the
/// confirmation UI and be persisted later. The scanner always
/// produces [AttributeSource.ai]; a user edit flips a field to
/// [AttributeSource.userConfirmed] / [AttributeSource.userCorrected] via
/// [withField].
class ItemAttributes {
  const ItemAttributes({
    this.category,
    this.subcategory,
    this.style,
    this.season,
    this.dominantColor,
    this.dominantColorAr,
    this.confidences = const {},
    this.source = AttributeSource.ai,
    this.isClothing = true,
  });

  final bool isClothing;

  /// Attribute keys in display / persistence order.
  static const List<String> attributeKeys = <String>[
    'category',
    'subcategory',
    'style',
    'season',
    kDominantColorKey,
  ];

  final String? category;
  final String? subcategory;
  final String? style;
  final String? season;

  /// English palette name (see `ColorPalette`), e.g. `red`.
  final String? dominantColor;

  /// Arabic palette name, e.g. `أحمر`; display-only, never stored.
  final String? dominantColorAr;

  /// Per-field confidence in [0, 1], keyed by [attributeKeys] entries.
  final Map<String, double> confidences;

  /// Provenance applied to every field.
  final AttributeSource source;

  /// Non-null attributes keyed by [attributeKeys] order.
  Map<String, String> get attributes {
    final out = <String, String>{};
    for (final key in attributeKeys) {
      final value = valueOf(key);
      if (value != null) out[key] = value;
    }
    return out;
  }

  bool get isEmpty => attributes.isEmpty;

  /// Value of the attribute named [key], or null when unknown/absent.
  String? valueOf(String key) => switch (key) {
        'category' => category,
        'subcategory' => subcategory,
        'style' => style,
        'season' => season,
        'dominantColor' => dominantColor,
        _ => null,
      };

  /// Confidence of [key], or null when no confidence was recorded.
  double? confidenceOf(String key) => confidences[key];

  /// Realistic confidence threshold per attribute dimension.
  /// Over 36 categories, uniform random probability is ~0.027.
  static double thresholdFor(String key) => switch (key) {
        'category' => 0.18,
        'subcategory' => 0.20,
        'style' => 0.15,
        'season' => 0.18,
        kDominantColorKey => 0.08,
        _ => kLowConfidenceThreshold,
      };

  /// Attribute keys whose recorded confidence is strictly below their threshold.
  List<String> get lowConfidenceFields => <String>[
        for (final key in attributeKeys)
          if (confidenceOf(key) != null &&
              confidenceOf(key)! < thresholdFor(key))
            key,
      ];

  /// Whether the scan needs user review for secondary attributes.
  bool get isLowConfidence => lowConfidenceFields.isNotEmpty;

  /// Whether the scan confirmed a valid clothing item.
  /// A valid clothing item must be verified as clothing and have a recognized category.
  bool get isValidClothing =>
      isClothing &&
      category != null &&
      category!.trim().isNotEmpty &&
      category != 'non-clothing item' &&
      category != 'digital graphic or illustration' &&
      (confidenceOf('category') == null || confidenceOf('category')! >= 0.12);

  /// A copy with [key] replaced by [value] and provenance set to [source].
  ItemAttributes withField(
    String key,
    String? value, {
    AttributeSource source = AttributeSource.userCorrected,
  }) {
    switch (key) {
      case 'category':
        return copyWith(category: value, source: source);
      case 'subcategory':
        return copyWith(subcategory: value, source: source);
      case 'style':
        return copyWith(style: value, source: source);
      case 'season':
        return copyWith(season: value, source: source);
      case 'dominantColor':
        return copyWith(dominantColor: value, source: source);
      default:
        return this;
    }
  }

  ItemAttributes copyWith({
    String? category,
    String? subcategory,
    String? style,
    String? season,
    String? dominantColor,
    String? dominantColorAr,
    Map<String, double>? confidences,
    AttributeSource? source,
    bool? isClothing,
  }) {
    return ItemAttributes(
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      style: style ?? this.style,
      season: season ?? this.season,
      dominantColor: dominantColor ?? this.dominantColor,
      dominantColorAr: dominantColorAr ?? this.dominantColorAr,
      confidences: confidences ?? this.confidences,
      source: source ?? this.source,
      isClothing: isClothing ?? this.isClothing,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ItemAttributes &&
      other.category == category &&
      other.subcategory == subcategory &&
      other.style == style &&
      other.season == season &&
      other.dominantColor == dominantColor &&
      other.dominantColorAr == dominantColorAr &&
      other.source == source &&
      _mapEquals(other.confidences, confidences);

  @override
  int get hashCode => Object.hash(
        category,
        subcategory,
        style,
        season,
        dominantColor,
        dominantColorAr,
        source,
        Object.hashAll(
          confidences.entries.map((e) => Object.hash(e.key, e.value)),
        ),
      );

  @override
  String toString() {
    final body =
        attributes.entries.map((e) => '${e.key}=${e.value}').join(', ');
    return 'ItemAttributes($body)';
  }
}

bool _mapEquals(Map<String, double> a, Map<String, double> b) {
  if (a.length != b.length) return false;
  for (final entry in a.entries) {
    if (b[entry.key] != entry.value) return false;
  }
  return true;
}
