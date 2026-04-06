import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/widgets/loading_widgets.dart';
import 'package:solar_hub/src/features/storefront/domain/entities/storefront_models.dart';
import 'package:solar_hub/src/features/storefront/presentation/providers/storefront_provider.dart';
import 'package:solar_hub/src/features/storefront/presentation/screens/storefront_cart_screen.dart';
import 'package:solar_hub/src/features/storefront/presentation/screens/storefront_product_details_screen.dart';
import 'package:solar_hub/src/features/storefront/presentation/utils/storefront_page_route.dart';
import 'package:solar_hub/src/features/storefront/presentation/widgets/storefront_filters_sheet.dart';
import 'package:solar_hub/src/features/storefront/presentation/widgets/storefront_header.dart';
import 'package:solar_hub/src/features/storefront/presentation/widgets/storefront_product_card.dart';
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

    final categories = state.meta.categoriesForType(state.activeCategoryType);
    final padding = widget.embedded
        ? EdgeInsets.zero
        : EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h);

    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width >= 1200
        ? 4
        : width >= 800
        ? 3
        : 2;

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
                TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onChanged: (value) {
                    setState(() {});
                    notifier.updateSearch(value);
                  },
                  decoration: InputDecoration(
                    hintText: widget.audience == StorefrontAudience.b2b
                        ? l10n.search_b2b_products
                        : l10n.search_products,
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
                SizedBox(height: 12.h),
                _FilterAndSortBar(
                  state: state,
                  notifier: notifier,
                  companyId: widget.companyId,
                ),
                SizedBox(height: 16.h),
                _CategoryTypeSelector(state: state, notifier: notifier),
                if (categories.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  _CategorySelector(
                    state: state,
                    notifier: notifier,
                    categories: categories,
                  ),
                ],
                SizedBox(height: 16.h),
                if (state.error != null && !state.isLoading)
                  _ErrorBanner(error: state.error!),
              ]),
            ),
          ),
          if (state.isLoading && state.products.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: LoadingWidget.widget(context: context)),
            )
          else if (state.products.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: padding.copyWith(top: 0),
                child: _EmptyState(message: l10n.no_store_products_found),
              ),
            )
          else
            SliverPadding(
              padding: padding.copyWith(top: 0),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12.w,
                  mainAxisSpacing: 12.h,
                  childAspectRatio: 0.67,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final product = state.products[index];
                    return StorefrontProductCard(
                      product: product,
                      audience: widget.audience,
                      onTap: () {
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
                    );
                  },
                  childCount: state.products.length,
                ),
              ),
            ),
          if (state.isLoadingMore || state.pagination.hasNext)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24.h),
                child: Center(
                  child: state.isLoadingMore
                      ? SizedBox(
                          width: 24.r,
                          height: 24.r,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2.5,
                          ),
                        )
                      : const SizedBox.shrink(), // Auto-loaded by scroll listener
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: SizedBox(height: widget.embedded ? 16.h : 32.h),
          ),
        ],
      ),
    );
  }
}

class _FilterAndSortBar extends StatelessWidget {
  final StorefrontState state;
  final StorefrontNotifier notifier;
  final int? companyId;

  const _FilterAndSortBar({
    required this.state,
    required this.notifier,
    this.companyId,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 430;
        final filterButton = OutlinedButton.icon(
          onPressed: () async {
            await showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              builder: (sheetContext) => StorefrontFiltersSheet(
                state: state,
                hideCompanyFilter: companyId != null,
                onApply: ({
                  required int? companyId,
                  required bool clearCompanyId,
                  required bool? isAvailable,
                  required bool clearAvailability,
                  required double? minPrice,
                  required bool clearMinPrice,
                  required double? maxPrice,
                  required bool clearMaxPrice,
                }) async {
                  Navigator.of(sheetContext).pop();
                  await notifier.applyFilters(
                    companyId: companyId,
                    clearCompanyId: clearCompanyId,
                    isAvailable: isAvailable,
                    clearAvailability: clearAvailability,
                    minPrice: minPrice,
                    clearMinPrice: clearMinPrice,
                    maxPrice: maxPrice,
                    clearMaxPrice: clearMaxPrice,
                  );
                },
                onClear: () async {
                  Navigator.of(sheetContext).pop();
                  await notifier.clearFilters();
                },
              ),
            );
          },
          icon: const Icon(Icons.filter_alt_outlined),
          label: Text(l10n.filters),
        );

        final sortField = DropdownButtonFormField<String>(
          initialValue: state.query.ordering,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: l10n.sort_by,
            prefixIcon: const Icon(Icons.swap_vert_rounded),
          ),
          items: [
            DropdownMenuItem(value: '-created_at', child: Text(l10n.sort_newest)),
            DropdownMenuItem(value: 'created_at', child: Text(l10n.sort_oldest)),
            DropdownMenuItem(value: 'name', child: Text(l10n.sort_name_asc)),
            DropdownMenuItem(value: '-name', child: Text(l10n.sort_name_desc)),
            DropdownMenuItem(value: 'price', child: Text(l10n.sort_price_asc)),
            DropdownMenuItem(value: '-price', child: Text(l10n.sort_price_desc)),
          ],
          onChanged: (value) {
            if (value != null) notifier.updateOrdering(value);
          },
        );

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
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
    );
  }
}

class _CategoryTypeSelector extends StatelessWidget {
  final StorefrontState state;
  final StorefrontNotifier notifier;

  const _CategoryTypeSelector({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: [
        _CategoryTypeChip(
          label: l10n.all,
          selected: state.activeCategoryType == null,
          onTap: () => notifier.updateCategoryType(null),
        ),
        _CategoryTypeChip(
          label: l10n.global_category,
          selected: state.activeCategoryType == StorefrontCategoryType.global,
          onTap: () => notifier.updateCategoryType(StorefrontCategoryType.global),
        ),
        _CategoryTypeChip(
          label: l10n.internal_category,
          selected: state.activeCategoryType == StorefrontCategoryType.internal,
          onTap: () => notifier.updateCategoryType(StorefrontCategoryType.internal),
        ),
        _CategoryTypeChip(
          label: l10n.company_category,
          selected: state.activeCategoryType == StorefrontCategoryType.company,
          onTap: () => notifier.updateCategoryType(StorefrontCategoryType.company),
        ),
      ],
    );
  }
}

class _CategorySelector extends StatelessWidget {
  final StorefrontState state;
  final StorefrontNotifier notifier;
  final List<StorefrontCategory> categories;

  const _CategorySelector({
    required this.state,
    required this.notifier,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: [
        _CategoryTypeChip(
          label: l10n.all_categories,
          selected: state.selectedCategoryId == null,
          onTap: () => notifier.updateCategory(null),
        ),
        ...categories.map(
          (category) => _CategoryTypeChip(
            label: category.name,
            selected: state.selectedCategoryId == category.id,
            onTap: () => notifier.updateCategory(category.id),
          ),
        ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String error;

  const _ErrorBanner({required this.error});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Text(
        error,
        style: TextStyle(color: AppTheme.errorColor),
      ),
    );
  }
}

class _CategoryTypeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryTypeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppTheme.primaryColor.withValues(alpha: 0.15),
      labelStyle: TextStyle(
        color: selected ? AppTheme.primaryDarkColor : null,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;

  const _EmptyState({required this.message});

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
            Icons.storefront_outlined,
            size: 42.sp,
            color: Colors.grey.shade500,
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
