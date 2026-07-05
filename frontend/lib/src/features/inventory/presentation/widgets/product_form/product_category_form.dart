import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/inventory/presentation/providers/inventory_provider.dart';
import 'package:solar_hub/src/features/inventory/presentation/providers/product_form_provider.dart';

class ProductCategoryForm extends ConsumerWidget {
  const ProductCategoryForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(productFormNotifierProvider);
    final notifier = ref.read(productFormNotifierProvider.notifier);
    
    // We get category options from the inventory provider (which fetches them from the API)
    final options = ref.watch(inventoryNotifierProvider).filterOptions;

    if (options == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdown(
          label: l10n.global_category,
          value: state.globalCategoryId,
          items: options.globalCategories,
          onChanged: (val) => notifier.setGlobalCategory(val),
        ),
        SizedBox(height: 16.h),
        _buildMultiSelect(
          label: l10n.internal_category,
          selectedIds: state.internalCategoryIds,
          items: options.internalCategories,
          onChanged: (val) => notifier.setInternalCategories(val),
        ),
        SizedBox(height: 16.h),
        _buildDropdown(
          label: l10n.company_category,
          value: state.companyCategoryId,
          items: options.companyCategories,
          onChanged: (val) => notifier.setCompanyCategory(val),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required int? value,
    required List<dynamic> items,
    required Function(int?) onChanged,
  }) {
    return DropdownButtonFormField<int>(
      initialValue: value,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      items: [
        const DropdownMenuItem(value: null, child: Text('None')),
        ...items.map((cat) => DropdownMenuItem(value: cat.id, child: Text(cat.name))),
      ],
      onChanged: onChanged,
    );
  }

  Widget _buildMultiSelect({
    required String label,
    required List<int> selectedIds,
    required List<dynamic> items,
    required Function(List<int>) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          children: items.map((cat) {
            final isSelected = selectedIds.contains(cat.id);
            return FilterChip(
              label: Text(cat.name),
              selected: isSelected,
              onSelected: (val) {
                final newList = List<int>.from(selectedIds);
                if (val) {
                  newList.add(cat.id);
                } else {
                  newList.remove(cat.id);
                }
                onChanged(newList);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
