import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/theme.dart';
import '../cubit/weather_cubit.dart';
import '../cubit/weather_state.dart';
import '../../data/models/weather_model.dart';

class WeatherCardWidget extends StatelessWidget {
  const WeatherCardWidget({super.key});

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.tryParse(dateStr) ?? DateTime.now();
      const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final weekday = weekdays[dt.weekday - 1];
      final month = months[dt.month - 1];
      return '$weekday • $month ${dt.day}';
    } catch (_) {
      return 'Today';
    }
  }

  String _getWeatherRecommendation(double tempC, String condition) {
    final lowerCond = condition.toLowerCase();
    if (lowerCond.contains('rain') || lowerCond.contains('drizzle') || lowerCond.contains('thunder')) {
      return 'Rain expected. Don\'t forget your umbrella and waterproof outerwear.';
    } else if (tempC >= 32) {
      return 'Very warm weather. Light, breathable cotton outfits recommended.';
    } else if (tempC >= 22) {
      return 'Comfortable weather for everyday styling.';
    } else if (tempC >= 14) {
      return 'Mild weather. Perfect for light jacket or layered outfits.';
    } else {
      return 'Chilly weather. Consider warm sweater or heavy jacket.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeatherCubit, WeatherState>(
      builder: (context, state) {
        if (state is WeatherInitial || state is WeatherLoading) {
          return _buildLoadingShimmer();
        }

        WeatherModel? weather;
        bool isRefreshing = false;

        if (state is WeatherLoaded) {
          weather = state.weather;
          isRefreshing = state.isRefreshing;
        } else if (state is WeatherError) {
          weather = state.cachedWeather;
        }

        if (weather == null) {
          return _buildErrorState(context);
        }

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              context.read<WeatherCubit>().fetchWeather(isRefresh: true);
            },
            borderRadius: BorderRadius.circular(18.r),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(
                  color: const Color(0xFFEAE3D9),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Date & Location + Refresh Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDate(weather.dateString),
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF9E9893),
                        ),
                      ),
                      Row(
                        children: [
                          if (isRefreshing)
                            Padding(
                              padding: EdgeInsets.only(right: 6.w),
                              child: SizedBox(
                                width: 12.w,
                                height: 12.w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFFB5956A),
                                ),
                              ),
                            )
                          else
                            Icon(
                              Icons.location_on_outlined,
                              size: 16.sp,
                              color: const Color(0xFFB5956A),
                            ),
                          SizedBox(width: 4.w),
                          Text(
                            '${weather.cityName}, ${weather.countryName}',
                            style: TextStyle(
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFB5956A),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),

                  // Row 2: Condition & Temperature
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Left: Condition Icon + Text
                      Row(
                        children: [
                          if (weather.conditionIcon.isNotEmpty)
                            Image.network(
                              weather.conditionIcon,
                              width: 34.w,
                              height: 34.w,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.wb_sunny_outlined,
                                size: 26.sp,
                                color: const Color(0xFFE5A638),
                              ),
                            )
                          else
                            Icon(
                              Icons.wb_sunny_outlined,
                              size: 26.sp,
                              color: const Color(0xFFE5A638),
                            ),
                          SizedBox(width: 8.w),
                          Text(
                            weather.conditionText,
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFE5A638),
                            ),
                          ),
                        ],
                      ),

                      // Right: Temperature + High/Low
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${weather.avgTempC.round()}°',
                            style: TextStyle(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFE5A638),
                              height: 1.0,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'H:${weather.maxTempC.round()}°   L:${weather.minTempC.round()}°',
                            style: TextStyle(
                              fontSize: 12.5.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF8E8883),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),

                  // Row 3: Golden Recommendation Banner
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBF4E8),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: const Color(0xFFF3E4CD),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          color: const Color(0xFFC8A97E),
                          size: 17.sp,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            _getWeatherRecommendation(
                              weather.avgTempC,
                              weather.conditionText,
                            ),
                            style: TextStyle(
                              fontSize: 12.5.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFB5956A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: Container(
        width: double.infinity,
        height: 150.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFEAE3D9), width: 1.2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Failed to load weather data',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.secondary,
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<WeatherCubit>().fetchWeather(isRefresh: true);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
