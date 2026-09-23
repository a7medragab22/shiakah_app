import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/theme.dart';
import '../../../../main.dart';
import '../screens/photo_analysis_preview_screen.dart';

/// Modal bottom sheet presented when tapping "Add Clothing" on the Home Screen.
class CameraAccessBottomSheet extends StatelessWidget {
  const CameraAccessBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (_) => const CameraAccessBottomSheet(),
    );
  }

  static Future<void> _pickAndOpenPreview(
    BuildContext context,
    ImageSource source,
  ) async {
    Navigator.pop(context); // Close the bottom sheet safely

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: source,
        imageQuality: 95,
      );

      if (photo != null && photo.path.isNotEmpty) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => PhotoAnalysisPreviewScreen(
              imagePath: photo.path,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (source == ImageSource.camera) {
        // Fallback to gallery on emulator if camera is unavailable
        try {
          final ImagePicker picker = ImagePicker();
          final XFile? photo = await picker.pickImage(
            source: ImageSource.gallery,
            imageQuality: 95,
          );
          if (photo != null && photo.path.isNotEmpty) {
            navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (_) => PhotoAnalysisPreviewScreen(
                  imagePath: photo.path,
                ),
              ),
            );
          }
        } catch (_) {}
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Handle Bar
            Container(
              width: 44.w,
              height: 4.5.h,
              decoration: BoxDecoration(
                color: const Color(0xFFDDD7CF),
                borderRadius: BorderRadius.circular(3.r),
              ),
            ),
            SizedBox(height: 20.h),

            // Top Badge Icon
            Container(
              width: 62.w,
              height: 62.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.12),
              ),
              child: Center(
                child: Icon(
                  Icons.camera_alt_rounded,
                  size: 30.sp,
                  color: AppColors.primary,
                ),
              ),
            ),
            SizedBox(height: 14.h),

            // Title: Add Clothing
            Text(
              'add_clothing'.tr(),
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
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                'scan_clothing_desc'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF8E8883),
                  height: 1.4,
                ),
              ),
            ),
            SizedBox(height: 22.h),

            // ── Option 1: Take Photo via Camera ─────────────────────────────
            _buildSourceOptionTile(
              context: context,
              icon: Icons.camera_alt_rounded,
              title: 'camera'.tr(),
              subtitle: 'camera_sub'.tr(),
              onTap: () => _pickAndOpenPreview(context, ImageSource.camera),
            ),
            SizedBox(height: 12.h),

            // ── Option 2: Choose from Gallery ────────────────────────────────
            _buildSourceOptionTile(
              context: context,
              icon: Icons.photo_library_rounded,
              title: 'choose_from_gallery'.tr(),
              subtitle: 'gallery_sub'.tr(),
              onTap: () => _pickAndOpenPreview(context, ImageSource.gallery),
            ),
            SizedBox(height: 16.h),

            // ── Cancel Button ────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 46.h,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                child: Text(
                  'not_now'.tr(),
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF8E8883),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOptionTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFFF9F6F1),
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: const Color(0xFFEDE5DA),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15.5.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF8E8883),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16.sp,
                color: const Color(0xFFB5AFA8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
