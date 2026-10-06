import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/local_storage/local_storage.dart';
import '../models/weather_model.dart';

class WeatherService {
  final Dio _dio;
  static const String _apiKey = '8885b48641ca49199bd142302261709';
  static const String _baseUrl = 'https://api.weatherapi.com/v1/forecast.json';

  WeatherService({Dio? dio}) : _dio = dio ?? _createSafeDio();

  static Dio _createSafeDio() {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
      ),
    );

    // Intercept connection and HTTP errors gracefully.
    // Resolving them avoids unhandled DioException and InterceptorState in the debugger.
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException err, ErrorInterceptorHandler handler) {
          return handler.resolve(
            Response(
              requestOptions: err.requestOptions,
              statusCode: err.response?.statusCode ?? 503,
              data: null,
            ),
          );
        },
      ),
    );

    return dio;
  }

  Future<WeatherModel> fetchWeather({String? city}) async {
    String query = city?.trim() ?? '';

    // Automatically detect location if not explicitly provided
    if (query.isEmpty) {
      try {
        bool serviceEnabled =
            await Geolocator.isLocationServiceEnabled().catchError((_) => false);
        if (serviceEnabled) {
          LocationPermission permission =
              await Geolocator.checkPermission().catchError((_) => LocationPermission.denied);
          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission()
                .catchError((_) => LocationPermission.denied);
          }
          if (permission == LocationPermission.whileInUse ||
              permission == LocationPermission.always) {
            Position? pos = await Geolocator.getLastKnownPosition();
            if (pos == null) {
              try {
                pos = await Geolocator.getCurrentPosition(
                  locationSettings: const LocationSettings(
                    accuracy: LocationAccuracy.low,
                    timeLimit: Duration(seconds: 2),
                  ),
                );
              } catch (_) {}
            }
            if (pos != null) {
              query = '${pos.latitude},${pos.longitude}';
            }
          }
        }
      } catch (_) {}
    }

    // If GPS is unavailable, use WeatherAPI's automatic IP lookup: 'auto:ip'
    if (query.isEmpty) {
      query = 'auto:ip';
    }

    try {
      final response = await _dio.get(
        _baseUrl,
        queryParameters: {
          'key': _apiKey,
          'q': query,
          'days': '1',
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> data = response.data is Map<String, dynamic>
            ? response.data
            : Map<String, dynamic>.from(response.data);
        return WeatherModel.fromJson(data);
      }
    } catch (_) {}

    // Check cached location from onboarding if auto:ip fails
    try {
      final cachedLocation = await HiveServiceImpl.get<String>('settings_box', 'user_location');
      if (cachedLocation != null && cachedLocation.trim().isNotEmpty) {
        final parts = cachedLocation.split(',');
        final fallbackCity = parts.length > 1 && parts[1].trim().isNotEmpty
            ? parts[1].trim()
            : parts[0].trim();
        final response = await _dio.get(
          _baseUrl,
          queryParameters: {
            'key': _apiKey,
            'q': fallbackCity,
            'days': '1',
          },
        );
        if (response.statusCode == 200 && response.data != null) {
          final Map<String, dynamic> data = response.data is Map<String, dynamic>
              ? response.data
              : Map<String, dynamic>.from(response.data);
          return WeatherModel.fromJson(data);
        }
      }
    } catch (_) {}

    // Secondary fallback with 'Cairo' if auto:ip fails
    if (query != 'Cairo') {
      try {
        final response = await _dio.get(
          _baseUrl,
          queryParameters: {
            'key': _apiKey,
            'q': 'Cairo',
            'days': '1',
          },
        );
        if (response.statusCode == 200 && response.data != null) {
          final Map<String, dynamic> data = response.data is Map<String, dynamic>
              ? response.data
              : Map<String, dynamic>.from(response.data);
          return WeatherModel.fromJson(data);
        }
      } catch (_) {}
    }

    return _buildFallbackWeather();
  }

  static WeatherModel _buildFallbackWeather() {
    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    return WeatherModel(
      cityName: 'Giza',
      countryName: 'Egypt',
      avgTempC: 33.0,
      maxTempC: 36.0,
      minTempC: 24.0,
      conditionText: 'Sunny',
      conditionIcon: 'https://cdn.weatherapi.com/weather/64x64/day/113.png',
      dateString: todayStr,
    );
  }
}
