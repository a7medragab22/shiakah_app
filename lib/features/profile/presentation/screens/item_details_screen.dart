import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helpers/helpers.dart';
import '../../../../core/theme/theme.dart';
import 'more_details_screen.dart';

class ItemDetailsScreen extends StatefulWidget {
  final String? initialImage;

  const ItemDetailsScreen({
    super.key,
    this.initialImage,
  });

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  int _currentIndex = 3; // 4th image (index 3 out of 7, displays "4/7")

  // Carousel images demo list
  final List<String> _thumbnails = const [
    'assets/images/Frame 17975.png',
    'assets/images/Frame 17976.png',
    'assets/images/Frame 17977.png',
    'assets/images/man.png',
    'assets/images/Frame 17963.png',
    'assets/images/Frame 17964.png',
    'assets/images/Frame 17965.png',
  ];

  late PageController _pageController;
  late ScrollController _thumbnailScrollController;

  @override
  void initState() {
    super.initState();
    if (widget.initialImage != null) {
      final idx = _thumbnails.indexOf(widget.initialImage!);
      if (idx != -1) {
        _currentIndex = idx;
      }
    }
    _pageController = PageController(initialPage: _currentIndex);
    _thumbnailScrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToThumbnail(_currentIndex, animate: false);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _thumbnailScrollController.dispose();
    super.dispose();
  }

