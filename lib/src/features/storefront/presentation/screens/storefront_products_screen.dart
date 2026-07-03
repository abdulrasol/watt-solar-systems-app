import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solar_hub/src/features/storefront/presentation/providers/storefront_cart_controller.dart';
import 'package:solar_hub/src/features/storefront/domain/entities/storefront_models.dart';
import 'package:solar_hub/src/features/storefront/presentation/providers/storefront_provider.dart';
import 'package:solar_hub/src/features/storefront/presentation/screens/storefront_cart_screen.dart';
import 'package:solar_hub/src/features/storefront/presentation/screens/storefront_product_details_screen.dart';
import 'package:solar_hub/src/features/storefront/presentation/utils/storefront_page_route.dart';
import 'package:solar_hub/src/features/storefront/presentation/utils/storefront_routes.dart';
import 'package:solar_hub/src/features/storefront/presentation/widgets/products/storefront_company_badges_row.dart';
import 'package:solar_hub/src/features/storefront/presentation/widgets/products/storefront_products_grid.dart';
import 'package:solar_hub/src/features/storefront/presentation/widgets/products/storefront_products_toolbar.dart';
import 'package:solar_hub/src/features/storefront/presentation/widgets/storefront_filters_sheet.dart';

class StorefrontProductsScreen extends ConsumerStatefulWidget {
  final StorefrontAudience audience;
  final int? companyId;
  final int? initialGlobalCategoryId;
  final String? title;
  final bool embedded;

  const StorefrontProductsScreen({
    super.key,
    required this.audience,
    this.companyId,
    this.initialGlobalCategoryId,
    this.title,
    this.embedded = false,
  });

  @override
  ConsumerState<StorefrontProductsScreen> createState() =>
      _StorefrontProductsScreenState();
}

