import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helpers/helpers.dart';
import '../../../../core/theme/theme.dart';
import '../../../profile/presentation/screens/profile_screen.dart';

class AddManuallyScreen extends StatefulWidget {
  const AddManuallyScreen({super.key});

  @override
  State<AddManuallyScreen> createState() => _AddManuallyScreenState();
}

class _AddManuallyScreenState extends State<AddManuallyScreen> {
  // ── 1. Category Data ───────────────────────────────────────────────────────
  String _selectedCategory = 'T-Shirts';
  int _selectedCategoryIndex = 0;

  final List<Map<String, String>> _categories = const [
    {'title': 'Crew Neck T-Shirt', 'image': 'assets/images/T-shirts category/1.jpg'},
    {'title': 'Oversized T-Shirt', 'image': 'assets/images/T-shirts category/2.jpg'},
    {'title': 'V-Neck T-Shirt', 'image': 'assets/images/T-shirts category/3.jpg'},
    {'title': 'Polo T-Shirt', 'image': 'assets/images/T-shirts category/4.jpg'},
    {'title': 'Tank Top', 'image': 'assets/images/T-shirts category/5.jpg'},
    {'title': 'Long Sleeve', 'image': 'assets/images/T-shirts category/6.png'},
    {'title': 'Henley T-Shirt', 'image': 'assets/images/T-shirts category/7.jpg'},
    {'title': 'Graphic T-Shirt', 'image': 'assets/images/T-shirts category/8.jpg'},
  ];

  // ── 2. Pattern Data ────────────────────────────────────────────────────────
  int _selectedPatternIndex = 0;

  final List<Map<String, String>> _patterns = const [
    {'name': 'Solid', 'image': 'assets/images/T-shirts patern/p10.jpg'},
    {'name': 'Graphic', 'image': 'assets/images/T-shirts patern/p9.png'},
    {'name': 'Printed', 'image': 'assets/images/T-shirts patern/p8.jpg'},
    {'name': 'Vertical Striped', 'image': 'assets/images/T-shirts patern/p7.jpg'},
    {'name': 'Horizontal Striped', 'image': 'assets/images/T-shirts patern/p6.jpg'},
    {'name': 'Checked', 'image': 'assets/images/T-shirts patern/p5.jpg'},
    {'name': 'Plaid', 'image': 'assets/images/T-shirts patern/p4.jpg'},
    {'name': 'Floral', 'image': 'assets/images/T-shirts patern/p3.jpg'},
    {'name': 'Horizontal Striped', 'image': 'assets/images/T-shirts patern/p2.jpg'},
    {'name': 'Camouflage', 'image': 'assets/images/T-shirts patern/p1.jpg'},
  ];

  // ── 3. Colors Data ─────────────────────────────────────────────────────────
  int _selectedColorCategoryIndex = 1; // Default to "Black & Gray" as in screenshot
  String _selectedColorName = 'Charcoal'; // Default to Charcoal as in screenshot

