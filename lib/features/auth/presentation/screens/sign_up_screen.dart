import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/bloc/paginated_bloc/exports.dart';
import '../../../../core/enum/status.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/router/router.dart';
import '../../../../core/service_locator/service_locator.dart';
import '../../auth.dart';
import '../widgets/auth_buttons.dart';
import '../widgets/auth_form_card.dart';
import '../widgets/auth_header.dart';
import '../widgets/custom_auth_input_field.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    DI.executeSync();
    return BlocProvider<RegisterBloc>(
      create: (_) => getIt<RegisterBloc>(),
      child: const _SignUpScreenContent(),
    );
  }
}

class _SignUpScreenContent extends StatefulWidget {
  const _SignUpScreenContent();

  @override
  State<_SignUpScreenContent> createState() => _SignUpScreenContentState();
}

class _SignUpScreenContentState extends State<_SignUpScreenContent> {
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

    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasDigits = password.contains(RegExp(r'[0-9]'));
    final hasSpecialChar = password.contains(RegExp(r'[_!@#$%^&*(),.?":{}|<>\-]'));

    if (password.isEmpty) {
      passErr = 'password_required'.tr();
    } else if (password.length < 6) {
      passErr = 'password_min_length'.tr();
    } else if (!hasUppercase) {
      passErr = 'password_needs_uppercase'.tr();
    } else if (!hasDigits) {
      passErr = 'password_needs_number'.tr();
    } else if (!hasSpecialChar) {
      passErr = 'password_needs_special'.tr();
    }

    setState(() {
      _emailError = emailErr;
      _passwordError = passErr;
    });

    return emailErr == null && passErr == null;
  }

  void _submitRegister(BuildContext context) {
    FocusScope.of(context).unfocus();
    if (_validateInputs()) {
      final email = _gmailController.text.trim();
      final password = _passwordController.text;
      context.read<RegisterBloc>().add(
            RegisterSubmitted(
              email: email,
              password: password,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFE5D8),
      body: BlocConsumer<RegisterBloc, BaseState<RegisterResponseModel>>(
        listener: (context, state) {
          if (state.status == Status.success) {
            final email = _gmailController.text.trim();
            final message = state.data?.message ?? 'تم إرسال كود التحقق بنجاح';
            context.showSuccessMessage(message);
            context.go(Routes.verifyOtp, extra: email);
          } else if (state.status == Status.failure) {
            final error = state.errorMessage ?? 'فشل إنشاء الحساب';
            context.showErrorMessage(error);
          }
        },
        builder: (context, state) {
          final isLoading = state.status == Status.loading;

          return Column(
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

                    // Gmail Input Field
                    CustomAuthInputField(
                      controller: _gmailController,
                      label: 'gmail'.tr(),
                      hintText: 'gmail_hint'.tr(),
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.mail_outline_rounded,
                      errorText: _emailError,
                      onChanged: (_) {
                        if (_emailError != null) {
                          _validateInputs();
                        }
                      },
                    ),

                    SizedBox(height: 14.h),

                    // Password Input Field
                    CustomAuthInputField(
                      controller: _passwordController,
                      label: 'password'.tr(),
                      hintText: 'password_hint'.tr(),
                      isPassword: true,
                      prefixIcon: Icons.lock_outline_rounded,
                      errorText: _passwordError,
                      helperText: 'password_requirements_hint'.tr(),
                      onChanged: (_) {
                        if (_passwordError != null) {
                          _validateInputs();
                        }
                      },
                    ),

                    const Spacer(),

                    // Continue button → Verify OTP via RegisterBloc
                    AuthPrimaryButton(
                      label: 'continue_btn'.tr(),
                      isLoading: isLoading,
                      onPressed: isLoading ? null : () => _submitRegister(context),
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
          );
        },
      ),
    );
  }
}
