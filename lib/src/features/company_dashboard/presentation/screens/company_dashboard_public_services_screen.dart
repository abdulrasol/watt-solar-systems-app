import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/layout/app_breakpoints.dart';
import 'package:solar_hub/src/core/theme/app_colors.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/controllers/company_public_services_controller.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/company_management_widgets.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/forms/public_service_form_sheet.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/public_services/public_service_card.dart';
import 'package:solar_hub/src/services/toast_service.dart';
import 'package:solar_hub/src/shared/domain/company/company_public_service.dart';
import 'package:solar_hub/src/shared/widgets/shared_widgets.dart';

/// Company public services management screen.
class CompanyDashboardPublicServicesScreen extends ConsumerStatefulWidget {
  final bool embedded;

  const CompanyDashboardPublicServicesScreen({super.key, this.embedded = false});

  @override
  ConsumerState<CompanyDashboardPublicServicesScreen> createState() => _CompanyDashboardPublicServicesScreenState();
}

class _CompanyDashboardPublicServicesScreenState extends ConsumerState<CompanyDashboardPublicServicesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    final companyId = ref.read(authProvider).company?.id;
    if (companyId != null) {
      await ref.read(companyPublicServicesProvider.notifier).fetchPublicServices(companyId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = ref.watch(appColorsProvider);
    final state = ref.watch(companyPublicServicesProvider);
    final company = ref.watch(authProvider).company;
    final companyId = company?.id;
    final canManage = company?.canManageWorkspace ?? false;

    if (companyId == null) {
      return AdminEmptyState(icon: Iconsax.briefcase, title: l10n.company_public_services, subtitle: l10n.company_public_services_no_company);
    }

    if (state.isLoading && state.services.isEmpty) {
      return AdminLoadingState(icon: Iconsax.briefcase, message: l10n.company_public_services_loading);
    }

    if (state.error != null && state.services.isEmpty) {
      return AdminErrorState(error: state.error!, onRetry: _load);
    }

    return RefreshIndicator(
      color: colors.primary,
      backgroundColor: colors.surface,
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: AppBreakpoints.pagePadding(context).copyWith(bottom: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: AppBreakpoints.contentMaxWidth(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CompanySectionIntro(
                  title: l10n.company_public_services,
                  subtitle: l10n.company_public_services_subtitle,
                  action: AppButton(
                    text: l10n.company_public_services_add,
                    icon: Iconsax.add_circle,
                    onPressed: canManage ? () => _openForm(context, companyId) : null,
                    width: null,
                  ),
                ),
                const SizedBox(height: 20),
                if (state.services.isEmpty)
                  AppEmptyState(
                    icon: Iconsax.briefcase,
                    title: l10n.company_public_services_empty_title,
                    subtitle: l10n.company_public_services_empty_subtitle,
                    actionTitle: canManage ? l10n.company_public_services_add : null,
                    onActionPressed: canManage ? () => _openForm(context, companyId) : null,
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.services.length,
                    itemBuilder: (context, index) {
                      final service = state.services[index];
                      return PublicServiceCard(
                        service: service,
                        onEdit: canManage ? () => _openForm(context, companyId, service: service) : null,
                        onDelete: canManage ? () => _deleteService(context, companyId, service) : null,
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

  Future<void> _deleteService(BuildContext context, int companyId, CompanyPublicService service) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showCompanyDeleteDialog(
      context: context,
      title: l10n.company_public_services_delete_title,
      message: l10n.company_public_services_delete_message(service.title),
    );
    if (confirmed != true || !mounted) return;

    try {
      await ref.read(companyPublicServicesProvider.notifier).deletePublicService(companyId, service.id);
      if (!context.mounted) return;
      ToastService.success(context, l10n.success, l10n.company_public_services_deleted);
    } catch (e) {
      if (!context.mounted) return;
      ToastService.error(context, l10n.error, e.toString());
    }
  }

  Future<void> _openForm(BuildContext context, int companyId, {CompanyPublicService? service}) async {
    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PublicServiceFormSheet(
        initialValue: service,
        onSubmit: (payload) async {
          final controller = ref.read(companyPublicServicesProvider.notifier);
          if (service == null) {
            await controller.createPublicService(companyId, payload);
          } else {
            await controller.updatePublicService(companyId, service.id, payload);
          }
        },
      ),
    );
  }
}
