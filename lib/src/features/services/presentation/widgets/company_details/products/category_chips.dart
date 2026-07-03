import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/storefront/presentation/providers/storefront_provider.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class CompanyCategoryChips extends StatelessWidget {
  final StorefrontState state;
  final ValueChanged<int?> onSelected;

  const CompanyCategoryChips({
    super.key,
    required this.state,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (state.isLoadingCompanyCategories && state.companyCategories.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Text(
          l10n.company_categories_loading,
          style: TextStyle(
            fontSize: 12.sp,
            color: Theme.of(
              context,
            ).textTheme.bodyMedium?.color?.withValues(alpha: 0.66),
          ),
        ),
      );
    }

    if (state.companyCategoriesError != null &&
        state.companyCategories.isEmpty) {
      return Text(
        state.companyCategoriesError!,
        style: TextStyle(fontSize: 12.sp, color: AppTheme.errorColor),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          CompanyCategoryChip(
            label: l10n.all_categories,
            selected: state.query.companyCategoryId == null,
            onTap: () => onSelected(null),
          ),
          ...state.companyCategories.map(
            (category) => Padding(
              padding: EdgeInsetsDirectional.only(start: 8.w),
              child: CompanyCategoryChip(
                label: category.name,
                selected: state.query.companyCategoryId == category.id,
                onTap: () => onSelected(category.id),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CompanyCategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const CompanyCategoryChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primaryColor
              : AppTheme.primaryColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(
            color: selected
                ? Colors.transparent
                : AppTheme.primaryColor.withValues(alpha: 0.18),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : AppTheme.primaryColor,
          ),
        ),
      ),
    );
  }
}
