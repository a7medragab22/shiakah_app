import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/theme.dart';

/// Reusable top header for auth screens.
///
/// Supports two variants:
/// - [AuthHeaderType.image] — full-bleed image with gradient, back button, and
///   an optional centered title overlaid on top.
/// - [AuthHeaderType.plain] — plain background colour with a back button and
///   optional centred title, used on the Sign In screen.
enum AuthHeaderType { image, plain }

class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    this.type = AuthHeaderType.image,
    required this.imagePath,
    this.title,
    this.fallbackRoute,
    this.height,
    this.backgroundColor,
  });

  final AuthHeaderType type;

  /// Asset path for the background image (used when [type] == image).
  final String imagePath;

  /// Optional text shown centred in the header bar (white, bold).
  final String? title;

  /// Route to push when back is tapped and [BuildContext.canPop] is false.
  final String? fallbackRoute;

  final double? height;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final double h = height ?? 230.h;

    return SizedBox(
      height: h,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ─── Background ───────────────────────────────────────────────
          if (type == AuthHeaderType.image)
            Image.asset(imagePath, fit: BoxFit.cover)
          else
            ColoredBox(
              color: backgroundColor ?? const Color(0xFFEFE5D8),
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
                alignment: Alignment.bottomCenter,
              ),
            ),

          // ─── Gradient overlay (image only) ────────────────────────────
          if (type == AuthHeaderType.image)
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.42),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

          // ─── Top bar (back + optional title) ─────────────────────────
          SafeArea(
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Back button
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: _BackButton(fallbackRoute: fallbackRoute),
                  ),

                  // Optional centred title
                  if (title != null)
                    Text(
                      title!,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: type == AuthHeaderType.image
                            ? Colors.white
                            : AppColors.textPrimary,
                        shadows: type == AuthHeaderType.image
                            ? [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.4),
                                  blurRadius: 4,
                                ),
                              ]
                            : null,
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
}

// ─────────────────────────────────────────────────────────────────────────────
// Private: circular white back button
// ─────────────────────────────────────────────────────────────────────────────

class _BackButton extends StatelessWidget {
  const _BackButton({this.fallbackRoute});
  final String? fallbackRoute;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (context.canPop()) {
          context.pop();
        } else if (fallbackRoute != null) {
          context.go(fallbackRoute!);
        }
      },
      child: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 16.sp,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
