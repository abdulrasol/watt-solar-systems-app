import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:solar_hub/src/core/widgets/loading_widgets.dart';
import 'package:solar_hub/src/features/services/presentation/providers/public_services_provider.dart';
import 'package:solar_hub/src/features/storefront/domain/entities/storefront_models.dart';
import 'package:solar_hub/src/features/storefront/presentation/providers/storefront_provider.dart';
import 'package:solar_hub/src/shared/domain/company/company.dart';
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
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24.r),
            child: Text(error.toString(), textAlign: TextAlign.center),
          ),
        ),
      ),
      loading: () => Scaffold(
        body: Center(child: LoadingWidget.widget(context: context)),
      ),
    );
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
    if (_mode == CompanyDetailsMode.overview) {
      // For overview, we refresh the company details themselves
      return ref.refresh(
        publicCompanyDetailsProvider(widget.company.id).future,
      );
    } else {
      // For products, we refresh the storefront notifier
      final scope = StorefrontScope(
        audience: StorefrontAudience.b2c,
        companyId: widget.company.id,
      );
      return ref.read(storefrontNotifierProvider(scope).notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    // If we can't show products, always stay in overview mode
    final currentMode = _canShowProducts ? _mode : CompanyDetailsMode.overview;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: NestedScrollView(
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