  final List<Map<String, dynamic>> _colorCategories = const [
    {
      'category': 'White & Neutral',
      'colors': [
        {'name': 'White', 'hex': 0xFFFFFFFF},
        {'name': 'Off White', 'hex': 0xFFFFFAFA},
        {'name': 'Cream', 'hex': 0xFFF8F5EC},
        {'name': 'Ivory', 'hex': 0xFFFFFFF0},
        {'name': 'Beige', 'hex': 0xFFFFFDD0},
        {'name': 'Ecru', 'hex': 0xFFF8F6F0},
      ]
    },
    {
      'category': 'Black & Gray',
      'colors': [
        {'name': 'Black', 'hex': 0xFF000000},
        {'name': 'Jet Black', 'hex': 0xFF0A0A0A},
        {'name': 'Charcoal', 'hex': 0xFF36454F},
        {'name': 'Dark Gray', 'hex': 0xFF4A4A4A},
        {'name': 'Gray', 'hex': 0xFF808080},
        {'name': 'Light Gray', 'hex': 0xFFA0A0A0},
        {'name': 'Silver', 'hex': 0xFFD3D3D3},
        {'name': 'Ash', 'hex': 0xFFB2BEB5},
        {'name': 'Slate', 'hex': 0xFF708090},
      ]
    },
    {
      'category': 'Brown & Earth',
      'colors': [
        {'name': 'Tan', 'hex': 0xFFCDB891},
        {'name': 'Khaki', 'hex': 0xFFD8C7A3},
        {'name': 'Sand', 'hex': 0xFFCDB79E},
        {'name': 'Taupe', 'hex': 0xFFB8B5AE},
        {'name': 'Camel', 'hex': 0xFFC19A6B},
        {'name': 'Saddle', 'hex': 0xFF8B4513},
        {'name': 'Coffee', 'hex': 0xFF6F4E37},
        {'name': 'Dark Brown', 'hex': 0xFF4B3621},
      ]
    },
    {
      'category': 'Blue',
      'colors': [
        {'name': 'Sky Blue', 'hex': 0xFFBFEFFF},
        {'name': 'Light Blue', 'hex': 0xFF87CEEB},
        {'name': 'Royal Blue', 'hex': 0xFF007BFF},
        {'name': 'Cobalt', 'hex': 0xFF4169E1},
        {'name': 'Navy', 'hex': 0xFF000080},
        {'name': 'Indigo', 'hex': 0xFF4B0082},
      ]
    },
    {
      'category': 'Green',
      'colors': [
        {'name': 'Mint', 'hex': 0xFF98FF98},
        {'name': 'Sage', 'hex': 0xFF9CAF88},
        {'name': 'Olive', 'hex': 0xFF808000},
        {'name': 'Army', 'hex': 0xFF4B5320},
        {'name': 'Green', 'hex': 0xFF008000},
        {'name': 'Dark Green', 'hex': 0xFF006400},
        {'name': 'Lime', 'hex': 0xFF32CD32},
      ]
    },
    {
      'category': 'Red',
      'colors': [
        {'name': 'Red', 'hex': 0xFFFF0000},
        {'name': 'Crimson', 'hex': 0xFFD2042D},
        {'name': 'Scarlet', 'hex': 0xFFFF2400},
        {'name': 'Coral', 'hex': 0xFFFF7F50},
        {'name': 'Burgundy', 'hex': 0xFF800020},
        {'name': 'Wine', 'hex': 0xFF722F37},
      ]
    },
    {
      'category': 'Pink',
      'colors': [
        {'name': 'Soft Pink', 'hex': 0xFFF4C2C2},
        {'name': 'Light Pink', 'hex': 0xFFFFB6C1},
        {'name': 'Pink', 'hex': 0xFFFFC0CB},
        {'name': 'Hot Pink', 'hex': 0xFFFF66CC},
        {'name': 'Dusty Rose', 'hex': 0xFFDEA5A4},
        {'name': 'Magenta', 'hex': 0xFFFF00FF},
      ]
    },
    {
      'category': 'Purple',
      'colors': [
        {'name': 'Purple', 'hex': 0xFF800080},
        {'name': 'Electric', 'hex': 0xFF8F00FF},
        {'name': 'Plum', 'hex': 0xFF8E4585},
        {'name': 'Lilac', 'hex': 0xFFC8A2C8},
        {'name': 'Lavender', 'hex': 0xFFE6E6FA},
      ]
    },
    {
      'category': 'Yellow',
      'colors': [
        {'name': 'Gold', 'hex': 0xFFFFD700},
        {'name': 'Yellow', 'hex': 0xFFFFF44F},
        {'name': 'Mustard', 'hex': 0xFFD4A017},
        {'name': 'Bright Yellow', 'hex': 0xFFFFDF00},
      ]
    },
    {
      'category': 'Orange',
      'colors': [
        {'name': 'Orange', 'hex': 0xFFFFA500},
        {'name': 'Burnt Orange', 'hex': 0xFFCC5500},
        {'name': 'Terracotta', 'hex': 0xFFE2725B},
        {'name': 'Peach', 'hex': 0xFFFBCEB1},
        {'name': 'Apricot', 'hex': 0xFFFFE5B4},
      ]
    },
    {
      'category': 'Aqua & Teal',
      'colors': [
        {'name': 'Turquoise', 'hex': 0xFF40E0D0},
        {'name': 'Teal', 'hex': 0xFF008080},
        {'name': 'Dark Teal', 'hex': 0xFF014D4E},
      ]
    },
    {
      'category': 'Metallics',
      'colors': [
        {'name': 'Gold', 'hex': 0xFFD4AF37},
        {'name': 'Silver', 'hex': 0xFFC0C0C0},
        {'name': 'Rose Gold', 'hex': 0xFFB76E79},
        {'name': 'Bronze', 'hex': 0xFFCD7F32},
        {'name': 'Gunmetal', 'hex': 0xFF2A3439},
      ]
    },
  ];

