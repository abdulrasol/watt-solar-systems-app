import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

enum CompanyDetailsMode { overview, products }

class CompanyModeSelector extends StatelessWidget {
  final CompanyDetailsMode currentMode;
  final ValueChanged<CompanyDetailsMode> onModeChanged;

  const CompanyModeSelector({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ModeChip(
              label: l10n.services_mode_overview,
              icon: Iconsax.info_circle_bold,
              selected: currentMode == CompanyDetailsMode.overview,
              onTap: () => onModeChanged(CompanyDetailsMode.overview),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: _ModeChip(
              label: l10n.services_mode_products,
              icon: Iconsax.shop_bold,
              selected: currentMode == CompanyDetailsMode.products,
              onTap: () => onModeChanged(CompanyDetailsMode.products),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ModeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppTheme.primaryColor : Colors.transparent,
      borderRadius: BorderRadius.circular(18.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16.sp,
                color: selected
                    ? Colors.white
                    : Theme.of(context).textTheme.bodyMedium?.color,
              ),
              SizedBox(width: 8.w),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: selected
                        ? Colors.white
                        : Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
