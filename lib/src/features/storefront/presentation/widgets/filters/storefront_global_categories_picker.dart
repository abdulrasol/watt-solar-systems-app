import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/storefront/domain/entities/storefront_models.dart';

class StorefrontGlobalCategoriesPicker extends StatelessWidget {
  final List<StorefrontCategory> categories;
  final int? selectedCategoryId;
  final ValueChanged<int?> onChanged;

  const StorefrontGlobalCategoriesPicker({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: [
        ChoiceChip(
          label: Text(l10n.all_categories),
          selected: selectedCategoryId == null,
          onSelected: (_) => onChanged(null),
        ),
        ...categories.map(
          (category) => ChoiceChip(
            label: Text(category.name),
            selected: selectedCategoryId == category.id,
            onSelected: (_) => onChanged(category.id),
          ),
        ),
      ],
    );
  }
}
