import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:simple_step_checkout/simple_step_checkout.dart';
import 'package:watt/src/utils/app_theme.dart';

class StepperShell extends StatelessWidget {
  const StepperShell({
    super.key,
    required this.stepperController,
    required this.isDark,
  });

  final SimpleCheckoutStepperController stepperController;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 0.5.w,
          ),
        ),
      ),
      child: SimpleCheckoutStepper(
        controller: stepperController,
        doneColor: AppTheme.primaryColor,
        unDoneColor: isDark ? Colors.white24 : Colors.grey.shade300,
        lineSize: 1.5.h,
        stepTitleStyle: TextStyle(
          fontSize: 11.sp,
          fontFamily: AppTheme.fontFamily,
          color: isDark ? Colors.white70 : Colors.grey.shade700,
        ),
        stepNumberStyle: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.bold,
          fontFamily: AppTheme.fontFamily,
          color: Colors.white,
        ),
        titlePaddingTop: 18.h,
      ),
    );
  }
}
