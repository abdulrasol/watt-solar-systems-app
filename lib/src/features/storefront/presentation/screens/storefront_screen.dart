import 'package:flutter/material.dart';
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

class StorefrontScreen extends StatefulWidget {
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
  State<StorefrontScreen> createState() => _StorefrontScreenState();
}

class _StorefrontScreenState extends State<StorefrontScreen> {
  late final TextEditingController _searchController;
  late final StorefrontController _controller;

  StorefrontScope get _scope =>
      StorefrontScope(audience: widget.audience, companyId: widget.companyId);

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _controller = StorefrontController(_scope);
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final state = _controller.state;
        final categories = state.meta.categoriesForType(
          state.activeCategoryType,
        );
        final padding = widget.embedded
            ? EdgeInsets.zero
            : EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h);

        return RefreshIndicator(
          onRefresh: _controller.refresh,
          child: ListView(
            padding: padding,
            children: [
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
                  _controller.updateSearch(value);
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
                            _controller.updateSearch('');
                            setState(() {});
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                ),
              ),
              SizedBox(height: 12.h),
              LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 430;
                  final filterButton = OutlinedButton.icon(
                    onPressed: () async {
                      await showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        builder: (sheetContext) => StorefrontFiltersSheet(
                          state: state,
                          hideCompanyFilter: widget.companyId != null,
                          onApply:
                              ({
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
                                await _controller.applyFilters(
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
                            await _controller.clearFilters();
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
                      DropdownMenuItem(
                        value: '-created_at',
                        child: Text(l10n.sort_newest),
                      ),
                      DropdownMenuItem(
                        value: 'created_at',
                        child: Text(l10n.sort_oldest),
                      ),
                      DropdownMenuItem(
                        value: 'name',
                        child: Text(l10n.sort_name_asc),
                      ),
                      DropdownMenuItem(
                        value: '-name',
                        child: Text(l10n.sort_name_desc),
                      ),
                      DropdownMenuItem(
                        value: 'price',
                        child: Text(l10n.sort_price_asc),
                      ),
                      DropdownMenuItem(
                        value: '-price',
                        child: Text(l10n.sort_price_desc),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) _controller.updateOrdering(value);
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
              ),
              SizedBox(height: 16.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  _CategoryTypeChip(
                    label: l10n.all,
                    selected: state.activeCategoryType == null,
                    onTap: () => _controller.updateCategoryType(null),
                  ),
                  _CategoryTypeChip(
                    label: l10n.global_category,
                    selected:
                        state.activeCategoryType ==
                        StorefrontCategoryType.global,
                    onTap: () => _controller.updateCategoryType(
                      StorefrontCategoryType.global,
                    ),
                  ),
                  _CategoryTypeChip(
                    label: l10n.internal_category,
                    selected:
                        state.activeCategoryType ==
                        StorefrontCategoryType.internal,
                    onTap: () => _controller.updateCategoryType(
                      StorefrontCategoryType.internal,
                    ),
                  ),
                  _CategoryTypeChip(
                    label: l10n.company_category,
                    selected:
                        state.activeCategoryType ==
                        StorefrontCategoryType.company,
                    onTap: () => _controller.updateCategoryType(
                      StorefrontCategoryType.company,
                    ),
                  ),
                ],
              ),
              if (categories.isNotEmpty) ...[
                SizedBox(height: 12.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    _CategoryTypeChip(
                      label: l10n.all_categories,
                      selected: state.selectedCategoryId == null,
                      onTap: () => _controller.updateCategory(null),
                    ),
                    ...categories.map(
                      (category) => _CategoryTypeChip(
                        label: category.name,
                        selected: state.selectedCategoryId == category.id,
                        onTap: () => _controller.updateCategory(category.id),
                      ),
                    ),
                  ],
                ),
              ],
              SizedBox(height: 16.h),
              if (state.error != null && !state.isLoading)
                Container(
                  margin: EdgeInsets.only(bottom: 16.h),
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Text(
                    state.error!,
                    style: TextStyle(color: AppTheme.errorColor),
                  ),
                ),
              if (state.isLoading && state.products.isEmpty)
                SizedBox(
                  height: 240.h,
                  child: Center(child: LoadingWidget.widget(context: context)),
                )
              else if (state.products.isEmpty)
                _EmptyState(message: l10n.no_store_products_found)
              else
                _ProductsGrid(
                  products: state.products,
                  audience: widget.audience,
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
              if (state.pagination.hasNext) ...[
                SizedBox(height: 16.h),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: state.isLoadingMore
                        ? null
                        : _controller.loadMore,
                    icon: state.isLoadingMore
                        ? SizedBox(
                            width: 16.r,
                            height: 16.r,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.keyboard_arrow_down_rounded),
                    label: Text(
                      state.isLoadingMore ? l10n.loading : l10n.load_more,
                    ),
                  ),
                ),
              ],
              SizedBox(height: widget.embedded ? 0 : 20.h),
            ],
          ),
        );
      },
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

class _ProductsGrid extends StatelessWidget {
  final List<StorefrontProduct> products;
  final StorefrontAudience audience;
  final ValueChanged<StorefrontProduct> onProductTap;

  const _ProductsGrid({
    required this.products,
    required this.audience,
    required this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width >= 1200
        ? 4
        : width >= 800
        ? 3
        : 2;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 0.67,
      ),
      itemBuilder: (context, index) {
        final product = products[index];
        return StorefrontProductCard(
          product: product,
          audience: audience,
          onTap: () => onProductTap(product),
        );
      },
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
