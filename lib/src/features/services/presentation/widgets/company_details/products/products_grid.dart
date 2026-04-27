import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:solar_hub/src/features/storefront/domain/entities/storefront_models.dart';
import 'package:solar_hub/src/features/storefront/presentation/widgets/storefront_product_card.dart';

class CompanyProductsGrid extends StatelessWidget {
  final List<StorefrontProduct> products;
  final ValueChanged<StorefrontProduct> onProductTap;

  const CompanyProductsGrid({
    super.key,
    required this.products,
    required this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width >= 1200
        ? 4
        : width >= 800
        ? 3
        : width < 520
        ? 1
        : 2;

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: crossAxisCount == 1 ? 1.28 : 0.67,
      ),
      delegate: SliverChildBuilderDelegate((context, index) {
        final product = products[index];
        return StorefrontProductCard(
          product: product,
          audience: StorefrontAudience.b2c,
          onTap: () => onProductTap(product),
        );
      }, childCount: products.length),
    );
  }
}
