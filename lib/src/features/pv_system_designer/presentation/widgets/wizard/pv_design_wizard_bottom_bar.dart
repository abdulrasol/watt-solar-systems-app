import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:solar_hub/l10n/app_localizations.dart';

class PvDesignWizardBottomBar extends StatelessWidget {
  const PvDesignWizardBottomBar({
    super.key,
    required this.stepIndex,
    required this.stepCount,
    required this.isLastStep,
    required this.canProceed,
    required this.l10n,
    required this.theme,
    required this.onBack,
    required this.onNext,
    required this.onFinish,
  });

  final int stepIndex;
  final int stepCount;
  final bool isLastStep;
  final bool canProceed;
  final AppLocalizations l10n;
  final ThemeData theme;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h + ScreenUtil().bottomBarHeight),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1), width: 1),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (stepIndex > 0)
              IconButton.filledTonal(onPressed: onBack, icon: const Icon(Icons.arrow_back_rounded))
            else
              IconButton(onPressed: onBack, icon: const Icon(Icons.close_rounded)),
            SizedBox(width: 12.w),
            Expanded(
              child: isLastStep
                  ? FilledButton.icon(
                      onPressed: onFinish,
                      icon: const Icon(Icons.check_rounded),
                      label: Text(l10n.pv_design_finish),
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                      ),
                    )
                  : FilledButton(
                      onPressed: canProceed ? onNext : null,
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                      ),
                      child: Text(l10n.next),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
