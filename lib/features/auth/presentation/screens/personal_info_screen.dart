import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/router.dart';
import '../../../../core/theme/theme.dart';
import '../widgets/auth_buttons.dart';
import '../widgets/auth_form_card.dart';
import '../widgets/auth_header.dart';
import '../widgets/step_progress_indicator.dart';

/// Step 2 of 5 in the style-setup flow.
/// Collects age group and skin tone from the user.
class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  static const _ageGroups = ['1–17', '18–24', '25–34', '35–44', '45+'];

  static const _skinTones = [
    Color(0xFFF5DCCA),
    Color(0xFFE8C5A0),
    Color(0xFFCB9B72),
    Color(0xFFA0714F),
    Color(0xFF6B4226),
    Color(0xFF3D1F10),
  ];

  String? _selectedAge;
  int? _selectedSkinIndex;
  bool _ageExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFE5D8),
      body: Column(
        children: [
          // ── Header with step 2 progress ─────────────────────────────
          AuthHeader(
            type: AuthHeaderType.image,
            imagePath: 'assets/images/cloths.jpg',
            title: 'Create Account',
            fallbackRoute: Routes.genderSelection,
            height: 130.h,
            stepIndicator: const StepProgressIndicator(currentStep: 2),
          ),

          // ── White form card ──────────────────────────────────────────
          AuthFormCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo + title + subtitle (centered)
                Center(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        height: 64.h,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: 14.h),
                      Text(
                        'Tell us about yourself',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: Text(
                          'This helps us personalize your avatar and outfit recommendations.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13.5.sp,
                            color: const Color(0xFF8E8883),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 22.h),

                // ── Age Group section ──────────────────────────────────
                _SectionCard(
                  child: Column(
                    children: [
                      // Section header with expand/collapse
                      GestureDetector(
                        onTap: () =>
                            setState(() => _ageExpanded = !_ageExpanded),
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Age Group',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Icon(
                              _ageExpanded
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                              color: AppColors.textPrimary,
                              size: 22.sp,
                            ),
                          ],
                        ),
                      ),

                      // Radio options (animated visibility)
                      AnimatedCrossFade(
                        duration: const Duration(milliseconds: 220),
                        crossFadeState: _ageExpanded
                            ? CrossFadeState.showFirst
                            : CrossFadeState.showSecond,
                        firstChild: Column(
                          children: _ageGroups.map((age) {
                            final bool selected = _selectedAge == age;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedAge = age),
                              behavior: HitTestBehavior.opaque,
                              child: Padding(
                                padding:
                                    EdgeInsets.symmetric(vertical: 7.h),
                                child: Row(
                                  children: [
                                    _RadioDot(selected: selected),
                                    SizedBox(width: 12.w),
                                    Text(
                                      age,
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: selected
                                            ? FontWeight.w700
                                            : FontWeight.w400,
                                        color: selected
                                            ? const Color(0xFFB5956A)
                                            : const Color(0xFF8E8883),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        secondChild: const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 14.h),

                // ── Skin Tone section ──────────────────────────────────
                _SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Skin Tone',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      SizedBox(height: 16.h),

                      // Avatar preview
                      Center(
                        child: Container(
                          width: 72.w,
                          height: 72.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFE2D6C6),
                              width: 2,
                            ),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/man.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 16.h),

                      // Skin tone colour swatches
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(_skinTones.length, (i) {
                          final bool selected = _selectedSkinIndex == i;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedSkinIndex = i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 38.w,
                              height: 38.w,
                              decoration: BoxDecoration(
                                color: _skinTones[i],
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selected
                                      ? const Color(0xFFB5956A)
                                      : Colors.transparent,
                                  width: 2.5,
                                ),
                                boxShadow: selected
                                    ? [
                                        BoxShadow(
                                          color: _skinTones[i]
                                              .withValues(alpha: 0.5),
                                          blurRadius: 8,
                                          spreadRadius: 1,
                                        ),
                                      ]
                                    : [],
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 28.h),

                // Continue button
                AuthPrimaryButton(
                  label: 'Continue',
                  onPressed: () => context.go(Routes.bodyType),
                ),

                SizedBox(height: 12.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Rounded card container used for each section on this screen.
class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFEEE8DF), width: 1),
      ),
      child: child,
    );
  }
}

/// Circular radio indicator dot.
class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected});
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 18.w,
      height: 18.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? const Color(0xFFB5956A) : Colors.transparent,
        border: Border.all(
          color: selected ? const Color(0xFFB5956A) : const Color(0xFFD0C8BE),
          width: 1.8,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 7.w,
                height: 7.w,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }
}
