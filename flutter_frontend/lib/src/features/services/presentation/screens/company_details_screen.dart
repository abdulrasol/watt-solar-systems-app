import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watt/src/core/widgets/loading_widgets.dart';
import 'package:watt/src/features/services/presentation/providers/public_services_provider.dart';
import 'package:watt/src/features/storefront/domain/entities/storefront_models.dart';
import 'package:watt/src/features/storefront/presentation/providers/storefront_provider.dart';
import 'package:watt/src/shared/domain/company/company.dart';
import '../widgets/company_details/hero_card.dart';
import '../widgets/company_details/mode_selector.dart';
import '../widgets/company_details/mode_selector_delegate.dart';
import '../widgets/company_details/overview/overview_section.dart';
import '../widgets/company_details/products/products_section.dart';

class CompanyDetailsScreen extends ConsumerWidget {
  final int companyId;

  const CompanyDetailsScreen({super.key, required this.companyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsAsync = ref.watch(publicCompanyDetailsProvider(companyId));
    return detailsAsync.when(
      data: (company) => _DetailsBody(company: company),
      error: (error, stackTrace) => Scaffold(
        body: RefreshIndicator(
          onRefresh: () => _refreshCompanyDetails(ref, companyId),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.r),
                    child: Text(error.toString(), textAlign: TextAlign.center),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      loading: () => Scaffold(
        body: RefreshIndicator(
          onRefresh: () => _refreshCompanyDetails(ref, companyId),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: LoadingWidget.widget(context: context)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _refreshCompanyDetails(WidgetRef ref, int companyId) async {
    try {
      final refreshedCompany = ref.refresh(
        publicCompanyDetailsProvider(companyId).future,
      );
      await refreshedCompany;
    } catch (_) {
      // The provider stores the error state for the UI; the refresh gesture
      // should still finish cleanly.
    }
  }
}

class _DetailsBody extends ConsumerStatefulWidget {
  final Company company;

  const _DetailsBody({required this.company});

  @override
  ConsumerState<_DetailsBody> createState() => _DetailsBodyState();
}

class _DetailsBodyState extends ConsumerState<_DetailsBody> {
  CompanyDetailsMode _mode = CompanyDetailsMode.overview;

  bool get _canShowProducts {
    final hasB2C = widget.company.allowsB2C;
    final hasStorefront = widget.company.services.any(
      (s) => s.serviceCode == 'storefront_b2c' && s.status == 'active',
    );
    return hasB2C && hasStorefront;
  }

  Future<void> _onRefresh() async {
    final refreshDetails = ref.refresh(
      publicCompanyDetailsProvider(widget.company.id).future,
    );

    if (_canShowProducts && _mode == CompanyDetailsMode.products) {
      final scope = StorefrontScope(
        audience: StorefrontAudience.b2c,
        companyId: widget.company.id,
      );
      await Future.wait([
        refreshDetails.catchError((_) => widget.company),
        ref.read(storefrontNotifierProvider(scope).notifier).refresh(),
      ]);
      return;
    }

    try {
      await refreshDetails;
    } catch (_) {
      // The parent provider will rebuild into its error state.
    }
  }

  @override
  Widget build(BuildContext context) {
    // If we can't show products, always stay in overview mode
    final currentMode = _canShowProducts ? _mode : CompanyDetailsMode.overview;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        notificationPredicate: (notification) {
          return notification.metrics.axis == Axis.vertical;
        },
        child: NestedScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    16.r,
                    16.r,
                    16.r,
                    _canShowProducts ? 0 : 16.r,
                  ),
                  child: CompanyHeroCard(company: widget.company),
                ),
              ),
              if (_canShowProducts)
                SliverPersistentHeader(
                  pinned: true,
                  delegate: CompanyModeSelectorDelegate(
                    currentMode: currentMode,
                    onModeChanged: (newMode) {
                      if (_mode != newMode) {
                        setState(() => _mode = newMode);
                      }
                    },
                  ),
                ),
            ];
          },
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: currentMode == CompanyDetailsMode.overview
                ? CompanyOverviewSection(
                    key: const ValueKey('overview'),
                    company: widget.company,
                  )
                : CompanyProductsSection(
                    key: const ValueKey('products'),
                    company: widget.company,
                  ),
          ),
        ),
      ),
    );
  }
}
