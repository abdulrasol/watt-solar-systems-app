import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watt/src/utils/app_theme.dart';

class WizardBottomBar extends StatelessWidget {
  const WizardBottomBar({super.key, required this.currentStep, required this.totalSteps, required this.onBack, required this.onNext, required this.onSave});

  final int currentStep;
  final int totalSteps;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';
    final isLastStep = currentStep == totalSteps - 1;
    final isFirstStep = currentStep == 0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (!isFirstStep)
              IconButton(
                onPressed: onBack,
                icon: Icon(isAr ? Icons.arrow_forward : Icons.arrow_back_rounded),
                style: IconButton.styleFrom(backgroundColor: Colors.grey.withValues(alpha: 0.1)),
              ),
            const Spacer(),
            if (isLastStep)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onSave,
                  icon: const Icon(Icons.save_rounded),
                  label: Text(isAr ? 'حفظ التصميم' : 'Save Design'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                ),
              )
            else
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onNext,
                  icon: Icon(isAr ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded),
                  label: Text(isAr ? 'التالي' : 'Next'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
