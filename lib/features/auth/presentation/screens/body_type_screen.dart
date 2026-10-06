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

class _BodyTypeItem {
  final String id;
  final String titleKey;
  final String subtitleKey;
  final String imagePath;

  const _BodyTypeItem({
    required this.id,
    required this.titleKey,
    required this.subtitleKey,
    required this.imagePath,
  });
}

class BodyTypeScreen extends StatefulWidget {
  const BodyTypeScreen({super.key});

  @override
  State<BodyTypeScreen> createState() => _BodyTypeScreenState();
}

class _BodyTypeScreenState extends State<BodyTypeScreen> {
  final TextEditingController _heightController =
      TextEditingController(text: '183');
  final TextEditingController _weightController =
      TextEditingController(text: '76');

  String _selectedBodyType = 'slim';

  static const List<_BodyTypeItem> _topRowItems = [
    _BodyTypeItem(
      id: 'slim',
      titleKey: 'slim',
      subtitleKey: 'lean_physique',
      imagePath: 'assets/images/body_type/slim.png',
    ),
    _BodyTypeItem(
      id: 'regular',
      titleKey: 'regular',
      subtitleKey: 'balanced_physique',
      imagePath: 'assets/images/body_type/regular.png',
    ),
    _BodyTypeItem(
      id: 'athletic',
      titleKey: 'athletic',
      subtitleKey: 'athletic_build',
      imagePath: 'assets/images/body_type/athletic.png',
    ),
  ];

  static const List<_BodyTypeItem> _bottomRowItems = [
    _BodyTypeItem(
      id: 'stocky',
      titleKey: 'stocky',
      subtitleKey: 'broad_build',
      imagePath: 'assets/images/body_type/stocky.png',
    ),
    _BodyTypeItem(
      id: 'plus_size',
      titleKey: 'plus_size',
      subtitleKey: 'fuller_build',
      imagePath: 'assets/images/body_type/plus_size.png',
    ),
  ];

  @override
  void initState() {
    super.initState();
    DI.executeSync();
    _heightController.addListener(_onTextChanged);
    _weightController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _heightController.removeListener(_onTextChanged);
    _weightController.removeListener(_onTextChanged);
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BodyBloc>(
      create: (_) => getIt<BodyBloc>(),
      child: BlocConsumer<BodyBloc, BaseState<BodyResponseModel>>(
        listener: (context, state) {
          if (state.status == Status.success) {
            context.go(Routes.defineStyle);
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
          final String heightText = _heightController.text.trim();
          final String weightText = _weightController.text.trim();
          final bool isEnabled =
              heightText.isNotEmpty && weightText.isNotEmpty && !isLoading;

          return Scaffold(
            backgroundColor: const Color(0xFFEFE5D8),
            body: Column(
              children: [
                // ── Header with Step 3 Progress ──────────────────────────────
                AuthHeader(
                  type: AuthHeaderType.image,
                  imagePath: 'assets/images/cloths.jpg',
                  title: 'create_account_title'.tr(),
                  fallbackRoute: Routes.personalInfo,
                  height: 140.h,
                  stepIndicator: const StepProgressIndicator(currentStep: 3),
                ),

                // ── White Form Card ──────────────────────────────────────────
                AuthFormCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo + Title + Subtitle
                      Center(
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/images/logo.png',
                              height: 58.h,
                              fit: BoxFit.contain,
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              'tell_us_about_body'.tr(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.w),
                              child: Text(
                                'body_type_subtitle'.tr(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13.5.sp,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF8E8883),
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 20.h),

                      // ── Height & Weight Row ─────────────────────────────────
                      Row(
                        children: [
                          // Height Field
                          Expanded(
                            child: _MeasurementField(
                              label: 'height'.tr(),
                              controller: _heightController,
                              enabled: !isLoading,
                            ),
                          ),
                          SizedBox(width: 14.w),
                          // Weight Field
                          Expanded(
                            child: _MeasurementField(
                              label: 'weight'.tr(),
                              controller: _weightController,
                              enabled: !isLoading,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 18.h),

                      // ── Body Type Section ───────────────────────────────────
                      Text(
                        'body_type'.tr(),
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      SizedBox(height: 12.h),

                      // Top Row: 3 items (Slim, Regular, Athletic)
                      Row(
                        children: _topRowItems.map((item) {
                          final bool isSelected = _selectedBodyType == item.id;
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4.w),
                              child: _BodyTypeCard(
                                item: item,
                                isSelected: isSelected,
                                onTap: isLoading
                                    ? () {}
                                    : () => setState(
                                        () => _selectedBodyType = item.id),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      SizedBox(height: 10.h),

                      // Bottom Row: 2 items (Stocky, Plus Size)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 36.w),
                          ..._bottomRowItems.map((item) {
                            final bool isSelected = _selectedBodyType == item.id;
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4.w),
                                child: _BodyTypeCard(
                                  item: item,
                                  isSelected: isSelected,
                                  onTap: isLoading
                                      ? () {}
                                      : () => setState(
                                          () => _selectedBodyType = item.id),
                                ),
                              ),
                            );
                          }),
                          SizedBox(width: 36.w),
                        ],
                      ),

                      SizedBox(height: 20.h),

                      // ── Continue Button ─────────────────────────────────────
                      AuthPrimaryButton(
                        label: 'continue_btn'.tr(),
                        isEnabled: isEnabled,
                        isLoading: isLoading,
                        onPressed: isEnabled
                            ? () {
                                final double height =
                                    double.tryParse(heightText) ?? 0.0;
                                final double weight =
                                    double.tryParse(weightText) ?? 0.0;
                                final int bodyType = BodyType.fromString(
                                  _selectedBodyType,
                                ).value;

                                context.read<BodyBloc>().add(
                                      BodySubmitted(
                                        height: height,
                                        weight: weight,
                                        bodyType: bodyType,
                                      ),
                                    );
                              }
                            : null,
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

class _MeasurementField extends StatelessWidget {
  const _MeasurementField({
    required this.label,
    required this.controller,
    this.enabled = true,
  });

  final String label;
  final TextEditingController controller;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          height: 48.h,
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: const Color(0xFFE2D6C6),
              width: 1.3,
            ),
          ),
          child: Center(
            child: TextField(
              controller: controller,
              enabled: enabled,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BodyTypeCard extends StatelessWidget {
  const _BodyTypeCard({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final _BodyTypeItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
        decoration: BoxDecoration(
          color:
              isSelected ? const Color(0xFFFBF4EB) : const Color(0xFFF9F7F4),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFB5956A)
                : const Color(0xFFEFE8DE),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFB5956A).withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Body Type Image
            SizedBox(
              height: 68.h,
              child: Image.asset(
                item.imagePath,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 6.h),
            // Title
            Text(
              item.titleKey.tr(),
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? const Color(0xFF2E2824)
                    : const Color(0xFF9E9892),
              ),
            ),
            SizedBox(height: 2.h),
            // Subtitle
            Text(
              item.subtitleKey.tr(),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9.5.sp,
                fontWeight: FontWeight.w400,
                color: isSelected
                    ? const Color(0xFF6E6760)
                    : const Color(0xFFB0AAA3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
