import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/storefront/domain/entities/storefront_models.dart';
import 'package:solar_hub/src/features/storefront/presentation/utils/storefront_layout.dart';
import 'package:solar_hub/src/features/storefront/presentation/widgets/landing/storefront_section_header.dart';
import 'package:solar_hub/src/features/storefront/presentation/widgets/products/storefront_product_card.dart';
import 'package:solar_hub/src/features/storefront/presentation/widgets/products/storefront_products_empty_state.dart';

class StorefrontNewProductsSection extends StatelessWidget {
  final List<StorefrontProduct> products;
  final String? error;
  final VoidCallback onViewMore;
  final ValueChanged<StorefrontProduct> onProductTap;
  final ValueChanged<StorefrontProduct> onAddToCart;
  final ValueChanged<StorefrontProduct> onRemoveFromCart;

  const StorefrontNewProductsSection({
    super.key,
    required this.products,
    required this.error,
    required this.onViewMore,
    required this.onProductTap,
    required this.onAddToCart,
    required this.onRemoveFromCart,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = storefrontProductColumns(width);
    final previewItems = products.take(storefrontTwoRowProductCount(width)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StorefrontSectionHeader(title: l10n.new_products, actionLabel: l10n.view_more, onAction: onViewMore),
        SizedBox(height: 12.h),
        if (previewItems.isEmpty)
          StorefrontProductsEmptyState(message: error ?? l10n.no_store_products_found, showErrorStyle: error != null)
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: previewItems.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: crossAxisCount == 1 ? 0.8 : 0.72,
            ),
            itemBuilder: (context, index) {
              final product = previewItems[index];
              return StorefrontProductCard(
                product: product,
                onTap: () => onProductTap(product),
                onAddToCart: () => onAddToCart(product),
                onRemoveFromCart: () => onRemoveFromCart(product),
              );
            },
          ),
      ],
    );
  }
}
