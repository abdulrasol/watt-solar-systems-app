import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/layout/app_breakpoints.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:solar_hub/src/shared/domain/company/company_public_service.dart';
import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/models/company_public_service_form_model.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/controllers/company_public_services_controller.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/company_management_widgets.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/company_page_scaffold.dart';
import 'package:solar_hub/src/services/toast_service.dart';
import 'package:solar_hub/src/utils/app_theme.dart';
import 'package:validatorless/validatorless.dart';

class CompanyDashboardPublicServicesScreen extends ConsumerStatefulWidget {
  const CompanyDashboardPublicServicesScreen({super.key});

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
    final state = ref.watch(companyPublicServicesProvider);
    final company = ref.watch(authProvider).company;
    final companyId = company?.id;
    final canManage = company?.canManageWorkspace ?? false;

    return CompanyPageScaffold(
      child: companyId == null
          ? AdminEmptyState(icon: Iconsax.briefcase_bold, title: l10n.company_public_services, subtitle: l10n.company_public_services_no_company)
          : state.isLoading && state.services.isEmpty
          ? AdminLoadingState(icon: Iconsax.briefcase_bold, message: l10n.company_public_services_loading)
          : state.error != null && state.services.isEmpty
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
                        title: l10n.company_public_services,
                        subtitle: l10n.company_public_services_subtitle,
                        action: FilledButton.icon(
                          onPressed: canManage ? () => _openForm(context, companyId) : null,
                          icon: const Icon(Iconsax.add_circle_bold),
                          label: Text(l10n.company_public_services_add),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (state.services.isEmpty)
                        AdminEmptyState(
                          icon: Iconsax.briefcase_bold,
                          title: l10n.company_public_services_empty_title,
                          subtitle: l10n.company_public_services_empty_subtitle,
                        )
                      else
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: state.services.length,
                              itemBuilder: (context, index) {
                                final service = state.services[index];
                                return _PublicServiceCard(
                                  service: service,
                                  onEdit: canManage ? () => _openForm(context, companyId, service: service) : null,
                                  onDelete: canManage ? () => _deleteService(context, companyId, service) : null,
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
      builder: (context) => _PublicServiceFormSheet(
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

class _PublicServiceCard extends StatelessWidget {
  const _PublicServiceCard({required this.service, required this.onEdit, required this.onDelete});

  final CompanyPublicService service;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
            child: const Icon(Iconsax.briefcase_bold, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.title,
                  style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 16, fontWeight: FontWeight.w700),
                ),
                if (service.description?.isNotEmpty == true) ...[
                  const SizedBox(height: 4),
                  Text(
                    service.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: Theme.of(context).hintColor),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  service.price == null ? '-' : '${service.price}',
                  style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.primaryColor),
                ),
              ],
            ),
          ),
          if (onEdit != null || onDelete != null) ...[
            const SizedBox(width: 8),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (onEdit != null)
                  IconButton(onPressed: onEdit, icon: const Icon(Iconsax.edit_bold, size: 20)),
                if (onDelete != null)
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Iconsax.trash_bold, color: Colors.redAccent, size: 20),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _PublicServiceFormSheet extends StatefulWidget {
  const _PublicServiceFormSheet({required this.onSubmit, this.initialValue});

  final CompanyPublicService? initialValue;
  final Future<void> Function(CompanyPublicServiceFormModel payload) onSubmit;

  @override
  State<_PublicServiceFormSheet> createState() => _PublicServiceFormSheetState();
}

class _PublicServiceFormSheetState extends State<_PublicServiceFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _priceController;
  late final TextEditingController _descriptionController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialValue?.title ?? '');
    _priceController = TextEditingController(text: widget.initialValue?.price?.toString() ?? '');
    _descriptionController = TextEditingController(text: widget.initialValue?.description ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
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
                  widget.initialValue == null ? l10n.company_public_services_add : l10n.company_public_services_edit,
                  style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: l10n.company_public_services_title),
                  validator: Validatorless.required(l10n.company_public_services_title_required),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _priceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: l10n.company_public_services_price),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(labelText: l10n.company_public_services_description),
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
                                CompanyPublicServiceFormModel(
                                  title: _titleController.text.trim(),
                                  price: _priceController.text.trim().isEmpty ? null : num.tryParse(_priceController.text.trim()),
                                  description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
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
                    child: Text(_isSubmitting ? l10n.loading : l10n.company_public_services_save),
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
