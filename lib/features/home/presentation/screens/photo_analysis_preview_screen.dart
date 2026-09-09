import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/helpers/helpers.dart';
import '../../../../core/theme/theme.dart';
import '../../../profile/presentation/screens/more_details_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';

class PhotoAnalysisPreviewScreen extends StatefulWidget {
  final String imagePath;

  const PhotoAnalysisPreviewScreen({
    super.key,
    required this.imagePath,
  });

  @override
  State<PhotoAnalysisPreviewScreen> createState() =>
      _PhotoAnalysisPreviewScreenState();
}

class _PhotoAnalysisPreviewScreenState
    extends State<PhotoAnalysisPreviewScreen> {
  late String _currentImagePath;

  @override
  void initState() {
    super.initState();
    _currentImagePath = widget.imagePath;
  }

  Future<void> _handleRetake() async {
    final ImagePicker picker = ImagePicker();
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
                'Retake Clothing Image',
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
                  'Take a new photo with camera',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                ),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  try {
                    final XFile? photo =
                        await picker.pickImage(source: ImageSource.camera);
                    if (photo != null && mounted) {
                      setState(() {
                        _currentImagePath = photo.path;
                      });
                    }
                  } catch (e) {
                    try {
                      final XFile? photo =
                          await picker.pickImage(source: ImageSource.gallery);
                      if (photo != null && mounted) {
                        setState(() {
                          _currentImagePath = photo.path;
                        });
                      }
                    } catch (_) {}
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
                  'Select another image from gallery',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                ),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  try {
                    final XFile? photo =
                        await picker.pickImage(source: ImageSource.gallery);
                    if (photo != null && mounted) {
                      setState(() {
                        _currentImagePath = photo.path;
                      });
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

  void _handleAddToCloset() {
    ClosetManager.instance.addItem(_currentImagePath);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text('Photo added to My Closet!'),
          ],
        ),
        backgroundColor: const Color(0xFF388E3C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const ProfileScreen(),
      ),
    );
  }

  void _handleAnalyzeItem() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MoreDetailsScreen(
          imagePath: _currentImagePath,
          onSaveToCloset: (path) {
            ClosetManager.instance.addItem(path);
          },
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    final isAsset = _currentImagePath.startsWith('assets/');
    if (isAsset) {
      return Image.asset(
        _currentImagePath,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    } else {
      return Image.file(
        File(_currentImagePath),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: const Color(0xFFEAD9C6),
            child: Center(
              child: Icon(
                Icons.image_not_supported_outlined,
                size: 60.sp,
                color: Colors.grey,
              ),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (size.width > 100 && size.height > 100) {
      ScreenUtil.init(
        context,
        designSize: const Size(393, 852),
        minTextAdapt: true,
        splitScreenMode: true,
      );
    }
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── 1. Full Screen Photo Preview Background ────────────────────────
          Positioned.fill(
            child: _buildImagePreview(),
          ),

          // Top Back Button Overlay
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18.sp,
                    color: Colors.white,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          ),

          // ── 2. Bottom Overlay Card (Matching UI Design) ────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 28.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(24.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Green Indicator Dot + Title "Ready for Analysis"
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF388E3C),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Flexible(
                        child: Text(
                          'Ready for Analysis',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),

                  // Subtitle: "Your photo is ready to be analyzed."
                  Text(
                    'Your photo is ready to be analyzed.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF8E8883),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // ── Buttons Row: "Add to My Closet" & "Analyze Item" ───────
                  Row(
                    children: [
                      // "Add to My Closet" Outlined Button
                      Expanded(
                        child: SizedBox(
                          height: 48.h,
                          child: OutlinedButton(
                            onPressed: _handleAddToCloset,
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 4.w),
                              side: const BorderSide(
                                color: Color(0xFFE2D6C6),
                                width: 1.3,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Add to My Closet',
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 13.5.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF9C826B),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),

                      // "Analyze Item" Primary Filled Button
                      Expanded(
                        child: SizedBox(
                          height: 48.h,
                          child: ElevatedButton(
                            onPressed: _handleAnalyzeItem,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 4.w),
                              backgroundColor: const Color(0xFFC8A97E),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Analyze Item',
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 14.5.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // ── "Retake" Text Button ────────────────────────────────────
                  GestureDetector(
                    onTap: _handleRetake,
                    child: Padding(
                      padding: EdgeInsets.all(4.w),
                      child: Text(
                        'Retake',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFB5A999),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
