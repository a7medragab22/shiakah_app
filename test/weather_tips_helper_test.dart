import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiakah/features/home/data/models/weather_model.dart';
import 'package:shiakah/features/home/presentation/helpers/weather_tips_helper.dart';

void main() {
  test('Null weather returns default style guide tips and good to know note', () {
    final tips = WeatherTips.fromWeather(null);
    expect(tips.checklistTips.length, 3);
    expect(tips.badgeIcon, Icons.air_rounded);
  });

  test('Rainy weather returns rain tips and umbrella reminder', () {
    const rainyWeather = WeatherModel(
      cityName: 'Alexandria',
      countryName: 'Egypt',
      avgTempC: 19.0,
      maxTempC: 22.0,
      minTempC: 15.0,
      conditionText: 'Light rain shower',
      conditionIcon: '',
      dateString: '2026-10-27',
    );

    final tips = WeatherTips.fromWeather(rainyWeather);
    expect(tips.checklistTips.length, 3);
    expect(tips.badgeIcon, Icons.grain_rounded);
    expect(tips.badgeColor, const Color(0xFF1E88E5));
  });

  test('Hot weather (32C) returns hot tips and sun icon', () {
    const hotWeather = WeatherModel(
      cityName: 'Aswan',
      countryName: 'Egypt',
      avgTempC: 34.0,
      maxTempC: 38.0,
      minTempC: 26.0,
      conditionText: 'Sunny',
      conditionIcon: '',
      dateString: '2026-10-27',
    );

    final tips = WeatherTips.fromWeather(hotWeather);
    expect(tips.checklistTips.length, 3);
    expect(tips.badgeIcon, Icons.wb_sunny_rounded);
    expect(tips.badgeColor, const Color(0xFFE5A638));
  });

  test('Pleasant weather (22C) returns mild tips and twilight icon', () {
    const mildWeather = WeatherModel(
      cityName: 'Cairo',
      countryName: 'Egypt',
      avgTempC: 22.0,
      maxTempC: 25.0,
      minTempC: 18.0,
      conditionText: 'Clear',
      conditionIcon: '',
      dateString: '2026-10-27',
    );

    final tips = WeatherTips.fromWeather(mildWeather);
    expect(tips.checklistTips.length, 3);
    expect(tips.badgeIcon, Icons.wb_twilight_rounded);
  });

  test('Cold weather (9C) returns winter cold tips and snowflake icon', () {
    const coldWeather = WeatherModel(
      cityName: 'Saint Catherine',
      countryName: 'Egypt',
      avgTempC: 8.0,
      maxTempC: 12.0,
      minTempC: 2.0,
      conditionText: 'Clear',
      conditionIcon: '',
      dateString: '2026-10-27',
    );

    final tips = WeatherTips.fromWeather(coldWeather);
    expect(tips.checklistTips.length, 3);
    expect(tips.badgeIcon, Icons.ac_unit_rounded);
    expect(tips.badgeColor, const Color(0xFF3F51B5));
  });
}
