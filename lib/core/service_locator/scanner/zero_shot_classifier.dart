import 'dart:math' as math;
import 'dart:typed_data';

/// The four attribute dimensions a wardrobe scan classifies.
enum ScanAttribute {
  category('category'),
  subcategory('subcategory'),
  style('style'),
  season('season');

  const ScanAttribute(this.key);

  /// Stable key used for DB attribute rows (`item_attribute.attribute_key`).
  final String key;

  static const List<ScanAttribute> valuesAll = [
    ScanAttribute.category,
    ScanAttribute.subcategory,
    ScanAttribute.style,
    ScanAttribute.season,
  ];
}

/// A single label with its softmax probability.
class ScoredLabel {
  const ScoredLabel(this.label, this.probability);

  final String label;
  final double probability;

  @override
  String toString() => '$label (${(probability * 100).toStringAsFixed(2)}%)';
}

/// Top-k results for one attribute.
class AttributeScore {
  const AttributeScore(this.attribute, this.topK);

  final ScanAttribute attribute;

  /// Ordered most significant (`topK.first` is the winner).
  final List<ScoredLabel> topK;

  /// Highest-probability label.
  String get value => topK.first.label;

  /// Confidence of the winning label, in [0, 1].
  double get confidence => topK.first.probability;

  @override
  String toString() => '${attribute.key}: $value';
}

/// Full zero-shot scan result: one top-k block per attribute.
class ScanClassification {
  const ScanClassification(this.scores, {this.isClothing = true});

  final List<AttributeScore> scores;
  final bool isClothing;

  AttributeScore? scoreFor(ScanAttribute attribute) {
    for (final s in scores) {
      if (s.attribute == attribute) return s;
    }
    return null;
  }

  /// Convenience accessors (null when the attribute was not requested or not clothing).
  String? get category {
    if (!isClothing) return null;
    final cat = scoreFor(ScanAttribute.category)?.value;
    if (cat == null || ClipZeroShotClassifier.nonClothingLabels.contains(cat)) {
      return null;
    }
    return cat;
  }

  String? get subcategory {
    if (!isClothing || category == null) return null;
    return scoreFor(ScanAttribute.subcategory)?.value;
  }

  String? get style => isClothing ? scoreFor(ScanAttribute.style)?.value : null;
  String? get season => isClothing ? scoreFor(ScanAttribute.season)?.value : null;

  @override
  String toString() => scores.map((s) => s.toString()).join(', ');
}

/// Embeds a phrase into a CLIP embedding (the caller supplies the real
/// tokenizer + text-encoder path; tests inject deterministic stubs).
typedef EmbedText = Float32List Function(String text);

/// MobileCLIP zero-shot classifier.
///
/// Every attribute is scored independently: the image embedding is compared
/// against a fixed prompt set (one prompt per label) using cosine similarity,
/// scaled by [temperature] (CLIP convention: `sim / temperature`), softmaxed,
/// and top-k ranked. Deterministic — same inputs always give the same scores.
///
/// Subcategory is parent-conditional: the winning category label selects which
/// subcategory prompt list applies.
/// Softmax temperature that reproduces MobileCLIP-S0's trained logit scale.
///
/// CLIP scales cosine similarities by `exp(logit_scale)`. The MobileCLIP-S0
/// checkpoint's learned `logit_scale` is `4.208`, i.e. `exp(4.208) = 67.2256`,
/// so the equivalent `sim / temperature` temperature is its reciprocal. The
/// untrained CLIP init (0.07) inflates the temperature ~4.7x and flattens the
/// softmax, suppressing every confidence below the review threshold.
const double kMobileClipS0Temperature = 0.014875293781718183;

class ClipZeroShotClassifier {
  ClipZeroShotClassifier(
    this._embedText, {
    this.temperature = kMobileClipS0Temperature,
  }) : assert(temperature > 0);

  final EmbedText _embedText;
  final double temperature;

  /// Default prompt template; `{label}` is substituted with each label.
  static const String defaultTemplate = 'a photo of a {label}';

  /// Set of labels indicating the image is not clothing.
  static const Set<String> nonClothingLabels = {
    'non-clothing item',
    'digital graphic or illustration',
  };

