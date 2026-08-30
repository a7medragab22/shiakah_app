import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/router.dart';
import '../../../../core/theme/theme.dart';
import '../widgets/auth_buttons.dart';
import '../widgets/auth_form_card.dart';
import '../widgets/auth_header.dart';
import '../widgets/step_progress_indicator.dart';

class _BodyTypeItem {
  final String id;
  final String title;
  final String subtitle;
  final String imagePath;

  const _BodyTypeItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imagePath,
  });
}

/// Step 3 of 5 in the style-setup flow.
/// Collects height, weight, and body type from the user.
class BodyTypeScreen extends StatefulWidget {
  const BodyTypeScreen({super.key});

  @override
  State<BodyTypeScreen> createState() => _BodyTypeScreenState();
}

class _BodyTypeScreenState extends State<BodyTypeScreen> {
  final TextEditingController _heightController =
      TextEditingController(text: '183');
  final TextEditingController _weightController =
      TextEditingController(text: '76');

  String _selectedBodyType = 'slim';

  static const List<_BodyTypeItem> _topRowItems = [
    _BodyTypeItem(
      id: 'slim',
      title: 'Slim',
      subtitle: 'Lean physique.',
      imagePath: 'assets/images/body_type/slim.png',
    ),
    _BodyTypeItem(
      id: 'regular',
      title: 'Regular',
      subtitle: 'Balanced physique.',
      imagePath: 'assets/images/body_type/regular.png',
    ),
    _BodyTypeItem(
      id: 'athletic',
      title: 'Athletic',
      subtitle: 'Athletic build.',
      imagePath: 'assets/images/body_type/athletic.png',
    ),
  ];

  static const List<_BodyTypeItem> _bottomRowItems = [
    _BodyTypeItem(
      id: 'stocky',
      title: 'Stocky',
      subtitle: 'Broad build.',
      imagePath: 'assets/images/body_type/stocky.png',
    ),
    _BodyTypeItem(
      id: 'plus_size',
      title: 'Plus Size',
      subtitle: 'Fuller build.',
      imagePath: 'assets/images/body_type/plus_size.png',
    ),
  ];

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFE5D8),
      body: Column(
        children: [
          // ── Header with Step 3 Progress ──────────────────────────────
          AuthHeader(
            type: AuthHeaderType.image,
            imagePath: 'assets/images/cloths.jpg',
            title: 'Create Account',
            fallbackRoute: Routes.personalInfo,
            height: 130.h,
            stepIndicator: const StepProgressIndicator(currentStep: 3),
          ),

          // ── White Form Card ──────────────────────────────────────────
          AuthFormCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo + Title + Subtitle
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
                        'Tell us about your body',
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
                          'This helps us recommend outfits that fit you better and improve your AI avatar.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF8E8883),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 22.h),

                // ── Height & Weight Row ─────────────────────────────────
                Row(
                  children: [
                    // Height Field
                    Expanded(
                      child: _MeasurementField(
                        label: 'Height',
                        controller: _heightController,
                      ),
                    ),
                    SizedBox(width: 14.w),
                    // Weight Field
                    Expanded(
                      child: _MeasurementField(
                        label: 'Weight',
                        controller: _weightController,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20.h),

                // ── Body Type Section ───────────────────────────────────
                Text(
                  'Body Type',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),

                SizedBox(height: 12.h),

                // Top Row: 3 items (Slim, Regular, Athletic)
                Row(
                  children: _topRowItems.map((item) {
                    final bool isSelected = _selectedBodyType == item.id;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: _BodyTypeCard(
                          item: item,
                          isSelected: isSelected,
                          onTap: () => setState(() => _selectedBodyType = item.id),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                SizedBox(height: 10.h),

                // Bottom Row: 2 items (Stocky, Plus Size)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 48.w),
                    ..._bottomRowItems.map((item) {
                      final bool isSelected = _selectedBodyType == item.id;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: _BodyTypeCard(
                            item: item,
                            isSelected: isSelected,
                            onTap: () =>
                                setState(() => _selectedBodyType = item.id),
                          ),
                        ),
                      );
                    }),
                    SizedBox(width: 48.w),
                  ],
                ),

                SizedBox(height: 28.h),

                // ── Continue Button ─────────────────────────────────────
                AuthPrimaryButton(
                  label: 'Continue',
                  onPressed: () => context.go(Routes.home),
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
// Private Widgets
// ─────────────────────────────────────────────────────────────────────────────

class _MeasurementField extends StatelessWidget {
  const _MeasurementField({
    required this.label,
    required this.controller,
  });

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          height: 48.h,
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: const Color(0xFFE2D6C6),
              width: 1.3,
            ),
          ),
          child: Center(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BodyTypeCard extends StatelessWidget {
  const _BodyTypeCard({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final _BodyTypeItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFBF4EB) : const Color(0xFFF9F7F4),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFB5956A)
                : const Color(0xFFEFE8DE),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFB5956A).withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Body Type Image
            SizedBox(
              height: 72.h,
              child: Image.asset(
                item.imagePath,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 6.h),
            // Title
            Text(
              item.title,
              style: TextStyle(
                fontSize: 13.5.sp,
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? const Color(0xFF2E2824)
                    : const Color(0xFF9E9892),
              ),
            ),
            SizedBox(height: 2.h),
            // Subtitle
            Text(
              item.subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9.5.sp,
                fontWeight: FontWeight.w400,
                color: isSelected
                    ? const Color(0xFF6E6760)
                    : const Color(0xFFB0AAA3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
