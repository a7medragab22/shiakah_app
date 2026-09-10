import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/theme.dart';

class MoreDetailsScreen extends StatefulWidget {
  final String? imagePath;
  final Function(String itemImage)? onSaveToCloset;

  const MoreDetailsScreen({
    super.key,
    this.imagePath,
    this.onSaveToCloset,
  });

  @override
  State<MoreDetailsScreen> createState() => _MoreDetailsScreenState();
}

class _MoreDetailsScreenState extends State<MoreDetailsScreen> {
  bool _isFavorite = true;
  bool _saveToCloset = false;

  void _handleDoneStyling() {
    if (_saveToCloset) {
      if (widget.onSaveToCloset != null) {
        widget.onSaveToCloset!(widget.imagePath ?? 'assets/images/man.png');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item saved to My Closet successfully!'),
          backgroundColor: Color(0xFF388E3C),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    Navigator.pop(context, _saveToCloset);
  }

  @override
  Widget build(BuildContext context) {
    final displayImage = widget.imagePath ?? 'assets/images/man.png';

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. Top Image Header with Back & Favorite Buttons ────────────
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 380.h,
                  color: const Color(0xFFEAD9C6),
                  child: Image.asset(
                    displayImage,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
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

                        // Red Heart Favorite Button
                        Container(
                          width: 40.w,
                          height: 40.w,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                _isFavorite = !_isFavorite;
                              });
                            },
                            icon: Icon(
                              _isFavorite
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              size: 20.sp,
                              color: const Color(0xFFFF4D4D),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Main Content Padding
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── 2. Title + Subtitle & Rating Badge (4.8 ★) ─────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Clean Minimal',
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Minimal casual outfit with clean neutral tones.',
                              style: TextStyle(
                                fontSize: 12.5.sp,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF8E8883),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),

                      // Rating Badge: 4.8 ★
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFBF4E8),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: const Color(0xFFF3E4CD),
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              '4.8',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Icon(
                              Icons.star_rounded,
                              color: const Color(0xFFC8A97E),
                              size: 16.sp,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 18.h),

                  // ── 3. Your Item Horizontal Row ────────────────────────────
                  Text(
                    'Your Item',
                    style: TextStyle(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF8E8883),
                    ),
                  ),
                  SizedBox(height: 10.h),

