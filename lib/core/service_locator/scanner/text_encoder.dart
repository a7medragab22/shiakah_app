import 'dart:typed_data';

import 'package:shiakah/core/service_locator/scanner/mobileclip_options.dart';
import 'package:shiakah/core/service_locator/scanner/tflite_runner.dart';

/// CLIP text encoder: token IDs -> fixed-length float32 embedding.
class ClipTextEncoder {
  ClipTextEncoder._(this._runner, this._inputShape, this._outputShape);

  final ClipTfliteRunner _runner;
  final List<int> _inputShape;
  final List<int> _outputShape;

  /// Model token window, e.g. 77 for a [1, 77] input tensor.
  int get window => _inputShape[_inputShape.length - 1];

  /// Embedding dimension, e.g. 512 for a [1, 512] output tensor.
  int get embeddingDim => _outputShape[_outputShape.length - 1];

  List<int> get inputShape => List.unmodifiable(_inputShape);
  List<int> get outputShape => List.unmodifiable(_outputShape);

  static Future<ClipTextEncoder> load(MobileClipOptions options) async {
    final runner = await ClipTfliteRunner.load(options.textModelPath, options);
    return ClipTextEncoder._(
      runner,
      runner.inputShape(0),
      runner.outputShape(0),
    );
  }

  /// Pads/truncates [ids] to the model window and runs the text encoder.
  ///
  /// [padToken] fills positions past [ids]. This MobileCLIP (open_clip-style)
  /// text model is trained with zero-padding — its tokenizer pads with 0, not
  /// with the EOS id — so padding with 49407 collapses every prompt into a
  /// near-identical embedding (verified: cosine vs the PyTorch reference is
  /// 0.29-0.49 with EOS padding vs 1.0000 with 0 padding).
  Float32List encode(
    List<int> ids, {
    int padToken = 0,
  }) {
    final window = this.window;
    final padded = Int32List(window);
    final kept = ids.length < window ? ids.length : window;
    for (var i = 0; i < window; i++) {
      padded[i] = i < kept ? ids[i] : padToken;
    }
    _runner.setInput(
      0,
      padded.buffer.asUint8List(padded.offsetInBytes, padded.lengthInBytes),
    );
    _runner.invoke();
    return _runner.readOutputF32(0);
  }

  void close() => _runner.close();
}
