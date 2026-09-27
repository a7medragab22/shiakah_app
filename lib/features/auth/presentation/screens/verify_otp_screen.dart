import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/bloc/paginated_bloc/exports.dart';
import '../../../../core/enum/status.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/router/router.dart';
import '../../../../core/service_locator/service_locator.dart';
import '../../../../core/theme/theme.dart';
import '../../auth.dart';
import '../widgets/auth_buttons.dart';
import '../widgets/auth_form_card.dart';
import '../widgets/auth_header.dart';

class VerifyOtpScreen extends StatelessWidget {
  final String? email;
  const VerifyOtpScreen({super.key, this.email});

  @override
  Widget build(BuildContext context) {
    DI.executeSync();
    return BlocProvider<VerifyOTPBloc>(
      create: (_) => getIt<VerifyOTPBloc>(),
      child: _VerifyOtpScreenContent(email: email),
    );
  }
}

class _VerifyOtpScreenContent extends StatefulWidget {
  final String? email;
  const _VerifyOtpScreenContent({this.email});

  @override
  State<_VerifyOtpScreenContent> createState() => _VerifyOtpScreenContentState();
}

class _VerifyOtpScreenContentState extends State<_VerifyOtpScreenContent> {
  static const int _otpLength = 6;

  final List<TextEditingController> _controllers =
      List.generate(_otpLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(_otpLength, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onDigitChanged(String value, int index) {
    if (value.isNotEmpty) {
      if (index < _otpLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        // Auto-submit when all 6 digits are filled
        final fullOtp = _controllers.map((c) => c.text.trim()).join();
        if (fullOtp.length == _otpLength) {
          _submitOtp(context);
        }
      }
    }
  }

  void _submitOtp(BuildContext context) {
    FocusScope.of(context).unfocus();
    final otp = _controllers.map((c) => c.text.trim()).join();
    if (otp.length < _otpLength) {
      context.showErrorMessage('يرجى إدخال كود التحقق المكون من 6 أرقام');
      return;
    }

    final email = widget.email?.trim() ?? '';
    if (email.isEmpty) {
      context.showErrorMessage('البريد الإلكتروني غير متوفر، يرجى إعادة المحاولة من صفحة التسجيل');
      return;
    }

    context.read<VerifyOTPBloc>().add(
          VerifyOtpSubmitted(
            email: email,
            otp: otp,
          ),
        );
  }

  void _resendOtp(BuildContext context) {
    final email = widget.email?.trim() ?? '';
    if (email.isEmpty) {
      context.showErrorMessage('البريد الإلكتروني غير متوفر');
      return;
    }
    context.read<VerifyOTPBloc>().add(ResendOtpSubmitted(email: email));
    context.showSuccessMessage('تم إرسال كود تحقق جديد');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFE5D8),
      body: BlocConsumer<VerifyOTPBloc, BaseState<VerifyOtpResponseModel>>(
        listener: (context, state) {
          if (state.status == Status.success) {
            final message = state.data?.message ?? 'تم تأكيد الحساب بنجاح';
            context.showSuccessMessage(message);
            context.go(Routes.styleSetup);
          } else if (state.status == Status.failure) {
            final error = state.errorMessage ?? 'فشل التحقق من الكود';
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
                fallbackRoute: Routes.register,
                height: 230.h,
              ),

              // ── White form card ──────────────────────────────────────────
              AuthFormCard(
                child: Column(
                  children: [
                    // Logo + title + subtitle
                    AuthLogoSection(
                      title: 'verify_your_number'.tr(),
                      subtitle: widget.email != null && widget.email!.isNotEmpty
                          ? '${'verify_subtitle'.tr()}\n(${widget.email})'
                          : 'verify_subtitle'.tr(),
                    ),

                    SizedBox(height: 24.h),

                    // OTP digit boxes
                    _OtpRow(
                      length: _otpLength,
                      controllers: _controllers,
                      focusNodes: _focusNodes,
                      onChanged: _onDigitChanged,
                    ),

                    SizedBox(height: 14.h),

                    // Resend link
                    AuthFooterLink(
                      prefixText: 'didnt_receive_code'.tr(),
                      linkText: 'resend_code'.tr(),
                      onTap: isLoading ? () {} : () => _resendOtp(context),
                    ),

                    const Spacer(),
                    SizedBox(height: 16.h),

                    // Continue button
                    AuthPrimaryButton(
                      label: 'continue_btn'.tr(),
                      isLoading: isLoading,
                      onPressed: isLoading ? null : () => _submitOtp(context),
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

class _OtpRow extends StatelessWidget {
  const _OtpRow({
    required this.length,
    required this.controllers,
    required this.focusNodes,
    required this.onChanged,
  });

  final int length;
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final void Function(String value, int index) onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        length,
        (i) => _OtpBox(
          controller: controllers[i],
          focusNode: focusNodes[i],
          previousFocusNode: i > 0 ? focusNodes[i - 1] : null,
          onChanged: (val) => onChanged(val, i),
        ),
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.controller,
    required this.focusNode,
    this.previousFocusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode? previousFocusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46.w,
      height: 52.h,
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace &&
              controller.text.isEmpty) {
            previousFocusNode?.requestFocus();
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: const Color(0xFFE2D6C6),
              width: 1.3,
            ),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [
              LengthLimitingTextInputFormatter(1),
              FilteringTextInputFormatter.digitsOnly,
            ],
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}
