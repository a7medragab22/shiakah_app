import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/models/fashion_analysis_model.dart';
import '../../../../core/localization/app_localization_helper.dart';
import '../../../../core/theme/theme.dart';
import '../../../profile/presentation/screens/item_details_screen.dart';

class AiDetectedScreen extends StatefulWidget {
  final String categoryTitle;
  final String imagePath;
  final String patternName;
  final String colorName;
  final int colorHex;
  final String fitName;
  final FashionAnalysisResponse? analysisResponse;

  const AiDetectedScreen({
    super.key,
    this.categoryTitle = 'Crew Neck T-Shirt',
    this.imagePath = 'assets/images/T-shirts category/1.jpg',
    this.patternName = 'Solid',
    this.colorName = 'Off-White',
    this.colorHex = 0xFFFFFAFA,
    this.fitName = 'Regular',
    this.analysisResponse,
  });

  @override
  State<AiDetectedScreen> createState() => _AiDetectedScreenState();
}

class _AiDetectedScreenState extends State<AiDetectedScreen> {
  String _selectedOccasion = 'Casual';

  final List<Map<String, String>> _occasions = const [
    {'id': 'Casual', 'key': 'casual'},
    {'id': 'Office', 'key': 'business_formal'},
    {'id': 'Formal', 'key': 'business_formal'},
    {'id': 'Wedding', 'key': 'classic'},
    {'id': 'Date Night', 'key': 'smart_casual'},
    {'id': 'Interview', 'key': 'business_formal'},
    {'id': 'Travel', 'key': 'casual'},
    {'id': 'Party', 'key': 'streetwear'},
    {'id': 'Gym', 'key': 'sportswear'},
    {'id': 'AI Pick', 'key': 'smart_casual'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // ── 1. Top Image Container ──────────────────────────────
                    Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 340.h,
                          color: const Color(0xFFF2EFEA),
                          child: _buildItemImage(widget.imagePath),
                        ),

                        // Back Arrow Button
                        Positioned(
                          top: MediaQuery.of(context).padding.top + 10.h,
                          left: 16.w,
                          child: Container(
                            width: 40.w,
                            height: 40.w,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(
                                Icons.arrow_back_rounded,
                                size: 20.sp,
                                color: AppColors.textPrimary,
                              ),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // ── 2. White Sheet Card (AI Detected + Occasions) ────────
                    Container(
                      transform: Matrix4.translationValues(0, -20.h, 0),
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 20.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24.r),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, -3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── AI Detected Header ──────────────────────────────
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.check_rounded,
                                    color: const Color(0xFF388E3C),
                                    size: 22.sp,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'ai_detected'.tr(),
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF2C2520),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'review_all'.tr(),
                                style: TextStyle(
                                  fontSize: 13.5.sp,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFFB5AFA8),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),

                          Divider(color: const Color(0xFFEFECE8), height: 1.h),
                          SizedBox(height: 4.h),

                          // ── Attributes Rows ─────────────────────────
                          _buildAttributeRow(
                            label: '${'category'.tr()}:',
                            value: AppLocalizationHelper.translateCategory(context, widget.categoryTitle),
                          ),
                          Divider(color: const Color(0xFFEFECE8), height: 1.h),

                          _buildAttributeRow(
                            label: '${'fit'.tr()}:',
                            value: AppLocalizationHelper.translateFit(context, widget.fitName),
                          ),
                          Divider(color: const Color(0xFFEFECE8), height: 1.h),

                          _buildColorAttributeRow(
                            label: '${'colors_found'.tr()}:',
                            colorName: AppLocalizationHelper.translateColorName(context, widget.colorName),
                            colorHex: widget.colorHex,
                          ),
                          Divider(color: const Color(0xFFEFECE8), height: 1.h),

                          _buildAttributeRow(
                            label: '${'pattern'.tr()}:',
                            value: AppLocalizationHelper.translatePattern(context, widget.patternName),
                          ),
                          if (widget.analysisResponse != null &&
                              widget.analysisResponse!.stylingTips.isNotEmpty) ...[
                            SizedBox(height: 16.h),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(14.w),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9F7F2),
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(color: const Color(0xFFEADBCE)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.auto_awesome_rounded,
                                    color: AppColors.primary,
                                    size: 20.sp,
                                  ),
                                  SizedBox(width: 10.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'AI Styling Tip',
                                          style: TextStyle(
                                            fontSize: 13.5.sp,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          widget.analysisResponse!.stylingTips,
                                          style: TextStyle(
                                            fontSize: 12.5.sp,
                                            color: const Color(0xFF55504A),
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          SizedBox(height: 24.h),

                          // ── Occasion Selection Section ───────────────────────
                          Text(
                            'wear_question'.tr(),
                            style: TextStyle(
                              fontSize: 17.5.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF6F6A65),
                            ),
                          ),
                          SizedBox(height: 14.h),

                          // Occasion Chips Wrap
                          Wrap(
                            spacing: 10.w,
                            runSpacing: 10.h,
                            children: _occasions.map((occasion) {
                              final isSelected = occasion['id'] == _selectedOccasion;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedOccasion = occasion['id']!;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 18.w,
                                    vertical: 10.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFFC8A97E)
                                        : const Color(0xFFFAFAFA),
                                    borderRadius: BorderRadius.circular(14.r),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFFC8A97E)
                                          : const Color(0xFFE5DDD0),
                                      width: 1.2,
                                    ),
                                  ),
                                  child: Text(
                                    occasion['key']!.tr(),
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w600,
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFFC4BCB3),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          SizedBox(height: 28.h),

                          // ── Generate Outfits Button ─────────────────────────
                          SizedBox(
                            width: double.infinity,
                            height: 52.h,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ItemDetailsScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFC8A97E),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14.r),
                                ),
                              ),
                              child: Text(
                                'generate_outfits'.tr(),
                                style: TextStyle(
                                  fontSize: 16.5.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
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
          ],
        ),
      ),
    );
  }

  Widget _buildAttributeRow({required String label, required String value}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.5.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF9E9893),
            ),
          ),
          SizedBox(width: 6.w),
          Text(
            value,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2C2520),
            ),
          ),
          const Spacer(),
          Icon(
            Icons.chevron_right_rounded,
            size: 20.sp,
            color: const Color(0xFFB5AFA8),
          ),
        ],
      ),
    );
  }

  Widget _buildColorAttributeRow({
    required String label,
    required String colorName,
    required int colorHex,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.5.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF9E9893),
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            width: 18.w,
            height: 18.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(colorHex),
              border: Border.all(
                color: const Color(0xFFD6CFC7),
                width: 1.0,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            colorName,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2C2520),
            ),
          ),
          const Spacer(),
          Icon(
            Icons.chevron_right_rounded,
            size: 20.sp,
            color: const Color(0xFFB5AFA8),
          ),
        ],
      ),
    );
  }

  Widget _buildItemImage(String path) {
    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        errorBuilder: (_, __, ___) => _buildFallbackImage(),
      );
    }
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        errorBuilder: (_, __, ___) => _buildFallbackImage(),
      );
    }

    return Image.file(
      File(path),
      fit: BoxFit.cover,
      alignment: Alignment.center,
      errorBuilder: (_, __, ___) => Image.asset(
        path,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        errorBuilder: (_, __, ___) => _buildFallbackImage(),
      ),
    );
  }

  Widget _buildFallbackImage() {
    return Container(
      color: const Color(0xFFF5EFE6),
      child: Icon(
        Icons.checkroom_rounded,
        size: 80.sp,
        color: AppColors.primary,
      ),
    );
  }
}
