import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/storefront/domain/entities/storefront_models.dart';
import 'package:solar_hub/src/features/storefront/presentation/providers/storefront_provider.dart';
import 'package:solar_hub/src/features/storefront/presentation/screens/storefront_products_screen.dart';
import 'package:solar_hub/src/features/storefront/presentation/utils/storefront_layout.dart';
import 'package:solar_hub/src/features/storefront/presentation/utils/storefront_page_route.dart';
import 'package:solar_hub/src/features/storefront/presentation/widgets/landing/storefront_company_grid_card.dart';
import 'package:solar_hub/src/features/storefront/presentation/widgets/products/storefront_products_empty_state.dart';

class StorefrontCompaniesScreen extends ConsumerStatefulWidget {
  final StorefrontAudience audience;

  const StorefrontCompaniesScreen({super.key, required this.audience});

  @override
  ConsumerState<StorefrontCompaniesScreen> createState() =>
      _StorefrontCompaniesScreenState();
}

class _StorefrontCompaniesScreenState
    extends ConsumerState<StorefrontCompaniesScreen> {
  late final ScrollController _scrollController;
  late final StorefrontScope _scope;

  @override
  void initState() {
    super.initState();
    _scope = StorefrontScope(audience: widget.audience);
    _scrollController = ScrollController()..addListener(_onScroll);
    Future.microtask(() {
      ref
          .read(storefrontNotifierProvider(_scope).notifier)
          .ensureCompaniesLoaded(forceRefresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 240) {
      ref.read(storefrontNotifierProvider(_scope).notifier).loadMoreCompanies();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(storefrontNotifierProvider(_scope));
    final filterSheet = state.filterSheet;
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = storefrontSquareGridColumns(width);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.companies)),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(storefrontNotifierProvider(_scope).notifier)
              .ensureCompaniesLoaded(forceRefresh: true);
        },
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.all(16.r),
              sliver:
                  filterSheet.isLoadingCompanies &&
                      filterSheet.companies.isEmpty
                  ? const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : filterSheet.companies.isEmpty
                  ? SliverToBoxAdapter(
                      child: StorefrontProductsEmptyState(
                        message:
                            filterSheet.companiesError ?? l10n.no_company_found,
                        showErrorStyle: filterSheet.companiesError != null,
                      ),
                    )
                  : SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 12.w,
                        mainAxisSpacing: 12.h,
                        childAspectRatio: 1,
                      ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final company = filterSheet.companies[index];
                        return StorefrontCompanyGridCard(
                          company: company,
                          onTap: () {
                            Navigator.of(context).push(
                              buildStorefrontRoute(
                                context: context,
                                page: StorefrontProductsScreen(
                                  audience: widget.audience,
                                  companyId: company.id,
                                  title: company.name,
                                ),
                              ),
                            );
                          },
                        );
                      }, childCount: filterSheet.companies.length),
                    ),
            ),
            if (filterSheet.isLoadingMoreCompanies)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.h),
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
            SliverToBoxAdapter(child: SizedBox(height: 24.h)),
          ],
        ),
      ),
    );
  }
}
