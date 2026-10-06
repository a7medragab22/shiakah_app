class WeatherModel {
  final String cityName;
  final String countryName;
  final double avgTempC;
  final double maxTempC;
  final double minTempC;
  final String conditionText;
  final String conditionIcon;
  final String dateString;

  const WeatherModel({
    required this.cityName,
    required this.countryName,
    required this.avgTempC,
    required this.maxTempC,
    required this.minTempC,
    required this.conditionText,
    required this.conditionIcon,
    required this.dateString,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>? ?? {};
    final current = json['current'] as Map<String, dynamic>? ?? {};
    final forecast = json['forecast'] as Map<String, dynamic>? ?? {};
    final forecastDayList = (forecast['forecastday'] as List?) ?? [];
    final firstDayMap = forecastDayList.isNotEmpty
        ? (forecastDayList.first as Map<String, dynamic>)
        : <String, dynamic>{};
    final dayMap = (firstDayMap['day'] as Map<String, dynamic>?) ?? {};

    final currentCondition = current['condition'] as Map<String, dynamic>?;
    final dayCondition = dayMap['condition'] as Map<String, dynamic>?;
    final conditionMap = currentCondition ?? dayCondition ?? {};

    String iconUrl = conditionMap['icon']?.toString() ?? '';
    if (iconUrl.startsWith('//')) {
      iconUrl = 'https:$iconUrl';
    }
    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final rawDate = firstDayMap['date']?.toString();
    final dateString = (rawDate != null && rawDate.trim().isNotEmpty)
        ? rawDate.trim()
        : todayStr;

    final currentTemp = (current['temp_c'] as num?)?.toDouble();
    final avgTemp = (dayMap['avgtemp_c'] as num?)?.toDouble();
    final displayTemp = currentTemp ?? avgTemp ?? 25.0;

    return WeatherModel(
      cityName: location['name']?.toString() ?? 'Giza',
      countryName: location['country']?.toString() ?? 'Egypt',
      avgTempC: displayTemp,
      maxTempC: (dayMap['maxtemp_c'] as num?)?.toDouble() ?? (displayTemp + 4.0),
      minTempC: (dayMap['mintemp_c'] as num?)?.toDouble() ?? (displayTemp - 4.0),
      conditionText: conditionMap['text']?.toString() ?? 'Sunny',
      conditionIcon: iconUrl,
      dateString: dateString,
    );
  }
}