  static const List<String> categoryLabels = [
    't-shirt',
    'shirt',
    'blouse',
    'sweater',
    'cardigan',
    'hoodie',
    'sweatshirt',
    'jacket',
    'coat',
    'blazer',
    'dress',
    'skirt',
    'trousers',
    'jeans',
    'shorts',
    'leggings',
    'jumpsuit',
    'swimwear',
    'tank top',
    'pajamas',
    'sneakers',
    'shoes',
    'boots',
    'sandals',
    'loafers',
    'heels',
    'hat',
    'cap',
    'beanie',
    'scarf',
    'gloves',
    'belt',
    'bag',
    'sunglasses',
    'watch',
    'non-clothing item',
    'digital graphic or illustration',
  ];

  static const List<String> styleLabels = [
    'casual',
    'formal',
    'business casual',
    'sporty',
    'athleisure',
    'streetwear',
    'bohemian',
    'minimalist',
    'vintage',
    'classic',
    'trendy',
    'elegant',
    'preppy',
    'edgy',
    'romantic',
  ];

  static const List<String> seasonLabels = [
    'summer',
    'spring',
    'autumn',
    'winter',
    'all-season',
  ];

  /// Specific subcategory prompts per winning category label.
  static const Map<String, List<String>> subcategoryByCategory = {
    't-shirt': ['graphic tee', 'plain tee', 'long-sleeve tee', 'henley tee'],
    'shirt': ['casual shirt', 'dress shirt', 'flannel shirt'],
    'blouse': ['silk blouse', 'cotton blouse', 'ruffled blouse'],
    'sweater': [
      'crew-neck sweater',
      'v-neck sweater',
      'turtleneck sweater',
      'chunky knit sweater',
    ],
    'cardigan': ['knit cardigan', 'long cardigan', 'cropped cardigan'],
    'hoodie': ['zip-up hoodie', 'pullover hoodie'],
    'sweatshirt': ['crewneck sweatshirt', 'oversized sweatshirt'],
    'jacket': ['denim jacket', 'bomber jacket', 'leather jacket'],
    'coat': ['trench coat', 'parka', 'pea coat', 'overcoat', 'puffer coat'],
    'blazer': ['tailored blazer', 'oversized blazer'],
    'dress': ['casual dress', 'evening dress', 'maxi dress', 'sundress'],
    'skirt': ['mini skirt', 'midi skirt', 'maxi skirt'],
    'trousers': ['chinos', 'dress pants', 'cargo pants', 'wide-leg pants'],
    'jeans': ['skinny jeans', 'straight-leg jeans', 'wide-leg jeans'],
    'shorts': ['denim shorts', 'chino shorts', 'athletic shorts'],
    'leggings': ['high-waist leggings', 'capri leggings'],
    'jumpsuit': ['casual jumpsuit', 'formal jumpsuit'],
    'sneakers': ['low-top sneakers', 'high-top sneakers', 'running shoes'],
    'shoes': ['casual shoes', 'dress shoes', 'slippers'],
    'boots': ['ankle boots', 'knee-high boots', 'winter boots'],
    'sandals': ['flat sandals', 'heeled sandals'],
    'hat': ['wide-brim hat', 'sun hat'],
    'cap': ['baseball cap', 'flat cap'],
    'bag': ['tote bag', 'backpack', 'crossbody bag', 'clutch bag'],
  };

  /// Fallback subcategory list when the winning category has no specific set.
  static const List<String> fallbackSubcategories = [
    'classic style',
    'modern style',
    'everyday wear',
  ];

  final Map<String, Float32List> _embeddingCache = {};

  bool get isWarm => _embeddingCache.isNotEmpty;

  /// Prompt embeddings hit count exposure for diagnostics.
  int get cachedPromptCount => _embeddingCache.length;

  /// Precomputes and caches prompt embeddings for [attributes] (all four by
  /// default), including the subcategory prompts for every category. Idempotent;
  /// after this, [classify] incurs no text-model calls regardless of the
  /// winning category.
  void warmUp([List<ScanAttribute> attributes = ScanAttribute.valuesAll]) {
    for (final attr in attributes) {
      switch (attr) {
        case ScanAttribute.category:
          for (final l in categoryLabels) {
            _promptEmbedding(l);
          }
        case ScanAttribute.style:
          for (final l in styleLabels) {
            _promptEmbedding(l);
          }
        case ScanAttribute.season:
          for (final l in seasonLabels) {
            _promptEmbedding(l);
          }
        case ScanAttribute.subcategory:
          for (final labels in subcategoryByCategory.values) {
            for (final l in labels) {
              _promptEmbedding(l);
            }
          }
          for (final l in fallbackSubcategories) {
            _promptEmbedding(l);
          }
      }
    }
  }

