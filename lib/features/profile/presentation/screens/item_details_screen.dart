import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helpers/helpers.dart';
import '../../../../core/http/http.dart';
import '../../../../core/local_storage/local_storage.dart';
import '../../../../core/outfit_engine/outfit_engine.dart';
import '../../../../core/service_locator/service_locator.dart';
import '../../../../core/theme/theme.dart';
import '../../../home/data/models/my_closet_response_model.dart';
import '../../../home/data/services/wardrobe_remote_data_source.dart';
import '../../../home/presentation/widgets/camera_access_bottom_sheet.dart';
import '../widgets/avatar_3d_viewer.dart';
import 'more_details_screen.dart';

class ItemDetailsScreen extends StatefulWidget {
  final String? initialImage;
  final List<String>? outfitImages;
  final String? garmentColor;
  final String? pantsColor;
  final UnityOutfitPayload? outfitPayload;
  final String? occasion;

  const ItemDetailsScreen({
    super.key,
    this.initialImage,
    this.outfitImages,
    this.garmentColor,
    this.pantsColor,
    this.outfitPayload,
    this.occasion,
  });

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  int _currentIndex = 0;
  bool _is3DAvatarMode = true;
  String _userGender = 'male';

  // Carousel images list
  late List<String> _thumbnails;

  late PageController _pageController;
  late ScrollController _thumbnailScrollController;

  bool get _isCustomOutfitFlow =>
      widget.outfitImages != null && widget.outfitImages!.isNotEmpty;

  WardrobeItemModel? _findClosetItem(String path) {
    final clean = path.trim().toLowerCase();
    for (final item in ClosetManager.instance.items) {
      if (item.imageUrl.toLowerCase() == clean ||
          item.fullImageUrl.toLowerCase() == clean) {
        return item;
      }
      final base = ClosetManager.extractBaseFileName(item.imageUrl);
      final pBase = ClosetManager.extractBaseFileName(clean);
      if (base.isNotEmpty && pBase.isNotEmpty && base == pBase) {
        return item;
      }
    }
    return null;
  }

  static String? _colorNameToHex(String? colorName) {
    if (colorName == null || colorName.trim().isEmpty) return null;
    final c = colorName.trim().toLowerCase();
    if (c.startsWith('#') && (c.length == 7 || c.length == 9)) return c;
    if (c.contains('black') || c.contains('أسود') || c.contains('اسود')) return '#1B1B1D';
    if (c.contains('white') || c.contains('أبيض') || c.contains('ابيض')) return '#FFFFFF';
    if (c.contains('navy') || c.contains('كحلي')) return '#243447';
    if (c.contains('blue') || c.contains('أزرق') || c.contains('ازرق')) return '#2B4C7E';
    if (c.contains('grey') || c.contains('gray') || c.contains('رمادي')) return '#8E9EAB';
    if (c.contains('beige') || c.contains('بيج') || c.contains('cream') || c.contains('كريمي')) return '#F4ECE1';
    if (c.contains('brown') || c.contains('بني') || c.contains('camel') || c.contains('هافان')) return '#C4AB80';
    if (c.contains('green') || c.contains('أخضر') || c.contains('اخضر') || c.contains('زيتي')) return '#2D4F38';
    if (c.contains('red') || c.contains('أحمر') || c.contains('احمر') || c.contains('burgundy') || c.contains('نبيتي')) return '#722F37';
    if (c.contains('yellow') || c.contains('أصفر') || c.contains('اصفر') || c.contains('mustard')) return '#D4AF37';
    if (c.contains('orange') || c.contains('برتقالي')) return '#C86432';
    if (c.contains('pink') || c.contains('وردي') || c.contains('بمبي')) return '#D9889B';
    if (c.contains('purple') || c.contains('بنفسجي')) return '#5A3866';
    return null;
  }

