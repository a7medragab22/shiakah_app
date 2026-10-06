import 'dart:typed_data';

import 'package:shiakah/core/service_locator/scanner/mobileclip_options.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;

/// Shared byte-exact interpreter lifecycle for the MobileCLIP encoders.
///
/// Inputs are written straight into the native tensor buffer (`Tensor.data`
/// with a raw `Uint8List`) and outputs are read back as raw bytes then
/// reinterpreted as `Float32List` — no `List<double>` boxing on the hot path.
class ClipTfliteRunner {
  ClipTfliteRunner._(
    this._interpreter,
    this._delegate,
    this._delegateOptions,
    this._interpreterOptions,
  );

  final tfl.Interpreter _interpreter;
  final tfl.XNNPackDelegate? _delegate;
  final tfl.XNNPackDelegateOptions? _delegateOptions;
  final tfl.InterpreterOptions _interpreterOptions;

  /// Loads [assetPath] with the threading/XNNPack policy from [options].
  static Future<ClipTfliteRunner> load(
    String assetPath,
    MobileClipOptions options,
  ) async {
    final interpreterOptions = tfl.InterpreterOptions();
    interpreterOptions.threads = options.threads;

    tfl.XNNPackDelegate? delegate;
    tfl.XNNPackDelegateOptions? delegateOptions;
    if (options.useXnnPack) {
      delegateOptions = tfl.XNNPackDelegateOptions(numThreads: options.threads);
      delegate = tfl.XNNPackDelegate(options: delegateOptions);
      interpreterOptions.addDelegate(delegate);
    }

    final interpreter = await tfl.Interpreter.fromAsset(
      assetPath,
      options: interpreterOptions,
    );
    return ClipTfliteRunner._(
      interpreter,
      delegate,
      delegateOptions,
      interpreterOptions,
    );
  }

  List<int> inputShape(int index) => _interpreter.getInputTensor(index).shape;

  List<int> outputShape(int index) => _interpreter.getOutputTensor(index).shape;

  /// Byte-exact input write; throws if [rawBytes] length != tensor byte size.
  void setInput(int index, Uint8List rawBytes) {
    _interpreter.getInputTensor(index).data = rawBytes;
  }

  void invoke() => _interpreter.invoke();

  /// Reads output tensor [index] as float32, reinterpreting the native bytes.
  Float32List readOutputF32(int index) {
    final tensor = _interpreter.getOutputTensor(index);
    // copyTo returns the bytes for a Uint8List destination (the passed-in
    // buffer is left untouched), so the tensor byte count always matches
    // output element count * sizeof(float32).
    final bytes = tensor.copyTo(Uint8List(tensor.numBytes())) as Uint8List;
    return Float32List.view(
      bytes.buffer,
      bytes.offsetInBytes,
      bytes.lengthInBytes ~/ float32Bytes,
    );
  }

  void close() {
    // Careful teardown order: the XNNPack delegate must be freed only after
    // the interpreter that references it is closed, and the options structs
    // (also caller-owned) last.
    _interpreter.close();
    _delegate?.delete();
    _delegateOptions?.delete();
    _interpreterOptions.delete();
  }

  static const int float32Bytes = 4;
}