  /// Classifies [imageEmb] against the prompt sets for [attributes] and
  /// returns top-k per attribute.
  ///
  /// Throws a [StateError] when [ScanAttribute.subcategory] is requested
  /// without also requesting [ScanAttribute.category] (it is conditional on
  /// the winning category label).
  ScanClassification classify(
    Float32List imageEmb, {
    List<ScanAttribute> attributes = ScanAttribute.valuesAll,
    int k = 3,
  }) {
    assert(attributes.isNotEmpty, 'classifier needs at least one attribute');
    if (attributes.contains(ScanAttribute.subcategory) &&
        !attributes.contains(ScanAttribute.category)) {
      throw StateError('subcategory requires category in the same call');
    }

    final clothingEmb = _promptEmbedding('__clothing__');
    final nonClothingEmb = _promptEmbedding('__non_clothing__');
    final clothingSim = cosineSimilarity(imageEmb, clothingEmb);
    final nonClothingSim = cosineSimilarity(imageEmb, nonClothingEmb);
    final passesBinaryCheck = clothingSim >= nonClothingSim;

    var categoryTop = '';
    final scores = <AttributeScore>[];
    for (final attr in attributes) {
      final labels = _labelsFor(attr, categoryTop);
      final logits = Float32List(labels.length);
      for (var i = 0; i < labels.length; i++) {
        final sim = cosineSimilarity(imageEmb, _promptEmbedding(labels[i]));
        logits[i] = sim * (1.0 / temperature);
      }
      final probabilities = softmax(logits.toList());
      final scored = <ScoredLabel>[
        for (var i = 0; i < labels.length; i++)
          ScoredLabel(labels[i], probabilities[i]),
      ];
      // Sort by probability, tie-broken by prompt-list order (stable even
      // though the sort itself isn't).
      scored.sort((a, b) {
        final byP = b.probability.compareTo(a.probability);
        return byP != 0 ? byP : labels.indexOf(a.label).compareTo(labels.indexOf(b.label));
      });
      if (attr == ScanAttribute.category) {
        categoryTop = scored.first.label;
      }
      scores.add(
        AttributeScore(attr, scored.take(k.clamp(1, scored.length)).toList()),
      );
    }

    final isClothing = passesBinaryCheck && !nonClothingLabels.contains(categoryTop);
    return ScanClassification(scores, isClothing: isClothing);
  }

  /// Cosine similarity between two vectors, in [-1, 1] (0 for zero vectors).
  static double cosineSimilarity(Float32List a, Float32List b) {
    final n = math.min(a.length, b.length);
    var dot = 0.0;
    var normA = 0.0;
    var normB = 0.0;
    for (var i = 0; i < n; i++) {
      dot += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }
    final denom = math.sqrt(normA) * math.sqrt(normB);
    if (denom == 0.0) return 0.0;
    return (dot / denom).clamp(-1.0, 1.0);
  }

  /// Numerically-stabilized softmax over [logits]. Deterministic.
  static Float32List softmax(List<double> logits) {
    var max = logits.first;
    for (final x in logits) {
      if (x > max) max = x;
    }
    final exps = Float32List(logits.length);
    var sum = 0.0;
    for (var i = 0; i < logits.length; i++) {
      exps[i] = math.exp(logits[i] - max);
      sum += exps[i];
    }
    for (var i = 0; i < exps.length; i++) {
      exps[i] = exps[i] / sum;
    }
    return exps;
  }

  String _promptForLabel(String label) {
    switch (label) {
      case '__clothing__':
        return 'a photo of clothing, an apparel garment, or wearable fashion item';
      case '__non_clothing__':
        return 'a photo of an illustration, cartoon, avatar, pixel art, drawing, face, animal, food, or non-clothing object';
      case 'non-clothing item':
        return 'a photo of something that is not clothing, such as a face, an animal, food, furniture, or a household object';
      case 'digital graphic or illustration':
        return 'an illustration, drawing, cartoon, pixel art, digital graphic, avatar, or icon';
      default:
        return defaultTemplate.replaceAll('{label}', label);
    }
  }

  Float32List _promptEmbedding(String label) {
    final text = _promptForLabel(label);
    return _embeddingCache.putIfAbsent(text, () => _embedText(text));
  }

  List<String> _labelsFor(ScanAttribute attribute, String? categoryTop) {
    switch (attribute) {
      case ScanAttribute.category:
        return categoryLabels;
      case ScanAttribute.subcategory:
        return subcategoryByCategory[categoryTop ?? ''] ??
            fallbackSubcategories;
      case ScanAttribute.style:
        return styleLabels;
      case ScanAttribute.season:
        return seasonLabels;
    }
  }

  }