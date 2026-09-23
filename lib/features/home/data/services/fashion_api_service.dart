import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/fashion_analysis_model.dart';

/// Custom Exception hierarchy for Fashion API operations
abstract class FashionApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  const FashionApiException(this.message,
      {this.statusCode, this.originalError});

  @override
  String toString() =>
      'FashionApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

class FashionNetworkException extends FashionApiException {
  const FashionNetworkException(super.message, {super.originalError});
}

class FashionTimeoutException extends FashionApiException {
  const FashionTimeoutException(super.message, {super.originalError});
}

class FashionServerException extends FashionApiException {
  const FashionServerException(super.message,
      {required int super.statusCode, super.originalError});
}

class FashionParseException extends FashionApiException {
  const FashionParseException(super.message, {super.originalError});
}

/// Service to interact with the local Flask backend for fashion image analysis.
///
/// Handles multipart/form-data uploads to `/api/chat-image` with configurable
/// base URLs for Android emulators (`http://10.0.2.2:5000`) and iOS/Desktop (`http://127.0.0.1:5000`).
class FashionApiService {
  final http.Client _client;
  String _baseUrl;
  final Duration timeout;

  /// Default local Flask backend port
  static const int defaultPort = 5000;

  /// Path for the image analysis endpoint
  static const String chatImagePath = '/api/chat-image';

  /// Local LAN IP of the PC running the Flask server on Wi-Fi
  static const String localLanIp = '192.168.1.14';

  /// Resolves the default base URL according to the current platform.
  /// - Real Android devices on Wi-Fi: 192.168.1.14:5000 (also works on Android Emulator)
  /// - iOS Simulator / Desktop / Web: 127.0.0.1:5000
  static String get defaultBaseUrl {
    if (kIsWeb) return 'http://127.0.0.1:$defaultPort';
    if (Platform.isAndroid) {
      return 'http://$localLanIp:$defaultPort';
    }
    return 'http://127.0.0.1:$defaultPort';
  }

  /// Singleton instance initialized with default platform configuration
  static final FashionApiService instance = FashionApiService();

  FashionApiService({
    http.Client? client,
    String? baseUrl,
    this.timeout = const Duration(seconds: 45),
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? defaultBaseUrl;

  /// Current base URL in use
  String get baseUrl => _baseUrl;

  /// Update the base URL dynamically (e.g. when connecting to a real device on local Wi-Fi)
  void setBaseUrl(String newUrl) {
    _baseUrl =
        newUrl.endsWith('/') ? newUrl.substring(0, newUrl.length - 1) : newUrl;
  }

  /// Sends an image file with form parameters to the Flask backend via multipart/form-data POST.
  ///
  /// Parameters:
  /// - [imageFile]: The local image [File] from gallery or camera.
  /// - [meetingType]: The occasion context, defaults to "Casual Outing".
  /// - [preferredStyles]: The fashion preference, defaults to "Smart Casual".
  /// - [location]: Contextual location, defaults to "Cairo".
  /// - [customBaseUrl]: Optional temporary override of the base URL for this specific call.
  ///
  /// Returns a strongly typed [FashionAnalysisResponse] containing the items and validation flag.
  Future<FashionAnalysisResponse> analyzeFashionImage({
    required File imageFile,
    String meetingType = 'Casual Outing',
    String preferredStyles = 'Smart Casual',
    String location = 'Cairo',
    String? customBaseUrl,
  }) async {
    // 1. Validate local file existence
    if (!imageFile.existsSync()) {
      return FashionAnalysisResponse.failure(
        'Selected image file does not exist at: ${imageFile.path}',
      );
    }

    final activeBaseUrl = (customBaseUrl ?? _baseUrl).trim();
    final sanitizedBaseUrl = activeBaseUrl.endsWith('/')
        ? activeBaseUrl.substring(0, activeBaseUrl.length - 1)
        : activeBaseUrl;

    final uri = Uri.parse('$sanitizedBaseUrl$chatImagePath');

    try {
      debugPrint('[FashionApiService] Uploading ${imageFile.path} to $uri');

      // 2. Prepare multipart request
      final request = http.MultipartRequest('POST', uri);

      // Add image file part
      final fileName = imageFile.path.split(RegExp(r'[/\\]')).last;
      final multipartFile = await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        filename: fileName.isNotEmpty ? fileName : 'fashion_input.jpg',
      );
      request.files.add(multipartFile);

      // Add required form fields
      request.fields['meeting_type'] = meetingType;
      request.fields['preferred_styles'] = preferredStyles;
      request.fields['location'] = location;

      // 3. Send request with timeout
      final streamedResponse = await _client.send(request).timeout(timeout);
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('[FashionApiService] Status code: ${response.statusCode}');

      // 4. Handle HTTP status codes
      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          throw const FashionParseException('Received empty body from backend');
        }

        final Map<String, dynamic> jsonMap;
        try {
          final decoded = jsonDecode(utf8.decode(response.bodyBytes));
          if (decoded is! Map<String, dynamic>) {
            throw const FormatException('Expected JSON Object at root');
          }
          jsonMap = decoded;
        } catch (e) {
          throw FashionParseException(
            'Failed to parse JSON response: $e',
            originalError: e,
          );
        }

        // Parse into typed response & evaluate clothing validation rules
        final result = FashionAnalysisResponse.fromJson(jsonMap);
        return result;
      } else {
        // Non-200 status code
        final errorSnippet = response.body.length > 200
            ? '${response.body.substring(0, 200)}...'
            : response.body;

        throw FashionServerException(
          'Backend returned error status ${response.statusCode}: $errorSnippet',
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      debugPrint('[FashionApiService] SocketException: $e');
      return FashionAnalysisResponse.failure(
        'Cannot connect to backend at $sanitizedBaseUrl. Ensure your Flask server is running on host 0.0.0.0 and port $defaultPort.',
      );
    } on TimeoutException catch (e) {
      debugPrint(
          '[FashionApiService] TimeoutException after ${timeout.inSeconds}s: $e');
      return FashionAnalysisResponse.failure(
        'Request timed out while analyzing the image (${timeout.inSeconds}s limit reached). Please try again.',
      );
    } on http.ClientException catch (e) {
      debugPrint('[FashionApiService] http.ClientException: $e');
      final errStr = e.toString().toLowerCase();
      if (errStr.contains('connection refused') ||
          errStr.contains('errno = 111')) {
        return FashionAnalysisResponse.failure(
          'Connection refused at $sanitizedBaseUrl. Your Flask server is not running or not bound to host 0.0.0.0 on port $defaultPort.',
        );
      }
      return FashionAnalysisResponse.failure(
        'Network error communicating with backend: ${e.message}',
      );
    } on FashionApiException catch (e) {
      debugPrint('[FashionApiService] Custom ApiException: ${e.message}');
      return FashionAnalysisResponse.failure(e.message);
    } catch (e, stack) {
      debugPrint('[FashionApiService] Unexpected error: $e\n$stack');
      return FashionAnalysisResponse.failure('Unexpected error: $e');
    }
  }

  /// Closes the underlying HTTP client if needed.
  void dispose() {
    _client.close();
  }
}
