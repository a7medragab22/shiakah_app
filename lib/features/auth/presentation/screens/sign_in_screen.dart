import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/bloc/paginated_bloc/exports.dart';
import '../../../../core/enum/status.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/service_locator/service_locator.dart';
import '../../../../core/router/router.dart';
import '../../auth.dart';
import '../widgets/auth_buttons.dart';
import '../widgets/auth_form_card.dart';
import '../widgets/auth_header.dart';
import '../widgets/custom_auth_input_field.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    DI.executeSync();
    return BlocProvider<LoginBloc>(
      create: (_) => getIt<LoginBloc>(),
      child: const _SignInScreenContent(),
    );
  }
}

class _SignInScreenContent extends StatefulWidget {
  const _SignInScreenContent();

  @override
  State<_SignInScreenContent> createState() => _SignInScreenContentState();
}

class _SignInScreenContentState extends State<_SignInScreenContent> {
  final TextEditingController _gmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _gmailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validateInputs() {
    final email = _gmailController.text.trim();
    final password = _passwordController.text;

    String? emailErr;
    String? passErr;

    if (email.isEmpty) {
      emailErr = 'يرجى إدخال البريد الإلكتروني';
    } else if (!email.contains('@') || !email.contains('.')) {
      emailErr = 'يرجى إدخال بريد إلكتروني صحيح';
    }

    if (password.isEmpty) {
      passErr = 'يرجى إدخال كلمة المرور';
    } else if (password.length < 6) {
      passErr = 'كلمة المرور يجب أن لا تقل عن 6 أحرف';
    }

    setState(() {
      _emailError = emailErr;
      _passwordError = passErr;
    });

    return emailErr == null && passErr == null;
  }

  void _submitLogin(BuildContext context) {
    FocusScope.of(context).unfocus();
    if (_validateInputs()) {
      context.read<LoginBloc>().add(
            LoginSubmitted(
              email: _gmailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFE5D8),
      body: SafeArea(
        bottom: false,
        child: BlocConsumer<LoginBloc, BaseState<LoginResponseModel>>(
          listener: (context, state) {
            if (state.status == Status.success) {
              final message = state.data?.message ?? 'تم تسجيل الدخول بنجاح';
              context.showSuccessMessage(message);
              context.go(Routes.home);
            } else if (state.status == Status.failure) {
              final error = state.errorMessage ?? 'فشل تسجيل الدخول';
              context.showErrorMessage(error);
            }
          },
          builder: (context, state) {
            final isLoading = state.status == Status.loading;

            return Column(
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
                        errorText: _emailError,
                      ),

                      SizedBox(height: 14.h),

                      // Password Input Field with Eye Toggle Suffix Icon
                      CustomAuthInputField(
                        controller: _passwordController,
                        label: 'password'.tr(),
                        hintText: 'password_hint'.tr(),
                        isPassword: true,
                        prefixIcon: Icons.lock_outline_rounded,
                        errorText: _passwordError,
                      ),

                      const Spacer(),

                      // Continue button → Authenticate via LoginBloc
                      AuthPrimaryButton(
                        label: 'continue_btn'.tr(),
                        isLoading: isLoading,
                        onPressed: isLoading ? null : () => _submitLogin(context),
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
            );
          },
        ),
      ),
    );
  }
}
