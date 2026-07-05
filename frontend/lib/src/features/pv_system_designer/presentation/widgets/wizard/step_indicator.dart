import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class StepIndicator extends StatelessWidget {
  const StepIndicator({super.key, required this.currentStep, required this.totalSteps, required this.stepLabels});

  final int currentStep;
  final int totalSteps;
  final List<String> stepLabels;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Column(
        children: [
          Row(
            children: List.generate(totalSteps, (index) {
              final isActive = index == currentStep;
              final isCompleted = index < currentStep;
              return Expanded(
                child: Container(
                  height: 4.h,
                  margin: EdgeInsets.symmetric(horizontal: 2.w),
                  decoration: BoxDecoration(
                    color: isCompleted || isActive
                        ? AppTheme.primaryColor
                        : (isDark ? Colors.white12 : Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Text(
                '${currentStep + 1} / $totalSteps',
                style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
              ),
              const Spacer(),
              if (currentStep < stepLabels.length)
                Text(
                  stepLabels[currentStep],
                  style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : Colors.grey[600]),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
