import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/storefront/domain/entities/storefront_models.dart';

class StorefrontToolbarSection extends StatelessWidget {
  final StorefrontAudience audience;
  final TextEditingController searchController;
  final String searchHint;
  final String ordering;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final VoidCallback onOpenFilters;
  final ValueChanged<String> onOrderingChanged;

  const StorefrontToolbarSection({
    super.key,
    required this.audience,
    required this.searchController,
    required this.searchHint,
    required this.ordering,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onOpenFilters,
    required this.onOrderingChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final priceSortItems = audience == StorefrontAudience.b2b
        ? [
            DropdownMenuItem(value: 'wholesale_price', child: Text(l10n.sort_wholesale_price_asc)),
            DropdownMenuItem(value: '-wholesale_price', child: Text(l10n.sort_wholesale_price_desc)),
            DropdownMenuItem(value: 'retail_price', child: Text(l10n.sort_retail_price_asc)),
            DropdownMenuItem(value: '-retail_price', child: Text(l10n.sort_retail_price_desc)),
          ]
        : [
            DropdownMenuItem(value: 'retail_price', child: Text(l10n.sort_retail_price_asc)),
            DropdownMenuItem(value: '-retail_price', child: Text(l10n.sort_retail_price_desc)),
            DropdownMenuItem(value: 'wholesale_price', child: Text(l10n.sort_wholesale_price_asc)),
            DropdownMenuItem(value: '-wholesale_price', child: Text(l10n.sort_wholesale_price_desc)),
          ];

    return Column(
      children: [
        TextField(
          controller: searchController,
          textInputAction: TextInputAction.search,
          onChanged: onSearchChanged,
          decoration: InputDecoration(
            hintText: searchHint,
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: searchController.text.isEmpty ? null : IconButton(onPressed: onClearSearch, icon: const Icon(Icons.close_rounded)),
          ),
        ),
        SizedBox(height: 12.h),
        LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 430;

            final filterButton = OutlinedButton.icon(onPressed: onOpenFilters, icon: const Icon(Icons.filter_alt_outlined), label: Text(l10n.filters));

            final sortField = DropdownButtonFormField<String>(
              initialValue: ordering,
              isExpanded: true,
              decoration: InputDecoration(labelText: l10n.sort_by, prefixIcon: const Icon(Icons.swap_vert_rounded)),
              items: [
                DropdownMenuItem(value: '-created_at', child: Text(l10n.sort_newest)),
                DropdownMenuItem(value: 'created_at', child: Text(l10n.sort_oldest)),
                DropdownMenuItem(value: 'name', child: Text(l10n.sort_name_asc)),
                DropdownMenuItem(value: '-name', child: Text(l10n.sort_name_desc)),
                ...priceSortItems,
                DropdownMenuItem(value: 'stock_quantity', child: Text(l10n.sort_stock_asc)),
                DropdownMenuItem(value: '-stock_quantity', child: Text(l10n.sort_stock_desc)),
              ],
              onChanged: (value) {
                if (value != null) onOrderingChanged(value);
              },
            );

            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  filterButton,
                  SizedBox(height: 12.h),
                  sortField,
                ],
              );
            }

            return Row(
              children: [
                Expanded(child: filterButton),
                SizedBox(width: 12.w),
                Expanded(child: sortField),
              ],
            );
          },
        ),
      ],
    );
  }
}
