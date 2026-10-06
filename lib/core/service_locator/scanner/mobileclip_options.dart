/// Options controlling how the MobileCLIP-S0 encoders and tokenizer are
/// loaded in the scanner module.
class MobileClipOptions {
  const MobileClipOptions({
    this.imageModelPath = defaultImageModelPath,
    this.textModelPath = defaultTextModelPath,
    this.tokenizerPath = defaultTokenizerPath,
    this.threads = 2,
    this.useXnnPack = false,
  });

  static const String defaultImageModelPath =
      'assets/models/mobileclip_s0_image_float32.tflite';
  static const String defaultTextModelPath =
      'assets/models/mobileclip_s0_text_float32.tflite';
  static const String defaultTokenizerPath = 'assets/models/tokenizer.json';

  /// TFLite/XNNPack CPU thread count (applies to both encoders).
  final int threads;

  /// Enable the XNNPack delegate. XNNPack gives a large speedup for these
  /// float32 CNN/transformer models on ARM CPUs, but its x86 CPUID feature
  /// detection reliably segfaults on Android x86_64 emulators (observed
  /// crashing both `TfLiteXNNPackDelegateCreateWithThreadpool` and model
  /// partitioning on API 33 x86_64), so it defaults to off. Enable it on real
  /// ARM64 hardware for acceleration.
  final bool useXnnPack;

  final String imageModelPath;
  final String textModelPath;
  final String tokenizerPath;
}