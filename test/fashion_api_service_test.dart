import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shiakah/features/home/data/services/fashion_api_service.dart';

void main() {
  group('FashionApiService & Model Tests', () {
    late Directory tempDir;
    late File testImageFile;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('fashion_test_');
      testImageFile = File('${tempDir.path}/sample_outfit.jpg')
        ..writeAsBytesSync([1, 2, 3, 4, 5]);
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('Identifies valid clothes when items contain clothing apparel', () async {
      final mockResponse = {
        "status": "success",
        "response": {
          "summary": "A chic monochrome outfit featuring an oversized shirt",
          "items": {
            "top": "Crisp oversized white long-sleeve button-down shirt",
            "bottom": "High-waisted black tailored shorts",
            "footwear": "Black pointed-toe leather ankle boots",
            "accessories": "Small black top-handle structured handbag"
          },
          "styling_tips": "For a warm 32°C day in Cairo...",
          "search_query": "oversized white linen shirt high waisted black shorts",
          "recommended_image_url": "https://images.unsplash.com/sample"
        }
      };

      final client = MockClient((request) async {
        expect(request.url.path, equals('/api/chat-image'));
        return http.Response(jsonEncode(mockResponse), 200, headers: {
          HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
        });
      });

      final service = FashionApiService(
        client: client,
        baseUrl: 'http://10.0.2.2:5000',
      );

      final result = await service.analyzeFashionImage(
        imageFile: testImageFile,
        meetingType: 'Casual Outing',
        preferredStyles: 'Smart Casual',
        location: 'Cairo',
      );

      expect(result.isSuccess, isTrue);
      expect(result.isClothes, isTrue);
      expect(result.items.top, contains('white'));
      expect(result.items.bottom, contains('shorts'));
      expect(result.items.footwear, contains('boots'));
      expect(result.items.accessories, contains('handbag'));
      expect(result.rejectionReason, isEmpty);
    });

    test('Validates image as NOT clothes when all clothing items are empty strings', () async {
      final mockResponse = {
        "status": "success",
        "response": {
          "summary":
              "The uploaded image shows home bedding and decor, which is unrelated to clothing or fashion.",
          "items": {
            "top": "",
            "bottom": "",
            "footwear": "",
            "accessories": ""
          },
          "styling_tips": "",
          "search_query": "",
          "recommended_image_url": ""
        }
      };

      final client = MockClient((request) async {
        return http.Response(jsonEncode(mockResponse), 200, headers: {
          HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
        });
      });

      final service = FashionApiService(
        client: client,
        baseUrl: 'http://127.0.0.1:5000',
      );

      final result = await service.analyzeFashionImage(imageFile: testImageFile);

      expect(result.isSuccess, isTrue);
      expect(result.isClothes, isFalse);
      expect(result.rejectionReason, contains('home bedding and decor'));
      expect(result.items.top, isEmpty);
      expect(result.items.bottom, isEmpty);
    });

    test('Gracefully handles HTTP 500 server error', () async {
      final client = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final service = FashionApiService(client: client);
      final result = await service.analyzeFashionImage(imageFile: testImageFile);

      expect(result.isSuccess, isFalse);
      expect(result.isClothes, isFalse);
      expect(result.errorMessage, contains('500'));
    });

    test('Handles missing local file without making network request', () async {
      final nonExistentFile = File('${tempDir.path}/does_not_exist.jpg');
      final service = FashionApiService();

      final result = await service.analyzeFashionImage(imageFile: nonExistentFile);

      expect(result.isSuccess, isFalse);
      expect(result.errorMessage, contains('does not exist'));
    });

    test('Configurable baseUrl works for Android vs Desktop/iOS', () {
      final defaultUrl = FashionApiService.defaultBaseUrl;
      expect(
          defaultUrl,
          anyOf(
            equals('http://192.168.1.14:5000'),
            equals('http://10.0.2.2:5000'),
            equals('http://127.0.0.1:5000'),
          ));

      final customService = FashionApiService(baseUrl: 'http://192.168.1.100:5000');
      expect(customService.baseUrl, equals('http://192.168.1.100:5000'));

      customService.setBaseUrl('http://myserver.com:5000/');
      expect(customService.baseUrl, equals('http://myserver.com:5000'));
    });
  });
}
