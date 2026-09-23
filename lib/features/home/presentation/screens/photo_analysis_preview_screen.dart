import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helpers/helpers.dart';
import '../../../../core/theme/theme.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../data/models/fashion_analysis_model.dart';
import '../../data/services/fashion_api_service.dart';
import '../widgets/camera_access_bottom_sheet.dart';
import 'ai_detected_screen.dart';

class PhotoAnalysisPreviewScreen extends StatelessWidget {
  final String categoryTitle;
  final String imagePath;
  final String patternName;
  final String colorName;
  final int colorHex;
  final String fitName;

  const PhotoAnalysisPreviewScreen({
    super.key,
    this.categoryTitle = 'Crew Neck T-Shirt',
    this.imagePath = 'assets/images/T-shirts category/1.jpg',
    this.patternName = 'Solid',
    this.colorName = 'Off-White',
    this.colorHex = 0xFFFFFAFA,
    this.fitName = 'Regular',
  });

  void _handleAddToCloset(BuildContext context) {
    ClosetManager.instance.addItem(imagePath);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text('item_added_closet'.tr()),
          ],
        ),
        backgroundColor: const Color(0xFF388E3C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
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

  Future<void> _handleAnalyzeItem(BuildContext context) async {
    // 1. Resolve image to local File
    File? fileToAnalyze;
    if (imagePath.startsWith('assets/')) {
      try {
        final byteData = await rootBundle.load(imagePath);
        final fileName = imagePath.split('/').last;
        final tempFile = File('${Directory.systemTemp.path}/$fileName');
        await tempFile.writeAsBytes(byteData.buffer.asUint8List());
        fileToAnalyze = tempFile;
      } catch (e) {
        debugPrint('Error writing temp asset file: $e');
      }
    } else {
      final f = File(imagePath);
      if (f.existsSync()) {
        fileToAnalyze = f;
      }
    }

    if (fileToAnalyze == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('file_not_found'.tr()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!context.mounted) return;

    // 2. Show Elegant AI Loading Dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22.r),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 52.w,
                  height: 52.w,
                  child: CircularProgressIndicator(
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    strokeWidth: 3.5,
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  'analyzing_image_ai'.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'verifying_clothing'.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // 3. Send to Flask backend
    final FashionAnalysisResponse response = await FashionApiService.instance.analyzeFashionImage(
      imageFile: fileToAnalyze,
      meetingType: 'Casual Outing',
      preferredStyles: 'Smart Casual',
      location: 'Cairo',
    );

    // Dismiss loading indicator safely
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    if (!context.mounted) return;

    // 4. Handle Network / Server Failure
    if (!response.isSuccess) {
      _showErrorDialog(context, response.errorMessage ?? 'Network error');
      return;
    }

    // 5. Check Fashion Validation Rule:
    // If image does NOT show clothes -> display alert dialog with backend summary
    if (!response.isClothes) {
      _showNotClothesDialog(context, response.rejectionReason);
      return;
    }

    // 6. Success: Image contains valid clothes! Proceed to AiDetectedScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AiDetectedScreen(
          categoryTitle: response.items.top.isNotEmpty
              ? response.items.top
              : categoryTitle,
          imagePath: imagePath,
          patternName: patternName,
          colorName: colorName,
          colorHex: colorHex,
          fitName: fitName,
          analysisResponse: response,
        ),
      ),
    );
  }

  void _showNotClothesDialog(BuildContext context, String reason) {
    showDialog(
      context: context,
      builder: (dialogCtx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22.r),
        ),
        backgroundColor: Colors.white,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Warning Icon Badge
              Container(
                width: 62.w,
                height: 62.w,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF3E0),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: const Color(0xFFE65100),
                  size: 34.sp,
                ),
              ),
              SizedBox(height: 16.h),

              // Title: No Clothing Detected
              Text(
                'no_clothing_detected'.tr(),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2C2520),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10.h),

              // Reason message from Flask backend
              Text(
                reason.isNotEmpty
                    ? reason
                    : 'The uploaded image does not contain recognizable clothing items. Please upload a clear photo of clothing or an outfit.',
                style: TextStyle(
                  fontSize: 13.5.sp,
                  color: const Color(0xFF6F6A65),
                  height: 1.45,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 22.h),

              // Primary Button: Take / Pick Another Photo
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(dialogCtx);
                    CameraAccessBottomSheet.show(context);
                  },
                  icon: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 20),
                  label: Text(
                    'take_another_photo'.tr(),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8.h),

              // Secondary Button: Cancel
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: Text(
                  'cancel'.tr(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.redAccent),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'connection_error'.tr(),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: TextStyle(fontSize: 13.5.sp, color: const Color(0xFF424242)),
            ),
            SizedBox(height: 10.h),
            Text(
              'please_check_backend'.tr(),
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey.shade600,
                height: 1.3,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              'cancel'.tr(),
              style: const TextStyle(color: AppColors.secondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              _showChangeServerUrlDialog(context);
            },
            child: const Text(
              'Change Server IP',
              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              _handleAnalyzeItem(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: Text(
              'retry'.tr(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showChangeServerUrlDialog(BuildContext context) {
    final controller = TextEditingController(text: FashionApiService.instance.baseUrl);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: const Text('Server URL / عنوان السيرفر'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter PC IP on Wi-Fi (e.g. http://192.168.1.14:5000) or public URL:',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'http://192.168.1.14:5000',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              final newUrl = controller.text.trim();
              if (newUrl.isNotEmpty) {
                FashionApiService.instance.setBaseUrl(newUrl);
              }
              Navigator.pop(ctx);
              _handleAnalyzeItem(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Save & Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3EF),
      body: SafeArea(
        child: Column(
          children: [
            // ── 1. Top Container (2/3 of Screen) ──────────────────────────────
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Center Selected Category Photo
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20.r),
                        child: Padding(
                          padding: EdgeInsets.all(16.w),
                          child: _buildPreviewImage(imagePath),
                        ),
                      ),
                    ),

                    // Top Left Back Button
                    Positioned(
                      top: 12.h,
                      left: 12.w,
                      child: Container(
                        width: 40.w,
                        height: 40.w,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFEAE3D9),
                            width: 1.2,
                          ),
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
              ),
            ),

            // ── 2. Bottom Container (1/3 of Screen) ───────────────────────────
            Expanded(
              flex: 1,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(28.r),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Row 1: Icon Green Circle + Text "Ready for analysis"
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: const BoxDecoration(
                            color: Color(0xFFE8F5E9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check_circle_rounded,
                            color: const Color(0xFF2E7D32),
                            size: 20.sp,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'ready_for_analysis'.tr(),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),

                    // Text: "your photo is ready to analyze"
                    Text(
                      'your_photo_ready'.tr(),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.secondary,
                      ),
                    ),

                    // Row 2: Two Buttons ("Add to My Closet" & "Analyze Item")
                    Row(
                      children: [
                        // Button 1: Add to My Closet
                        Expanded(
                          child: SizedBox(
                            height: 48.h,
                            child: OutlinedButton(
                              onPressed: () => _handleAddToCloset(context),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFFC8A97E),
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14.r),
                                ),
                              ),
                              child: Text(
                                'add_to_closet'.tr(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),

                        // Button 2: Analyze Item
                        Expanded(
                          child: SizedBox(
                            height: 48.h,
                            child: ElevatedButton(
                              onPressed: () => _handleAnalyzeItem(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14.r),
                                ),
                              ),
                              child: Text(
                                'analyze_item'.tr(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Retake Text/Icon Button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.h),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.refresh_rounded,
                              size: 18.sp,
                              color: AppColors.secondary,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              'retake'.tr(),
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.secondary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
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

  Widget _buildPreviewImage(String path) {
    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _buildFallbackPlaceholder(),
      );
    }
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _buildFallbackPlaceholder(),
      );
    }

    return Image.file(
      File(path),
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Image.asset(
        path,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _buildFallbackPlaceholder(),
      ),
    );
  }

  Widget _buildFallbackPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.checkroom_rounded,
          size: 64.sp,
          color: AppColors.primary,
        ),
        SizedBox(height: 12.h),
        Text(
          'ready_for_analysis'.tr(),
          style: TextStyle(
            fontSize: 16.sp,
            color: AppColors.secondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
