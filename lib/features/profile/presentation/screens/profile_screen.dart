import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/theme.dart';
import 'item_details_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedTabIndex = 0; // 0: My Closet, 1: My Looks

  // Demo clothing assets for My Closet tab
  final List<String> _closetItems = const [
    'assets/images/Frame 17975.png',
    'assets/images/Frame 17976.png',
    'assets/images/Frame 17977.png',
    'assets/images/Frame 17963.png',
    'assets/images/Frame 17964.png',
    'assets/images/Frame 17965.png',
  ];

  // Demo outfit assets for My Looks tab
  final List<String> _looksItems = const [
    'assets/images/Frame 1000005722.png',
    'assets/images/Frame 1000005723.png',
    'assets/images/Frame 1000005725.png',
    'assets/images/Frame 17975.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SingleChildScrollView(
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
                    'Amgad Shallan',
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
    return Padding(
      padding: EdgeInsets.only(top: 14.h),
      child: Row(
        children: [
          // Stat 1: My Closet
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: const Color(0xFFEAE3D9),
                  width: 1.2,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    '124',
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'My Closet',
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
          SizedBox(width: 12.w),

          // Stat 2: My Looks
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: const Color(0xFFEAE3D9),
                  width: 1.2,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    '18',
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'My Looks',
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
                  'My Closet',
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
                  'My Looks',
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
    final items = _selectedTabIndex == 0 ? _closetItems : _looksItems;

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
              child: Image.asset(
                imagePath,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),

            // Top Left 3-Dots Action Button
            Positioned(
              top: 10.h,
              left: 10.w,
              child: Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.65),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.8),
                    width: 1.0,
                  ),
                ),
                child: IconButton(
                  onPressed: () => _openItemDetails(context, imagePath),
                  icon: Icon(
                    Icons.more_vert_rounded,
                    size: 18.sp,
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
