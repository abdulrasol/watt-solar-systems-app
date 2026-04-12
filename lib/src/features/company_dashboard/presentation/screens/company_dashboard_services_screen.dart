import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/layout/app_breakpoints.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/providers/summery_provider.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/company_page_scaffold.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/company_workspace_service_card.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class CompanyDashboardServicesScreen extends ConsumerWidget {
  const CompanyDashboardServicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(companySummeryProvider);
    final l10n = AppLocalizations.of(context)!;
    final company = ref.watch(authProvider).company;
    final companyId = company?.id;
    final services = [...?state.summery?.services];

    return CompanyPageScaffold(
      child: state.isError && services.isEmpty
          ? AdminErrorState(
              error: l10n.error_loading_data,
              onRetry: () =>
                  ref.read(companySummeryProvider.notifier).getSummery(),
            )
          : state.isLoading && services.isEmpty
          ? const AdminLoadingState(
              icon: Iconsax.category_bold,
              message: 'Loading services...',
            )
          : SingleChildScrollView(
              padding: AppBreakpoints.pagePadding(context),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: AppBreakpoints.contentMaxWidth(context),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.services,
                        style: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.section_label(l10n.services),
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 13,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (services.isEmpty)
                        AdminEmptyState(
                          icon: Iconsax.category_bold,
                          title: l10n.services,
                          subtitle: l10n.section_label(l10n.services),
                        )
                      else
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final width = constraints.maxWidth;
                            final columns = width >= 1180
                                ? 6
                                : width >= 760
                                ? 4
                                : 2;

                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: services.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: columns,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    childAspectRatio: columns == 2
                                        ? 0.6.h
                                        : 1.0,
                                  ),
                              itemBuilder: (context, index) {
                                return CompanyWorkspaceServiceCard(
                                  service: services[index],
                                  companyId: companyId,
                                  canManageActions:
                                      company?.canManageWorkspace ?? false,
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
