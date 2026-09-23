import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shiakah/features/auth/presentation/widgets/custom_auth_input_field.dart';

import '../../../../core/router/router.dart';
import '../widgets/auth_buttons.dart';
import '../widgets/auth_form_card.dart';
import '../widgets/auth_header.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _gmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _gmailController.dispose();
    _passwordController.dispose();
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
            title: 'create_account_title'.tr(),
            fallbackRoute: Routes.welcome,
            height: 230.h,
          ),

          // ── White form card ──────────────────────────────────────────
          AuthFormCard(
            child: Column(
              children: [
                // Logo + title + subtitle
                AuthLogoSection(
                  title: 'create_your_account'.tr(),
                  subtitle: 'sign_up_subtitle'.tr(),
                ),

                SizedBox(height: 24.h),

                // Phone input
                CustomAuthInputField(
                  controller: _gmailController,
                  label: 'gmail'.tr(),
                  hintText: 'gmail_hint'.tr(),
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.mail_outline_rounded,
                ),
                SizedBox(height: 14.h),
                CustomAuthInputField(
                  controller: _passwordController,
                  label: 'password'.tr(),
                  hintText: 'password_hint'.tr(),
                  isPassword: true,
                  prefixIcon: Icons.lock_outline_rounded,
                ),
                const Spacer(),
                // Continue button → Verify OTP
                AuthPrimaryButton(
                  label: 'continue_btn'.tr(),
                  onPressed: () => context.go(Routes.verifyOtp),
                ),

                SizedBox(height: 16.h),

                // Footer link
                AuthFooterLink(
                  prefixText: 'already_have_an_account'.tr(),
                  linkText: 'sign_in'.tr(),
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
