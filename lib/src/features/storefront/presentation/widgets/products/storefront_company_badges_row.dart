import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/storefront/domain/entities/storefront_models.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class StorefrontCompanyBadgesRow extends StatelessWidget {
  final List<StorefrontCompanyCategory> categories;
  final int? selectedCategoryId;
  final bool isLoading;
  final String? error;
  final ValueChanged<int?> onCategorySelected;

  const StorefrontCompanyBadgesRow({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.isLoading,
    required this.error,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (isLoading) {
      return Text(
        l10n.company_categories_loading,
        style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
      );
    }

    if (error != null) {
      return Text(error!, style: const TextStyle(color: AppTheme.errorColor));
    }

    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: [
        ChoiceChip(
          label: Text(l10n.all_categories),
          selected: selectedCategoryId == null,
          onSelected: (_) => onCategorySelected(null),
        ),
        ...categories.map(
          (category) => ChoiceChip(
            label: Text(category.name),
            selected: selectedCategoryId == category.id,
            onSelected: (_) => onCategorySelected(category.id),
          ),
        ),
      ],
    );
  }
}
