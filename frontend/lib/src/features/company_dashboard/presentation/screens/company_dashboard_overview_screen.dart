import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/layout/app_breakpoints.dart';
import 'package:solar_hub/src/core/theme/app_colors.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/providers/summary_provider.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/company_workspace_header_card.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/financial_summary_card.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/overview/overview_cta_card.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/overview/overview_section_title.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/overview/overview_services_grid.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/overview/overview_stats_grid.dart';

/// Company dashboard overview landing page.
class CompanyDashboardOverviewScreen extends ConsumerWidget {
  const CompanyDashboardOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(companySummaryProvider);
    final authState = ref.watch(authProvider);
    final l10n = AppLocalizations.of(context)!;
    final colors = ref.watch(appColorsProvider);
    final summary = state.summary;
    final company = authState.company;

    if (state.isError && summary == null) {
      return AdminErrorState(
        error: l10n.error_loading_data,
        onRetry: () => ref.read(companySummaryProvider.notifier).getSummary(),
      );
    }

    if (summary == null && state.isLoading) {
      return const AdminLoadingState(icon: Iconsax.buildings_2, message: 'Loading company workspace...');
    }

    return RefreshIndicator(
      color: colors.primary,
      backgroundColor: colors.surface,
      onRefresh: () async => ref.read(companySummaryProvider.notifier).getSummary(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: AppBreakpoints.contentMaxWidth(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (company != null) ...[
                  CompanyWorkspaceHeaderCard(company: company, onEditPressed: () => context.push('/auth/company_registration')),
                  const SizedBox(height: 24),
                ],
                OverviewSectionTitle(title: l10n.quick_stats, subtitle: l10n.monitor_growth_subscriptions),
                const SizedBox(height: 16),
                OverviewStatsGrid(summary: summary),
                const SizedBox(height: 28),
                OverviewSectionTitle(title: l10n.services, subtitle: l10n.ready_to_scale_business),
                const SizedBox(height: 16),
                OverviewServicesGrid(summary: summary, company: company),
                const SizedBox(height: 28),
                const FinancialSummaryCard(),
                const SizedBox(height: 28),
                const OverviewCTACard(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
