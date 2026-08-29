import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/router/router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  late final AnimationController _shineController;
  late final Animation<double> _shineAnimation;

  @override
  void initState() {
    super.initState();

    // Logo animations: smooth scaling and fading in
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.85, curve: Curves.easeOutBack),
      ),
    );

    // Shine animation: slowly shifts the metallic gradient to create a luxury shimmer reflection
    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    _shineAnimation = Tween<double>(begin: -1.8, end: 1.8).animate(
      CurvedAnimation(
        parent: _shineController,
        curve: Curves.easeInOutSine,
      ),
    );

    // Start logo animation
    _logoController.forward();

    // Navigate to home page after animation finishes (approx 3.2s)
    Timer(const Duration(milliseconds: 3200), () {
      if (mounted) {
        context.go(Routes.home);
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _shineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _shineAnimation,
        builder: (context, child) {
          final offset = _shineAnimation.value;
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(offset - 0.6, -1.0),
                end: Alignment(offset + 0.6, 1.0),
                colors: const [
                  Color(0xFF6F6A65), // Secondary (Grayish Gold)
                  AppColors.primary, // Primary (Gold)
                  Color(
                      0xFFFAF7F2), // Dynamic metallic shine reflection (white/cream)
                  AppColors.hover, // Hover/Secondary light gold
                  AppColors.primary, // Primary (Gold)
                  Color(0xFF6F6A65), // Secondary (Grayish Gold)
                ],
                stops: const [0.0, 0.25, 0.45, 0.65, 0.85, 1.0],
              ),
            ),
            child: child,
          );
        },
        child: Center(
          child: AnimatedBuilder(
            animation: _logoController,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Hero(
                    tag: 'app_logo',
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 450.w,
                      height: 450.h,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
