import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/widgets/loading_widgets.dart';
import 'package:solar_hub/src/features/storefront/domain/entities/storefront_models.dart';
import 'package:solar_hub/src/features/storefront/presentation/widgets/storefront_product_card.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class StorefrontProductsSliver extends StatelessWidget {
  final StorefrontAudience audience;
  final bool isLoading;
  final bool isLoadingMore;
  final List<StorefrontProduct> products;
  final bool hasNextPage;
  final String? error;
  final EdgeInsets padding;
  final VoidCallback? onRetry;
  final ValueChanged<StorefrontProduct> onProductTap;
  final bool embedded;

  const StorefrontProductsSliver({
    super.key,
    required this.audience,
    required this.isLoading,
    required this.isLoadingMore,
    required this.products,
    required this.hasNextPage,
    required this.error,
    required this.padding,
    required this.onProductTap,
    this.onRetry,
    this.embedded = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width >= 1200
        ? 4
        : width >= 800
        ? 3
        : width < 520
        ? 1
        : 2;

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
          child: _EmptyState(
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
              childAspectRatio: crossAxisCount == 1 ? 1.28 : 0.67,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final product = products[index];
              return StorefrontProductCard(
                product: product,
                audience: audience,
                onTap: () => onProductTap(product),
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

class _EmptyState extends StatelessWidget {
  final String message;
  final bool showErrorStyle;

  const _EmptyState({required this.message, required this.showErrorStyle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(28.r),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        children: [
          Icon(
            showErrorStyle
                ? Icons.error_outline_rounded
                : Icons.storefront_outlined,
            size: 42.sp,
            color: showErrorStyle ? AppTheme.errorColor : Colors.grey.shade500,
          ),
          SizedBox(height: 12.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15.sp),
          ),
        ],
      ),
    );
  }
}