  bool get _isCurrentItemBottom {
    if (_currentIndex < 0 || _currentIndex >= _thumbnails.length) return false;
    final path = _thumbnails[_currentIndex];
    if (widget.outfitPayload != null) {
      for (final slot in widget.outfitPayload!.slots) {
        if (slot.imagePath == path) {
          return slot.slot == GarmentSlotType.bottom;
        }
      }
    }
    final item = _findClosetItem(path);
    if (item != null) return item.isBottom;
    final lp = path.toLowerCase();
    return lp.contains('pant') ||
        lp.contains('jean') ||
        lp.contains('trouser') ||
        lp.contains('short') ||
        lp.contains('jogger') ||
        lp.contains('cargo') ||
        lp.contains('sweatpant');
  }

  String _getGarmentColor(int index) {
    if (widget.garmentColor != null && widget.garmentColor!.isNotEmpty) {
      return widget.garmentColor!;
    }
    if (index >= 0 && index < _thumbnails.length) {
      final path = _thumbnails[index];
      final item = _findClosetItem(path);
      if (item != null && item.isTop) {
        final colorAttr = item.attributes?['color'] ??
            item.attributes?['Color'] ??
            item.parsedAttributes.color;
        final hex = _colorNameToHex(colorAttr?.toString());
        if (hex != null) return hex;
      }
      final lp = path.toLowerCase();
      final isBottom = item?.isBottom == true ||
          lp.contains('pant') ||
          lp.contains('jean') ||
          lp.contains('trouser') ||
          lp.contains('short');
      if (!isBottom) {
        if (path.contains('17975')) return '#222225'; // Dark Charcoal Knitted Sweater
        if (path.contains('17976')) return '#F4ECE1'; // Cream
        if (path.contains('17977')) return '#C4AB80'; // Sand / Camel
        if (path.contains('17963')) return '#243447'; // Classic Navy
        if (path.contains('17964')) return '#8E9EAB'; // Grey
        if (path.contains('17965')) return '#FFFFFF'; // White
        final nameHex = _colorNameToHex(path);
        if (nameHex != null) return nameHex;
      }
    }
    return '#222225';
  }

  String _getPantsColor(int index) {
    if (widget.pantsColor != null && widget.pantsColor!.isNotEmpty) {
      return widget.pantsColor!;
    }
    if (index >= 0 && index < _thumbnails.length) {
      final path = _thumbnails[index];
      final item = _findClosetItem(path);
      if (item != null && item.isBottom) {
        final colorAttr = item.attributes?['color'] ??
            item.attributes?['Color'] ??
            item.parsedAttributes.color;
        final hex = _colorNameToHex(colorAttr?.toString());
        if (hex != null) return hex;
      }
      if (path.contains('17975')) return '#EFEAE2'; // Off-white / Cream trousers
      if (path.contains('17976')) return '#EFEAE2'; // White
      if (path.contains('17977')) return '#4A4238'; // Dark Mocha
      if (path.contains('man')) return '#2B2D31';   // Slate Black
      if (path.contains('17963')) return '#C4AB80'; // Sand
      if (path.contains('17964')) return '#2B2D31'; // Charcoal
      if (path.contains('17965')) return '#2B4C7E'; // Denim Blue
      final nameHex = _colorNameToHex(path);
      if (nameHex != null) return nameHex;
    }
    return '#2B2D31';
  }

  Future<void> _loadUserGender() async {
    try {
      final stored = await HiveServiceImpl.get<String>('settings_box', 'user_gender');
      if (stored != null && stored.isNotEmpty && mounted) {
        setState(() {
          _userGender = stored;
        });
      }
    } catch (_) {}
  }

  void _onClosetChanged() {
    if (!mounted || _isCustomOutfitFlow) return;
    setState(() {
      _thumbnails = List<String>.from(ClosetManager.instance.value);
      if (_currentIndex >= _thumbnails.length) {
        _currentIndex = _thumbnails.isEmpty ? 0 : _thumbnails.length - 1;
      }
    });
  }

