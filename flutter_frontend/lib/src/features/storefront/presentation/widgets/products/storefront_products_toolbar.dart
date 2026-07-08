import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/storefront/presentation/widgets/products/storefront_filter_button.dart';

class StorefrontProductsToolbar extends StatelessWidget {
  final TextEditingController searchController;
  final int activeFilterCount;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final VoidCallback onOpenFilters;

  const StorefrontProductsToolbar({
    super.key,
    required this.searchController,
    required this.activeFilterCount,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onOpenFilters,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: searchController,
      builder: (context, value, _) {
        return Row(
          children: [
            Expanded(
              child: TextField(
                controller: searchController,
                textInputAction: TextInputAction.search,
                onChanged: onSearchChanged,
                decoration: InputDecoration(
                  hintText: l10n.search_products,
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: value.text.isEmpty
                      ? null
                      : IconButton(
                          onPressed: onClearSearch,
                          icon: const Icon(Icons.close_rounded),
                        ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            StorefrontFilterButton(
              activeCount: activeFilterCount,
              onTap: onOpenFilters,
            ),
          ],
        );
      },
    );
  }
}
