import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/weather_model.dart';
import '../../data/services/weather_service.dart';
import 'weather_state.dart';

class WeatherCubit extends Cubit<WeatherState> {
  final WeatherService _weatherService;

  WeatherCubit({WeatherService? weatherService})
      : _weatherService = weatherService ?? WeatherService(),
        super(WeatherInitial());

  Future<void> fetchWeather({String? city, bool isRefresh = false}) async {
    WeatherModel? currentData;
    if (state is WeatherLoaded) {
      currentData = (state as WeatherLoaded).weather;
    }

    if (!isRefresh && state is! WeatherLoaded) {
      emit(const WeatherLoading());
    } else if (isRefresh && currentData != null) {
      emit(WeatherLoaded(weather: currentData, isRefreshing: true));
    }

    try {
      final weather = await _weatherService.fetchWeather(city: city);
      emit(WeatherLoaded(weather: weather, isRefreshing: false));
    } catch (e) {
      if (currentData != null) {
        emit(WeatherLoaded(weather: currentData, isRefreshing: false));
      } else {
        emit(WeatherError(message: e.toString()));
      }
    }
  }
}
