import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/router.dart';
import '../../../../core/theme/theme.dart';
import '../widgets/auth_buttons.dart';
import '../widgets/auth_form_card.dart';
import '../widgets/auth_header.dart';
import '../widgets/step_progress_indicator.dart';

/// Step 1 of 5 in the style-setup flow.
/// Lets the user pick their fashion category: Men or Women.
class GenderSelectionScreen extends StatefulWidget {
  const GenderSelectionScreen({super.key});

  @override
  State<GenderSelectionScreen> createState() => _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends State<GenderSelectionScreen> {
  /// null = nothing selected yet, 'men' or 'women'
  String? _selected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFE5D8),
      body: Column(
        children: [
          // ── Header with progress indicator ──────────────────────────
          AuthHeader(
            type: AuthHeaderType.image,
            imagePath: 'assets/images/cloths.jpg',
            title: 'Create Account',
            fallbackRoute: Routes.styleSetup,
            height: 130.h,
            stepIndicator: const StepProgressIndicator(currentStep: 1),
          ),

          // ── White form card ──────────────────────────────────────────
          AuthFormCard(
            child: Column(
              children: [
                // Logo
                Image.asset(
                  'assets/images/logo.png',
                  height: 64.h,
                  fit: BoxFit.contain,
                ),

                SizedBox(height: 14.h),

                // Title
                Text(
                  'Who are we styling today?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),

                SizedBox(height: 8.h),

                // Subtitle
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Text(
                    'Choose your fashion category to personalize '
                    'your AI stylist and recommendations.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF8E8883),
                      height: 1.4,
                    ),
                  ),
                ),

                SizedBox(height: 28.h),

                // Gender cards
                Row(
                  children: [
                    Expanded(
                      child: _GenderCard(
                        label: 'Men',
                        imagePath: 'assets/images/man.png',
                        isSelected: _selected == 'men',
                        onTap: () => setState(() => _selected = 'men'),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: _GenderCard(
                        label: 'Women',
                        imagePath: 'assets/images/women.jpg',
                        isSelected: _selected == 'women',
                        onTap: () => setState(() => _selected = 'women'),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 36.h),

                // Continue — enabled only when a gender is selected
                AuthPrimaryButton(
                  label: 'Continue',
                  onPressed: _selected == null
                      ? () {}
                      : () => context.go(Routes.personalInfo),
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
// Private: individual gender selection card
// ─────────────────────────────────────────────────────────────────────────────

class _GenderCard extends StatelessWidget {
  const _GenderCard({
    required this.label,
    required this.imagePath,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String imagePath;
  final bool isSelected;
  final VoidCallback onTap;

  static const Color _borderSelected = Color(0xFFB5956A);
  static const Color _borderIdle = Color(0xFFE2D6C6);
  static const Color _bgSelected = Color(0xFFFDF8F2);
  static const Color _bgIdle = Colors.white;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? _bgSelected : _bgIdle,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? _borderSelected : _borderIdle,
            width: isSelected ? 2.0 : 1.3,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFB5956A).withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.asset(
                imagePath,
                height: 130.h,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: isSelected ? _borderSelected : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
