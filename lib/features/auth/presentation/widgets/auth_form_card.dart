import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/theme.dart';

/// White rounded-top card that wraps all auth forms.
class AuthFormCard extends StatelessWidget {
  const AuthFormCard({
    super.key,
    required this.child,
    this.horizontalPadding,
    this.verticalPadding,
  });

  final Widget child;
  final double? horizontalPadding;
  final double? verticalPadding;

  @override
  Widget build(BuildContext context) {
    final double hPad = horizontalPadding ?? 24.w;
    final double vPad = verticalPadding ?? 20.h;

    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28.r),
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: hPad,
                vertical: vPad,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - (vPad * 2),
                ),
                child: IntrinsicHeight(
                  child: child,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Logo + title + subtitle section (reused in all 3 auth screens)
// ─────────────────────────────────────────────────────────────────────────────

class AuthLogoSection extends StatelessWidget {
  const AuthLogoSection({
    super.key,
    required this.title,
    required this.subtitle,
    this.logoHeight,
  });

  final String title;
  final String subtitle;
  final double? logoHeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'assets/images/logo.png',
          height: logoHeight ?? 72.h,
          fit: BoxFit.contain,
        ),
        SizedBox(height: 12.h),
        Text(
          title,
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Text(
            subtitle,
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
    );
  }
}