class _StorefrontProductsScreenState
    extends ConsumerState<StorefrontProductsScreen> {
  late final TextEditingController _searchController;
  late final ScrollController _scrollController;

  late final StorefrontScope _scope;

  @override
  void initState() {
    super.initState();
    _scope = StorefrontScope(
      audience: widget.audience,
      companyId: widget.companyId,
      initialQuery: StorefrontQuery(
        globalCategoryId: widget.initialGlobalCategoryId,
      ),
    );
    _searchController = TextEditingController();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 400) {
      final state = ref.read(storefrontNotifierProvider(_scope));
      if (!state.isLoadingMore && state.pagination.hasNext) {
        ref.read(storefrontNotifierProvider(_scope).notifier).loadMore();
      }
    }
  }

  String get _returnLocation => storefrontProductsLocation(
    audience: widget.audience,
    companyId: widget.companyId,
    globalCategoryId: widget.initialGlobalCategoryId,
    title: widget.title,
  );

  List<StorefrontProductOption> _requiredOptionsForProduct(
    StorefrontProduct product,
  ) {
    return product.options.where((option) => option.isRequired).toList();
  }

  Future<StorefrontAudience> _resolveAudienceForAddToCart(
    StorefrontProduct product,
    bool isCompanyMember,
  ) async {
    if (!isCompanyMember) return widget.audience;

    final existingAudiences = storefrontCart.audiencesForCompany(
      product.company.id,
    );
    if (existingAudiences.length == 1) return existingAudiences.first;

    final l10n = AppLocalizations.of(context)!;
    final selected = await showModalBottomSheet<StorefrontAudience>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.choose_cart_audience,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 16.h),
                ListTile(
                  leading: const Icon(Icons.store_mall_directory_rounded),
                  title: Text(l10n.b2b_cart),
                  subtitle: Text(l10n.add_to_b2b_cart),
                  onTap: () =>
                      Navigator.of(context).pop(StorefrontAudience.b2b),
                ),
                ListTile(
                  leading: const Icon(Icons.storefront_rounded),
                  title: Text(l10n.b2c_cart),
                  subtitle: Text(l10n.add_to_b2c_cart),
                  onTap: () =>
                      Navigator.of(context).pop(StorefrontAudience.b2c),
                ),
              ],
            ),
          ),
        );
      },
    );

    return selected ?? widget.audience;
  }

  Future<void> _handleAddToCart(StorefrontProduct product) async {
    final authState = ref.read(authProvider);
    if (!authState.isSigned) {
      context.go('/auth?redirect_to=${Uri.encodeComponent(_returnLocation)}');
      return;
    }

    final audience = await _resolveAudienceForAddToCart(
      product,
      authState.isCompanyMember,
    );
    await storefrontCart.addProduct(
      product,
      audience: audience,
      quantity: 1,
      selectedOptions: _requiredOptionsForProduct(product),
    );
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          audience == StorefrontAudience.b2b
              ? l10n.added_to_b2b_cart
              : l10n.added_to_b2c_cart,
        ),
      ),
    );
  }

  Future<void> _handleRemoveFromCart(StorefrontProduct product) async {
    await storefrontCart.removeProductAcrossAudiences(
      companyId: product.company.id,
      productId: product.id,
      selectedOptionIds: _requiredOptionsForProduct(
        product,
      ).map((e) => e.id).toList(),
    );
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.removed_from_cart)));
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      storefrontNotifierProvider(_scope).select((s) => s.query.search),
      (previous, next) {
        if (_searchController.text != next) {
          _searchController.value = _searchController.value.copyWith(
            text: next,
            selection: TextSelection.collapsed(offset: next.length),
          );
        }
      },
    );

    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(storefrontNotifierProvider(_scope));
    final notifier = ref.read(storefrontNotifierProvider(_scope).notifier);
    final effectiveCompanyId = widget.companyId ?? state.query.companyId;
    final pagePadding = widget.embedded
        ? EdgeInsets.zero
        : EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h);

    final content = RefreshIndicator(
      onRefresh: notifier.refresh,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: pagePadding,
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (!widget.embedded)
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: IconButton.filledTonal(
                      onPressed: () {
                        Navigator.of(context).push(
                          buildStorefrontRoute(
                            context: context,
                            page: StorefrontCartScreen(
                              audience: widget.audience,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.shopping_cart_checkout_rounded),
                    ),
                  ),
                StorefrontProductsToolbar(
                  searchController: _searchController,
                  activeFilterCount: state.query.activeFilterCount,
                  onSearchChanged: notifier.updateSearch,
                  onClearSearch: () {
                    _searchController.clear();
                    notifier.updateSearch('');
                    setState(() {});
                  },
                  onOpenFilters: () async {
                    await showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => StorefrontFiltersSheet(
                        scope: _scope,
                        hideCompanyFilter: widget.companyId != null,
                      ),
                    );
                  },
                ),
                if (effectiveCompanyId != null &&
                    (state.companyCategories.isNotEmpty ||
                        state.isLoadingCompanyCategories ||
                        state.companyCategoriesError != null)) ...[
                  SizedBox(height: 16.h),
                  StorefrontCompanyBadgesRow(
                    categories: state.companyCategories,
                    selectedCategoryId: state.query.companyCategoryId,
                    isLoading: state.isLoadingCompanyCategories,
                    error: state.companyCategoriesError,
                    onCategorySelected: notifier.updateCompanyCategory,
                  ),
                ],
              ]),
            ),
          ),
          StorefrontProductsGridSliver(
            isLoading: state.isLoading,
            isLoadingMore: state.isLoadingMore,
            products: state.products,
            hasNextPage: state.pagination.hasNext,
            error: state.error,
            padding: pagePadding,
            embedded: widget.embedded,
            onProductTap: (product) {
              Navigator.of(context).push(
                buildStorefrontRoute(
                  context: context,
                  page: StorefrontProductDetailsScreen(
                    product: product,
                    audience: widget.audience,
                  ),
                ),
              );
            },
            onAddToCart: _handleAddToCart,
            onRemoveFromCart: _handleRemoveFromCart,
          ),
        ],
      ),
    );

    if (widget.embedded) return content;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title ?? l10n.new_products)),
      body: content,
    );
  }
}
