import 'dart:io';
import 'dart:typed_data';

import 'scanner.dart';

/// Embeds model-ready float32 pixels into a CLIP image embedding.
///
/// The caller supplies the real path (`ClipScanner.encodeImage`); tests inject
/// deterministic stubs.
typedef EmbedImage = Float32List Function(Float32List pixels);

/// A decoded, model-ready photo: the same pixels in both representations the
/// scan pipeline needs (float32 for the image encoder, packed ARGB for color
/// k-means).
class ScanImageInput {
  const ScanImageInput({
    required this.pixels,
    required this.argb,
    required this.width,
    required this.height,
  });

  /// Model-ready float32 pixels for `ClipImageEncoder` (length
  /// `numElements(inputShape)`).
  final Float32List pixels;

  /// Packed `0xAARRGGBB` pixels in row-major order (`width * height` long).
  final List<int> argb;

  final int width;
  final int height;
}

/// Orchestrates a scan: pixels -> [ItemAttributes].
///
/// [analyzeScan] is pure and synchronous; [scanWardrobeImage] handles
/// end-to-end file reading, preprocessing, and classification.
class ScannerService {
  ScannerService({
    required this.classifier,
    required this.embedImage,
    this.colorAnalyzer = const ColorAnalyzer(),
    this.modelVersion = 'mobileclip-s0',
  });

  /// Wires the service to a loaded [ClipScanner].
  factory ScannerService.forScanner(
    ClipScanner scanner, {
    ColorAnalyzer colorAnalyzer = const ColorAnalyzer(),
    String modelVersion = 'mobileclip-s0',
  }) {
    return ScannerService(
      classifier: scanner.classifier,
      embedImage: scanner.encodeImage,
      colorAnalyzer: colorAnalyzer,
      modelVersion: modelVersion,
    );
  }

  final ClipZeroShotClassifier classifier;
  final EmbedImage embedImage;
  final ColorAnalyzer colorAnalyzer;

  /// Provenance recorded on model version.
  final String modelVersion;

  /// Precomputes and caches zero-shot prompt embeddings for fast inference.
  void warmUp() => classifier.warmUp();

  /// Preprocesses an image [File] (center-crop, 256x256 bilinear resize, float32 normalization)
  /// and runs the classification and dominant color extraction.
  Future<ItemAttributes> scanWardrobeImage(
    File imageFile, {
    int colorTop = 1,
  }) async {
    final input = await ImagePreprocessor.preprocessFile(imageFile);
    return analyzeScan(input, colorTop: colorTop);
  }

  /// Preprocesses image [bytes] and runs the classification and dominant color extraction.
  Future<ItemAttributes> scanWardrobeBytes(
    Uint8List bytes, {
    int colorTop = 1,
  }) async {
    final input = ImagePreprocessor.preprocessBytes(bytes);
    return analyzeScan(input, colorTop: colorTop);
  }

  /// Classifies all four attributes and extracts the dominant color.
  ///
  /// Dominant color is resolved through hue-family aggregation (see
  /// [ColorAnalyzer.aggregateFamilies]) so that a single garment hue that
  /// k-means split into several named clusters (e.g. `sky` + `navy` + `blue`)
  /// is reported as one family winner instead of several low-share also-rans.
  /// For a solid swatch the result is identical to the per-cluster quantizer
  /// (one family, ~1.0 share), so existing solid-color contracts are unchanged.
  ///
  /// Scans are background-aware: when a white/light photo backdrop would
  /// otherwise let the neutral family (white + black + grey) win every pixel
  /// share, the largest chromatic family is promoted instead (see
  /// [ColorAnalyzer.aggregateFamilies]' [preferChromatic]). Deterministic for
  /// identical input; the result always has `source == AttributeSource.ai`.
  ItemAttributes analyzeScan(ScanImageInput input, {int colorTop = 1}) {
    final classification = classifier.classify(embedImage(input.pixels));
    final families = colorAnalyzer.aggregateFamilies(
      argb: input.argb,
      width: input.width,
      height: input.height,
      top: colorTop,
      preferChromatic: true,
    );

    final confidences = <String, double>{
      for (final score in classification.scores)
        score.attribute.key: score.confidence,
    };
    final dominant = families.isEmpty ? null : families.first;
    if (dominant != null) {
      confidences[kDominantColorKey] = dominant.proportion;
    }

    final isClothing =
        classification.isClothing && classification.category != null;

    return ItemAttributes(
      category: isClothing ? classification.category : null,
      subcategory: isClothing ? classification.subcategory : null,
      style: isClothing ? classification.style : null,
      season: isClothing ? classification.season : null,
      dominantColor: isClothing ? dominant?.namedColor.name : null,
      dominantColorAr: isClothing ? dominant?.namedColor.nameAr : null,
      confidences: confidences,
      isClothing: isClothing,
    );
  }

  /// Starts a confirmable [ScanSession] for [input] (T-SCAN-06).
  ///
  /// Runs [analyzeScan] once immediately; the UI then reviews, corrects, or
  /// retries and finally calls [ScanSession.confirm].
  ScanSession startScan(
    ScanImageInput input, {
    String photoPath = '',
    int colorTop = 1,
  }) {
    return ScanSession(
      service: this,
      input: input,
      attributes: analyzeScan(input, colorTop: colorTop),
      photoPath: photoPath,
    );
  }
}
