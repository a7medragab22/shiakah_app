import 'package:equatable/equatable.dart';
import '../../data/models/weather_model.dart';

abstract class WeatherState extends Equatable {
  const WeatherState();

  @override
  List<Object?> get props => [];
}

class WeatherInitial extends WeatherState {}

class WeatherLoading extends WeatherState {
  final bool isRefreshing;
  const WeatherLoading({this.isRefreshing = false});

  @override
  List<Object?> get props => [isRefreshing];
}

class WeatherLoaded extends WeatherState {
  final WeatherModel weather;
  final bool isRefreshing;

  const WeatherLoaded({required this.weather, this.isRefreshing = false});

  @override
  List<Object?> get props => [weather, isRefreshing];
}

class WeatherError extends WeatherState {
  final String message;
  final WeatherModel? cachedWeather;

  const WeatherError({required this.message, this.cachedWeather});

  @override
  List<Object?> get props => [message, cachedWeather];
}
