import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/router.dart';
import '../widgets/auth_buttons.dart';
import '../widgets/auth_form_card.dart';
import '../widgets/auth_header.dart';
import '../widgets/custom_auth_input_field.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
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
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Header: avatar image + back button ──────────────────────
            AuthHeader(
              type: AuthHeaderType.plain,
              imagePath: 'assets/images/rectangle_209.png',
              fallbackRoute: Routes.welcome,
              height: 200.h,
            ),

            // ── White form card ──────────────────────────────────────────
            AuthFormCard(
              child: Column(
                children: [
                  // Logo + title + subtitle
                  AuthLogoSection(
                    title: 'welcome_back'.tr(),
                    subtitle: 'sign_in_subtitle'.tr(),
                  ),

                  SizedBox(height: 20.h),

                  // Gmail Input Field
                  CustomAuthInputField(
                    controller: _gmailController,
                    label: 'gmail'.tr(),
                    hintText: 'gmail_hint'.tr(),
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.mail_outline_rounded,
                  ),

                  SizedBox(height: 14.h),

                  // Password Input Field with Eye Toggle Suffix Icon
                  CustomAuthInputField(
                    controller: _passwordController,
                    label: 'password'.tr(),
                    hintText: 'password_hint'.tr(),
                    isPassword: true,
                    prefixIcon: Icons.lock_outline_rounded,
                  ),

                  const Spacer(),

                  // Continue button → Go straight to HOME (Routes.home)
                  AuthPrimaryButton(
                    label: 'continue_btn'.tr(),
                    onPressed: () => context.go(Routes.home),
                  ),

                  SizedBox(height: 16.h),

                  // Footer link
                  AuthFooterLink(
                    prefixText: 'new_to_shiakah'.tr(),
                    linkText: 'create_an_account'.tr(),
                    onTap: () => context.go(Routes.register),
                  ),

                  SizedBox(height: 8.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
