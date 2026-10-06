import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/bloc/paginated_bloc/exports.dart';
import '../../../../core/enum/status.dart';
import '../../../../core/router/router.dart';
import '../../../../core/service_locator/service_locator.dart';
import '../../../../core/theme/theme.dart';
import '../../auth.dart';
import '../widgets/auth_buttons.dart';
import '../widgets/auth_form_card.dart';
import '../widgets/auth_header.dart';
import '../widgets/step_progress_indicator.dart';

class GenderSelectionScreen extends StatefulWidget {
  const GenderSelectionScreen({super.key});

  @override
  State<GenderSelectionScreen> createState() => _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends State<GenderSelectionScreen> {
  String? _selected;

  @override
  void initState() {
    super.initState();
    DI.executeSync();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GenderBloc>(
      create: (_) => getIt<GenderBloc>(),
      child: BlocConsumer<GenderBloc, BaseState<GenderResponseModel>>(
        listener: (context, state) {
          if (state.status == Status.success) {
            context.go(Routes.personalInfo);
          } else if (state.status == Status.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.errorMessage ?? 'Something went wrong',
                ),
                backgroundColor: Colors.red.shade700,
              ),
            );
          }
        },
        builder: (context, state) {
          final bool isLoading = state.status == Status.loading;

          return Scaffold(
            backgroundColor: const Color(0xFFEFE5D8),
            body: Column(
              children: [
                // ── Header with progress indicator ──────────────────────────
                AuthHeader(
                  type: AuthHeaderType.image,
                  imagePath: 'assets/images/cloths.jpg',
                  title: 'create_account_title'.tr(),
                  fallbackRoute: Routes.styleSetup,
                  height: 140.h,
                  stepIndicator: const StepProgressIndicator(currentStep: 1),
                ),

                // ── White form card ──────────────────────────────────────────
                AuthFormCard(
                  child: Column(
                    children: [
                      // Logo
                      Image.asset(
                        'assets/images/logo.png',
                        height: 58.h,
                        fit: BoxFit.contain,
                      ),

                      SizedBox(height: 12.h),

                      // Title
                      Text(
                        'who_styling_today'.tr(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      SizedBox(height: 8.h),

                      // Subtitle
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: Text(
                          'gender_selection_subtitle'.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF8E8883),
                            height: 1.4,
                          ),
                        ),
                      ),

                      SizedBox(height: 22.h),

                      // Gender cards
                      Row(
                        children: [
                          Expanded(
                            child: _GenderCard(
                              label: 'men'.tr(),
                              imagePath: 'assets/images/man.png',
                              isSelected: _selected == 'men',
                              onTap: isLoading
                                  ? () {}
                                  : () => setState(() => _selected = 'men'),
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: _GenderCard(
                              label: 'women'.tr(),
                              imagePath: 'assets/images/women.jpg',
                              isSelected: _selected == 'women',
                              onTap: isLoading
                                  ? () {}
                                  : () => setState(() => _selected = 'women'),
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),
                      SizedBox(height: 16.h),

                      // Continue — calls gender endpoint
                      AuthPrimaryButton(
                        label: 'continue_btn'.tr(),
                        isEnabled: _selected != null && !isLoading,
                        isLoading: isLoading,
                        onPressed: _selected == null || isLoading
                            ? null
                            : () {
                                final int genderId = _selected == 'men' ? 1 : 2;
                                context.read<GenderBloc>().add(
                                      GenderSubmitted(gender: genderId),
                                    );
                              },
                      ),

                      SizedBox(height: 8.h),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _GenderCard extends StatelessWidget {
  const _GenderCard({
    required this.label,
    required this.imagePath,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String imagePath;
  final bool isSelected;
  final VoidCallback onTap;

  static const Color _borderSelected = Color(0xFFB5956A);
  static const Color _borderIdle = Color(0xFFE2D6C6);
  static const Color _bgSelected = Color(0xFFFDF8F2);
  static const Color _bgIdle = Colors.white;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? _bgSelected : _bgIdle,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? _borderSelected : _borderIdle,
            width: isSelected ? 2.0 : 1.3,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFB5956A).withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 8.w),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.asset(
                imagePath,
                height: 120.h,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: isSelected ? _borderSelected : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
