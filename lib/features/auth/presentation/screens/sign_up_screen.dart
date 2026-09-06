import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/router.dart';
import '../widgets/auth_buttons.dart';
import '../widgets/auth_form_card.dart';
import '../widgets/auth_header.dart';
import '../widgets/phone_input_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
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
      body: Column(
        children: [
          // ── Header: clothes image + back button + title ──────────────
          AuthHeader(
            type: AuthHeaderType.image,
            imagePath: 'assets/images/cloths.jpg',
            title: 'Create Account',
            fallbackRoute: Routes.welcome,
            height: 230.h,
          ),

          // ── White form card ──────────────────────────────────────────
          AuthFormCard(
            child: Column(
              children: [
                // Logo + title + subtitle
                AuthLogoSection(
                  title: 'Create Your Account',
                  subtitle:
                      'Enter your phone number to receive a verification code '
                      'and start your AI fashion journey.',
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

                const Spacer(),
                SizedBox(height: 16.h),

                // Continue button → Verify OTP
                AuthPrimaryButton(
                  label: 'Continue',
                  onPressed: () => context.go(Routes.verifyOtp),
                ),

                SizedBox(height: 16.h),

                // Footer link
                AuthFooterLink(
                  prefixText: 'Already have an account? ',
                  linkText: 'Sign In',
                  onTap: () => context.go(Routes.login),
                ),

                SizedBox(height: 8.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
