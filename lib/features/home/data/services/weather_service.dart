import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import '../models/weather_model.dart';

class WeatherService {
  final Dio _dio;
  static const String _apiKey = '8885b48641ca49199bd142302261709';
  static const String _baseUrl = 'https://api.weatherapi.com/v1/forecast.json';

  WeatherService({Dio? dio}) : _dio = dio ?? Dio();

  Future<WeatherModel> fetchWeather({String? city}) async {
    String query = city ?? '';

    if (query.isEmpty) {
      try {
        bool serviceEnabled =
            await Geolocator.isLocationServiceEnabled().catchError((_) => false);
        if (serviceEnabled) {
          LocationPermission permission =
              await Geolocator.checkPermission().catchError((_) => LocationPermission.denied);
          if (permission == LocationPermission.whileInUse ||
              permission == LocationPermission.always) {
            Position? pos = await Geolocator.getLastKnownPosition()
                .timeout(const Duration(seconds: 1), onTimeout: () => null)
                .catchError((_) => null);
            if (pos != null) {
              query = '${pos.latitude},${pos.longitude}';
            }
          }
        }
      } catch (_) {}
    }

    if (query.isEmpty) {
      query = 'giza';
    }

    try {
      final response = await _dio.get(
        _baseUrl,
        queryParameters: {
          'key': _apiKey,
          'q': query,
        },
        options: Options(
          sendTimeout: const Duration(seconds: 6),
          receiveTimeout: const Duration(seconds: 6),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> data = response.data is Map<String, dynamic>
            ? response.data
            : Map<String, dynamic>.from(response.data);
        return WeatherModel.fromJson(data);
      }
    } catch (_) {}

    // Fallback data if offline or error occurs
    return const WeatherModel(
      cityName: 'Giza',
      countryName: 'Egypt',
      avgTempC: 33.0,
      maxTempC: 36.0,
      minTempC: 24.0,
      conditionText: 'Sunny',
      conditionIcon: 'https://cdn.weatherapi.com/weather/64x64/day/113.png',
      dateString: '',
    );
  }
}
