import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../core/localization/app_localization_helper.dart';
import '../../../../core/localization/locales.dart';
import '../../../../core/theme/theme.dart';
import '../../../profile/presentation/screens/item_details_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../data/models/weather_model.dart';
import '../cubit/weather_cubit.dart';
import '../cubit/weather_state.dart';
import '../helpers/weather_tips_helper.dart';
import '../widgets/camera_access_bottom_sheet.dart';
import '../widgets/weather_card_widget.dart';
import 'add_manually_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
  }

  WeatherModel? _extractWeather(WeatherState state) {
    if (state is WeatherLoaded) return state.weather;
    if (state is WeatherError) return state.cachedWeather;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<WeatherCubit>(
      create: (_) => WeatherCubit()..fetchWeather(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: const Color(0xFFFAFAFA),
            body: SafeArea(
              child: RefreshIndicator(
                color: const Color(0xFFC8A97E),
                onRefresh: () async {
                  await context.read<WeatherCubit>().fetchWeather(isRefresh: true);
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── 1. Top Header (Profile + Greeting & Language & User Icons) ──
                      _buildHeader(context),
                      SizedBox(height: 18.h),

                      // ── 2. Weather & Location Card ────────────────────────────────
                      const WeatherCardWidget(),
                      SizedBox(height: 16.h),

                      // ── 3. Today's Style Guide Card (Weather-driven tips) ─────────
                      BlocBuilder<WeatherCubit, WeatherState>(
                        builder: (context, weatherState) {
                          final weather = _extractWeather(weatherState);
                          final tips = WeatherTips.fromWeather(weather);
                          return _buildStyleGuideCard(context, tips);
                        },
                      ),
                      SizedBox(height: 16.h),

                      // ── 4. Action Cards (Add Clothing & Add Manually) ──────────────
                      _buildActionCardsRow(context),
                      SizedBox(height: 8.h),

                      // Sub-text under action cards
                      Center(
                        child: Text(
                          'scanning_note'.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: const Color(0xFFA09B95),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      SizedBox(height: 18.h),

                      // ── 5. Good to Know Card (Weather-driven advice) ───────────────
                      BlocBuilder<WeatherCubit, WeatherState>(
                        builder: (context, weatherState) {
                          final weather = _extractWeather(weatherState);
                          final tips = WeatherTips.fromWeather(weather);
                          return _buildGoodToKnowCard(tips);
                        },
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Header Widget
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left Side: Profile Avatar + Greeting Text
        GestureDetector(
          onTap: () => _openProfile(context),
          child: Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFE5D5C0),
                    width: 1.2,
                  ),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/man.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'good_morning'.tr(),
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF8E8883),
                    ),
                  ),
                  Text(
                    AppLocalizationHelper.getUserDisplayName(context),
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Right Side: Globe Language Switcher & Profile Buttons
        Row(
          children: [
            // Globe Language Button
            Container(
              width: 42.w,
              height: 42.w,
              decoration: BoxDecoration(
                color: const Color(0xFFF6F2EC),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: IconButton(
                onPressed: () {
                  context.setLocale(
                    context.isArabic ? Locales.english : Locales.arabic,
                  );
                },
                icon: Icon(
                  Icons.language_rounded,
                  color: AppColors.primary,
                  size: 22.sp,
                ),
                padding: EdgeInsets.zero,
              ),
            ),
            SizedBox(width: 8.w),

            // Profile Button
            Container(
              width: 42.w,
              height: 42.w,
              decoration: BoxDecoration(
                color: const Color(0xFFF6F2EC),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: IconButton(
                onPressed: () => _openProfile(context),
                icon: Icon(
                  Icons.person_outline_rounded,
                  color: AppColors.textPrimary,
                  size: 22.sp,
                ),
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Today's Style Guide Card (Tap to open 3D Avatar Outfits)
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildStyleGuideCard(BuildContext context, WeatherTips tips) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ItemDetailsScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(18.w),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "today_style_guide".tr(),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC8A97E).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.accessibility_new_rounded,
                        size: 14.sp,
                        color: const Color(0xFFC8A97E),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '3D Try-On',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF9E7E52),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Text(
              'style_guide_subtitle'.tr(),
              style: TextStyle(
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF8E8883),
              ),
            ),
            SizedBox(height: 16.h),

            // Checklist Items (Dynamic from real Weather)
            for (int i = 0; i < tips.checklistTips.length; i++) ...[
              if (i > 0) SizedBox(height: 10.h),
              _buildChecklistItem(tips.checklistTips[i]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Green Check Circle
        Container(
          width: 22.w,
          height: 22.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF4CAF50),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Icon(
              Icons.check_rounded,
              color: const Color(0xFF4CAF50),
              size: 14.sp,
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13.5.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF5E5954),
            ),
          ),
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Action Cards (Add Clothing & Add Manually)
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildActionCardsRow(BuildContext context) {
    return Row(
      children: [
        // ── Card 1: Add Clothing (Primary Brown/Gold Card) ────────────────
        Expanded(
          child: GestureDetector(
            onTap: () => CameraAccessBottomSheet.show(context),
            child: Container(
              height: 140.h,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: const Color(0xFFC8A97E),
                borderRadius: BorderRadius.circular(18.r),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFC8A97E).withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Icon Frame
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.qr_code_scanner_rounded,
                        color: Colors.white,
                        size: 22.sp,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'add_clothing'.tr(),
                        style: TextStyle(
                          fontSize: 16.5.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'add_clothing_sub'.tr(),
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withValues(alpha: 0.9),
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),

        // ── Card 2: Add Manually (White Card) ──────────────────────────────
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddManuallyScreen(),
                ),
              );
            },
            child: Container(
              height: 140.h,
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Pencil Icon Frame
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F3EE),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: const Color(0xFFE8DFC0),
                        width: 1.0,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.edit_outlined,
                        color: const Color(0xFFB5956A),
                        size: 20.sp,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'add_manually'.tr(),
                        style: TextStyle(
                          fontSize: 16.5.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFC0A580),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'add_manually_sub'.tr(),
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF8E8883),
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Good to Know Card
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildGoodToKnowCard(WeatherTips tips) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F5F0),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: const Color(0xFFEEE7DD),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'good_to_know'.tr(),
                style: TextStyle(
                  fontSize: 17.5.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              Row(
                children: [
                  Icon(
                    tips.badgeIcon,
                    color: tips.badgeColor,
                    size: 18.sp,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    tips.badgeText,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: tips.badgeColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            tips.noteText,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF6E6862),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
