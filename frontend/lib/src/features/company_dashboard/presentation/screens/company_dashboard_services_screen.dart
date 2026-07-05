import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/layout/app_breakpoints.dart';
import 'package:solar_hub/src/core/theme/app_colors.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/providers/summary_provider.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/company_workspace_service_card.dart';
import 'package:solar_hub/src/shared/widgets/shared_widgets.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

/// Company subscribed services catalog screen.
class CompanyDashboardServicesScreen extends ConsumerWidget {
  final bool embedded;

  const CompanyDashboardServicesScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(companySummaryProvider);
    final l10n = AppLocalizations.of(context)!;
    final colors = ref.watch(appColorsProvider);
    final company = ref.watch(authProvider).company;
    final companyId = company?.id;
    final services = [...?state.summary?.services];

    if (state.isError && services.isEmpty) {
      return AdminErrorState(error: l10n.error_loading_data, onRetry: () => ref.read(companySummaryProvider.notifier).getSummary());
    }

    if (state.isLoading && services.isEmpty) {
      return const AdminLoadingState(icon: Iconsax.category, message: 'Loading services...');
    }

    return RefreshIndicator(
      color: colors.primary,
      backgroundColor: colors.surface,
      onRefresh: () async => ref.read(companySummaryProvider.notifier).getSummary(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: AppBreakpoints.pagePadding(context).copyWith(bottom: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: AppBreakpoints.contentMaxWidth(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.services,
                  style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 20, fontWeight: FontWeight.w800, color: colors.textPrimary),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.section_label(l10n.services),
                  style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: colors.textSecondary),
                ),
                const SizedBox(height: 20),
                if (services.isEmpty)
                  AppEmptyState(icon: Iconsax.category, title: l10n.services, subtitle: l10n.section_label(l10n.services))
                else
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final columns = width >= 1180 ? 6 : width >= 760 ? 4 : 2;

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: services.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: columns == 2 ? 0.6 : 1.0,
                        ),
                        itemBuilder: (context, index) {
                          return CompanyWorkspaceServiceCard(
                            service: services[index],
                            companyId: companyId,
                            canManageActions: company?.canManageWorkspace ?? false,
                          );
                        },
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
