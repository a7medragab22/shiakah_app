import 'package:easy_localization/easy_localization.dart';
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
  final String labelKey;
  final Color color;
  final bool isWhite;

  const _ColorItem({
    required this.id,
    required this.labelKey,
    required this.color,
    this.isWhite = false,
  });
}

class DefineStyleScreen extends StatefulWidget {
  const DefineStyleScreen({super.key});

  @override
  State<DefineStyleScreen> createState() => _DefineStyleScreenState();
}

class _DefineStyleScreenState extends State<DefineStyleScreen> {
  static const List<Map<String, String>> _styleItems = [
    {'id': 'Casual', 'key': 'casual'},
    {'id': 'Smart Casual', 'key': 'smart_casual'},
    {'id': 'Streetwear', 'key': 'streetwear'},
    {'id': 'Business Formal', 'key': 'business_formal'},
    {'id': 'Minimalist', 'key': 'minimalist'},
    {'id': 'Classic', 'key': 'classic'},
    {'id': 'Sportswear', 'key': 'sportswear'},
  ];

  final Set<String> _selectedStyles = {'Casual', 'Classic', 'Sportswear'};

  static const List<_ColorItem> _popularColors = [
    _ColorItem(id: 'black', labelKey: 'black', color: Color(0xFF1B1B1B)),
    _ColorItem(
        id: 'white', labelKey: 'white', color: Color(0xFFFFFFFF), isWhite: true),
    _ColorItem(id: 'gray', labelKey: 'gray', color: Color(0xFF7E8286)),
    _ColorItem(id: 'mustard', labelKey: 'mustard', color: Color(0xFFCCA229)),
    _ColorItem(id: 'beige', labelKey: 'beige', color: Color(0xFFD6BE9F)),
    _ColorItem(id: 'burgundy', labelKey: 'burgundy', color: Color(0xFF7A1C30)),
    _ColorItem(id: 'navy', labelKey: 'navy', color: Color(0xFF1B365D)),
    _ColorItem(id: 'blue', labelKey: 'blue', color: Color(0xFF4A7AB5)),
    _ColorItem(id: 'olive', labelKey: 'olive', color: Color(0xFF6B7E43)),
    _ColorItem(id: 'brown', labelKey: 'brown', color: Color(0xFF5E422D)),
    _ColorItem(id: 'camel', labelKey: 'camel', color: Color(0xFFC08C56)),
    _ColorItem(
        id: 'forest_green', labelKey: 'forest_green', color: Color(0xFF265640)),
  ];

  static const List<_ColorItem> _extraColors = [
    _ColorItem(id: 'charcoal', labelKey: 'gray', color: Color(0xFF36454F)),
    _ColorItem(id: 'sage', labelKey: 'olive', color: Color(0xFF9CAF88)),
    _ColorItem(id: 'terracotta', labelKey: 'mustard', color: Color(0xFFE2725B)),
    _ColorItem(id: 'rust', labelKey: 'brown', color: Color(0xFFB7410E)),
    _ColorItem(id: 'lavender', labelKey: 'navy', color: Color(0xFF967BB6)),
    _ColorItem(id: 'peach', labelKey: 'beige', color: Color(0xFFF4C2C2)),
  ];

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
            title: 'create_account_title'.tr(),
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
                        'define_your_style'.tr(),
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
                          'define_style_subtitle'.tr(),
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
                  'styles'.tr(),
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
                  children: _styleItems.map((item) {
                    final bool isSelected = _selectedStyles.contains(item['id']);
                    return GestureDetector(
                      onTap: () => _toggleStyle(item['id']!),
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
                          item['key']!.tr(),
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
                            'preferred_colors'.tr(),
                            style: TextStyle(
                              fontSize: 14.5.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'popular_colors'.tr(),
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
                            _showMoreColors ? 'less'.tr() : 'more'.tr(),
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
                  label: 'continue_btn'.tr(),
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
            item.labelKey.tr(),
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
