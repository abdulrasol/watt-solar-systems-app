import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watt/l10n/app_localizations.dart';
import 'package:watt/src/core/layout/app_breakpoints.dart';
import 'package:watt/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:watt/src/features/company_dashboard/presentation/widgets/company_management_widgets.dart';
import 'package:watt/src/features/company_dashboard/presentation/widgets/company_page_scaffold.dart';
import 'package:watt/src/features/storefront/domain/entities/storefront_models.dart';
import 'package:watt/src/features/storefront/presentation/screens/storefront_products_screen.dart';

/// Lets a company see its own storefront exactly as buyers do, with a
/// B2B/B2C toggle since a company can sell under both audiences at once.
/// Reuses `StorefrontProductsScreen` in embedded mode scoped to the
/// company's own `companyId` rather than building a parallel read model —
/// what a buyer sees for this company IS this screen, just filtered to one
/// company, so there's no separate "preview" data path to keep in sync.
///
/// No own Scaffold/AppBar here: like the other company-dashboard screens
/// (see `CompanyDashboardSystemsScreen`), the surrounding ShellRoute already
/// supplies the page chrome — this widget only returns body content.
class CompanyStorefrontPreviewScreen extends ConsumerStatefulWidget {
  const CompanyStorefrontPreviewScreen({super.key});

  @override
  ConsumerState<CompanyStorefrontPreviewScreen> createState() => _CompanyStorefrontPreviewScreenState();
}

class _CompanyStorefrontPreviewScreenState extends ConsumerState<CompanyStorefrontPreviewScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final companyId = ref.watch(authProvider).company?.id;

    if (companyId == null) {
      return CompanyPageScaffold(child: Center(child: Text(l10n.no_company_workspace)));
    }

    return CompanyPageScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: AppBreakpoints.pagePadding(context).copyWith(bottom: 0),
            child: CompanySectionIntro(title: l10n.storefront_preview, subtitle: l10n.storefront_preview_subtitle, action: const SizedBox.shrink()),
          ),
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: l10n.b2b_storefront),
              Tab(text: l10n.b2c_storefront),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                StorefrontProductsScreen(audience: StorefrontAudience.b2b, companyId: companyId, embedded: true),
                StorefrontProductsScreen(audience: StorefrontAudience.b2c, companyId: companyId, embedded: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
