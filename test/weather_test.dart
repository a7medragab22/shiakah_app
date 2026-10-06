import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shiakah/features/home/data/models/weather_model.dart';
import 'package:shiakah/features/home/data/services/weather_service.dart';
import 'package:shiakah/features/home/presentation/cubit/weather_cubit.dart';
import 'package:shiakah/features/home/presentation/cubit/weather_state.dart';
import 'package:shiakah/features/home/presentation/widgets/weather_card_widget.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    HttpOverrides.global = null;
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  test('WeatherModel parses exact WeatherAPI response correctly', () {
    final sampleJson = {
      "location": {
        "name": "London",
        "region": "City of London, Greater London",
        "country": "United Kingdom",
        "lat": 51.5171,
        "lon": -0.1062,
        "tz_id": "Europe/London",
        "localtime_epoch": 1790518040,
        "localtime": "2026-09-27 15:07"
      },
      "current": {
        "last_updated_epoch": 1790517600,
        "last_updated": "2026-09-27 15:00",
        "temp_c": 21.8,
        "temp_f": 71.2,
        "is_day": 1,
        "condition": {
          "text": "Patchy rain nearby",
          "icon": "//cdn.weatherapi.com/weather/64x64/day/176.png",
          "code": 1063
        }
      },
      "forecast": {
        "forecastday": [
          {
            "date": "2026-09-27",
            "date_epoch": 1790467200,
            "day": {
              "maxtemp_c": 23.2,
              "mintemp_c": 14.2,
              "avgtemp_c": 17.6,
              "condition": {
                "text": "Overcast",
                "icon": "//cdn.weatherapi.com/weather/64x64/day/122.png",
                "code": 1009
              }
            }
          }
        ]
      }
    };

    final weather = WeatherModel.fromJson(sampleJson);
    expect(weather.cityName, 'London');
    expect(weather.countryName, 'United Kingdom');
    expect(weather.avgTempC, 21.8);
    expect(weather.maxTempC, 23.2);
    expect(weather.minTempC, 14.2);
    expect(weather.conditionText, 'Patchy rain nearby');
    expect(weather.conditionIcon, 'https://cdn.weatherapi.com/weather/64x64/day/176.png');
    expect(weather.dateString, '2026-09-27');
  });

  test('WeatherService fetches London directly from WeatherAPI with days=1', () async {
    final service = WeatherService();
    final weather = await service.fetchWeather(city: 'London');
    expect(weather.cityName.toLowerCase(), contains('london'));
    expect(weather.countryName.isNotEmpty, true);
    expect(weather.maxTempC, isNotNull);
    expect(weather.minTempC, isNotNull);
  });

  test('WeatherService fetches auto-detected location cleanly', () async {
    final service = WeatherService();
    final weather = await service.fetchWeather();
    expect(weather.cityName.isNotEmpty, true);
    expect(weather.countryName.isNotEmpty, true);
  });

  testWidgets('WeatherCardWidget renders correctly across states and screen sizes',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0; // 360 dp width
    addTearDown(() {
      tester.view.resetPhysicalSize();
    });

    final cubit = WeatherCubit();

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ar')],
        path: 'assets/translations',
        fallbackLocale: const Locale('ar'),
        startLocale: const Locale('ar'),
        child: ScreenUtilInit(
          designSize: const Size(393, 852),
          builder: (context, child) {
            return MaterialApp(
              locale: context.locale,
              supportedLocales: context.supportedLocales,
              localizationsDelegates: context.localizationDelegates,
              home: Scaffold(
                body: BlocProvider.value(
                  value: cubit,
                  child: const WeatherCardWidget(),
                ),
              ),
            );
          },
        ),
      ),
    );

    // Initial / loading state
    await tester.pump();
    expect(find.byType(WeatherCardWidget), findsOneWidget);

    // Emit loaded state
    cubit.emit(
      WeatherLoaded(
        weather: const WeatherModel(
          cityName: 'Giza',
          countryName: 'Egypt',
          avgTempC: 30.0,
          maxTempC: 35.0,
          minTempC: 22.0,
          conditionText: 'Sunny',
          conditionIcon: 'https://cdn.weatherapi.com/weather/64x64/day/113.png',
          dateString: '2026-09-27',
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(WeatherCardWidget), findsOneWidget);

    // Test on small screen 320px with long text and Arabic locale
    tester.view.physicalSize = const Size(640, 1136);
    tester.view.devicePixelRatio = 2.0;
    cubit.emit(
      WeatherLoaded(
        weather: const WeatherModel(
          cityName: 'Alexandria and New Cairo City',
          countryName: 'United Arab Emirates',
          avgTempC: 38.4,
          maxTempC: 44.0,
          minTempC: 28.0,
          conditionText: 'Thundery outbreaks in nearby with heavy rain',
          conditionIcon: 'https://cdn.weatherapi.com/weather/64x64/day/113.png',
          dateString: '2026-09-27',
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(WeatherCardWidget), findsOneWidget);

    // Test error state
    cubit.emit(const WeatherError(message: 'Network connection failed'));
    await tester.pump();
    expect(find.byType(WeatherCardWidget), findsOneWidget);
  });
}

