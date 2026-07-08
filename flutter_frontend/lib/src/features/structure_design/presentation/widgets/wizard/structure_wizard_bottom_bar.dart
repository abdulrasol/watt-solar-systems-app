import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watt/l10n/app_localizations.dart';

class StructureWizardBottomBar extends StatelessWidget {
  const StructureWizardBottomBar({
    super.key,
    required this.tabIndex,
    required this.l10n,
    required this.theme,
    required this.onBack,
    required this.onNext,
    required this.onSave,
  });

  final int tabIndex;
  final AppLocalizations l10n;
  final ThemeData theme;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h + ScreenUtil().bottomBarHeight),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          if (tabIndex > 0)
            IconButton.filledTonal(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded),
            )
          else
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.close_rounded),
            ),
          SizedBox(width: 12.w),
          Expanded(
            child: tabIndex == 2
                ? FilledButton.icon(
                    onPressed: onSave,
                    icon: const Icon(Icons.share_rounded),
                    label: Text(l10n.structure_save_watt_drawing),
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                  )
                : FilledButton(
                    onPressed: onNext,
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    child: Text(
                      tabIndex == 1
                          ? l10n.calculate
                          : l10n.structure_button_next,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