                  SizedBox(
                    height: 105.h,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _buildYourItemCard(
                          icon: Icons.checkroom_rounded,
                          label: 'Off-White Tee',
                        ),
                        _buildYourItemCard(
                          icon: Icons.dry_cleaning_rounded,
                          label: 'Beige Short',
                        ),
                        _buildYourItemCard(
                          icon: Icons.roller_skating_outlined,
                          label: 'Off-White Sneaker',
                        ),
                        _buildYourItemCard(
                          icon: Icons.watch_rounded,
                          label: 'Brown Leather Watch',
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // ── 4. AI Match Analysis Card ──────────────────────────────
                  _buildAiMatchAnalysisCard(),
                  SizedBox(height: 16.h),

                  // ── 5. Occasion Suitability Card ───────────────────────────
                  _buildOccasionSuitabilityCard(),
                  SizedBox(height: 16.h),

                  // ── 6. Why AI Picked This? Card ────────────────────────────
                  _buildWhyAiPickedCard(),
                  SizedBox(height: 16.h),

                  // ── 7. Weather Fit Card ────────────────────────────────────
                  _buildWeatherFitCard(),
                  SizedBox(height: 24.h),

                  // ── 8. Save to My Closet Checkbox ──────────────────────────
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _saveToCloset = !_saveToCloset;
                      });
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Custom Checkbox
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 22.w,
                          height: 22.w,
                          decoration: BoxDecoration(
                            color: _saveToCloset
                                ? const Color(0xFFC8A97E)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(
                              color: _saveToCloset
                                  ? const Color(0xFFC8A97E)
                                  : const Color(0xFFD0C8BD),
                              width: 1.5,
                            ),
                          ),
                          child: _saveToCloset
                              ? Icon(
                                  Icons.check_rounded,
                                  size: 16.sp,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Save this item to My Closet',
                                style: TextStyle(
                                  fontSize: 14.5.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'Keep this item for future outfit recommendations.',
                                style: TextStyle(
                                  fontSize: 11.5.sp,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF8E8883),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 18.h),

                  // ── 9. Done Styling Primary Button ──────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: _handleDoneStyling,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC8A97E),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: Text(
                        'Done Styling',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Your Item Thumbnail Card Helper
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildYourItemCard({required IconData icon, required String label}) {
    return Container(
      width: 95.w,
      margin: EdgeInsets.only(right: 10.w),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: const Color(0xFFEAE3D9),
          width: 1.2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: const Color(0xFFF9F5EE),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              icon,
              size: 24.sp,
              color: const Color(0xFFB5956A),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF8E8883),
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // AI Match Analysis Card
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildAiMatchAnalysisCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: const Color(0xFFEAE3D9),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI Match Analysis',
            style: TextStyle(
              fontSize: 16.5.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            'AI evaluation based on style, comfort, and color harmony.',
            style: TextStyle(
              fontSize: 12.sp,
              color: const Color(0xFF8E8883),
            ),
          ),
          SizedBox(height: 12.h),

          // Analysis Row Items
          _buildAnalysisRow('Color Harmony', 'Excellent', const Color(0xFFE8F5E9), const Color(0xFF4CAF50)),
          const Divider(height: 14),
          _buildAnalysisRow('Style Consistency', 'Excellent', const Color(0xFFE8F5E9), const Color(0xFF4CAF50)),
          const Divider(height: 14),
          _buildAnalysisRow('Comfort Level', 'Very Comfortable', const Color(0xFFFFF8E1), const Color(0xFFFFA000)),
          const Divider(height: 14),
          _buildAnalysisRow('Weather Suitability', 'Warm Weather', const Color(0xFFFFF3E0), const Color(0xFFE65100)),
        ],
      ),
    );
  }

  Widget _buildAnalysisRow(String title, String badgeText, Color bgColor, Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13.5.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF6E6862),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            badgeText,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Occasion Suitability Card
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildOccasionSuitabilityCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: const Color(0xFFEAE3D9),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Occasion Suitability',
            style: TextStyle(
              fontSize: 16.5.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 10.h),

          // Recommended Subsection
          Row(
            children: [
              Icon(Icons.thumb_up_alt_outlined, size: 15.sp, color: const Color(0xFF8E8883)),
              SizedBox(width: 6.w),
              Text(
                'Recommended',
                style: TextStyle(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF8E8883),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 6.w,
            runSpacing: 6.h,
            children: [
              _buildChip('Coffee', isRecommended: true),
              _buildChip('Shopping', isRecommended: true),
              _buildChip('Walking', isRecommended: true),
              _buildChip('Summer', isRecommended: true),
              _buildChip('Travel', isRecommended: true),
            ],
          ),

          SizedBox(height: 14.h),

          // Not Recommended Subsection
          Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 15.sp, color: const Color(0xFF8E8883)),
              SizedBox(width: 6.w),
              Text(
                'Not Recommended',
                style: TextStyle(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF8E8883),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 6.w,
            runSpacing: 6.h,
            children: [
              _buildChip('Formal Events', isRecommended: false),
              _buildChip('Business Meetings', isRecommended: false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, {required bool isRecommended}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: isRecommended ? const Color(0xFFD6BE9F) : const Color(0xFFF0EBE4),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: isRecommended ? Colors.white : const Color(0xFF8E8883),
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Why AI Picked This? Card
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildWhyAiPickedCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: const Color(0xFFEAE3D9),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Why AI Picked This?',
            style: TextStyle(
              fontSize: 16.5.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          _buildCheckItem('Neutral colors create a clean appearance.'),
          SizedBox(height: 8.h),
          _buildCheckItem('Lightweight pieces keep you comfortable.'),
          SizedBox(height: 8.h),
          _buildCheckItem('Versatile enough for multiple casual occasions.'),
          SizedBox(height: 8.h),
          _buildCheckItem('Timeless style that won\'t go out of fashion.'),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String text) {
    return Row(
      children: [
        Container(
          width: 20.w,
          height: 20.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF4CAF50), width: 1.4),
          ),
          child: Center(
            child: Icon(Icons.check_rounded, color: const Color(0xFF4CAF50), size: 13.sp),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF5E5954),
            ),
          ),
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Weather Fit Card
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildWeatherFitCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: const Color(0xFFEAE3D9),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weather Fit',
            style: TextStyle(
              fontSize: 16.5.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Icon(Icons.thumb_up_alt_outlined, size: 14.sp, color: const Color(0xFFB5956A)),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  'Excellent choice for today\'s warm and sunny weather.',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFB5956A),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),

          // 2x2 Metric Boxes Grid
          Row(
            children: [
              Expanded(
                child: _buildMetricBox(
                  icon: Icons.thermostat_rounded,
                  label: 'Ideal Temperature',
                  val: '22° - 34°C',
                  valColor: const Color(0xFFE5A638),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _buildMetricBox(
                  icon: Icons.wb_sunny_outlined,
                  label: 'Best Seasons',
                  val: 'Spring & Summer',
                  valColor: const Color(0xFFE5A638),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: _buildMetricBox(
                  icon: Icons.sentiment_very_satisfied_rounded,
                  label: 'Breathability',
                  val: 'Excellent',
                  valColor: const Color(0xFF4CAF50),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _buildMetricBox(
                  icon: Icons.sentiment_satisfied_alt_rounded,
                  label: 'Comfort Level',
                  val: 'Very Comfortable',
                  valColor: const Color(0xFFE5A638),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricBox({
    required IconData icon,
    required String label,
    required String val,
    required Color valColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 10.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F5F0),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: const Color(0xFFC8A97E).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18.sp, color: const Color(0xFFC8A97E)),
          ),
          SizedBox(height: 6.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF8E8883),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            val,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: valColor,
            ),
          ),
        ],
      ),
    );
  }
}
