import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A horizontal 5-step progress bar for the style-setup flow.
/// [currentStep] is 1-indexed (1 = first step, 5 = last step).
class StepProgressIndicator extends StatelessWidget {
  const StepProgressIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = 5,
  });

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (i) {
        final bool isActive = i < currentStep;
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: EdgeInsets.only(right: i < totalSteps - 1 ? 4.w : 0),
            height: 4.h,
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFFB5956A)
                  : const Color(0xFFE2D6C6),
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
      }),
    );
  }
}
