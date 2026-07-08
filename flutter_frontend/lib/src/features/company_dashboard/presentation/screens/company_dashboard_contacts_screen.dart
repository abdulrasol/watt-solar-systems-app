import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/layout/app_breakpoints.dart';
import 'package:solar_hub/src/core/theme/app_colors.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/controllers/company_contacts_controller.dart';
import 'package:solar_hub/src/shared/domain/company/company_contact.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/company_management_widgets.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/contacts/contact_card.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/forms/contact_form_sheet.dart';
import 'package:solar_hub/src/services/toast_service.dart';
import 'package:solar_hub/src/shared/widgets/shared_widgets.dart';

/// Company contacts management screen.
class CompanyDashboardContactsScreen extends ConsumerStatefulWidget {
  final bool embedded;

  const CompanyDashboardContactsScreen({super.key, this.embedded = false});

  @override
  ConsumerState<CompanyDashboardContactsScreen> createState() => _CompanyDashboardContactsScreenState();
}

class _CompanyDashboardContactsScreenState extends ConsumerState<CompanyDashboardContactsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    final companyId = ref.read(authProvider).company?.id;
    if (companyId != null) {
      await ref.read(companyContactsProvider.notifier).fetchContacts(companyId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = ref.watch(appColorsProvider);
    final state = ref.watch(companyContactsProvider);
    final company = ref.watch(authProvider).company;
    final companyId = company?.id;
    final canManage = company?.canManageWorkspace ?? false;

    final content = companyId == null
        ? AdminEmptyState(icon: Iconsax.call, title: l10n.contacts, subtitle: l10n.company_contacts_no_company)
        : state.isLoading && state.contacts.isEmpty
        ? AdminLoadingState(icon: Iconsax.call, message: l10n.company_contacts_loading)
        : state.error != null && state.contacts.isEmpty
        ? AdminErrorState(error: state.error!, onRetry: _load)
        : RefreshIndicator(
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
                        title: l10n.contacts,
                        subtitle: l10n.company_contacts_subtitle,
                        action: AppButton(
                          text: l10n.company_contacts_add,
                          icon: Iconsax.add_circle,
                          onPressed: canManage ? () => _openContactSheet(context, companyId) : null,
                          width: null,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (state.contacts.isEmpty)
                        AppEmptyState(
                          icon: Iconsax.call,
                          title: l10n.company_contacts_empty_title,
                          subtitle: l10n.company_contacts_empty_subtitle,
                          actionTitle: canManage ? l10n.company_contacts_add : null,
                          onActionPressed: canManage ? () => _openContactSheet(context, companyId) : null,
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.contacts.length,
                          itemBuilder: (context, index) {
                            final contact = state.contacts[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: ContactCard(
                                contact: contact,
                                onDelete: canManage ? () => _deleteContact(context, companyId, contact) : null,
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );

    return widget.embedded ? content : content;
  }

  Future<void> _deleteContact(BuildContext context, int companyId, CompanyContact contact) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showCompanyDeleteDialog(
      context: context,
      title: l10n.company_contacts_delete_title,
      message: l10n.company_contacts_delete_message(contact.name),
    );
    if (confirmed != true || !mounted) return;

    try {
      await ref.read(companyContactsProvider.notifier).deleteContact(companyId, contact.id);
      if (!context.mounted) return;
      ToastService.success(context, l10n.success, l10n.company_contacts_deleted);
    } catch (e) {
      if (!context.mounted) return;
      ToastService.error(context, l10n.error, e.toString());
    }
  }

  Future<void> _openContactSheet(BuildContext context, int companyId) async {
    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ContactFormSheet(
        onSubmit: (payload) async {
          await ref.read(companyContactsProvider.notifier).createContact(companyId, payload);
        },
      ),
    );
  }
}
