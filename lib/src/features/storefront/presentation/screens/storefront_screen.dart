import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/storefront/domain/entities/storefront_models.dart';
import 'package:solar_hub/src/features/storefront/presentation/providers/storefront_provider.dart';
import 'package:solar_hub/src/features/storefront/presentation/screens/storefront_cart_screen.dart';
import 'package:solar_hub/src/features/storefront/presentation/screens/storefront_product_details_screen.dart';
import 'package:solar_hub/src/features/storefront/presentation/utils/storefront_page_route.dart';
import 'package:solar_hub/src/features/storefront/presentation/widgets/storefront_category_section.dart';
import 'package:solar_hub/src/features/storefront/presentation/widgets/storefront_filters_sheet.dart';
import 'package:solar_hub/src/features/storefront/presentation/widgets/storefront_header.dart';
import 'package:solar_hub/src/features/storefront/presentation/widgets/storefront_products_sliver.dart';
import 'package:solar_hub/src/features/storefront/presentation/widgets/storefront_toolbar_section.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class StorefrontScreen extends ConsumerStatefulWidget {
  final StorefrontAudience audience;
  final int? companyId;
  final bool embedded;

  const StorefrontScreen({
    super.key,
    required this.audience,
    this.companyId,
    this.embedded = false,
  });

  @override
  ConsumerState<StorefrontScreen> createState() => _StorefrontScreenState();
}

class _StorefrontScreenState extends ConsumerState<StorefrontScreen> {
  late final TextEditingController _searchController;
  late final ScrollController _scrollController;

  StorefrontScope get _scope =>
      StorefrontScope(audience: widget.audience, companyId: widget.companyId);

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(storefrontNotifierProvider(_scope));
    final notifier = ref.read(storefrontNotifierProvider(_scope).notifier);
    final effectiveCompanyId = widget.companyId ?? state.query.companyId;

    if (_searchController.text != state.query.search) {
      _searchController.value = _searchController.value.copyWith(
        text: state.query.search,
        selection: TextSelection.collapsed(offset: state.query.search.length),
      );
    }

    final padding = widget.embedded
        ? EdgeInsets.zero
        : EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h);

    return RefreshIndicator(
      onRefresh: notifier.refresh,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: padding,
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                StorefrontHeader(
                  audience: widget.audience,
                  totalItems: state.pagination.totalItems,
                  embedded: widget.embedded,
                  onCartTap: () {
                    Navigator.of(context).push(
                      buildStorefrontRoute(
                        context: context,
                        page: StorefrontCartScreen(audience: widget.audience),
                      ),
                    );
                  },
                ),
                SizedBox(height: 16.h),
                StorefrontToolbarSection(
                  audience: widget.audience,
                  searchController: _searchController,
                  searchHint: widget.audience == StorefrontAudience.b2b
                      ? l10n.search_b2b_products
                      : l10n.search_products,
                  ordering: state.query.ordering,
                  onSearchChanged: (value) {
                    setState(() {});
                    notifier.updateSearch(value);
                  },
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
                  onOrderingChanged: (value) {
                    notifier.updateOrdering(value);
                  },
                ),
                SizedBox(height: 16.h),
                StorefrontCategorySection(
                  title: l10n.global_category,
                  allLabel: l10n.all_categories,
                  selectedCategoryId: state.query.globalCategoryId,
                  categories: state.meta.globalCategories
                      .map(StorefrontCategoryOption.fromGlobalCategory)
                      .toList(),
                  onCategorySelected: (value) {
                    notifier.updateGlobalCategory(value);
                  },
                ),
                if (effectiveCompanyId != null &&
                    (state.companyCategories.isNotEmpty ||
                        state.isLoadingCompanyCategories ||
                        state.companyCategoriesError != null)) ...[
                  SizedBox(height: 16.h),
                  _CompanyCategoriesSection(
                    state: state,
                    onCategorySelected: (value) {
                      notifier.updateCompanyCategory(value);
                    },
                  ),
                ],
                if (state.error != null && state.products.isNotEmpty) ...[
                  SizedBox(height: 16.h),
                  _ErrorBanner(error: state.error!),
                ],
              ]),
            ),
          ),
          StorefrontProductsSliver(
            audience: widget.audience,
            isLoading: state.isLoading,
            isLoadingMore: state.isLoadingMore,
            products: state.products,
            hasNextPage: state.pagination.hasNext,
            error: state.error,
            padding: padding,
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
          ),
        ],
      ),
    );
  }
}

class _CompanyCategoriesSection extends StatelessWidget {
  final StorefrontState state;
  final ValueChanged<int?> onCategorySelected;

  const _CompanyCategoriesSection({
    required this.state,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (state.isLoadingCompanyCategories) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Text(
          l10n.company_categories_loading,
          style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
        ),
      );
    }

    if (state.companyCategoriesError != null) {
      return _ErrorBanner(error: state.companyCategoriesError!);
    }

    if (state.companyCategories.isEmpty) {
      return const SizedBox.shrink();
    }

    return StorefrontCategorySection(
      title: l10n.company_category,
      allLabel: l10n.all_categories,
      selectedCategoryId: state.query.companyCategoryId,
      categories: state.companyCategories
          .map(StorefrontCategoryOption.fromCompanyCategory)
          .toList(),
      onCategorySelected: onCategorySelected,
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String error;

  const _ErrorBanner({required this.error});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Text(error, style: const TextStyle(color: AppTheme.errorColor)),
    );
  }
}
