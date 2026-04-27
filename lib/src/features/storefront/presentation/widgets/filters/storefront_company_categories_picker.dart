import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/storefront/domain/entities/storefront_models.dart';

class StorefrontCompanyCategoriesPicker extends StatelessWidget {
  final List<StorefrontCompanyCategory> categories;
  final bool isLoading;
  final String? error;
  final int? selectedCompanyCategoryId;
  final ValueChanged<int?> onChanged;

  const StorefrontCompanyCategoriesPicker({
    super.key,
    required this.categories,
    required this.isLoading,
    required this.error,
    required this.selectedCompanyCategoryId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (isLoading) {
      return _InlineMessage(message: l10n.company_categories_loading);
    }

    if (error != null) {
      return _InlineMessage(message: error!);
    }

    if (categories.isEmpty) {
      return _InlineMessage(message: l10n.company_categories_empty_title);
    }

    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: [
        ChoiceChip(
          label: Text(l10n.all_categories),
          selected: selectedCompanyCategoryId == null,
          onSelected: (_) => onChanged(null),
        ),
        ...categories.map(
          (category) => ChoiceChip(
            label: Text(category.name),
            selected: selectedCompanyCategoryId == category.id,
            onSelected: (_) => onChanged(category.id),
          ),
        ),
      ],
    );
  }
}

class _InlineMessage extends StatelessWidget {
  final String message;

  const _InlineMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 13.sp),
    );
  }
}
