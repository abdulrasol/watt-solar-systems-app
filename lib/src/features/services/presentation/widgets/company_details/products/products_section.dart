import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/widgets/loading_widgets.dart';
import 'package:solar_hub/src/features/storefront/domain/entities/storefront_models.dart'
    show StorefrontAudience;
import 'package:solar_hub/src/features/storefront/presentation/providers/storefront_provider.dart';
import 'package:solar_hub/src/features/storefront/presentation/screens/storefront_cart_screen.dart';
import 'package:solar_hub/src/features/storefront/presentation/screens/storefront_product_details_screen.dart';
import 'package:solar_hub/src/features/storefront/presentation/utils/storefront_page_route.dart';
import 'package:solar_hub/src/features/storefront/presentation/widgets/storefront_cart_button.dart';
import 'package:solar_hub/src/shared/domain/company/company.dart';
import '../common_widgets.dart';
import 'category_chips.dart';
import 'products_grid.dart';

class CompanyProductsSection extends ConsumerStatefulWidget {
  final Company company;

  const CompanyProductsSection({super.key, required this.company});

  @override
  ConsumerState<CompanyProductsSection> createState() =>
      _CompanyProductsSectionState();
}

class _CompanyProductsSectionState
    extends ConsumerState<CompanyProductsSection> {
  late final TextEditingController _searchController;

  StorefrontScope get _scope => StorefrontScope(
    audience: StorefrontAudience.b2c,
    companyId: widget.company.id,
  );

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll(ScrollNotification notification) {
    if (notification.metrics.pixels >=
        notification.metrics.maxScrollExtent - 320) {
      final state = ref.read(storefrontNotifierProvider(_scope));
      if (!state.isLoadingMore && state.pagination.hasNext) {
        ref.read(storefrontNotifierProvider(_scope).notifier).loadMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(storefrontNotifierProvider(_scope));
    final notifier = ref.read(storefrontNotifierProvider(_scope).notifier);

    if (_searchController.text != state.query.search) {
      _searchController.value = _searchController.value.copyWith(
        text: state.query.search,
        selection: TextSelection.collapsed(offset: state.query.search.length),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        _onScroll(notification);
        return false;
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CompanySurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.services_products_mode_title,
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    l10n.storefront_products_available(
                                      state.pagination.totalItems,
                                    ),
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color
                                          ?.withValues(alpha: 0.68),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            StorefrontCartButton(
                              audience: StorefrontAudience.b2c,
                              onPressed: () {
                                Navigator.of(context).push(
                                  buildStorefrontRoute(
                                    context: context,
                                    page: const StorefrontCartScreen(
                                      audience: StorefrontAudience.b2c,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 14.h),
                        TextField(
                          controller: _searchController,
                          textInputAction: TextInputAction.search,
                          onChanged: notifier.updateSearch,
                          decoration: InputDecoration(
                            hintText: l10n.search_products,
                            prefixIcon: const Icon(Icons.search_rounded),
                            suffixIcon: _searchController.text.isEmpty
                                ? null
                                : IconButton(
                                    onPressed: () {
                                      _searchController.clear();
                                      notifier.updateSearch('');
                                      setState(() {});
                                    },
                                    icon: const Icon(Icons.close_rounded),
                                  ),
                          ),
                        ),
                        SizedBox(height: 14.h),
                        CompanySectionHeading(
                          title: l10n.services_company_categories_title,
                        ),
                        SizedBox(height: 10.h),
                        CompanyCategoryChips(
                          state: state,
                          onSelected: notifier.updateCompanyCategory,
                        ),
                      ],
                    ),
                  ),
                  if (state.error != null && state.products.isNotEmpty) ...[
                    SizedBox(height: 14.h),
                    CompanyInlineErrorCard(
                      message: state.error!,
                      onRetry: notifier.refresh,
                    ),
                  ],
                  SizedBox(height: 14.h),
                ],
              ),
            ),
          ),
          if (state.isLoading && state.products.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: LoadingWidget.widget(context: context)),
            )
          else if (state.error != null && state.products.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: CompanyInlineErrorCard(
                  message: state.error!,
                  onRetry: notifier.refresh,
                ),
              ),
            )
          else if (state.products.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: CompanyEmptyStateCard(
                  icon: Iconsax.shop_bold,
                  message: l10n.no_store_products_found,
                ),
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              sliver: CompanyProductsGrid(
                products: state.products,
                onProductTap: (product) {
                  Navigator.of(context).push(
                    buildStorefrontRoute(
                      context: context,
                      page: StorefrontProductDetailsScreen(
                        product: product,
                        audience: StorefrontAudience.b2c,
                      ),
                    ),
                  );
                },
              ),
            ),
          if (state.isLoadingMore)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              ),
            ),
          SliverToBoxAdapter(child: SizedBox(height: 24.h)),
        ],
      ),
    );
  }
}
