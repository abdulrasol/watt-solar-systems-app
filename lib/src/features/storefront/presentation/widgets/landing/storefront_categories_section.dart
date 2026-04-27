import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/storefront/domain/entities/storefront_models.dart';
import 'package:solar_hub/src/features/storefront/presentation/utils/storefront_layout.dart';
import 'package:solar_hub/src/features/storefront/presentation/widgets/landing/storefront_category_grid_card.dart';
import 'package:solar_hub/src/features/storefront/presentation/widgets/landing/storefront_section_header.dart';
import 'package:solar_hub/src/features/storefront/presentation/widgets/products/storefront_products_empty_state.dart';

class StorefrontCategoriesSection extends StatelessWidget {
  final List<StorefrontCategory> categories;
  final VoidCallback onSeeAll;
  final ValueChanged<StorefrontCategory> onCategoryTap;

  const StorefrontCategoriesSection({
    super.key,
    required this.categories,
    required this.onSeeAll,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = storefrontSquareGridColumns(width);
    final previewItems = categories
        .take(storefrontTwoRowSquareCount(width))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StorefrontSectionHeader(
          title: l10n.categories,
          actionLabel: l10n.see_all,
          onAction: onSeeAll,
        ),
        SizedBox(height: 12.h),
        if (previewItems.isEmpty)
          StorefrontProductsEmptyState(message: l10n.no_categories_found)
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: previewItems.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              final category = previewItems[index];
              return StorefrontCategoryGridCard(
                category: category,
                onTap: () => onCategoryTap(category),
              );
            },
          ),
      ],
    );
  }
}