  // ── 4. Sleeve Data ─────────────────────────────────────────────────────────
  bool _isSleeveExpanded = true;
  String _selectedSleeve = 'Long Sleeve';

  final List<String> _sleeves = const [
    'Short Sleeve',
    'Long Sleeve',
    'Sleeveless',
    'Raglan',
  ];

  // ── 5. Fit Data ────────────────────────────────────────────────────────────
  String _selectedFit = 'Regular';

  final List<String> _fits = const [
    'Regular',
    'Slim',
    'Relaxed',
    'Oversized',
  ];

  void _handleSave() {
    final selectedImage = _categories[_selectedCategoryIndex]['image']!;
    ClosetManager.instance.addItem(selectedImage);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              '${_categories[_selectedCategoryIndex]['title']} added to My Closet!',
            ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Navigation Bar ───────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                children: [
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
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
                ],
              ),
            ),

            // ── Main Scrollable Form Body ─────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── 1. Category Section ──────────────────────────────────
                    _buildCategorySection(),
                    SizedBox(height: 22.h),

                    // ── 2. Pattern Section ───────────────────────────────────
                    _buildPatternSection(),
                    SizedBox(height: 22.h),

                    // ── 3. Colors Section ────────────────────────────────────
                    _buildColorsSection(),
                    SizedBox(height: 22.h),

                    // ── 4. Sleeve Section ────────────────────────────────────
                    _buildSleeveSection(),
                    SizedBox(height: 22.h),

                    // ── 5. Fit Section ───────────────────────────────────────
                    _buildFitSection(),
                    SizedBox(height: 28.h),

                    // ── 6. Save Button ───────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 52.h,
                      child: ElevatedButton(
                        onPressed: _handleSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC8A97E),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                        ),
                        child: Text(
                          'Save to My Closet',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 1. Category Section
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row: Category Title + Dropdown Pill Button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Category',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF6F6A65),
              ),
            ),

            // Category Dropdown Pill
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F4EF),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: const Color(0xFFE5DDD0),
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _selectedCategory,
                    style: TextStyle(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF7A746E),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18.sp,
                    color: const Color(0xFF7A746E),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),

        // Horizontal Grid/List of Category Cards
        SizedBox(
          height: 140.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _categories.length,
            separatorBuilder: (_, __) => SizedBox(width: 12.w),
            itemBuilder: (context, index) {
              final isSelected = index == _selectedCategoryIndex;
              final item = _categories[index];

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategoryIndex = index;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 110.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFC8A97E)
                          : const Color(0xFFEAE3D9),
                      width: isSelected ? 2.0 : 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? const Color(0xFFC8A97E).withValues(alpha: 0.15)
                            : Colors.black.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Top Image Container
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(14.r),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(8.w),
                            child: Image.asset(
                              item['image']!,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Container(
                                color: const Color(0xFFF5EFE6),
                                child: Icon(
                                  Icons.checkroom_rounded,
                                  size: 32.sp,
                                  color: const Color(0xFFC8A97E),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Bottom Label Container
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                            vertical: 8.h, horizontal: 4.w),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFFAF6F0)
                              : const Color(0xFFFAFAFA),
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(14.r),
                          ),
                        ),
                        child: Text(
                          item['title']!,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: isSelected
                                ? const Color(0xFF2C2520)
                                : const Color(0xFF9E9893),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 2. Pattern Section
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildPatternSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pattern',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF6F6A65),
          ),
        ),
        SizedBox(height: 12.h),

        SizedBox(
          height: 48.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _patterns.length,
            separatorBuilder: (_, __) => SizedBox(width: 10.w),
            itemBuilder: (context, index) {
              final isSelected = index == _selectedPatternIndex;
              final pattern = _patterns[index];

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPatternIndex = index;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFFAF6F0)
                        : const Color(0xFFF7F4EF),
                    borderRadius: BorderRadius.circular(24.r),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFC8A97E)
                          : const Color(0xFFE5DDD0),
                      width: isSelected ? 1.8 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Pattern Image Thumbnail Circle
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16.r),
                        child: SizedBox(
                          width: 32.w,
                          height: 32.w,
                          child: Image.asset(
                            pattern['image']!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: const Color(0xFFC8A97E),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),

                      Text(
                        pattern['name']!,
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color: isSelected
                              ? const Color(0xFF2C2520)
                              : const Color(0xFF9E9893),
                        ),
                      ),
                      SizedBox(width: 4.w),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 3. Colors Section
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildColorsSection() {
    final activeCategoryColors =
        _colorCategories[_selectedColorCategoryIndex]['colors'] as List;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row: Colors Title + Multicolor Pill Chip
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Colors',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF6F6A65),
              ),
            ),

            // Multicolor Chip
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF3EEEC),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Text(
                'Multicolor',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFA59E99),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),

        // Color Category Tabs (Horizontal Scroll)
        SizedBox(
          height: 34.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _colorCategories.length,
            separatorBuilder: (_, __) => SizedBox(width: 14.w),
            itemBuilder: (context, index) {
              final isSelected = index == _selectedColorCategoryIndex;
              final catName = _colorCategories[index]['category'] as String;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColorCategoryIndex = index;
                  });
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      catName,
                      style: TextStyle(
                        fontSize: 14.5.sp,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w600,
                        color: isSelected
                            ? const Color(0xFF3E3935)
                            : const Color(0xFFA8A29D),
                      ),
                    ),
                    if (isSelected) ...[
                      SizedBox(height: 4.h),
                      Container(
                        width: 32.w,
                        height: 2.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3E3935),
                          borderRadius: BorderRadius.circular(1.r),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
        SizedBox(height: 14.h),

        // Specific Color Swatch Chips Row under Active Category
        SizedBox(
          height: 44.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: activeCategoryColors.length,
            separatorBuilder: (_, __) => SizedBox(width: 10.w),
            itemBuilder: (context, index) {
              final colorData = activeCategoryColors[index];
              final colorName = colorData['name'] as String;
              final colorHex = colorData['hex'] as int;
              final isSelected = _selectedColorName == colorName;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColorName = colorName;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFFAF6F0)
                        : const Color(0xFFF7F4EF),
                    borderRadius: BorderRadius.circular(22.r),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFC8A97E)
                          : const Color(0xFFE5DDD0),
                      width: isSelected ? 1.8 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        colorName,
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color: isSelected
                              ? const Color(0xFF2C2520)
                              : const Color(0xFF9E9893),
                        ),
                      ),
                      SizedBox(width: 8.w),

                      // Circle Color Swatch
                      Container(
                        width: 18.w,
                        height: 18.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(colorHex),
                          border: Border.all(
                            color: colorHex == 0xFFFFFFFF || colorHex == 0xFFFFFFF0
                                ? Colors.grey.shade400
                                : Colors.black.withValues(alpha: 0.1),
                            width: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 4. Sleeve Section
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildSleeveSection() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAF8F5),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: const Color(0xFFEFE8DE),
          width: 1.2,
        ),
      ),
      child: Column(
        children: [
          // Sleeve Header (Collapsible)
          InkWell(
            onTap: () {
              setState(() {
                _isSleeveExpanded = !_isSleeveExpanded;
              });
            },
            borderRadius: BorderRadius.circular(18.r),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sleeve',
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF5E5954),
                    ),
                  ),
                  Icon(
                    _isSleeveExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 22.sp,
                    color: const Color(0xFF7A746E),
                  ),
                ],
              ),
            ),
          ),

          // Radio List Items
          if (_isSleeveExpanded) ...[
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
              child: Column(
                children: _sleeves.map((sleeve) {
                  final isSelected = _selectedSleeve == sleeve;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedSleeve = sleeve;
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: Row(
                        children: [
                          // Custom Radio Circle
                          Container(
                            width: 20.w,
                            height: 20.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? const Color(0xFFC8A97E)
                                  : Colors.white,
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFFC8A97E)
                                    : const Color(0xFFD5CDC2),
                                width: 1.5,
                              ),
                            ),
                            child: isSelected
                                ? Center(
                                    child: Container(
                                      width: 8.w,
                                      height: 8.w,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                          SizedBox(width: 12.w),

                          Text(
                            sleeve,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? const Color(0xFFC8A97E)
                                  : const Color(0xFF8E8883),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 5. Fit Section
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildFitSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fit',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF6F6A65),
          ),
        ),
        SizedBox(height: 12.h),

        // Horizontal Row of Fit Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: _fits.map((fit) {
              final isSelected = _selectedFit == fit;

              return Padding(
                padding: EdgeInsets.only(right: 10.w),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedFit = fit;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFC8A97E)
                          : const Color(0xFFF7F4EF),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFC8A97E)
                            : const Color(0xFFE5DDD0),
                        width: 1.2,
                      ),
                    ),
                    child: Text(
                      fit,
                      style: TextStyle(
                        fontSize: 14.5.sp,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFFA09B95),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
