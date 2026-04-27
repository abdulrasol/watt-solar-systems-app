import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/widgets/loading_widgets.dart';
import 'package:solar_hub/src/features/storefront/domain/entities/storefront_models.dart';
import 'package:solar_hub/src/features/storefront/presentation/utils/storefront_layout.dart';
import 'package:solar_hub/src/features/storefront/presentation/widgets/products/storefront_product_card.dart';
import 'package:solar_hub/src/features/storefront/presentation/widgets/products/storefront_products_empty_state.dart';

class StorefrontProductsGridSliver extends StatelessWidget {
  final bool isLoading;
  final bool isLoadingMore;
  final List<StorefrontProduct> products;
  final bool hasNextPage;
  final String? error;
  final EdgeInsets padding;
  final bool embedded;
  final ValueChanged<StorefrontProduct> onProductTap;
  final ValueChanged<StorefrontProduct> onAddToCart;
  final ValueChanged<StorefrontProduct> onRemoveFromCart;

  const StorefrontProductsGridSliver({
    super.key,
    required this.isLoading,
    required this.isLoadingMore,
    required this.products,
    required this.hasNextPage,
    required this.error,
    required this.padding,
    required this.embedded,
    required this.onProductTap,
    required this.onAddToCart,
    required this.onRemoveFromCart,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = storefrontProductColumns(width);

    if (isLoading && products.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: LoadingWidget.widget(context: context)),
      );
    }

    if (products.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: padding.copyWith(top: 0),
          child: StorefrontProductsEmptyState(
            message: error ?? l10n.no_store_products_found,
            showErrorStyle: error != null,
          ),
        ),
      );
    }

    return SliverMainAxisGroup(
      slivers: [
        SliverPadding(
          padding: padding.copyWith(top: 0),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: crossAxisCount == 1 ? 0.96 : 0.72,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final product = products[index];
              return StorefrontProductCard(
                product: product,
                onTap: () => onProductTap(product),
                onAddToCart: () => onAddToCart(product),
                onRemoveFromCart: () => onRemoveFromCart(product),
              );
            }, childCount: products.length),
          ),
        ),
        if (isLoadingMore || hasNextPage)
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: Center(
                child: isLoadingMore
                    ? SizedBox(
                        width: 24.r,
                        height: 24.r,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2.5,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ),
        SliverToBoxAdapter(child: SizedBox(height: embedded ? 16.h : 32.h)),
      ],
    );
  }
}