  void _scrollToThumbnail(int index, {bool animate = true}) {
    if (!_thumbnailScrollController.hasClients) return;

    final itemWidth = 80.w;
    final targetOffset = (index * itemWidth).toDouble();

    final maxScroll = _thumbnailScrollController.position.maxScrollExtent;
    final minScroll = _thumbnailScrollController.position.minScrollExtent;
    final clampedOffset = targetOffset.clamp(minScroll, maxScroll);

    if (animate) {
      _thumbnailScrollController.animateTo(
        clampedOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    } else {
      _thumbnailScrollController.jumpTo(clampedOffset);
    }
  }

  void _nextPage() {
    if (_currentIndex < _thumbnails.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showMoreDetailsModal() async {
    final currentImage = _thumbnails[_currentIndex];
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => MoreDetailsScreen(
          imagePath: currentImage,
        ),
      ),
    );

    if (result == true && mounted) {
      // Return true to parent if saved
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3EE),
      body: SafeArea(
        child: Column(
          children: [
            // ── 1. Top Bar (Back Button + Heart Button) ─────────────────────
            Padding(
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
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18.sp,
                        color: AppColors.textPrimary,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),

                  // Favorite Button
                  Builder(
                    builder: (context) {
                      final currentImage = _thumbnails[_currentIndex];
                      final isFav =
                          LooksManager.instance.contains(currentImage);

                      return Container(
                        width: 40.w,
                        height: 40.w,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () {
                            LooksManager.instance.toggleItem(currentImage);
                            setState(() {});

                            final isNowFav =
                                LooksManager.instance.contains(currentImage);
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    Icon(
                                      isNowFav
                                          ? Icons.favorite_rounded
                                          : Icons.favorite_border_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      isNowFav
                                          ? 'Added to My Looks!'
                                          : 'Removed from My Looks',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                                backgroundColor: isNowFav
                                    ? const Color(0xFFE56B82)
                                    : const Color(0xFF262321),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: Icon(
                            isFav
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 20.sp,
                            color: isFav
                                ? const Color(0xFFE56B82)
                                : AppColors.textPrimary,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // ── 2. Main Outfit Model View + Left/Right Side Arrows ──────────
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Full PageView for outfit items
                  PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                      _scrollToThumbnail(index);
                    },
                    itemCount: _thumbnails.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Center(
                          child: Image.asset(
                            _thumbnails[index],
                            fit: BoxFit.contain,
                            height: double.infinity,
                          ),
                        ),
                      );
                    },
                  ),

                  // Left Navigation Arrow Button
                  Positioned(
                    left: 12.w,
                    child: Container(
                      width: 38.w,
                      height: 38.w,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.7),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFEAE3D9),
                          width: 1.0,
                        ),
                      ),
                      child: IconButton(
                        onPressed: _previousPage,
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 16.sp,
                          color: const Color(0xFFB5956A),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),

                  // Right Navigation Arrow Button
                  Positioned(
                    right: 12.w,
                    child: Container(
                      width: 38.w,
                      height: 38.w,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.7),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFEAE3D9),
                          width: 1.0,
                        ),
                      ),
                      child: IconButton(
                        onPressed: _nextPage,
                        icon: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16.sp,
                          color: const Color(0xFFB5956A),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── 3. Rating Stars + Counter (4/7) & Style Tag ────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Left: Counter 4/7 & Stars
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '${_currentIndex + 1}',
                            style: TextStyle(
                              fontSize: 26.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFB5956A),
                            ),
                          ),
                          Text(
                            '/${_thumbnails.length}',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFB0A9A2),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),

                      // 5 Star Rating (2 filled gold, 3 grey)
                      Row(
                        children: List.generate(5, (starIndex) {
                          final isFilled = starIndex < 2;
                          return Padding(
                            padding: EdgeInsets.only(right: 3.w),
                            child: Icon(
                              isFilled
                                  ? Icons.star_rounded
                                  : Icons.star_rounded,
                              size: 18.sp,
                              color: isFilled
                                  ? const Color(0xFFC8A97E)
                                  : const Color(0xFFD6CEC4),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),

                  // Right: Summer Essentials Tag
                  Text(
                    'summer_essentials'.tr(),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.h),

            // ── 4. Bottom Panel Container with Horizontal Thumbnails ────────
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 24.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F5F0),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(28.r),
                ),
                border: Border(
                  top: BorderSide(
                    color: const Color(0xFFECE4D8),
                    width: 1.2,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Gold Handle Pill
                  Container(
                    width: 54.w,
                    height: 5.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFC8A97E),
                      borderRadius: BorderRadius.circular(3.r),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Horizontal Thumbnails Carousel
                  SizedBox(
                    height: 118.h,
                    child: ListView.builder(
                      controller: _thumbnailScrollController,
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal:
                            (MediaQuery.of(context).size.width / 2) - 52.w,
                        vertical: 8.h,
                      ),
                      itemCount: _thumbnails.length,
                      itemBuilder: (context, index) {
                        final isSelected = index == _currentIndex;
                        return GestureDetector(
                          onTap: () {
                            _pageController.animateToPage(
                              index,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOutCubic,
                            transform: Matrix4.translationValues(
                              0,
                              isSelected ? -10.h : 0,
                              0,
                            ),
                            margin: EdgeInsets.symmetric(horizontal: 6.w),
                            width: isSelected ? 92.w : 66.w,
                            height: isSelected ? 96.h : 76.h,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFE8DD),
                              borderRadius: BorderRadius.circular(
                                isSelected ? 22.r : 16.r,
                              ),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFFC8A97E)
                                    : const Color(0xFFE2D6C6),
                                width: isSelected ? 2.8 : 1.0,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFFC8A97E)
                                            .withValues(alpha: 0.42),
                                        blurRadius: 18,
                                        spreadRadius: 1,
                                        offset: const Offset(0, 10),
                                      ),
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.12),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ]
                                  : [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.03),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                            ),
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 250),
                              opacity: isSelected ? 1.0 : 0.65,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  isSelected ? 19.r : 14.r,
                                ),
                                child: Image.asset(
                                  _thumbnails[index],
                                  fit: BoxFit.cover,
                                  alignment: Alignment.topCenter,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // "More Details" Primary Button
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: _showMoreDetailsModal,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: Text(
                        'more_details'.tr(),
                        style: TextStyle(
                          fontSize: 16.sp,
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
    );
  }
}
