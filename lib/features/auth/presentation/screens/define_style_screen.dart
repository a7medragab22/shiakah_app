import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/router.dart';
import '../../../../core/theme/theme.dart';
import '../widgets/auth_buttons.dart';
import '../widgets/auth_form_card.dart';
import '../widgets/auth_header.dart';
import '../widgets/step_progress_indicator.dart';

class _ColorItem {
  final String id;
  final String label;
  final Color color;
  final bool isWhite;

  const _ColorItem({
    required this.id,
    required this.label,
    required this.color,
    this.isWhite = false,
  });
}

/// Step 4 of 5 in the style-setup flow.
/// Lets the user define their preferred styles and colors.
class DefineStyleScreen extends StatefulWidget {
  const DefineStyleScreen({super.key});

  @override
  State<DefineStyleScreen> createState() => _DefineStyleScreenState();
}

class _DefineStyleScreenState extends State<DefineStyleScreen> {
  // Available style choices
  static const List<String> _styles = [
    'Casual',
    'Smart Casual',
    'Streetwear',
    'Business Formal',
    'Minimalist',
    'Classic',
    'Sportswear',
  ];

  // Default selected styles matching design
  final Set<String> _selectedStyles = {'Casual', 'Classic', 'Sportswear'};

  // Popular colors (12 items in 2 rows of 6)
  static const List<_ColorItem> _popularColors = [
    _ColorItem(id: 'black', label: 'Black', color: Color(0xFF1B1B1B)),
    _ColorItem(
        id: 'white', label: 'White', color: Color(0xFFFFFFFF), isWhite: true),
    _ColorItem(id: 'gray', label: 'Gray', color: Color(0xFF7E8286)),
    _ColorItem(id: 'mustard', label: 'Mustard', color: Color(0xFFCCA229)),
    _ColorItem(id: 'beige', label: 'Beige', color: Color(0xFFD6BE9F)),
    _ColorItem(id: 'burgundy', label: 'Burgundy', color: Color(0xFF7A1C30)),
    _ColorItem(id: 'navy', label: 'Navy', color: Color(0xFF1B365D)),
    _ColorItem(id: 'blue', label: 'Blue', color: Color(0xFF4A7AB5)),
    _ColorItem(id: 'olive', label: 'Olive', color: Color(0xFF6B7E43)),
    _ColorItem(id: 'brown', label: 'Brown', color: Color(0xFF5E422D)),
    _ColorItem(id: 'camel', label: 'Camel', color: Color(0xFFC08C56)),
    _ColorItem(
        id: 'forest_green', label: 'Forest Green', color: Color(0xFF265640)),
  ];

  // Additional colors shown when "More" is expanded
  static const List<_ColorItem> _extraColors = [
    _ColorItem(id: 'charcoal', label: 'Charcoal', color: Color(0xFF36454F)),
    _ColorItem(id: 'sage', label: 'Sage', color: Color(0xFF9CAF88)),
    _ColorItem(id: 'terracotta', label: 'Terracotta', color: Color(0xFFE2725B)),
    _ColorItem(id: 'rust', label: 'Rust', color: Color(0xFFB7410E)),
    _ColorItem(id: 'lavender', label: 'Lavender', color: Color(0xFF967BB6)),
    _ColorItem(id: 'peach', label: 'Peach', color: Color(0xFFF4C2C2)),
  ];

  // Default selected colors matching design
  final Set<String> _selectedColors = {'white', 'beige', 'brown'};

  bool _showMoreColors = false;

  void _toggleStyle(String style) {
    setState(() {
      if (_selectedStyles.contains(style)) {
        _selectedStyles.remove(style);
      } else {
        _selectedStyles.add(style);
      }
    });
  }

  void _toggleColor(String colorId) {
    setState(() {
      if (_selectedColors.contains(colorId)) {
        _selectedColors.remove(colorId);
      } else {
        _selectedColors.add(colorId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFE5D8),
      body: Column(
        children: [
          // ── Header with Step 4 Progress ──────────────────────────────
          AuthHeader(
            type: AuthHeaderType.image,
            imagePath: 'assets/images/cloths.jpg',
            title: 'Create Account',
            fallbackRoute: Routes.bodyType,
            height: 130.h,
            stepIndicator: const StepProgressIndicator(currentStep: 4),
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
                        'Define Your Style',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Text(
                          'Choose your favorite styles and colors to personalize your recommendations.',
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

                // ── Styles Section ──────────────────────────────────────
                Text(
                  'Styles',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),

                SizedBox(height: 12.h),

                // Style chips wrap
                Wrap(
                  spacing: 8.w,
                  runSpacing: 10.h,
                  children: _styles.map((style) {
                    final bool isSelected = _selectedStyles.contains(style);
                    return GestureDetector(
                      onTap: () => _toggleStyle(style),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFB5956A)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFB5956A)
                                : const Color(0xFFE2D6C6),
                            width: 1.2,
                          ),
                        ),
                        child: Text(
                          style,
                          style: TextStyle(
                            fontSize: 13.5.sp,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF9E9892),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                SizedBox(height: 20.h),

                // ── Preferred Colors Section ────────────────────────────
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 14.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF7F2),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: const Color(0xFFEFE8DE),
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Header: Preferred Colors + Popular Colors label
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Preferred Colors',
                            style: TextStyle(
                              fontSize: 14.5.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Popular Colors',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFFB0AAA3),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 14.h),

                      // Popular colors row 1 (6 items)
                      _buildColorRow(_popularColors.sublist(0, 6)),

                      SizedBox(height: 12.h),

                      // Popular colors row 2 (6 items)
                      _buildColorRow(_popularColors.sublist(6, 12)),

                      // Extra colors if "More" is toggled
                      AnimatedCrossFade(
                        duration: const Duration(milliseconds: 240),
                        crossFadeState: _showMoreColors
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        firstChild: const SizedBox.shrink(),
                        secondChild: Padding(
                          padding: EdgeInsets.only(top: 12.h),
                          child: _buildColorRow(_extraColors),
                        ),
                      ),

                      SizedBox(height: 14.h),

                      // "More" / "Less" button
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showMoreColors = !_showMoreColors;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 28.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: const Color(0xFFE2D6C6),
                              width: 1.2,
                            ),
                          ),
                          child: Text(
                            _showMoreColors ? 'Less' : 'More',
                            style: TextStyle(
                              fontSize: 12.5.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF6E6760),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                AuthPrimaryButton(
                  label: 'Continue',
                  onPressed: () => context.go(Routes.completeProfile),
                ),

                SizedBox(height: 12.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorRow(List<_ColorItem> items) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        final bool isSelected = _selectedColors.contains(item.id);
        return Expanded(
          child: _ColorSwatchWidget(
            item: item,
            isSelected: isSelected,
            onTap: () => _toggleColor(item.id),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Color Swatch Widget with label
// ─────────────────────────────────────────────────────────────────────────────

class _ColorSwatchWidget extends StatelessWidget {
  const _ColorSwatchWidget({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final _ColorItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Circular color swatch
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 36.w,
            height: 36.w,
            padding: EdgeInsets.all(isSelected ? 2.5.w : 0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(
                      color: const Color(0xFFB5956A),
                      width: 2.2,
                    )
                  : null,
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: item.color,
                border: item.isWhite
                    ? Border.all(
                        color: const Color(0xFFE2D6C6),
                        width: 1.2,
                      )
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 6.h),

          // Color label text
          Text(
            item.label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              color: isSelected
                  ? const Color(0xFFB5956A)
                  : const Color(0xFF8E8883),
            ),
          ),
        ],
      ),
    );
  }
}
