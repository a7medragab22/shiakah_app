import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/theme.dart';

/// Labeled phone-number input with an Egyptian country code prefix (+20).
class PhoneInputField extends StatelessWidget {
  const PhoneInputField({
    super.key,
    required this.controller,
    this.label = 'Phone Number',
    this.hintText = '1234 567 890',
    this.helperText,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;

  /// Small grey note shown below the field (e.g. verification disclaimer).
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          label,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),

        // Input row
        Container(
          height: 52.h,
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: const Color(0xFFE2D6C6),
              width: 1.3,
            ),
          ),
          child: Row(
            children: [
              // Country code
              Text(
                '+20',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFB5956A),
                ),
              ),

              // Vertical divider
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10.w),
                width: 1.w,
                height: 22.h,
                color: const Color(0xFFE5DCD0),
              ),

              // Text field
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: TextStyle(
                      fontSize: 15.sp,
                      color: const Color(0xFFB0AAA3),
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Helper text
        if (helperText != null) ...[
          SizedBox(height: 8.h),
          Text(
            helperText!,
            style: TextStyle(
              fontSize: 12.sp,
              color: const Color(0xFF8E8883),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ],
    );
  }
}
