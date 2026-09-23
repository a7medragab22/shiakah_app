import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/theme.dart';
import '../../data/models/fashion_analysis_model.dart';
import '../../data/services/fashion_api_service.dart';

/// Standalone UI example demonstrating:
/// 1. Picking image via image_picker (Camera or Gallery).
/// 2. Showing loading state while uploading/analyzing with Flask backend.
/// 3. Validating if the image contains clothing.
/// 4. Presenting fashion results on success, or a descriptive warning dialog when not clothing.
class FashionClassifierScreen extends StatefulWidget {
  const FashionClassifierScreen({super.key});

  @override
  State<FashionClassifierScreen> createState() => _FashionClassifierScreenState();
}

class _FashionClassifierScreenState extends State<FashionClassifierScreen> {
  final ImagePicker _picker = ImagePicker();
  final FashionApiService _apiService = FashionApiService.instance;

  File? _selectedImage;
  bool _isLoading = false;
  FashionAnalysisResponse? _analysisResult;
  String? _errorMessage;

  /// Picks an image from Camera or Gallery and triggers analysis
  Future<void> _pickAndAnalyzeImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 90,
      );

      if (pickedFile == null) return;

      final File file = File(pickedFile.path);
      setState(() {
        _selectedImage = file;
        _isLoading = true;
        _errorMessage = null;
        _analysisResult = null;
      });

      // ── API Call ───────────────────────────────────────────────────────────
      final response = await _apiService.analyzeFashionImage(
        imageFile: file,
        meetingType: 'Casual Outing',
        preferredStyles: 'Smart Casual',
        location: 'Cairo',
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      // ── Handle Error or Validation Rules ───────────────────────────────────
      if (!response.isSuccess) {
        setState(() {
          _errorMessage = response.errorMessage ?? 'Analysis failed';
        });
        _showErrorDialog(response.errorMessage ?? 'Network error');
        return;
      }

      if (!response.isClothes) {
        // Validation Rule: Not clothes
        _showNotClothesDialog(response.rejectionReason);
        return;
      }

      // Success: Image contains valid clothes!
      setState(() {
        _analysisResult = response;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
      _showErrorDialog(e.toString());
    }
  }

  /// Alert Dialog shown when uploaded image does not contain clothing
  void _showNotClothesDialog(String reason) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: const BoxDecoration(
                color: Color(0xFFFFF3E0),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: const Color(0xFFE65100),
                size: 26.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                'No Clothing Detected',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2C2520),
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
              reason.isNotEmpty
                  ? reason
                  : 'The AI model could not identify any apparel or clothing items in this photo.',
              style: TextStyle(
                fontSize: 13.5.sp,
                color: const Color(0xFF5A5550),
                height: 1.4,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Please capture or select another photo clearly showing an outfit or piece of clothing.',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              _showImageSourcePicker();
            },
            icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
            label: const Text('Try Another Photo', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('Server Error', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          '$error\n\nEnsure your Flask backend is running on port 5000 (http://10.0.2.2:5000 for Android).',
          style: TextStyle(fontSize: 13.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Image Source',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.h),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.primary),
                title: const Text('Take Photo from Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndAnalyzeImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.primary),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndAnalyzeImage(ImageSource.gallery);
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
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F0),
      appBar: AppBar(
        title: const Text('Fashion Image Classifier'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Image Preview Card ───────────────────────────────────────────
            Container(
              height: 280.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: const Color(0xFFE5DDD0)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.r),
                child: _selectedImage != null
                    ? Image.file(_selectedImage!, fit: BoxFit.contain)
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 56.sp,
                              color: Colors.grey.shade400,
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              'No image selected',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            SizedBox(height: 16.h),

            // ── Pick / Analyze Buttons ───────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : () => _pickAndAnalyzeImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt, color: Colors.white),
                    label: const Text('Camera', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : () => _pickAndAnalyzeImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library, color: AppColors.primary),
                    label: const Text('Gallery', style: TextStyle(color: AppColors.primary)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),

            // ── Loading Indicator ────────────────────────────────────────────
            if (_isLoading)
              Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  children: [
                    const CircularProgressIndicator(color: AppColors.primary),
                    SizedBox(height: 16.h),
                    Text(
                      'Analyzing clothing with AI...',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

            // ── Error Message Banner ─────────────────────────────────────────
            if (_errorMessage != null && !_isLoading)
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(fontSize: 13.sp, color: Colors.red.shade900),
                      ),
                    ),
                  ],
                ),
              ),

            // ── Success Results Section ──────────────────────────────────────
            if (_analysisResult != null && !_isLoading) ...[
              Container(
                padding: EdgeInsets.all(18.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle, color: Color(0xFF2E7D32)),
                        SizedBox(width: 8.w),
                        Text(
                          'Valid Clothes Identified',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),

                    // Summary
                    if (_analysisResult!.summary.isNotEmpty) ...[
                      Text(
                        _analysisResult!.summary,
                        style: TextStyle(fontSize: 13.5.sp, color: const Color(0xFF55504A)),
                      ),
                      SizedBox(height: 14.h),
                      const Divider(),
                      SizedBox(height: 10.h),
                    ],

                    // Items List
                    _buildItemTile('Top', _analysisResult!.items.top),
                    _buildItemTile('Bottom', _analysisResult!.items.bottom),
                    _buildItemTile('Footwear', _analysisResult!.items.footwear),
                    _buildItemTile('Accessories', _analysisResult!.items.accessories),

                    // Styling Tips
                    if (_analysisResult!.stylingTips.isNotEmpty) ...[
                      SizedBox(height: 14.h),
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9F7F2),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: const Color(0xFFEADBCE)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.auto_awesome, color: AppColors.primary, size: 18),
                                SizedBox(width: 6.w),
                                Text(
                                  'AI Styling Advice',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              _analysisResult!.stylingTips,
                              style: TextStyle(fontSize: 12.5.sp, color: const Color(0xFF5A5550)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildItemTile(String label, String value) {
    if (value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.secondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
