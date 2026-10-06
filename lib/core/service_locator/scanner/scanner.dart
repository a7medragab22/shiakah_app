/// Scanner module: MobileCLIP-S0 tokenizer + text/image encoders.
library;

import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:shiakah/core/service_locator/scanner/clip_tokenizer.dart';
import 'package:shiakah/core/service_locator/scanner/image_encoder.dart';
import 'package:shiakah/core/service_locator/scanner/image_preprocessor.dart';
import 'package:shiakah/core/service_locator/scanner/mobileclip_options.dart';
import 'package:shiakah/core/service_locator/scanner/scanner_service.dart';
import 'package:shiakah/core/service_locator/scanner/text_encoder.dart';
import 'package:shiakah/core/service_locator/scanner/zero_shot_classifier.dart';
import 'package:shiakah/database/models/item_attributes.dart';

export 'clip_tokenizer.dart';
export 'color_analyzer.dart';
export 'image_encoder.dart';
export 'image_preprocessor.dart';
export 'mobileclip_options.dart';
export 'scan_session.dart';
export 'scanner_service.dart';
export 'text_encoder.dart';
export 'tflite_runner.dart';
export 'zero_shot_classifier.dart';
export 'package:shiakah/database/models/attribute_source.dart';
export 'package:shiakah/database/models/item_attributes.dart';

/// High-level facade that owns a tokenizer plus both encoders.
class ClipScanner {
  ClipScanner._(this._tokenizer, this._textEncoder, this._imageEncoder);

  final ClipTokenizer _tokenizer;
  final ClipTextEncoder _textEncoder;
  final ClipImageEncoder _imageEncoder;

  /// Loads the tokenizer and both encoders with [options] (defaults span the
  /// preloaded `assets/models/` files).
  ///
  /// [imageFirst] loads the image encoder before the text encoder; it only
  /// changes construction order and never the resulting behavior.
  static Future<ClipScanner> load({
    MobileClipOptions? options,
    bool imageFirst = false,
  }) async {
    final opts = options ?? const MobileClipOptions();
    final tokenizer = await ClipTokenizer.fromAsset(opts.tokenizerPath);
    if (imageFirst) {
      final image = await ClipImageEncoder.load(opts);
      final text = await ClipTextEncoder.load(opts);
      return ClipScanner._(tokenizer, text, image);
    }
    final text = await ClipTextEncoder.load(opts);
    final image = await ClipImageEncoder.load(opts);
    return ClipScanner._(tokenizer, text, image);
  }

  ClipTokenizer get tokenizer => _tokenizer;
  ClipTextEncoder get textEncoder => _textEncoder;
  ClipImageEncoder get imageEncoder => _imageEncoder;

  /// Tokenizes [text] into ids including BOS/EOS (no window cap).
  List<int> tokenize(String text) => _tokenizer.encode(text);

  /// Tokenizes, pads/truncates to the text window, and embeds.
  Float32List encodeText(String text) =>
      _textEncoder.encode(_tokenizer.encode(text));

  /// Embeds preprocessed float32 [pixels] (see [ClipImageEncoder]).
  Float32List encodeImage(Float32List pixels) => _imageEncoder.encode(pixels);

  /// Zero-shot classifier over the loaded text encoder (prompt embeddings are
  /// cached, so the first scan pays the text-model cost and later scans reuse
  /// it).
  ClipZeroShotClassifier get classifier =>
      _classifier ??= ClipZeroShotClassifier(_embedPhrase);
  ClipZeroShotClassifier? _classifier;

  /// Precomputes and caches zero-shot prompt embeddings for fast inference.
  void warmUp() => classifier.warmUp();

  /// Runs the full end-to-end scanning pipeline for a picked [File]:
  /// 1. Center-square crop
  /// 2. Bilinear resize to 256x256
  /// 3. Float32 normalization (0.0 to 1.0, RGB interleaved)
  /// 4. Runs inference (encodeImage + zero-shot classification + color analysis)
  /// Returns the detected [ItemAttributes].
  Future<ItemAttributes> scanImageFile(File file, {int colorTop = 1}) async {
    final input = await ImagePreprocessor.preprocessFile(file);
    final service = ScannerService.forScanner(this);
    return service.analyzeScan(input, colorTop: colorTop);
  }

  /// Runs the full end-to-end scanning pipeline on raw [Uint8List] bytes.
  Future<ItemAttributes> scanBytes(Uint8List bytes, {int colorTop = 1}) async {
    final input = ImagePreprocessor.preprocessBytes(bytes);
    final service = ScannerService.forScanner(this);
    return service.analyzeScan(input, colorTop: colorTop);
  }

  Float32List _embedPhrase(String phrase) => encodeText(phrase);

  /// Cosine similarity in [-1, 1]; the standard CLIP relevance measure.
  double cosineSimilarity(Float32List a, Float32List b) {
    var dot = 0.0;
    var normA = 0.0;
    var normB = 0.0;
    final n = math.min(a.length, b.length);
    for (var i = 0; i < n; i++) {
      dot += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }
    final denom = math.sqrt(normA) * math.sqrt(normB);
    if (denom == 0.0) return 0.0;
    return (dot / denom).clamp(-1.0, 1.0);
  }

  void close() {
    _imageEncoder.close();
    _textEncoder.close();
  }
}