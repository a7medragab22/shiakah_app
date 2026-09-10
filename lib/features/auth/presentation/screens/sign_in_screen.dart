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
            // AuthFormCard already handles scrolling via LayoutBuilder + SingleChildScrollView
            // + IntrinsicHeight, allowing Spacer() to expand properly without exception!
            AuthFormCard(
              child: Column(
                children: [
                  // Logo + title + subtitle
                  AuthLogoSection(
                    title: 'Welcome Back',
                    subtitle:
                        'Sign in to continue your personalized styling experience.',
                  ),

                  SizedBox(height: 20.h),

                  // Gmail Input Field
                  CustomAuthInputField(
                    controller: _gmailController,
                    label: 'Gmail',
                    hintText: 'example@gmail.com',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.mail_outline_rounded,
                  ),

                  SizedBox(height: 14.h),

                  // Password Input Field with Eye Toggle Suffix Icon
                  CustomAuthInputField(
                    controller: _passwordController,
                    label: 'Password',
                    hintText: '••••••••',
                    isPassword: true,
                    prefixIcon: Icons.lock_outline_rounded,
                  ),

                  // Spacer works perfectly inside AuthFormCard!
                  const Spacer(),

                  // Continue button → Go straight to HOME (Routes.home)
                  AuthPrimaryButton(
                    label: 'Continue',
                    onPressed: () => context.go(Routes.home),
                  ),

                  SizedBox(height: 16.h),

                  // Footer link
                  AuthFooterLink(
                    prefixText: 'New to SHIAKAH? ',
                    linkText: 'Create an account',
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