  Future<void> _fetchClosetIfEmpty() async {
    if (_isCustomOutfitFlow) return;
    try {
      final dataSource = getIt<WardrobeRemoteDataSource>();
      final result = await dataSource.getMyCloset();
      result.fold(
        (_) {},
        (model) {
          if (!mounted) return;
          if (model.data?.items != null && model.data!.items.isNotEmpty) {
            ClosetManager.instance.syncRemoteModels(model.data!.items);
          }
        },
      );
    } catch (_) {}
  }

  @override
  void initState() {
    super.initState();
    _loadUserGender();

    if (_isCustomOutfitFlow) {
      // 1. Entered from scan/generation flow: Display the 1 generated outfit
      _thumbnails = List<String>.from(widget.outfitImages!);
      _currentIndex = 0;
    } else {
      // 2. Entered from bottom nav bar: Display user's My Closet items
      ClosetManager.instance.addListener(_onClosetChanged);
      _thumbnails = List<String>.from(ClosetManager.instance.value);
      _currentIndex = 0;

      if (_thumbnails.isEmpty) {
        _fetchClosetIfEmpty();
      } else if (widget.initialImage != null && widget.initialImage!.isNotEmpty) {
        final idx = _thumbnails.indexOf(widget.initialImage!);
        if (idx != -1) {
          _currentIndex = idx;
        } else {
          _thumbnails.insert(0, widget.initialImage!);
          _currentIndex = 0;
        }
      }
    }

    _pageController = PageController(
      initialPage: _thumbnails.isEmpty ? 0 : _currentIndex,
    );
    _thumbnailScrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_thumbnails.isNotEmpty) {
        _scrollToThumbnail(_currentIndex, animate: false);
      }
    });
  }

  @override
  void dispose() {
    if (!_isCustomOutfitFlow) {
      ClosetManager.instance.removeListener(_onClosetChanged);
    }
    _pageController.dispose();
    _thumbnailScrollController.dispose();
    super.dispose();
  }

  void _scrollToThumbnail(int index, {bool animate = true}) {
    if (!_thumbnailScrollController.hasClients || _thumbnails.isEmpty) return;

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
    if (_thumbnails.isNotEmpty && _currentIndex < _thumbnails.length - 1) {
      if (_is3DAvatarMode) {
        setState(() {
          _currentIndex++;
        });
        _scrollToThumbnail(_currentIndex);
      } else {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _previousPage() {
    if (_thumbnails.isNotEmpty && _currentIndex > 0) {
      if (_is3DAvatarMode) {
        setState(() {
          _currentIndex--;
        });
        _scrollToThumbnail(_currentIndex);
      } else {
        _pageController.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _showMoreDetailsModal() async {
    if (_thumbnails.isEmpty) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (_) => const CameraAccessBottomSheet(),
      );
      return;
    }
    final currentImage =
        _thumbnails[_currentIndex.clamp(0, _thumbnails.length - 1)];
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => MoreDetailsScreen(
          imagePath: currentImage,
          onSaveToCloset: (savedImg) async {
            if (ClosetManager.instance.contains(savedImg)) return;
            try {
              final dataSource = getIt<WardrobeRemoteDataSource>();
              String? category;
              if (widget.outfitPayload != null) {
                for (final slot in widget.outfitPayload!.slots) {
                  if (slot.imagePath == savedImg) {
                    category = slot.slot == GarmentSlotType.bottom
                        ? 'Pants'
                        : (slot.slot == GarmentSlotType.top
                            ? 'T-Shirt'
                            : 'Clothing');
                    break;
                  }
                }
              }
              if (category == null) {
                final lp = savedImg.toLowerCase();
                if (lp.contains('pant') ||
                    lp.contains('jean') ||
                    lp.contains('trouser') ||
                    lp.contains('short')) {
                  category = 'Pants';
                }
              }
              await dataSource.addToMyCloset(
                imagePath: savedImg,
                category: category,
                addToMyCloset: true,
              );
              ClosetManager.instance.addItem(
                savedImg,
                model: WardrobeItemModel(
                  id: DateTime.now().millisecondsSinceEpoch,
                  imageUrl: savedImg,
                  attributes: category != null ? {'category': category} : null,
                ),
              );
            } catch (_) {}
          },
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
                      onPressed: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                      },
                      icon: Icon(
                        Navigator.canPop(context)
                            ? Icons.arrow_back_ios_new_rounded
                            : Icons.checkroom_rounded,
                        size: 18.sp,
                        color: AppColors.textPrimary,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),

                  // Center: 2D Photo / 3D Avatar Mode Toggle
                  _buildModeToggle(),

                  // Favorite Button
                  Builder(
                    builder: (context) {
                      if (_thumbnails.isEmpty) {
                        return Container(
                          width: 40.w,
                          height: 40.w,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.favorite_border_rounded,
                            size: 20.sp,
                            color: AppColors.disabled,
                          ),
                        );
                      }
                      final currentImage = _thumbnails[
                          _currentIndex.clamp(0, _thumbnails.length - 1)];
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
                  if (_is3DAvatarMode)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Avatar3DViewer(
                        key: ValueKey('avatar_$_userGender'),
                        gender: _userGender,
                        garmentColor: _thumbnails.isNotEmpty
                            ? _getGarmentColor(_currentIndex)
                            : '#222225',
                        pantsColor: _thumbnails.isNotEmpty
                            ? _getPantsColor(_currentIndex)
                            : '#2B2D31',
                        garmentType: _isCurrentItemBottom ? 'pants' : 'sweater',
                        garmentCategory: _isCurrentItemBottom ? 'bottom' : 'top',
                      ),
                    )
                  else if (_thumbnails.isEmpty)
                    _buildEmptyClosetView()
                  else
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
                            child: _buildItemImage(
                              _thumbnails[index],
                              BoxFit.contain,
                            ),
                          ),
                        );
                      },
                    ),

                  // Left Navigation Arrow Button
                  if (_thumbnails.length > 1) ...[
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
                ],
              ),
            ),

            // ── 3. Sleek Bottom Panel (Takes only ~1/3, giving 2/3 of screen to 3D Stage) ──
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(18.w, 8.h, 18.w, 12.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F5F0),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(24.r),
                ),
                border: const Border(
                  top: BorderSide(
                    color: Color(0xFFECE4D8),
                    width: 1.2,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Gold Handle Pill
                  Container(
                    width: 44.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFC8A97E),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  SizedBox(height: 8.h),

                  // Rating Stars + Counter & Style Tag Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Text(
                            _thumbnails.isEmpty ? '0' : '${_currentIndex + 1}',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFB5956A),
                            ),
                          ),
                          Text(
                            '/${_thumbnails.length}',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFB0A9A2),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Row(
                            children: List.generate(5, (starIndex) {
                              final isFilled = starIndex < 2;
                              return Padding(
                                padding: EdgeInsets.only(right: 2.w),
                                child: Icon(
                                  Icons.star_rounded,
                                  size: 14.sp,
                                  color: isFilled
                                      ? const Color(0xFFC8A97E)
                                      : const Color(0xFFD6CEC4),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                      Text(
                        'summer_essentials'.tr(),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),

                  // Horizontal Thumbnails Carousel
                  SizedBox(
                    height: 76.h,
                    child: _thumbnails.isEmpty
                        ? Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              child: Text(
                                'empty_closet_desc'.tr(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.secondary,
                                ),
                              ),
                            ),
                          )
                        : ListView.builder(
                            controller: _thumbnailScrollController,
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  (MediaQuery.of(context).size.width / 2) -
                                      44.w,
                              vertical: 4.h,
                            ),
                            itemCount: _thumbnails.length,
                            itemBuilder: (context, index) {
                              final isSelected = index == _currentIndex;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _currentIndex = index;
                                  });
                                  if (_pageController.hasClients) {
                                    _pageController.animateToPage(
                                      index,
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  }
                                  _scrollToThumbnail(index);
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeOutCubic,
                                  margin: EdgeInsets.symmetric(horizontal: 5.w),
                                  width: isSelected ? 68.w : 52.w,
                                  height: isSelected ? 68.h : 54.h,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFE8DD),
                                    borderRadius: BorderRadius.circular(
                                      isSelected ? 16.r : 12.r,
                                    ),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFFC8A97E)
                                          : const Color(0xFFE2D6C6),
                                      width: isSelected ? 2.2 : 1.0,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: const Color(0xFFC8A97E)
                                                  .withValues(alpha: 0.35),
                                              blurRadius: 10,
                                              spreadRadius: 1,
                                              offset: const Offset(0, 4),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: AnimatedOpacity(
                                    duration:
                                        const Duration(milliseconds: 250),
                                    opacity: isSelected ? 1.0 : 0.65,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                        isSelected ? 14.r : 10.r,
                                      ),
                                      child: _buildItemImage(
                                        _thumbnails[index],
                                        BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  SizedBox(height: 10.h),

                  // "More Details" or "Add Clothes" Primary Button
                  SizedBox(
                    width: double.infinity,
                    height: 44.h,
                    child: ElevatedButton(
                      onPressed: _showMoreDetailsModal,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        _thumbnails.isEmpty
                            ? 'add_clothes_btn'.tr()
                            : 'more_details'.tr(),
                        style: TextStyle(
                          fontSize: 14.sp,
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

  Widget _buildEmptyClosetView() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76.w,
              height: 76.w,
              decoration: BoxDecoration(
                color: const Color(0xFFEFE8DD),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFE2D6C6),
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.checkroom_rounded,
                size: 38.sp,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 14.h),
            Text(
              'empty_closet_title'.tr(),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'empty_closet_desc'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.secondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemImage(String path, BoxFit fit) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: fit,
        errorBuilder: (_, __, ___) => _buildFallbackImage(),
      );
    }

    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: fit,
        errorBuilder: (_, __, ___) => _buildFallbackImage(),
      );
    }

    final file = File(path);
    if (file.existsSync()) {
      return Image.file(
        file,
        fit: fit,
        errorBuilder: (_, __, ___) => _buildFallbackImage(),
      );
    }

    if (path.contains('Images/') || path.contains('WardrobeItems/')) {
      final cleanBase = Endpoints.baseUrl.endsWith('/')
          ? Endpoints.baseUrl.substring(0, Endpoints.baseUrl.length - 1)
          : Endpoints.baseUrl;
      final cleanPath = path.startsWith('/') ? path : '/$path';
      return Image.network(
        '$cleanBase$cleanPath',
        fit: fit,
        errorBuilder: (_, __, ___) => _buildFallbackImage(),
      );
    }

    return Image.asset(
      path,
      fit: fit,
      errorBuilder: (_, __, ___) => _buildFallbackImage(),
    );
  }

  Widget _buildFallbackImage() {
    return Container(
      color: const Color(0xFFEFE8DD),
      child: Center(
        child: Icon(
          Icons.checkroom_rounded,
          size: 40.sp,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildModeToggle() {
    return Container(
      height: 38.h,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: const Color(0xFFEAE3D9),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildModeButton(
            title: '3D Avatar',
            icon: Icons.accessibility_new_rounded,
            isActive: _is3DAvatarMode,
            onTap: () {
              if (!_is3DAvatarMode) {
                setState(() => _is3DAvatarMode = true);
              }
            },
          ),
          _buildModeButton(
            title: '2D Photo',
            icon: Icons.photo_outlined,
            isActive: !_is3DAvatarMode,
            onTap: () {
              if (_is3DAvatarMode) {
                setState(() => _is3DAvatarMode = false);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton({
    required String title,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFB5956A) : Colors.transparent,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15.sp,
              color: isActive ? Colors.white : const Color(0xFF8A7E73),
            ),
            SizedBox(width: 4.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? Colors.white : const Color(0xFF8A7E73),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

