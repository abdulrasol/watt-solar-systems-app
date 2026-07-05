import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/storefront/domain/entities/storefront_models.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class StorefrontCategorySection extends StatelessWidget {
  final String title;
  final String allLabel;
  final int? selectedCategoryId;
  final List<StorefrontCategoryOption> categories;
  final ValueChanged<int?> onCategorySelected;

  const StorefrontCategorySection({
    super.key,
    required this.title,
    required this.allLabel,
    required this.selectedCategoryId,
    required this.categories,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800),
        ),
        SizedBox(height: 10.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            _CategoryChip(
              label: allLabel,
              selected: selectedCategoryId == null,
              onTap: () => onCategorySelected(null),
            ),
            ...categories.map(
              (category) => _CategoryChip(
                label: category.name,
                selected: selectedCategoryId == category.id,
                onTap: () => onCategorySelected(category.id),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class StorefrontCategoryOption {
  final int id;
  final String name;

  const StorefrontCategoryOption({required this.id, required this.name});

  factory StorefrontCategoryOption.fromGlobalCategory(
    StorefrontCategory category,
  ) {
    return StorefrontCategoryOption(id: category.id, name: category.name);
  }

  factory StorefrontCategoryOption.fromCompanyCategory(
    StorefrontCompanyCategory category,
  ) {
    return StorefrontCategoryOption(id: category.id, name: category.name);
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppTheme.primaryColor.withValues(alpha: 0.15),
      labelStyle: TextStyle(
        color: selected ? AppTheme.primaryDarkColor : null,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

String storefrontCategorySectionTitle(
  BuildContext context,
  StorefrontCategoryType type,
) {
  final l10n = AppLocalizations.of(context)!;
  switch (type) {
    case StorefrontCategoryType.global:
      return l10n.global_category;
    case StorefrontCategoryType.company:
      return l10n.company_category;
  }
}
