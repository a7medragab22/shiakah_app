import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/router.dart';
import '../widgets/auth_buttons.dart';
import '../widgets/auth_form_card.dart';
import '../widgets/auth_header.dart';
import '../widgets/phone_input_field.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFE5D8),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Header: avatar image + back button ──────────────────────
            AuthHeader(
              type: AuthHeaderType.plain,
              imagePath: 'assets/images/rectangle_209.png',
              fallbackRoute: Routes.welcome,
              height: 230.h,
            ),

            // ── White form card ──────────────────────────────────────────
            AuthFormCard(
              child: Column(
                children: [
                  // Logo + title + subtitle
                  AuthLogoSection(
                    title: 'Welcome Back',
                    subtitle:
                        'Sign in to continue your personalized styling experience.',
                  ),

                  SizedBox(height: 24.h),

                  // Phone input
                  PhoneInputField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    hintText: '1234 567 890',
                    helperText:
                        "We'll verify your number before creating your account.",
                  ),

                  SizedBox(height: 36.h),

                  // Continue button
                  AuthPrimaryButton(
                    label: 'Continue',
                    onPressed: () => context.go(Routes.verifyOtp),
                  ),

                  SizedBox(height: 16.h),

                  // Footer link
                  AuthFooterLink(
                    prefixText: 'New to SHIAKAH? ',
                    linkText: 'Create an account',
                    onTap: () => context.go(Routes.register),
                  ),

                  SizedBox(height: 12.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
