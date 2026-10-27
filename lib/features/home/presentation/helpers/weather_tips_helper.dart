import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../data/models/weather_model.dart';

class WeatherTips {
  final List<String> checklistTips;
  final String badgeText;
  final IconData badgeIcon;
  final Color badgeColor;
  final String noteText;

  const WeatherTips({
    required this.checklistTips,
    required this.badgeText,
    required this.badgeIcon,
    required this.badgeColor,
    required this.noteText,
  });

  factory WeatherTips.fromWeather(WeatherModel? weather) {
    if (weather == null) {
      return WeatherTips(
        checklistTips: [
          'style_guide_check_1'.tr(),
          'style_guide_check_2'.tr(),
          'style_guide_check_3'.tr(),
        ],
        badgeText: 'windy'.tr(),
        badgeIcon: Icons.air_rounded,
        badgeColor: const Color(0xFF2EAA9B),
        noteText: 'breezy_note'.tr(),
      );
    }

    final cond = weather.conditionText.toLowerCase();
    final temp = weather.avgTempC;

    // 1. Rainy / Thunder / Drizzle / Shower
    if (cond.contains('rain') ||
        cond.contains('drizzle') ||
        cond.contains('thunder') ||
        cond.contains('shower')) {
      return WeatherTips(
        checklistTips: [
          'weather_tip_rain_1'.tr(),
          'weather_tip_rain_2'.tr(),
          'weather_tip_rain_3'.tr(),
        ],
        badgeText: 'good_to_know_rain'.tr(),
        badgeIcon: Icons.grain_rounded,
        badgeColor: const Color(0xFF1E88E5),
        noteText: 'good_to_know_rain_desc'.tr(),
      );
    }

    // 2. Very Hot (>= 30°C)
    if (temp >= 30) {
      return WeatherTips(
        checklistTips: [
          'weather_tip_hot_1'.tr(),
          'weather_tip_hot_2'.tr(),
          'weather_tip_hot_3'.tr(),
        ],
        badgeText: 'good_to_know_hot'.tr(),
        badgeIcon: Icons.wb_sunny_rounded,
        badgeColor: const Color(0xFFE5A638),
        noteText: 'good_to_know_hot_desc'.tr(),
      );
    }

    // 3. Warm (24°C - 30°C)
    if (temp >= 24) {
      return WeatherTips(
        checklistTips: [
          'weather_tip_warm_1'.tr(),
          'weather_tip_warm_2'.tr(),
          'weather_tip_warm_3'.tr(),
        ],
        badgeText: 'good_to_know_warm'.tr(),
        badgeIcon: Icons.wb_sunny_outlined,
        badgeColor: const Color(0xFFE5A638),
        noteText: 'good_to_know_warm_desc'.tr(),
      );
    }

    // 4. Pleasant / Mild (18°C - 24°C)
    if (temp >= 18) {
      return WeatherTips(
        checklistTips: [
          'weather_tip_mild_1'.tr(),
          'weather_tip_mild_2'.tr(),
          'weather_tip_mild_3'.tr(),
        ],
        badgeText: 'good_to_know_mild'.tr(),
        badgeIcon: Icons.wb_twilight_rounded,
        badgeColor: const Color(0xFF2EAA9B),
        noteText: 'good_to_know_mild_desc'.tr(),
      );
    }

    // 5. Cool / Breezy (12°C - 18°C)
    if (temp >= 12) {
      return WeatherTips(
        checklistTips: [
          'weather_tip_cool_1'.tr(),
          'weather_tip_cool_2'.tr(),
          'weather_tip_cool_3'.tr(),
        ],
        badgeText: 'good_to_know_cool'.tr(),
        badgeIcon: Icons.air_rounded,
        badgeColor: const Color(0xFF5C6BC0),
        noteText: 'good_to_know_cool_desc'.tr(),
      );
    }

    // 6. Cold (< 12°C)
    return WeatherTips(
      checklistTips: [
        'weather_tip_cold_1'.tr(),
        'weather_tip_cold_2'.tr(),
        'weather_tip_cold_3'.tr(),
      ],
      badgeText: 'good_to_know_cold'.tr(),
      badgeIcon: Icons.ac_unit_rounded,
      badgeColor: const Color(0xFF3F51B5),
      noteText: 'good_to_know_cold_desc'.tr(),
    );
  }
}
