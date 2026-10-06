import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/helpers/helpers.dart';
import '../../../../core/service_locator/service_locator.dart';
import '../../../../core/theme/theme.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../widgets/camera_guidelines_bottom_sheet.dart';
import 'ai_detected_screen.dart';

class PhotoAnalysisPreviewScreen extends StatefulWidget {
  final String categoryTitle;
  final String imagePath;
  final String patternName;
  final String colorName;
  final int colorHex;
  final String fitName;
  final bool autoScan;

  const PhotoAnalysisPreviewScreen({
    super.key,
    this.categoryTitle = 'Crew Neck T-Shirt',
    this.imagePath = 'assets/images/T-shirts category/1.jpg',
    this.patternName = 'Solid',
    this.colorName = 'Off-White',
    this.colorHex = 0xFFFFFAFA,
    this.fitName = 'Regular',
    this.autoScan = true,
  });

  @override
  State<PhotoAnalysisPreviewScreen> createState() =>
      _PhotoAnalysisPreviewScreenState();
}

class _PhotoAnalysisPreviewScreenState
    extends State<PhotoAnalysisPreviewScreen> {
  late String _currentImagePath;
  bool _isAddingToCloset = false;

  @override
  void initState() {
    super.initState();
    _currentImagePath = widget.imagePath;
  }

  Future<void> _handleAddToCloset(BuildContext context) async {
    if (_isAddingToCloset) return;

    setState(() {
      _isAddingToCloset = true;
    });

    final dataSource = getIt<WardrobeRemoteDataSource>();
    final result = await dataSource.addToMyCloset(imagePath: _currentImagePath);

    if (!mounted) return;

    setState(() {
      _isAddingToCloset = false;
    });

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded,
                    color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    failure.message.isNotEmpty
                        ? failure.message
                        : 'error_occurred'.tr(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFD32F2F),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
      (response) {
        ClosetManager.instance.addItem(_currentImagePath);

        final successMessage = response.message ==
                    'WardrobeItemAddedToYourClosetSuccessfully' ||
                response.message == null ||
                response.message!.isEmpty
            ? 'item_added_closet'.tr()
            : response.message!;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    successMessage,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
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
      },
    );
  }

  void _startScan(BuildContext context) {
    context.read<WardrobeScannerBloc>().add(
          ScanWardrobeImageRequested(imageFile: File(_currentImagePath)),
        );
  }

  void _navigateToAiDetected(
    BuildContext context,
    ItemAttributes attributes,
  ) {
    final hex = ColorPalette.hexForName(attributes.dominantColor) ??
        widget.colorHex;
    final colorName = attributes.dominantColor ?? widget.colorName;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AiDetectedScreen(
          imagePath: _currentImagePath,
          attributes: attributes,
          categoryTitle: attributes.subcategory ??
              attributes.category ??
              widget.categoryTitle,
          fitName: attributes.style ?? widget.fitName,
          colorName: colorName,
          colorHex: hex,
          patternName: widget.patternName,
        ),
      ),
    );
  }

  /// Mandatory retake modal: user cannot proceed or bypass.
  void _showMandatoryRetakeDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (modalCtx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top handle
                Container(
                  width: 44.w,
                  height: 4.5.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDD7CF),
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                ),
                SizedBox(height: 18.h),

                // Warning badge icon
                Container(
                  width: 60.w,
                  height: 60.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF3E0),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: const Color(0xFFE65100),
                      size: 34.sp,
                    ),
                  ),
                ),
                SizedBox(height: 14.h),

                // Title
                Text(
                  'no_clothing_detected_title'.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 19.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),

                // Notice description
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  child: Text(
                    'no_clothing_detected_desc'.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.5.sp,
                      color: const Color(0xFF756F68),
                      height: 1.4,
                    ),
                  ),
                ),
                SizedBox(height: 24.h),

                // Mandatory Retake Button Only
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(modalCtx);
                      _handleRetake(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE65100),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.refresh_rounded, color: Colors.white),
                        SizedBox(width: 8.w),
                        Text(
                          'retake_mandatory'.tr(),
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
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
      },
    );
  }

  Future<void> _handleRetake(BuildContext context) async {
    final bloc = context.read<WardrobeScannerBloc>();
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (modalCtx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44.w,
                height: 4.5.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFDDD7CF),
                  borderRadius: BorderRadius.circular(3.r),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'retake'.tr(),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 16.h),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: AppColors.primary,
                  ),
                ),
                title: Text(
                  'camera'.tr(),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                onTap: () => Navigator.pop(modalCtx, ImageSource.camera),
              ),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.photo_library_rounded,
                    color: AppColors.primary,
                  ),
                ),
                title: Text(
                  'choose_from_gallery'.tr(),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                onTap: () => Navigator.pop(modalCtx, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null || !mounted) return;

    if (source == ImageSource.camera) {
      if (!context.mounted) return;
      await CameraGuidelinesBottomSheet.show(
        context,
        onImagePicked: (squareFile) {
          if (!mounted) return;
          setState(() {
            _currentImagePath = squareFile.path;
          });
          bloc.add(ScanWardrobeImageRequested(imageFile: squareFile));
        },
      );
    } else {
      try {
        final photo = await picker.pickImage(source: source, imageQuality: 95);
        if (photo != null && photo.path.isNotEmpty) {
          // Crop gallery photo to 1:1 square
          final squareFile =
              await ImagePreprocessor.cropToSquareFile(File(photo.path));
          if (!mounted) return;
          setState(() {
            _currentImagePath = squareFile.path;
          });
          bloc.add(ScanWardrobeImageRequested(imageFile: squareFile));
        }
      } catch (e) {
        debugPrint('Error retaking image: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<WardrobeScannerBloc>(
      create: (_) {
        final bloc = getIt<WardrobeScannerBloc>();
        if (widget.autoScan) {
          bloc.add(
            ScanWardrobeImageRequested(imageFile: File(_currentImagePath)),
          );
        }
        return bloc;
      },
      child: BlocConsumer<WardrobeScannerBloc, WardrobeScannerState>(
        listener: (context, state) {
          if (state is WardrobeScannerFailure) {
            _showMandatoryRetakeDialog(context);
          }
        },
        builder: (context, state) {
          final isLoading = state is WardrobeScannerLoading;
          final isLowConfidence = state is WardrobeScannerLowConfidence;
          final isFailure = state is WardrobeScannerFailure;
          final isSuccess = state is WardrobeScannerSuccess;
          final hasClothing = isSuccess || isLowConfidence;
          final needsMandatoryRetake = isFailure;

          ItemAttributes? detectedAttributes;
          if (state is WardrobeScannerSuccess) {
            detectedAttributes = state.attributes;
          } else if (state is WardrobeScannerLowConfidence) {
            detectedAttributes = state.attributes;
          }

          return Scaffold(
            backgroundColor: const Color(0xFFF5F3EF),
            body: SafeArea(
              child: Column(
                children: [
                  // ── 1. Top Container with 1:1 Square Frame ───────────────
                  Expanded(
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
                          // Center 1:1 Square Frame Viewfinder
                          Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.w),
                              child: AspectRatio(
                                aspectRatio: 1.0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.r),
                                    border: Border.all(
                                      color: needsMandatoryRetake
                                          ? const Color(0xFFE65100)
                                          : (hasClothing
                                              ? const Color(0xFF2E7D32)
                                              : const Color(0xFFC8A97E)),
                                      width: 2.0,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(18.r),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        _buildPreviewImage(_currentImagePath),

                                        // 1:1 Square Corner Overlay Brackets
                                        _buildSquareViewfinderOverlay(
                                          needsMandatoryRetake
                                              ? const Color(0xFFE65100)
                                              : (hasClothing
                                                  ? const Color(0xFF2E7D32)
                                                  : const Color(0xFFC8A97E)),
                                        ),

                                        // Scanning Beam / Overlay
                                        if (isLoading)
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.black
                                                  .withValues(alpha: 0.38),
                                            ),
                                            child: Center(
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 20.w,
                                                  vertical: 14.h,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.8),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          14.r),
                                                  border: Border.all(
                                                    color: const Color(
                                                            0xFFC8A97E)
                                                        .withValues(alpha: 0.6),
                                                    width: 1.2,
                                                  ),
                                                ),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    SizedBox(
                                                      width: 32.w,
                                                      height: 32.w,
                                                      child:
                                                          const CircularProgressIndicator(
                                                        color:
                                                            Color(0xFFC8A97E),
                                                        strokeWidth: 3.0,
                                                      ),
                                                    ),
                                                    SizedBox(height: 12.h),
                                                    Text(
                                                      'analyzing_clothing_item'
                                                          .tr(),
                                                      style: TextStyle(
                                                        fontSize: 14.sp,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
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
                                color: Colors.white.withValues(alpha: 0.92),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFEAE3D9),
                                  width: 1.2,
                                ),
                              ),
                              child: IconButton(
                                onPressed: (isLoading || _isAddingToCloset)
                                    ? null
                                    : () => Navigator.pop(context),
                                icon: Icon(
                                  Icons.arrow_back_rounded,
                                  size: 20.sp,
                                  color: AppColors.textPrimary,
                                ),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ),

                          // Top Right Aspect Ratio 1:1 Badge
                          Positioned(
                            top: 14.h,
                            right: 14.w,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.65),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.crop_square_rounded,
                                    size: 14.sp,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    '1:1',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
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

                  // ── 2. Bottom Actions Container ──────────────────────────
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
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
                    child: SafeArea(
                      top: false,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Status Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.all(4.w),
                                decoration: BoxDecoration(
                                  color: needsMandatoryRetake
                                      ? const Color(0xFFFFEBEE)
                                      : (isLoading
                                          ? const Color(0xFFFFF3E0)
                                          : const Color(0xFFE8F5E9)),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  needsMandatoryRetake
                                      ? Icons.error_outline_rounded
                                      : (isLoading
                                          ? Icons.hourglass_top_rounded
                                          : Icons.check_circle_rounded),
                                  color: needsMandatoryRetake
                                      ? const Color(0xFFD32F2F)
                                      : (isLoading
                                          ? const Color(0xFFE65100)
                                          : const Color(0xFF2E7D32)),
                                  size: 18.sp,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Flexible(
                                child: Text(
                                  needsMandatoryRetake
                                      ? 'no_clothing_detected_title'.tr()
                                      : (isLoading
                                          ? 'analyzing_clothing_item'.tr()
                                          : (hasClothing
                                              ? 'clothing_detected_success'.tr()
                                              : 'ready_for_analysis'.tr())),
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w700,
                                    color: needsMandatoryRetake
                                        ? const Color(0xFFD32F2F)
                                        : (isLoading
                                            ? const Color(0xFFE65100)
                                            : const Color(0xFF2E7D32)),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6.h),

                          // Subtitle explanation
                          Text(
                            needsMandatoryRetake
                                ? 'retake_required_notice'.tr()
                                : (isLoading
                                    ? 'analyzing_clothing_item'.tr()
                                    : (hasClothing
                                        ? '${detectedAttributes?.subcategory ?? detectedAttributes?.category ?? widget.categoryTitle} • ${detectedAttributes?.dominantColor ?? widget.colorName}'
                                        : 'your_photo_ready'.tr())),
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: needsMandatoryRetake
                                  ? const Color(0xFFC62828)
                                  : AppColors.secondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 16.h),

                          // ── Action Buttons ──────────────────────────────
                          if (needsMandatoryRetake) ...[
                            // Mandatory Retake Button (Takes full width)
                            SizedBox(
                              width: double.infinity,
                              height: 50.h,
                              child: ElevatedButton.icon(
                                onPressed: () => _handleRetake(context),
                                icon: const Icon(Icons.refresh_rounded,
                                    color: Colors.white),
                                label: Text(
                                  'retake_mandatory'.tr(),
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFD32F2F),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14.r),
                                  ),
                                ),
                              ),
                            ),
                          ] else ...[
                            Row(
                              children: [
                                // Button 1: Add to My Closet
                                Expanded(
                                  child: SizedBox(
                                    height: 48.h,
                                    child: OutlinedButton(
                                      onPressed: (isLoading ||
                                              _isAddingToCloset ||
                                              !hasClothing)
                                          ? null
                                          : () => _handleAddToCloset(context),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                          color: Color(0xFFC8A97E),
                                          width: 1.5,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14.r),
                                        ),
                                      ),
                                      child: _isAddingToCloset
                                          ? SizedBox(
                                              width: 22.w,
                                              height: 22.w,
                                              child:
                                                  const CircularProgressIndicator(
                                                color: Color(0xFFC8A97E),
                                                strokeWidth: 2.2,
                                              ),
                                            )
                                          : Text(
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

                                // Button 2: Analyze Item / Review
                                Expanded(
                                  child: SizedBox(
                                    height: 48.h,
                                    child: ElevatedButton(
                                      onPressed: (isLoading || _isAddingToCloset)
                                          ? null
                                          : () {
                                              if (hasClothing &&
                                                  detectedAttributes != null) {
                                                _navigateToAiDetected(
                                                  context,
                                                  detectedAttributes,
                                                );
                                              } else {
                                                _startScan(context);
                                              }
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14.r),
                                        ),
                                      ),
                                      child: isLoading
                                          ? SizedBox(
                                              width: 22.w,
                                              height: 22.w,
                                              child:
                                                  const CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2.2,
                                              ),
                                            )
                                          : Text(
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
                          ],
                          SizedBox(height: 12.h),

                          // Retake link button at bottom
                          GestureDetector(
                            onTap: (isLoading || _isAddingToCloset)
                                ? null
                                : () => _handleRetake(context),
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 4.h),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.refresh_rounded,
                                    size: 18.sp,
                                    color: (isLoading || _isAddingToCloset)
                                        ? AppColors.secondary
                                            .withValues(alpha: 0.4)
                                        : AppColors.secondary,
                                  ),
                                  SizedBox(width: 6.w),
                                  Text(
                                    'retake'.tr(),
                                    style: TextStyle(
                                      fontSize: 13.5.sp,
                                      fontWeight: FontWeight.w600,
                                      color: (isLoading || _isAddingToCloset)
                                          ? AppColors.secondary
                                              .withValues(alpha: 0.4)
                                          : AppColors.secondary,
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
        },
      ),
    );
  }

  Widget _buildSquareViewfinderOverlay(Color color) {
    return IgnorePointer(
      child: Stack(
        children: [
          // Top Left Bracket
          Positioned(
            top: 8.h,
            left: 8.w,
            child: Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: color, width: 3),
                  left: BorderSide(color: color, width: 3),
                ),
              ),
            ),
          ),
          // Top Right Bracket
          Positioned(
            top: 8.h,
            right: 8.w,
            child: Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: color, width: 3),
                  right: BorderSide(color: color, width: 3),
                ),
              ),
            ),
          ),
          // Bottom Left Bracket
          Positioned(
            bottom: 8.h,
            left: 8.w,
            child: Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: color, width: 3),
                  left: BorderSide(color: color, width: 3),
                ),
              ),
            ),
          ),
          // Bottom Right Bracket
          Positioned(
            bottom: 8.h,
            right: 8.w,
            child: Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: color, width: 3),
                  right: BorderSide(color: color, width: 3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewImage(String path) {
    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        errorBuilder: (_, __, ___) => _buildFallbackPlaceholder(),
      );
    }
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        errorBuilder: (_, __, ___) => _buildFallbackPlaceholder(),
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
