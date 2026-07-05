import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/widgets/offline_status_banner.dart';
import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solar_hub/src/features/storefront/domain/entities/storefront_models.dart';
import 'package:solar_hub/src/features/storefront/presentation/providers/storefront_provider.dart';
import 'package:solar_hub/src/features/storefront/presentation/providers/storefront_cart_controller.dart';
import 'package:solar_hub/src/features/storefront/presentation/screens/storefront_cart_screen.dart';
import 'package:solar_hub/src/features/storefront/presentation/screens/storefront_companies_screen.dart';
import 'package:solar_hub/src/features/storefront/presentation/screens/storefront_product_details_screen.dart';
import 'package:solar_hub/src/features/storefront/presentation/screens/storefront_products_screen.dart';
import 'package:solar_hub/src/features/storefront/presentation/utils/storefront_page_route.dart';
import 'package:solar_hub/src/features/storefront/presentation/utils/storefront_routes.dart';
import 'package:solar_hub/src/features/storefront/presentation/widgets/landing/storefront_categories_section.dart';
import 'package:solar_hub/src/features/storefront/presentation/widgets/landing/storefront_companies_section.dart';
import 'package:solar_hub/src/features/storefront/presentation/widgets/landing/storefront_landing_header.dart';
import 'package:solar_hub/src/features/storefront/presentation/widgets/landing/storefront_new_products_section.dart';
import 'package:solar_hub/src/features/storefront/presentation/widgets/storefront_filters_sheet.dart';

class StorefrontScreen extends ConsumerStatefulWidget {
  final StorefrontAudience audience;
  final int? companyId;
  final bool embedded;

  const StorefrontScreen({super.key, required this.audience, this.companyId, this.embedded = false});

  @override
  ConsumerState<StorefrontScreen> createState() => _StorefrontScreenState();
}

class _StorefrontScreenState extends ConsumerState<StorefrontScreen> {
  late final StorefrontScope _scope;

  @override
  void initState() {
    super.initState();
    _scope = StorefrontScope(audience: widget.audience, companyId: widget.companyId);
    Future.microtask(() {
      if (widget.companyId == null) {
        ref.read(storefrontNotifierProvider(_scope).notifier).ensureCompaniesLoaded();
      }
    });
  }

  String get _returnLocation => storefrontLandingLocation(audience: widget.audience, companyId: widget.companyId);

  List<StorefrontProductOption> _requiredOptionsForProduct(StorefrontProduct product) {
    return product.options.where((option) => option.isRequired).toList();
  }

  Future<StorefrontAudience> _resolveAudienceForAddToCart(StorefrontProduct product, bool isCompanyMember) async {
    if (!isCompanyMember) return widget.audience;

    final existingAudiences = storefrontCart.audiencesForCompany(product.company.id);
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
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 16.h),
                ListTile(
                  leading: const Icon(Icons.store_mall_directory_rounded),
                  title: Text(l10n.b2b_cart),
                  subtitle: Text(l10n.add_to_b2b_cart),
                  onTap: () => Navigator.of(context).pop(StorefrontAudience.b2b),
                ),
                ListTile(
                  leading: const Icon(Icons.storefront_rounded),
                  title: Text(l10n.b2c_cart),
                  subtitle: Text(l10n.add_to_b2c_cart),
                  onTap: () => Navigator.of(context).pop(StorefrontAudience.b2c),
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

    final audience = await _resolveAudienceForAddToCart(product, authState.isCompanyMember);
    await storefrontCart.addProduct(product, audience: audience, quantity: 1, selectedOptions: _requiredOptionsForProduct(product));
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(audience == StorefrontAudience.b2b ? l10n.added_to_b2b_cart : l10n.added_to_b2c_cart)));
  }

  Future<void> _handleRemoveFromCart(StorefrontProduct product) async {
    await storefrontCart.removeProductAcrossAudiences(
      companyId: product.company.id,
      productId: product.id,
      selectedOptionIds: _requiredOptionsForProduct(product).map((e) => e.id).toList(),
    );
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.removed_from_cart)));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(storefrontNotifierProvider(_scope));
    final padding = widget.embedded ? EdgeInsets.zero : EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h);

    if (state.isLoading && state.products.isEmpty && state.meta.globalCategories.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: ref.read(storefrontNotifierProvider(_scope).notifier).refresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: padding,
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const OfflineStatusBanner(padding: EdgeInsets.zero),
                SizedBox(height: 12.h),
                StorefrontLandingHeader(
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
                SizedBox(height: 20.h),
                StorefrontNewProductsSection(
                  products: state.products,
                  error: state.error,
                  onViewMore: () {
                    Navigator.of(context).push(
                      buildStorefrontRoute(
                        context: context,
                        page: StorefrontProductsScreen(audience: widget.audience, companyId: widget.companyId),
                      ),
                    );
                  },
                  onProductTap: (product) {
                    Navigator.of(context).push(
                      buildStorefrontRoute(
                        context: context,
                        page: StorefrontProductDetailsScreen(product: product, audience: widget.audience),
                      ),
                    );
                  },
                  onAddToCart: _handleAddToCart,
                  onRemoveFromCart: _handleRemoveFromCart,
                ),
                if (state.meta.globalCategories.isNotEmpty) ...[
                  SizedBox(height: 20.h),
                  StorefrontCategoriesSection(
                    categories: state.meta.globalCategories,
                    onSeeAll: () async {
                      await showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => StorefrontFiltersSheet(scope: _scope, hideCompanyFilter: widget.companyId != null),
                      );
                    },
                    onCategoryTap: (category) {
                      Navigator.of(context).push(
                        buildStorefrontRoute(
                          context: context,
                          page: StorefrontProductsScreen(
                            audience: widget.audience,
                            companyId: widget.companyId,
                            initialGlobalCategoryId: category.id,
                            title: category.name,
                          ),
                        ),
                      );
                    },
                  ),
                ],
                if (widget.companyId == null) ...[
                  SizedBox(height: 20.h),
                  StorefrontCompaniesSection(
                    companies: state.filterSheet.companies,
                    error: state.filterSheet.companiesError,
                    isLoading: state.filterSheet.isLoadingCompanies,
                    onViewMore: () {
                      Navigator.of(context).push(
                        buildStorefrontRoute(
                          context: context,
                          page: StorefrontCompaniesScreen(audience: widget.audience),
                        ),
                      );
                    },
                    onCompanyTap: (company) {
                      Navigator.of(context).push(
                        buildStorefrontRoute(
                          context: context,
                          page: StorefrontProductsScreen(audience: widget.audience, companyId: company.id, title: company.name),
                        ),
                      );
                    },
                  ),
                ],
                SizedBox(height: widget.embedded ? 16.h : 32.h),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
