import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/layout/app_breakpoints.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/providers/summery_provider.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/company_page_scaffold.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/company_workspace_header_card.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/company_workspace_service_card.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/company_workspace_stat_card.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class CompanyDashboardOverviewScreen extends ConsumerWidget {
  const CompanyDashboardOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(companySummeryProvider);
    final authState = ref.watch(authProvider);
    final l10n = AppLocalizations.of(context)!;
    final summary = state.summery;
    final company = authState.company;

    return CompanyPageScaffold(
      child: Stack(
        children: [
          if (state.isError && summary == null)
            AdminErrorState(error: l10n.error_loading_data, onRetry: () => ref.read(companySummeryProvider.notifier).getSummery())
          else if (summary == null && state.isLoading)
            const AdminLoadingState(icon: Iconsax.buildings_2_bold, message: 'Loading company workspace...')
          else
            SingleChildScrollView(
              padding: AppBreakpoints.pagePadding(context),
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
                      _SectionTitle(title: l10n.quick_stats, subtitle: l10n.monitor_growth_subscriptions),
                      const SizedBox(height: 16),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final width = constraints.maxWidth;
                          final columns = width >= 1180
                              ? 5
                              : width >= 760
                              ? 3
                              : 2;

                          return GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: columns,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: columns == 2 ? 1 : 1.5,
                            children: [
                              CompanyWorkspaceStatCard(title: l10n.members, value: '${summary?.members ?? 0}', icon: Iconsax.people_bold, color: Colors.blue),
                              CompanyWorkspaceStatCard(
                                title: l10n.orders,
                                value: '${summary?.orders ?? 0}',
                                icon: Iconsax.shopping_cart_bold,
                                color: Colors.green,
                              ),
                              CompanyWorkspaceStatCard(title: l10n.offers, value: '${summary?.offers ?? 0}', icon: Iconsax.document_bold, color: Colors.orange),
                              CompanyWorkspaceStatCard(
                                title: l10n.contacts,
                                value: '${summary?.contactsCount ?? 0}',
                                icon: Iconsax.call_bold,
                                color: Colors.purple,
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 28),
                      _SectionTitle(title: l10n.services, subtitle: l10n.ready_to_scale_business),
                      const SizedBox(height: 16),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final width = constraints.maxWidth;
                          final services = [...?summary?.services];
                          final preview = services.take(width >= 1100 ? 4 : 2).toList();
                          if (preview.isEmpty) {
                            return AdminEmptyState(icon: Iconsax.category_bold, title: l10n.services, subtitle: l10n.section_label(l10n.services));
                          }

                          final columns = width >= 1180
                              ? 5
                              : width >= 760
                              ? 3
                              : 2;

                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: preview.length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: columns,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: columns == 2 ? 0.6.h : 0.98,
                            ),
                            itemBuilder: (context, index) {
                              return CompanyWorkspaceServiceCard(
                                service: preview[index],
                                companyId: company?.id,
                                canManageActions: company?.canManageWorkspace ?? false,
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 28),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.08)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Iconsax.chart_2_bold, color: AppTheme.primaryColor, size: 32),
                            const SizedBox(height: 14),
                            Text(
                              l10n.ready_to_scale_business,
                              style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 20, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.monitor_growth_subscriptions,
                              style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, height: 1.5, color: Theme.of(context).hintColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (state.isLoading && summary != null)
            const Positioned(top: 16, right: 16, child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: Theme.of(context).hintColor),
        ),
      ],
    );
  }
}
