import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/theme.dart';

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

  Future<void> _handleContinue(BuildContext context) async {
    Navigator.pop(context); // Close the permission sheet first

    final ImagePicker picker = ImagePicker();

    // Show source selection sheet (Camera vs Gallery)
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: 16.h),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              Text(
                'Select Clothing Image',
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 16.h),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    color: AppColors.primary,
                    size: 22.sp,
                  ),
                ),
                title: Text(
                  'Camera',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  'Take a photo of your clothing item',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                ),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  try {
                    final XFile? photo =
                        await picker.pickImage(source: ImageSource.camera);
                    if (photo != null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Clothing photo captured: ${photo.name}'),
                          backgroundColor: const Color(0xFF388E3C),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      // Fallback to gallery if camera is unavailable (e.g. emulator without camera)
                      final XFile? photo =
                          await picker.pickImage(source: ImageSource.gallery);
                      if (photo != null && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('Clothing photo selected: ${photo.name}'),
                            backgroundColor: const Color(0xFF388E3C),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  }
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.photo_library_rounded,
                    color: AppColors.primary,
                    size: 22.sp,
                  ),
                ),
                title: Text(
                  'Choose from Gallery',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  'Select an existing image from photos',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                ),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  try {
                    final XFile? photo =
                        await picker.pickImage(source: ImageSource.gallery);
                    if (photo != null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Clothing photo selected: ${photo.name}'),
                          backgroundColor: const Color(0xFF388E3C),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  } catch (_) {}
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Handle Bar
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 24.h),

            // Camera Access Circular Badge Icon
            Container(
              width: 68.w,
              height: 68.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.12),
              ),
              child: Center(
                child: Icon(
                  Icons.camera_alt_outlined,
                  size: 32.sp,
                  color: AppColors.primary,
                ),
              ),
            ),
            SizedBox(height: 18.h),

            // Title: Allow Camera Access
            Text(
              'Allow Camera Access',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),

            // Subtitle: Scan your clothing to automatically identify item details.
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Text(
                'Scan your clothing to automatically identify item details.',
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

            // Action Buttons Row (Not now & Continue)
            Row(
              children: [
                // Not now Button
                Expanded(
                  child: SizedBox(
                    height: 48.h,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xFFE2D6C6),
                          width: 1.3,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Not now',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6F6A65),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),

                // Continue Button (Primary Color)
                Expanded(
                  child: SizedBox(
                    height: 48.h,
                    child: ElevatedButton(
                      onPressed: () => _handleContinue(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
