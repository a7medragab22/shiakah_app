import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

import 'scanner_service.dart';

/// Preprocessing pipeline for On-Device Wardrobe Scanner.
///
/// Converts arbitrary camera or gallery photos into model-ready [ScanImageInput]:
/// 1. Center-square crop (retains central garment area, eliminates border distortion).
/// 2. Bilinear resize to 256x256.
/// 3. Normalizes float pixel values to [0.0, 1.0] (RGB interleaved: [R, G, B, R, G, B...]).
/// 4. Extracts packed ARGB pixels for color analysis.
class ImagePreprocessor {
  const ImagePreprocessor._();

  static const int targetWidth = 256;
  static const int targetHeight = 256;

  /// Takes any captured or picked image [File] and center-crops it into an exact 1:1 square.
  /// Saves the cropped 1:1 square image into the app's cache directory and returns the new [File].
  static Future<File> cropToSquareFile(File originalFile) async {
    try {
      final bytes = await originalFile.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return originalFile;

      final size = math.min(decoded.width, decoded.height);
      final cropX = (decoded.width - size) ~/ 2;
      final cropY = (decoded.height - size) ~/ 2;

      final cropped = img.copyCrop(
        decoded,
        x: cropX,
        y: cropY,
        width: size,
        height: size,
      );

      final encodedJpg = img.encodeJpg(cropped, quality: 95);
      final tempDir = await getTemporaryDirectory();
      final targetPath =
          '${tempDir.path}/square_1_1_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final targetFile = File(targetPath);
      await targetFile.writeAsBytes(encodedJpg);
      return targetFile;
    } catch (_) {
      return originalFile;
    }
  }

  /// Preprocesses an image [File] into [ScanImageInput].
  static Future<ScanImageInput> preprocessFile(File file) async {
    final bytes = await file.readAsBytes();
    return preprocessBytes(bytes);
  }

  /// Preprocesses raw encoded image [bytes] (PNG, JPEG, WebP, etc.).
  static ScanImageInput preprocessBytes(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw ArgumentError('Unable to decode image from provided bytes.');
    }
    return preprocessImage(decoded);
  }

  /// Preprocesses a decoded [img.Image].
  static ScanImageInput preprocessImage(img.Image image) {
    // 1. Center-square crop
    final size = math.min(image.width, image.height);
    final cropX = (image.width - size) ~/ 2;
    final cropY = (image.height - size) ~/ 2;

    final cropped = img.copyCrop(
      image,
      x: cropX,
      y: cropY,
      width: size,
      height: size,
    );

    // 2. Bilinear resize to 256x256
    final resized = img.copyResize(
      cropped,
      width: targetWidth,
      height: targetHeight,
      interpolation: img.Interpolation.linear,
    );

    // 3. RGB interleaved float32 normalization [0.0, 1.0] and packed ARGB
    const totalPixels = targetWidth * targetHeight;
    final pixels = Float32List(totalPixels * 3);
    final argb = List<int>.filled(totalPixels, 0);

    var pixelIdx = 0;
    for (var y = 0; y < targetHeight; y++) {
      for (var x = 0; x < targetWidth; x++) {
        final p = resized.getPixel(x, y);

        final r = p.r.toDouble();
        final g = p.g.toDouble();
        final b = p.b.toDouble();

        final rClamped = (r / 255.0).clamp(0.0, 1.0);
        final gClamped = (g / 255.0).clamp(0.0, 1.0);
        final bClamped = (b / 255.0).clamp(0.0, 1.0);

        pixels[pixelIdx * 3 + 0] = rClamped;
        pixels[pixelIdx * 3 + 1] = gClamped;
        pixels[pixelIdx * 3 + 2] = bClamped;

        final rInt = (rClamped * 255.0).round() & 0xFF;
        final gInt = (gClamped * 255.0).round() & 0xFF;
        final bInt = (bClamped * 255.0).round() & 0xFF;

        argb[pixelIdx] = (0xFF << 24) | (rInt << 16) | (gInt << 8) | bInt;

        pixelIdx++;
      }
    }

    return ScanImageInput(
      pixels: pixels,
      argb: argb,
      width: targetWidth,
      height: targetHeight,
    );
  }
}
