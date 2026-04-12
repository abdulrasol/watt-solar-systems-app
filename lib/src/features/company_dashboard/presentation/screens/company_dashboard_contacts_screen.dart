import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/layout/app_breakpoints.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:solar_hub/src/shared/domain/company/company_contact.dart';
import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/models/company_contact_form_model.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/controllers/company_contacts_controller.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/company_management_widgets.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/company_page_scaffold.dart';
import 'package:solar_hub/src/services/toast_service.dart';
import 'package:solar_hub/src/utils/app_theme.dart';
import 'package:validatorless/validatorless.dart';

class CompanyDashboardContactsScreen extends ConsumerStatefulWidget {
  const CompanyDashboardContactsScreen({super.key});

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
    final state = ref.watch(companyContactsProvider);
    final company = ref.watch(authProvider).company;
    final companyId = company?.id;
    final canManage = company?.canManageWorkspace ?? false;

    return CompanyPageScaffold(
      child: companyId == null
          ? AdminEmptyState(icon: Iconsax.call_bold, title: l10n.contacts, subtitle: l10n.company_contacts_no_company)
          : state.isLoading && state.contacts.isEmpty
          ? AdminLoadingState(icon: Iconsax.call_bold, message: l10n.company_contacts_loading)
          : state.error != null && state.contacts.isEmpty
          ? AdminErrorState(error: state.error!, onRetry: _load)
          : SingleChildScrollView(
              padding: AppBreakpoints.pagePadding(context),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: AppBreakpoints.contentMaxWidth(context)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CompanySectionIntro(
                        title: l10n.contacts,
                        subtitle: l10n.company_contacts_subtitle,
                        action: FilledButton.icon(
                          onPressed: canManage ? () => _openContactSheet(context, companyId) : null,
                          icon: const Icon(Iconsax.add_circle_bold),
                          label: Text(l10n.company_contacts_add),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (state.contacts.isEmpty)
                        AdminEmptyState(icon: Iconsax.call_bold, title: l10n.company_contacts_empty_title, subtitle: l10n.company_contacts_empty_subtitle)
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.contacts.length,
                          itemBuilder: (context, index) {
                            final contact = state.contacts[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: _ContactCard(contact: contact, onDelete: canManage ? () => _deleteContact(context, companyId, contact) : null),
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
      builder: (context) => _ContactFormSheet(
        onSubmit: (payload) async {
          await ref.read(companyContactsProvider.notifier).createContact(companyId, payload);
        },
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.contact, required this.onDelete});

  final CompanyContact contact;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
                child: const Icon(Iconsax.user_bold, color: AppTheme.primaryColor),
              ),
              const Spacer(),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Iconsax.trash_bold, color: Colors.redAccent),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            contact.name,
            style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          _MetaRow(icon: Iconsax.sms_bold, value: contact.email ?? '-'),
          const SizedBox(height: 8),
          _MetaRow(icon: Iconsax.call_bold, value: contact.phone ?? '-'),
          if ((contact.notes ?? '').isNotEmpty) ...[const SizedBox(height: 8), _MetaRow(icon: Iconsax.note_bold, value: contact.notes!)],
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).hintColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: Theme.of(context).hintColor),
          ),
        ),
      ],
    );
  }
}

class _ContactFormSheet extends StatefulWidget {
  const _ContactFormSheet({required this.onSubmit});

  final Future<void> Function(CompanyContactFormModel payload) onSubmit;

  @override
  State<_ContactFormSheet> createState() => _ContactFormSheetState();
}

class _ContactFormSheetState extends State<_ContactFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: screenHeight * 0.75),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.company_contacts_add,
                  style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: l10n.company_contacts_name),
                  validator: Validatorless.required(l10n.company_contacts_name_required),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: l10n.company_contacts_email),
                  validator: Validatorless.multiple([
                    Validatorless.required(l10n.company_contacts_email_required),
                    Validatorless.email(l10n.company_contacts_email_invalid),
                  ]),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(labelText: l10n.company_contacts_phone),
                  validator: Validatorless.required(l10n.company_contacts_phone_required),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: InputDecoration(labelText: l10n.company_contacts_notes),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isSubmitting
                        ? null
                        : () async {
                            if (!_formKey.currentState!.validate()) return;
                            setState(() => _isSubmitting = true);
                            try {
                              await widget.onSubmit(
                                CompanyContactFormModel(
                                  name: _nameController.text.trim(),
                                  email: _emailController.text.trim(),
                                  phone: _phoneController.text.trim(),
                                  notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
                                ),
                              );
                              if (!mounted) return;
                              Navigator.of(this.context).pop();
                            } finally {
                              if (mounted) {
                                setState(() => _isSubmitting = false);
                              }
                            }
                          },
                    child: Text(_isSubmitting ? l10n.loading : l10n.company_contacts_save),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
