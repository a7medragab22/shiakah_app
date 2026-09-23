import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../core/localization/app_localization_helper.dart';
import '../../../../core/theme/theme.dart';
import '../cubit/weather_cubit.dart';
import '../cubit/weather_state.dart';
import '../../data/models/weather_model.dart';

class WeatherCardWidget extends StatelessWidget {
  const WeatherCardWidget({super.key});

  String _formatDate(BuildContext context, String? dateStr) {
    final dt = _safeParseDate(dateStr);
    final isAr = context.isArabic;
    const weekdaysEn = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const weekdaysAr = ['الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'];
    const monthsEn = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    const monthsAr = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
    final weekday = isAr ? weekdaysAr[dt.weekday - 1] : weekdaysEn[dt.weekday - 1];
    final month = isAr ? monthsAr[dt.month - 1] : monthsEn[dt.month - 1];
    return isAr ? '$weekday، ${dt.day} $month' : '$weekday • $month ${dt.day}';
  }

  String _localizeCondition(BuildContext context, String condition) {
    if (!context.isArabic) return condition;
    final cond = condition.toLowerCase();
    if (cond.contains('sunny')) return 'مشمس';
    if (cond.contains('clear')) return 'صافٍ';
    if (cond.contains('partly')) return 'غائم جزئياً';
    if (cond.contains('cloud') || cond.contains('overcast')) return 'غائم';
    if (cond.contains('thunder') || cond.contains('storm')) return 'عاصفة رعدية';
    if (cond.contains('rain') || cond.contains('drizzle') || cond.contains('shower')) return 'ممطر';
    if (cond.contains('snow') || cond.contains('ice') || cond.contains('sleet') || cond.contains('blizzard')) return 'ثلوج';
    if (cond.contains('mist') || cond.contains('fog')) return 'ضباب';
    if (cond.contains('wind') || cond.contains('breeze')) return 'عاصف';
    return condition;
  }

  static DateTime _safeParseDate(String? dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty) {
      return DateTime.now();
    }
    final trimmed = dateStr.trim();
    // Fast path: parse YYYY-MM-DD safely using int.tryParse to avoid FormatException in DateTime.parse
    final parts = trimmed.split(RegExp(r'[-/ T]'));
    if (parts.length >= 3) {
      final y = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      final d = int.tryParse(parts[2]);
      if (y != null && m != null && d != null && m >= 1 && m <= 12 && d >= 1 && d <= 31) {
        return DateTime(y, m, d);
      }
    }
    // Only attempt tryParse if it looks like an ISO date
    if (RegExp(r'^\d{4}-\d{2}-\d{2}').hasMatch(trimmed)) {
      final parsed = DateTime.tryParse(trimmed);
      if (parsed != null) return parsed;
    }
    return DateTime.now();
  }

  IconData _getWeatherIconData(String condition) {
    final cond = condition.toLowerCase();
    if (cond.contains('rain') || cond.contains('drizzle') || cond.contains('shower')) {
      return Icons.grain_rounded;
    } else if (cond.contains('thunder') || cond.contains('storm')) {
      return Icons.thunderstorm_rounded;
    } else if (cond.contains('snow') || cond.contains('ice') || cond.contains('sleet') || cond.contains('blizzard')) {
      return Icons.ac_unit_rounded;
    } else if (cond.contains('cloud') || cond.contains('overcast')) {
      return Icons.wb_cloudy_rounded;
    } else if (cond.contains('mist') || cond.contains('fog')) {
      return Icons.blur_on_rounded;
    } else if (cond.contains('wind') || cond.contains('breeze')) {
      return Icons.air_rounded;
    } else if (cond.contains('clear') || cond.contains('night')) {
      return Icons.nights_stay_rounded;
    } else {
      return Icons.wb_sunny_rounded;
    }
  }

  Color _getWeatherIconColor(String condition) {
    final cond = condition.toLowerCase();
    if (cond.contains('rain') || cond.contains('drizzle') || cond.contains('shower') || cond.contains('thunder') || cond.contains('storm')) {
      return const Color(0xFF4A90E2);
    } else if (cond.contains('snow') || cond.contains('ice')) {
      return const Color(0xFF64B5F6);
    } else if (cond.contains('cloud') || cond.contains('overcast') || cond.contains('mist') || cond.contains('fog')) {
      return const Color(0xFF78909C);
    } else if (cond.contains('wind')) {
      return const Color(0xFF2EAA9B);
    } else if (cond.contains('clear') || cond.contains('night')) {
      return const Color(0xFF5C6BC0);
    } else {
      return const Color(0xFFE5A638);
    }
  }

  String _getWeatherRecommendation(double tempC, String condition) {
    final lowerCond = condition.toLowerCase();
    if (lowerCond.contains('rain') || lowerCond.contains('drizzle') || lowerCond.contains('thunder')) {
      return 'weather_rec_rain'.tr();
    } else if (tempC >= 32) {
      return 'weather_rec_hot'.tr();
    } else if (tempC >= 22) {
      return 'weather_rec_comfortable'.tr();
    } else if (tempC >= 14) {
      return 'weather_rec_mild'.tr();
    } else {
      return 'weather_rec_cold'.tr();
    }
  }

  Widget _buildWeatherIcon(WeatherModel weather) {
    final fallbackIconData = _getWeatherIconData(weather.conditionText);
    final iconColor = _getWeatherIconColor(weather.conditionText);

    final fallbackWidget = Icon(
      fallbackIconData,
      size: 28.sp,
      color: iconColor,
    );

    final iconUrl = weather.conditionIcon.trim();
    if (iconUrl.isEmpty || !iconUrl.startsWith('http')) {
      return fallbackWidget;
    }

    return CachedNetworkImage(
      imageUrl: iconUrl,
      width: 36.w,
      height: 36.w,
      fit: BoxFit.contain,
      placeholder: (_, __) => fallbackWidget,
      errorWidget: (_, __, ___) => fallbackWidget,
    );
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

        final themeColor = _getWeatherIconColor(weather.conditionText);

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
                        _formatDate(context, weather.dateString),
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
                            AppLocalizationHelper.formatLocation(
                              context,
                              weather.cityName,
                              weather.countryName,
                            ),
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
                      // Left: Dynamic Weather Icon + Condition Text
                      Row(
                        children: [
                          _buildWeatherIcon(weather),
                          SizedBox(width: 8.w),
                          Text(
                            _localizeCondition(context, weather.conditionText),
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w600,
                              color: themeColor,
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
                              color: themeColor,
                              height: 1.0,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '${'high_short'.tr()}:${weather.maxTempC.round()}°   ${'low_short'.tr()}:${weather.minTempC.round()}°',
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
            'weather_error'.tr(),
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.secondary,
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<WeatherCubit>().fetchWeather(isRefresh: true);
            },
            child: Text('retry'.tr()),
          ),
        ],
      ),
    );
  }
}
