import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/local_storage/local_storage.dart';
import '../../../../core/router/router.dart';
import '../../../../core/theme/theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  static const Color _bgColor = Color(0xFFEFE5D8);

  Future<void> _finishOnboarding() async {
    await HiveServiceImpl.put<bool>(
        'settings_box', 'has_seen_onboarding', true);
    if (mounted) {
      context.go(Routes.welcome);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          child: Column(
            children: [
              // Top Bar with Skip Button
              SizedBox(
                height: 32.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (_currentIndex < 2)
                      GestureDetector(
                        onTap: _finishOnboarding,
                        child: Text(
                          'skip'.tr(),
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF8E8883),
                            decoration: TextDecoration.underline,
                            decorationColor: const Color(0xFF8E8883),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              SizedBox(height: 10.h),

              // Responsive Page View
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  children: [
                    _buildFirstSlide(),
                    _buildSecondSlide(),
                    _buildThirdSlide(),
                  ],
                ),
              ),

              SizedBox(height: 12.h),

              // Bottom Section (Indicator & Action Button)
              _buildBottomSection(),
            ],
          ),
        ),
      ),
    );
  }

  /// Slide 1: Discover Your Perfect Style
  Widget _buildFirstSlide() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            // Images Layout
            Expanded(
              flex: 12,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left Image: Tall capsule (frame_17963)
                  Expanded(
                    flex: 11,
                    child: Image.asset(
                      'assets/images/frame_17963.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  // Right Column: Circle top (frame_17965) + Rounded rect bottom (frame_17964)
                  Expanded(
                    flex: 10,
                    child: Column(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Image.asset(
                            'assets/images/frame_17965.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Expanded(
                          flex: 6,
                          child: Image.asset(
                            'assets/images/frame_17964.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // Text Section
            Expanded(
              flex: 5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'onboarding_title_1'.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 23.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14.w),
                    child: Text(
                      'onboarding_subtitle_1'.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF6F6A65),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// Slide 2: Style Smarter with AI
  Widget _buildSecondSlide() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            // Images Layout
            Expanded(
              flex: 12,
              child: Column(
                children: [
                  // Top Row: Flat lay outfits (frame_17975 & frame_17976)
                  Expanded(
                    flex: 6,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Image.asset(
                            'assets/images/frame_17975.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Image.asset(
                            'assets/images/frame_17976.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),
                  // Bottom Image: Center piece with recommendations (frame_17977)
                  Expanded(
                    flex: 5,
                    child: SizedBox(
                      width: double.infinity,
                      child: Image.asset(
                        'assets/images/frame_17977.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // Text Section
            Expanded(
              flex: 5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'onboarding_title_2'.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Text(
                      'onboarding_subtitle_2'.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF6F6A65),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// Slide 3: See It on You First
  Widget _buildThirdSlide() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            // Images Layout (Three mannequin panels joined seamlessly)
            Expanded(
              flex: 12,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.r),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Left Panel: Beige top & trousers mannequin (frame_1000005722)
                    Expanded(
                      flex: 10,
                      child: Image.asset(
                        'assets/images/frame_1000005722.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Middle Panel: Blue shirt mannequin (frame_1000005725)
                    Expanded(
                      flex: 13,
                      child: Image.asset(
                        'assets/images/frame_1000005725.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Right Panel: Pink striped polo mannequin (frame_1000005723)
                    Expanded(
                      flex: 10,
                      child: Image.asset(
                        'assets/images/frame_1000005723.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20.h),

            // Text Section
            Expanded(
              flex: 5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'onboarding_title_3'.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Text(
                      'onboarding_subtitle_3'.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF6F6A65),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// Bottom Section with Indicators and Button
  Widget _buildBottomSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Dots Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            3,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: EdgeInsets.symmetric(horizontal: 3.w),
              width: _currentIndex == index ? 24.w : 7.w,
              height: 7.h,
              decoration: BoxDecoration(
                color: _currentIndex == index
                    ? AppColors.primary
                    : Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
        ),

        SizedBox(height: 18.h),

        // Action Button
        SizedBox(
          width: double.infinity,
          height: 52.h,
          child: ElevatedButton(
            onPressed: () {
              if (_currentIndex < 2) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeInOut,
                );
              } else {
                _finishOnboarding();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
            ),
            child: Text(
              _currentIndex == 2 ? 'get_started'.tr() : 'next'.tr(),
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),

        SizedBox(height: 6.h),
      ],
    );
  }
}
