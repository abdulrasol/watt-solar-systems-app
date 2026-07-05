import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:solar_hub/src/features/calculations/presentation/widgets/explanation_dialog.dart';
import 'package:solar_hub/src/utils/app_explanations.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class ExplanationButton extends StatelessWidget {
  const ExplanationButton({
    super.key,
    required this.explanations,
    this.storageKey,
    this.icon = Icons.lightbulb_outline_rounded,
    this.tooltip = 'Explanation',
    this.withBorder = false,
  });
  final List<ExplanationItem> explanations;
  final String? storageKey;
  final IconData? icon;
  final String? tooltip;
  final bool withBorder;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 4.0.h),
      child: Container(
        decoration: BoxDecoration(
          border: withBorder ? Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)) : null,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: IconButton(
          onPressed: () {
            ExplanationDialog.show(context, explanations: explanations, showDontShowAgain: storageKey != null, storageKey: storageKey);
          },
          icon: Icon(icon),
          color: AppTheme.primaryColor,
          tooltip: tooltip,
        ),
      ),
    );
  }
}
