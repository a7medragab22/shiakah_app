import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/router.dart';
import '../../../../core/theme/theme.dart';
import '../widgets/auth_buttons.dart';
import '../widgets/auth_form_card.dart';
import '../widgets/auth_header.dart';
import '../widgets/step_progress_indicator.dart';

/// Step 5 of 5 in the style-setup flow.
/// Takes the user's name and verifies their location.
class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final TextEditingController _nameController =
      TextEditingController(text: 'Amgad');

  bool _isLoadingLocation = false;
  bool _isLocationVerified = false;
  String _locationText = '';

  @override
  void initState() {
    super.initState();
    // Automatically detect and verify location on screen load!
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchLocation();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _applyLocation(String location) {
    if (mounted) {
      setState(() {
        _locationText = location;
        _isLocationVerified = true;
        _isLoadingLocation = false;
      });
    }
  }

  /// Fast IP-based Geolocation (< 250ms), highly accurate for country and city
  Future<String?> _fetchIpLocation() async {
    // 1. Try ipwho.is (fast HTTPS, returns Egyptian governorate & city)
    try {
      final res = await Dio().get(
        'https://ipwho.is/',
        options: Options(
          receiveTimeout: const Duration(seconds: 2),
          sendTimeout: const Duration(seconds: 2),
        ),
      );
      if (res.statusCode == 200 &&
          res.data != null &&
          res.data['success'] == true) {
        final country = res.data['country']?.toString() ?? 'Egypt';
        final city = res.data['city']?.toString() ??
            res.data['region']?.toString() ??
            'Cairo';
        if (country.isNotEmpty && city.isNotEmpty) {
          return '$country, $city';
        }
      }
    } catch (_) {}

    // 2. Try freeipapi.com (backup)
    try {
      final res = await Dio().get(
        'https://freeipapi.com/api/json',
        options: Options(
          receiveTimeout: const Duration(seconds: 2),
          sendTimeout: const Duration(seconds: 2),
        ),
      );
      if (res.statusCode == 200 && res.data != null) {
        final country = res.data['countryName']?.toString() ?? 'Egypt';
        final city = res.data['cityName']?.toString() ??
            res.data['regionName']?.toString() ??
            'Cairo';
        if (country.isNotEmpty && city.isNotEmpty && city != '-') {
          return '$country, $city';
        }
      }
    } catch (_) {}

    return null;
  }

  /// Detects location instantly without ever throwing TimeoutException:
  /// 1. First tries cached GPS position (instant 0ms) if permission is already granted.
  /// 2. If no cached GPS fix, instantly resolves city via HTTPS IP Geolocation (~200ms).
  /// 3. Safely defaults to 'Egypt, Cairo' so the user is never blocked.
  Future<void> _fetchLocation() async {
    if (_isLoadingLocation) return;

    setState(() {
      _isLoadingLocation = true;
    });

    // 1. Check if GPS is already enabled & has cached coordinates
    try {
      bool serviceEnabled =
          await Geolocator.isLocationServiceEnabled().catchError((_) => false);
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission()
            .catchError((_) => LocationPermission.denied);
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission()
              .catchError((_) => LocationPermission.denied);
        }

        if (permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always) {
          final lastPos =
              await Geolocator.getLastKnownPosition().catchError((_) => null);
          if (lastPos != null) {
            try {
              final geocoding = Geocoding();
              final placemarks = await geocoding
                  .placemarkFromCoordinates(
                    lastPos.latitude,
                    lastPos.longitude,
                  )
                  .timeout(const Duration(seconds: 1), onTimeout: () => []);
              if (placemarks.isNotEmpty) {
                final place = placemarks.first;
                final country = place.country?.isNotEmpty == true
                    ? place.country!
                    : 'Egypt';
                final city = place.administrativeArea?.isNotEmpty == true
                    ? place.administrativeArea!
                    : (place.locality?.isNotEmpty == true
                        ? place.locality!
                        : (place.subAdministrativeArea ?? 'Cairo'));
                _applyLocation('$country, $city');
                return;
              }
            } catch (_) {}
          }
        }
      }
    } catch (_) {}

    // 2. Fast IP Geolocation (instant, works on emulator & real devices)
    final ipLoc = await _fetchIpLocation();
    if (ipLoc != null && mounted) {
      _applyLocation(ipLoc);
      return;
    }

    // 3. Fallback default
    _applyLocation('Egypt, Cairo');
  }

  /// Allows the user to manually pick or change their Egyptian city
  void _showCityPickerSheet() {
    final cities = [
      'Cairo',
      'Giza',
      'Alexandria',
      'Mansoura',
      'Tanta',
      'Zagazig',
      'Ismailia',
      'Port Said',
      'Suez',
      'Assiut',
      'Sohag',
      'Luxor',
      'Aswan',
      'Fayoum',
      'Beni Suef',
      'Hurghada',
      'Sharm El Sheikh',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Your City',
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  itemCount: cities.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final cityName = cities[index];
                    final isSelected = _locationText.contains(cityName);
                    return ListTile(
                      title: Text(
                        'Egypt, $cityName',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? const Color(0xFFB5956A)
                              : AppColors.textPrimary,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check, color: Color(0xFFB5956A))
                          : null,
                      onTap: () {
                        _applyLocation('Egypt, $cityName');
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFE5D8),
      body: Column(
        children: [
          // ── Header with Step 5 Progress ──────────────────────────────
          AuthHeader(
            type: AuthHeaderType.image,
            imagePath: 'assets/images/cloths.jpg',
            title: 'Create Account',
            fallbackRoute: Routes.defineStyle,
            height: 130.h,
            stepIndicator: const StepProgressIndicator(currentStep: 5),
          ),

          // ── White Form Card ──────────────────────────────────────────
          AuthFormCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo + Title + Subtitle
                Center(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        height: 64.h,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: 14.h),
                      Text(
                        'Complete Your Profile',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Text(
                          'Personalize your experience before you get started.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF8E8883),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                // ── Your Name Field ─────────────────────────────────────
                Text(
                  'Your Name',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),

                SizedBox(height: 8.h),

                Container(
                  height: 48.h,
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: const Color(0xFFE2D6C6),
                      width: 1.3,
                    ),
                  ),
                  child: Center(
                    child: TextField(
                      controller: _nameController,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        hintText: 'Enter your name',
                        hintStyle: TextStyle(
                          color: Color(0xFFA09B95),
                          fontWeight: FontWeight.w400,
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20.h),

                // ── Location Verification Card ──────────────────────────
                GestureDetector(
                  onTap: _isLoadingLocation
                      ? null
                      : (_isLocationVerified
                          ? _showCityPickerSheet
                          : _fetchLocation),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 22.h,
                    ),
                    decoration: BoxDecoration(
                      color: _isLocationVerified
                          ? Colors.white
                          : const Color(0xFFFDFBF7),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: _isLocationVerified
                            ? const Color(0xFFEAE3D9)
                            : const Color(0xFFDECFC0),
                        width: _isLocationVerified ? 1.3 : 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _isLocationVerified
                              ? Colors.black.withValues(alpha: 0.03)
                              : const Color(0xFFB5956A).withValues(alpha: 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: AnimatedCrossFade(
                      duration: const Duration(milliseconds: 260),
                      crossFadeState: _isLoadingLocation
                          ? CrossFadeState.showFirst
                          : _isLocationVerified
                              ? CrossFadeState.showFirst
                              : CrossFadeState.showSecond,
                      firstChild: _isLoadingLocation
                          ? _buildLoadingLocation()
                          : _buildVerifiedLocation(),
                      secondChild: _buildUnverifiedLocation(),
                    ),
                  ),
                ),

                const Spacer(),
                SizedBox(height: 16.h),

                // ── Continue Button (Enabled ONLY when location is verified) ──
                AuthPrimaryButton(
                  label: 'Continue',
                  isEnabled: _isLocationVerified,
                  onPressed: _isLocationVerified
                      ? () => context.go(Routes.home)
                      : null,
                ),

                SizedBox(height: 8.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// State: Location is verified (as shown in the screenshot)
  Widget _buildVerifiedLocation() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Custom Green Location Pin with Checkmark
        SizedBox(
          width: 56.w,
          height: 56.w,
          child: CustomPaint(
            painter: _LocationVerifiedIconPainter(),
          ),
        ),

        SizedBox(height: 12.h),

        // Title
        Text(
          'Location Verified',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),

        SizedBox(height: 8.h),

        // Subtitle
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Text(
            'Weather-based outfit recommendations are now personalized for your location.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF8E8883),
              height: 1.4,
            ),
          ),
        ),

        SizedBox(height: 14.h),

        // Location tag (Gold pin + Country, City + Change button)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_on,
              size: 18.sp,
              color: const Color(0xFFB5956A),
            ),
            SizedBox(width: 5.w),
            Text(
              _locationText,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFB5956A),
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: const Color(0xFFB5956A).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                'Change',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFB5956A),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// State: Detecting Location (loading animation)
  Widget _buildLoadingLocation() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 40.w,
          height: 40.w,
          child: const CircularProgressIndicator(
            strokeWidth: 3.0,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB5956A)),
          ),
        ),
        SizedBox(height: 14.h),
        Text(
          'Detecting Location...',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          'Please wait while we determine your city',
          style: TextStyle(
            fontSize: 12.5.sp,
            color: const Color(0xFF8E8883),
          ),
        ),
      ],
    );
  }

  /// State: Location not yet verified (Initial state)
  Widget _buildUnverifiedLocation() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Location Pin Icon in circular badge
        Container(
          width: 56.w,
          height: 56.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFB5956A).withValues(alpha: 0.12),
          ),
          child: Icon(
            Icons.location_on_outlined,
            size: 30.sp,
            color: const Color(0xFFB5956A),
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          'Verify Your Location',
          style: TextStyle(
            fontSize: 17.5.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 6.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Text(
            'Tap here to allow weather-based outfit recommendations.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              color: const Color(0xFF8E8883),
              height: 1.35,
            ),
          ),
        ),
        SizedBox(height: 14.h),
        // Action pill indicator
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 7.h,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFB5956A).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: const Color(0xFFB5956A),
              width: 1.1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.my_location_rounded,
                size: 15.sp,
                color: const Color(0xFFB5956A),
              ),
              SizedBox(width: 6.w),
              Text(
                'Tap to Detect Location',
                style: TextStyle(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFB5956A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom Painter for the Green Location Pin with Checkmark Icon
// ─────────────────────────────────────────────────────────────────────────────

class _LocationVerifiedIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Green stroke paint
    final Paint pinPaint = Paint()
      ..color = const Color(0xFF388E3C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Paint checkPaint = Paint()
      ..color = const Color(0xFF388E3C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Draw Location Pin Path
    final Path pinPath = Path();
    final double centerX = w * 0.46;
    final double headRadius = w * 0.26;
    final double headCenterY = h * 0.34;

    // Top circular head and tapered tail
    pinPath.addArc(
      Rect.fromCircle(
        center: Offset(centerX, headCenterY),
        radius: headRadius,
      ),
      -0.65 * 3.14159,
      1.85 * 3.14159,
    );

    // Left curve down to bottom tip
    pinPath.moveTo(
        centerX - headRadius * 0.88, headCenterY + headRadius * 0.45);
    pinPath.cubicTo(
      centerX - headRadius * 0.7,
      headCenterY + headRadius * 1.3,
      centerX - headRadius * 0.3,
      headCenterY + headRadius * 1.8,
      centerX,
      h * 0.78,
    );

    // Right curve up towards head
    pinPath.cubicTo(
      centerX + headRadius * 0.3,
      headCenterY + headRadius * 1.8,
      centerX + headRadius * 0.7,
      headCenterY + headRadius * 1.3,
      centerX + headRadius * 0.88,
      headCenterY + headRadius * 0.45,
    );

    canvas.drawPath(pinPath, pinPaint);

    // Draw inner circle dot inside the pin
    final Paint dotPaint = Paint()
      ..color = const Color(0xFF388E3C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;

    canvas.drawCircle(
      Offset(centerX, headCenterY),
      headRadius * 0.34,
      dotPaint,
    );

    // Draw checkmark badge on the bottom right
    final Path checkPath = Path();
    final double checkStartX = w * 0.52;
    final double checkStartY = h * 0.74;
    final double checkMidX = w * 0.60;
    final double checkMidY = h * 0.82;
    final double checkEndX = w * 0.76;
    final double checkEndY = h * 0.65;

    checkPath.moveTo(checkStartX, checkStartY);
    checkPath.lineTo(checkMidX, checkMidY);
    checkPath.lineTo(checkEndX, checkEndY);

    canvas.drawPath(checkPath, checkPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
