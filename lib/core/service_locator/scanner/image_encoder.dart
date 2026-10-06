import 'dart:typed_data';

import 'package:shiakah/core/service_locator/scanner/mobileclip_options.dart';
import 'package:shiakah/core/service_locator/scanner/tflite_runner.dart';

/// CLIP image encoder: preprocessed float32 pixels -> float32 embedding.
///
/// The caller owns preprocessing (resize / center-crop / mean & std
/// normalization) and must supply pixels matching [inputShape] (element count
/// is enforced by the tensor byte-size check on write).
class ClipImageEncoder {
  ClipImageEncoder._(this._runner, this._inputShape, this._outputShape);

  final ClipTfliteRunner _runner;
  final List<int> _inputShape;
  final List<int> _outputShape;

  List<int> get inputShape => List.unmodifiable(_inputShape);
  List<int> get outputShape => List.unmodifiable(_outputShape);

  /// Embedding dimension, e.g. 512 for a [1, 512] output tensor.
  int get embeddingDim => _outputShape[_outputShape.length - 1];

  static Future<ClipImageEncoder> load(MobileClipOptions options) async {
    final runner = await ClipTfliteRunner.load(options.imageModelPath, options);
    return ClipImageEncoder._(
      runner,
      runner.inputShape(0),
      runner.outputShape(0),
    );
  }

  /// Runs the image encoder. [pixels] must hold exactly
  /// `numElements(inputShape)` float32 values in the model's expected layout
  /// (e.g. channels-first [1, 3, H, W] or channels-last [1, H, W, 3]).
  Float32List encode(Float32List pixels) {
    _runner.setInput(
      0,
      pixels.buffer.asUint8List(pixels.offsetInBytes, pixels.lengthInBytes),
    );
    _runner.invoke();
    return _runner.readOutputF32(0);
  }

  void close() => _runner.close();
}
