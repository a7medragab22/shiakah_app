import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/service_locator/scanner/image_preprocessor.dart';
import '../../../../core/theme/theme.dart';
import '../../../../main.dart';
import '../screens/photo_analysis_preview_screen.dart';

/// Modal bottom sheet showing photo capture guidelines before opening the camera.
class CameraGuidelinesBottomSheet extends StatelessWidget {
  final void Function(File image)? onImagePicked;

  const CameraGuidelinesBottomSheet({
    super.key,
    this.onImagePicked,
  });

  static Future<void> show(
    BuildContext context, {
    void Function(File image)? onImagePicked,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (_) => CameraGuidelinesBottomSheet(
        onImagePicked: onImagePicked,
      ),
    );
  }

  Future<void> _openCameraAndProcess(BuildContext context) async {
    Navigator.pop(context); // Close guidelines sheet

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 95,
      );

      if (photo != null && photo.path.isNotEmpty) {
        // Automatically crop to 1:1 square ratio
        final squareFile =
            await ImagePreprocessor.cropToSquareFile(File(photo.path));
        onImagePicked?.call(squareFile);

        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => PhotoAnalysisPreviewScreen(
              imagePath: squareFile.path,
              autoScan: true,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error launching camera with guidelines: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Handle Bar
            Center(
              child: Container(
                width: 44.w,
                height: 4.5.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFDDD7CF),
                  borderRadius: BorderRadius.circular(3.r),
                ),
              ),
            ),
            SizedBox(height: 18.h),

            // Top Icon Header
            Center(
              child: Container(
                width: 64.w,
                height: 64.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFC8A97E).withValues(alpha: 0.14),
                  border: Border.all(
                    color: const Color(0xFFC8A97E).withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.camera_enhance_rounded,
                    size: 32.sp,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            SizedBox(height: 14.h),

            // Title
            Text(
              'camera_guidelines_title'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 6.h),

            // Subtitle
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Text(
                'camera_guidelines_subtitle'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF8E8883),
                  height: 1.35,
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // ── Guidelines Cards ──────────────────────────────────────
            // Rule 1: Solid background
            _buildRuleCard(
              icon: Icons.contrast_rounded,
              title: 'camera_rule_background_title'.tr(),
              desc: 'camera_rule_background_desc'.tr(),
              highlightColor: const Color(0xFF2C2520),
            ),
            SizedBox(height: 10.h),

            // Rule 2: 1:1 Aspect Ratio
            _buildRuleCard(
              icon: Icons.crop_square_rounded,
              title: 'camera_rule_ratio_title'.tr(),
              desc: 'camera_rule_ratio_desc'.tr(),
              highlightColor: const Color(0xFFC8A97E),
            ),
            SizedBox(height: 10.h),

            // Rule 3: Good Lighting
            _buildRuleCard(
              icon: Icons.light_mode_rounded,
              title: 'camera_rule_lighting_title'.tr(),
              desc: 'camera_rule_lighting_desc'.tr(),
              highlightColor: const Color(0xFFF57C00),
            ),
            SizedBox(height: 22.h),

            // ── Action Buttons ────────────────────────────────────────
            ElevatedButton(
              onPressed: () => _openCameraAndProcess(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.camera_alt_rounded, color: Colors.white),
                  SizedBox(width: 8.w),
                  Text(
                    'open_camera_btn'.tr(),
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'not_now'.tr(),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF8E8883),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleCard({
    required IconData icon,
    required String title,
    required String desc,
    required Color highlightColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F7F4),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: const Color(0xFFEDE7DF),
          width: 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: highlightColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 20.sp,
              color: highlightColor,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    color: const Color(0xFF7A746E),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
