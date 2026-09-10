import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/theme.dart';

/// Reusable Input Field for Auth screens (Gmail, Password, etc.)
class CustomAuthInputField extends StatefulWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool isPassword;
  final IconData? prefixIcon;
  final String? helperText;

  const CustomAuthInputField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.prefixIcon,
    this.helperText,
  });

  @override
  State<CustomAuthInputField> createState() => _CustomAuthInputFieldState();
}

class _CustomAuthInputFieldState extends State<CustomAuthInputField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Field Label
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),

        // Input Container Box
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
              // Optional Prefix Icon with vertical divider
              if (widget.prefixIcon != null) ...[
                Icon(
                  widget.prefixIcon,
                  color: const Color(0xFFB5956A),
                  size: 20.sp,
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 10.w),
                  width: 1.w,
                  height: 22.h,
                  color: const Color(0xFFE5DCD0),
                ),
              ],

              // Text field
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  keyboardType: widget.keyboardType,
                  obscureText: widget.isPassword ? _obscureText : false,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hintText,
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

              // Password Eye Toggle Suffix Icon
              if (widget.isPassword)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: EdgeInsets.only(left: 8.w),
                    child: Icon(
                      _obscureText
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: const Color(0xFF8E8883),
                      size: 20.sp,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Helper text
        if (widget.helperText != null) ...[
          SizedBox(height: 6.h),
          Text(
            widget.helperText!,
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
