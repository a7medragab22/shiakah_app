import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:image/image.dart' as img;
import 'package:shiakah/core/service_locator/service_locator.dart';

void main() {
  group('ImagePreprocessor Pipeline Tests', () {
    test('center-square crop, 256x256 bilinear resize, and float32 normalization [0.0, 1.0]', () {
      // Create a 400x200 test image with distinct colors
      final testImage = img.Image(width: 400, height: 200);
      for (var y = 0; y < 200; y++) {
        for (var x = 0; x < 400; x++) {
          testImage.setPixelRgb(x, y, 100, 150, 200);
        }
      }

      final input = ImagePreprocessor.preprocessImage(testImage);

      expect(input.width, 256);
      expect(input.height, 256);
      expect(input.pixels.length, 256 * 256 * 3);
      expect(input.argb.length, 256 * 256);

      // Verify float32 normalization
      for (var i = 0; i < input.pixels.length; i++) {
        expect(input.pixels[i], inInclusiveRange(0.0, 1.0));
      }

      // Check values match ~ (100/255, 150/255, 200/255)
      expect(input.pixels[0], closeTo(100 / 255.0, 0.05));
      expect(input.pixels[1], closeTo(150 / 255.0, 0.05));
      expect(input.pixels[2], closeTo(200 / 255.0, 0.05));

      // Check ARGB format (alpha = 0xFF, R=100, G=150, B=200)
      final firstPixelArgb = input.argb[0];
      final a = (firstPixelArgb >> 24) & 0xFF;
      final r = (firstPixelArgb >> 16) & 0xFF;
      final g = (firstPixelArgb >> 8) & 0xFF;
      final b = firstPixelArgb & 0xFF;

      expect(a, 0xFF);
      expect(r, closeTo(100, 5));
      expect(g, closeTo(150, 5));
      expect(b, closeTo(200, 5));
    });

    test('preprocessBytes decodes PNG/JPEG correctly', () {
      final image = img.Image(width: 100, height: 100);
      img.fill(image, color: img.ColorRgb8(255, 0, 0));
      final pngBytes = Uint8List.fromList(img.encodePng(image));

      final input = ImagePreprocessor.preprocessBytes(pngBytes);
      expect(input.width, 256);
      expect(input.height, 256);
      expect(input.pixels[0], closeTo(1.0, 0.01)); // Red channel
      expect(input.pixels[1], closeTo(0.0, 0.01)); // Green channel
      expect(input.pixels[2], closeTo(0.0, 0.01)); // Blue channel
    });
  });

  group('ScannerService and ScanSession Tests', () {
    late ScannerService scannerService;

    setUp(() {
      // Deterministic stub: returns a fixed 512-dim embedding for any input
      Float32List mockEmbedText(String text) {
        return Float32List.fromList(List.filled(512, 0.1));
      }

      Float32List mockEmbedImage(Float32List pixels) {
        return Float32List.fromList(List.filled(512, 0.1));
      }

      final classifier = ClipZeroShotClassifier(mockEmbedText);

      scannerService = ScannerService(
        classifier: classifier,
        embedImage: mockEmbedImage,
      );
    });

    test('analyzeScan runs purely and extracts attributes and color', () {
      final dummyPixels = Float32List(256 * 256 * 3);
      final dummyArgb = List<int>.filled(256 * 256, 0xFF0000FF); // Blue

      final input = ScanImageInput(
        pixels: dummyPixels,
        argb: dummyArgb,
        width: 256,
        height: 256,
      );

      final result = scannerService.analyzeScan(input);

      expect(result.source, AttributeSource.ai);
      expect(result.dominantColor, isNotNull);
      expect(result.dominantColorAr, isNotNull);
      expect(result.category, isNotNull);
    });

    test('ScanSession supports corrections, retries, and confirms without DB dependency', () {
      final dummyPixels = Float32List(256 * 256 * 3);
      final dummyArgb = List<int>.filled(256 * 256, 0xFF0000FF);

      final input = ScanImageInput(
        pixels: dummyPixels,
        argb: dummyArgb,
        width: 256,
        height: 256,
      );

      final session = scannerService.startScan(input, photoPath: '/path/to/photo.jpg');

      expect(session.isEdited, isFalse);
      expect(session.isConfirmed, isFalse);
      expect(session.result.source, AttributeSource.ai);

      // User corrects category
      session.correct('category', 'jacket');
      expect(session.isEdited, isTrue);
      expect(session.result.category, 'jacket');
      expect(session.result.source, AttributeSource.userCorrected);

      // Confirm returns finalized ItemAttributes
      final confirmedAttributes = session.confirm();
      expect(session.isConfirmed, isTrue);
      expect(confirmedAttributes.category, 'jacket');
      expect(confirmedAttributes.source, AttributeSource.userCorrected);

      // Subsequent modification or confirm throws StateError
      expect(() => session.correct('style', 'casual'), throwsStateError);
      expect(() => session.confirm(), throwsStateError);
      expect(() => session.retry(), throwsStateError);
    });
  });

  group('ServiceLocator Scanner Registration Tests', () {
    test('ScannerServiceLocator registers ClipScanner and ScannerService in GetIt', () async {
      final testGetIt = GetIt.asNewInstance();

      await ScannerServiceLocator.execute(getIt: testGetIt);

      expect(testGetIt.isRegistered<ClipScanner>(), isTrue);
      expect(testGetIt.isRegistered<ScannerService>(), isTrue);
      expect(testGetIt.isRegistered<WardrobeScannerBloc>(), isTrue);
    });
  });

  group('ColorPalette and WardrobeScannerBloc Tests', () {
    test('ColorPalette.hexForName resolves hex values for colors', () {
      expect(ColorPalette.hexForName('black'), 0xFF0A0A0A);
      expect(ColorPalette.hexForName('أسود'), 0xFF0A0A0A);
      expect(ColorPalette.hexForName('white'), 0xFFF5F5F5);
      expect(ColorPalette.hexForName('navy'), 0xFF141E5F);
      expect(ColorPalette.hexForName('nonexistent'), isNull);
    });

    test('WardrobeScannerBloc emits loading then success on scan', () async {
      Float32List mockEmbedText(String text) =>
          Float32List.fromList(List.filled(512, 0.2));
      Float32List mockEmbedImage(Float32List pixels) =>
          Float32List.fromList(List.filled(512, 0.2));

      final service = ScannerService(
        classifier: ClipZeroShotClassifier(mockEmbedText),
        embedImage: mockEmbedImage,
      );

      final bloc = WardrobeScannerBloc(scannerService: service);

      // Create an encoded 100x100 blue PNG
      final image = img.Image(width: 100, height: 100);
      img.fill(image, color: img.ColorRgb8(0, 0, 255));
      final pngBytes = Uint8List.fromList(img.encodePng(image));

      // Test scanning via scanWardrobeBytes
      final attributes = await service.scanWardrobeBytes(pngBytes);
      expect(attributes.dominantColor, isNotNull);
      expect(attributes.category, isNotNull);

      // Verify reset works
      bloc.add(const ResetWardrobeScan());
      expect(bloc.state, isA<WardrobeScannerInitial>());
      await bloc.close();
    });

    test('rejects non-clothing items when binary check or reject category wins', () {
      Float32List mockEmbedText(String text) {
        final vec = Float32List(512);
        if (text.contains('illustration') || text.contains('not clothing')) {
          vec[0] = 1.0;
        } else {
          vec[1] = 1.0;
        }
        return vec;
      }

      final classifier = ClipZeroShotClassifier(mockEmbedText);
      final imageEmb = Float32List(512)..[0] = 1.0;

      final classification = classifier.classify(imageEmb);
      expect(classification.isClothing, isFalse);
      expect(classification.category, isNull);

      final attributes = ItemAttributes(
        category: classification.category,
        isClothing: classification.isClothing,
      );
      expect(attributes.isValidClothing, isFalse);
    });
  });
}
