import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helpers/helpers.dart';
import '../../../../core/localization/app_localization_helper.dart';
import '../../../../core/theme/theme.dart';
import 'item_details_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedTabIndex = 0; // 0: My Closet, 1: My Looks

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: AnimatedBuilder(
        animation: Listenable.merge([
          ClosetManager.instance,
          LooksManager.instance,
        ]),
        builder: (context, _) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // ── 1. Hero Header Section with Portrait & Floating Name Badge ──
                _buildHeroHeader(context),
                SizedBox(height: 16.h),

                // Padding wrapper for the remaining content
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18.w),
                  child: Column(
                    children: [
                      // ── 2. Stats Row (My Closet & My Looks Counts) ──────────────
                      _buildStatsRow(),
                      SizedBox(height: 16.h),

                      // ── 3. Segmented Tab Switcher (My Closet / My Looks) ────────
                      _buildSegmentedTabSwitcher(),
                      SizedBox(height: 16.h),

                      // ── 4. Outfit / Item Grid View ──────────────────────────────
                      _buildGridContent(),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Hero Header Widget
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildHeroHeader(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Background Curved Container with Character Photo
        ClipPath(
          clipper: _BottomCurveClipper(),
          child: Container(
            width: double.infinity,
            height: 310.h,
            color: const Color(0xFFEAD9C6),
            child: Stack(
              children: [
                // Top Half-Body Character Portrait
                Positioned.fill(
                  top: 10.h,
                  child: Image.asset(
                    'assets/images/man.png',
                    fit: BoxFit.contain,
                    alignment: Alignment.topCenter,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Top Action Bar (Back Button + Right Action Icons)
        SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back Button
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                    },
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18.sp,
                      color: AppColors.textPrimary,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ),

                // Right Icons: User Profile & Menu
                Row(
                  children: [
                    Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.person_outline_rounded,
                          size: 22.sp,
                          color: AppColors.textPrimary,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.menu_rounded,
                          size: 22.sp,
                          color: AppColors.textPrimary,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Floating Name Card Badge at Bottom Center of Curve
        Positioned(
          bottom: -20.h,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(
                  color: const Color(0xFFE2D6C6),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 38.w,
                    height: 38.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFC8A97E),
                        width: 1.0,
                      ),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/man.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    AppLocalizationHelper.getUserFullName(context),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(width: 6.w),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Stats Row (My Closet & My Looks)
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildStatsRow() {
    final closetCount = ClosetManager.instance.value.length;
    final looksCount = LooksManager.instance.value.length;

    return Padding(
      padding: EdgeInsets.only(top: 14.h),
      child: Row(
        children: [
          // Stat 1: My Closet
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: 16.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: _selectedTabIndex == 0
                        ? AppColors.primary
                        : const Color(0xFFEAE3D9),
                    width: _selectedTabIndex == 0 ? 1.8 : 1.2,
                  ),
                  boxShadow: _selectedTabIndex == 0
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  children: [
                    Text(
                      '$closetCount',
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'my_closet'.tr(),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF8E8883),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),

          // Stat 2: My Looks
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = 1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: 16.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: _selectedTabIndex == 1
                        ? AppColors.primary
                        : const Color(0xFFEAE3D9),
                    width: _selectedTabIndex == 1 ? 1.8 : 1.2,
                  ),
                  boxShadow: _selectedTabIndex == 1
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  children: [
                    Text(
                      '$looksCount',
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'my_looks'.tr(),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF8E8883),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Segmented Tab Switcher (My Closet / My Looks)
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildSegmentedTabSwitcher() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F2EC),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: const Color(0xFFECE5DB),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          // Tab 1: My Closet
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: _selectedTabIndex == 0
                      ? const Color(0xFFC8A97E)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  'my_closet'.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: _selectedTabIndex == 0
                        ? FontWeight.w700
                        : FontWeight.w600,
                    color: _selectedTabIndex == 0
                        ? Colors.white
                        : const Color(0xFFB0A9A2),
                  ),
                ),
              ),
            ),
          ),

          // Tab 2: My Looks
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = 1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: _selectedTabIndex == 1
                      ? const Color(0xFFC8A97E)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  'my_looks'.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: _selectedTabIndex == 1
                        ? FontWeight.w700
                        : FontWeight.w600,
                    color: _selectedTabIndex == 1
                        ? Colors.white
                        : const Color(0xFFB0A9A2),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Grid Content (Clothing & Outfits Grid Cards)
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildGridContent() {
    final items = _selectedTabIndex == 0
        ? ClosetManager.instance.value
        : LooksManager.instance.value;

    if (items.isEmpty) {
      return _buildEmptyState();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14.w,
        mainAxisSpacing: 14.h,
        childAspectRatio: 0.78,
      ),
      itemBuilder: (context, index) {
        final imagePath = items[index];
        return _buildItemCard(imagePath);
      },
    );
  }

  Widget _buildEmptyState() {
    final isCloset = _selectedTabIndex == 0;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: const Color(0xFFEAE3D9),
          width: 1.0,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: const BoxDecoration(
              color: Color(0xFFF7F3EE),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCloset
                  ? Icons.checkroom_rounded
                  : Icons.favorite_border_rounded,
              size: 42.sp,
              color: isCloset ? AppColors.primary : const Color(0xFFE56B82),
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            isCloset ? 'Your Closet is Empty' : 'No Looks Saved Yet',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            isCloset
                ? 'Add items from photo analysis or manual entry'
                : 'Tap the heart icon on any outfit to save it to My Looks',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF8E8883),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmAndDeleteItem(BuildContext context, String imagePath) {
    final isCloset = _selectedTabIndex == 0;
    final itemName = isCloset ? 'My Closet' : 'My Looks';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          contentPadding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 12.h),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFEBEE),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  color: const Color(0xFFD32F2F),
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                'Delete Item',
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to remove this item from $itemName?',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.secondary,
              height: 1.3,
            ),
          ),
          actionsPadding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
          actions: [
            Row(
              children: [
                // Cancel Button (إلغاء)
                Expanded(
                  child: SizedBox(
                    height: 44.h,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xFFE2D6C6),
                          width: 1.2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),

                // Delete Button (مسح)
                Expanded(
                  child: SizedBox(
                    height: 44.h,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        if (_selectedTabIndex == 0) {
                          ClosetManager.instance.removeItem(imagePath);
                        } else {
                          LooksManager.instance.removeItem(imagePath);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD32F2F),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Delete',
                        style: TextStyle(
                          fontSize: 14.sp,
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
        );
      },
    );
  }

  void _openItemDetails(BuildContext context, String imagePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ItemDetailsScreen(initialImage: imagePath),
      ),
    );
  }

  Widget _buildItemCard(String imagePath) {
    return GestureDetector(
      onTap: () => _openItemDetails(context, imagePath),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF1EAE0),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: const Color(0xFFE8DFC0).withValues(alpha: 0.6),
            width: 1.0,
          ),
        ),
        child: Stack(
          children: [
            // Outfit / Clothing Image
            ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: _buildItemImage(imagePath),
            ),

            // Top Right Delete/Remove Icon Button
            Positioned(
              top: 10.h,
              right: 10.w,
              child: Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () => _confirmAndDeleteItem(context, imagePath),
                  icon: Icon(
                    Icons.close_rounded,
                    size: 16.sp,
                    color: const Color(0xFF8E8883),
                  ),
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemImage(String path) {
    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        errorBuilder: (_, __, ___) => _buildFallbackCardImage(),
      );
    } else {
      final file = File(path);
      if (file.existsSync()) {
        return Image.file(
          file,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          errorBuilder: (_, __, ___) => _buildFallbackCardImage(),
        );
      }
      return Image.asset(
        path,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        errorBuilder: (_, __, ___) => _buildFallbackCardImage(),
      );
    }
  }

  Widget _buildFallbackCardImage() {
    return Container(
      color: const Color(0xFFF5EFE6),
      child: Center(
        child: Icon(
          Icons.checkroom_rounded,
          size: 40.sp,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom Clipper for curved hero header bottom edge
// ─────────────────────────────────────────────────────────────────────────────

class _BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 35.h);

    final controlPoint = Offset(size.width / 2, size.height + 25.h);
    final endPoint = Offset(size.width, size.height - 35.h);

    path.quadraticBezierTo(
      controlPoint.dx,
      controlPoint.dy,
      endPoint.dx,
      endPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

