import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/layout/app_breakpoints.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:solar_hub/src/shared/domain/company/delivery_option.dart';
import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/models/delivery_option_form_model.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/controllers/company_delivery_controller.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/company_management_widgets.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/company_page_scaffold.dart';
import 'package:solar_hub/src/services/toast_service.dart';
import 'package:solar_hub/src/utils/app_theme.dart';
import 'package:validatorless/validatorless.dart';

class CompanyDashboardDeliveryScreen extends ConsumerStatefulWidget {
  final bool embedded;
  const CompanyDashboardDeliveryScreen({super.key, this.embedded = false});

  @override
  ConsumerState<CompanyDashboardDeliveryScreen> createState() => _CompanyDashboardDeliveryScreenState();
}

class _CompanyDashboardDeliveryScreenState extends ConsumerState<CompanyDashboardDeliveryScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final threshold = _scrollController.position.maxScrollExtent - 300;
    if (_scrollController.position.pixels >= threshold) {
      final companyId = ref.read(authProvider).company?.id;
      if (companyId != null) {
        ref.read(companyDeliveryProvider.notifier).fetchNextPage(companyId);
      }
    }
  }

  Future<void> _load() async {
    final companyId = ref.read(authProvider).company?.id;
    if (companyId != null) {
      await ref.read(companyDeliveryProvider.notifier).fetchFirstPage(companyId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(companyDeliveryProvider);
    final company = ref.watch(authProvider).company;
    final companyId = company?.id;
    final canManage = company?.canManageWorkspace ?? false;

    final content = companyId == null
        ? AdminEmptyState(icon: Icons.local_shipping_outlined, title: l10n.delivery, subtitle: l10n.company_workspace_no_company)
        : state.isLoading && state.items.isEmpty
        ? AdminLoadingState(icon: Icons.local_shipping_outlined, message: l10n.loading)
        : state.error != null && state.items.isEmpty
        ? AdminErrorState(error: state.error!, onRetry: _load)
        : SingleChildScrollView(
            controller: _scrollController,
            padding: AppBreakpoints.pagePadding(context),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: AppBreakpoints.contentMaxWidth(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CompanySectionIntro(
                      title: l10n.delivery,
                      subtitle: l10n.section_label(l10n.delivery),
                      action: FilledButton.icon(
                        onPressed: canManage ? () => _openOptionSheet(context, companyId) : null,
                        icon: const Icon(Iconsax.add_circle),
                        label: Text('${l10n.add} ${l10n.delivery}'),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (state.items.isEmpty)
                      AdminEmptyState(icon: Icons.local_shipping_outlined, title: l10n.delivery, subtitle: l10n.no_data_available)
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.items.length,
                        itemBuilder: (context, index) {
                          final option = state.items[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: _DeliveryOptionCard(option: option, onDelete: canManage ? () => _deleteOption(context, companyId, option) : null),
                          );
                        },
                      ),
                    if (state.isLoadingMore)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                  ],
                ),
              ),
            ),
          );

    if (widget.embedded) {
      return content;
    }

    return CompanyPageScaffold(child: content);
  }

  Future<void> _deleteOption(BuildContext context, int companyId, DeliveryOption option) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showCompanyDeleteDialog(context: context, title: l10n.delete, message: l10n.company_delivery_delete_message(option.name));
    if (confirmed != true || !mounted) return;

    try {
      await ref.read(companyDeliveryProvider.notifier).deleteOption(companyId, option.id);
      if (!context.mounted) return;
      ToastService.success(context, l10n.success, l10n.delete);
    } catch (e) {
      if (!context.mounted) return;
      ToastService.error(context, l10n.error, e.toString());
    }
  }

  Future<void> _openOptionSheet(BuildContext context, int companyId) async {
    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DeliveryOptionFormSheet(
        onSubmit: (payload) async {
          await ref.read(companyDeliveryProvider.notifier).createOption(companyId, payload);
        },
      ),
    );
  }
}

class _DeliveryOptionCard extends StatelessWidget {
  const _DeliveryOptionCard({required this.option, required this.onDelete});

  final DeliveryOption option;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasDaysRange = option.estimatedDaysMin != null || option.estimatedDaysMax != null;
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
                child: const Icon(Icons.local_shipping_outlined, color: AppTheme.primaryColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  option.name,
                  style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              if (!option.isActive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                  child: Text(l10n.status, style: TextStyle(fontSize: 10, color: Colors.grey[700])),
                ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Iconsax.trash, color: Colors.redAccent),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${l10n.cost}: ${option.cost.toStringAsFixed(2)}',
            style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: Theme.of(context).hintColor),
          ),
          if (hasDaysRange) ...[
            const SizedBox(height: 4),
            Text(
              '${l10n.company_delivery_estimated_days_min}: ${option.estimatedDaysMin ?? '-'}   ${l10n.company_delivery_estimated_days_max}: ${option.estimatedDaysMax ?? '-'}',
              style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: Theme.of(context).hintColor),
            ),
          ],
          if ((option.description ?? '').isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              option.description!,
              style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: Theme.of(context).hintColor),
            ),
          ],
        ],
      ),
    );
  }
}

class _DeliveryOptionFormSheet extends StatefulWidget {
  const _DeliveryOptionFormSheet({required this.onSubmit});

  final Future<void> Function(DeliveryOptionFormModel payload) onSubmit;

  @override
  State<_DeliveryOptionFormSheet> createState() => _DeliveryOptionFormSheetState();
}

class _DeliveryOptionFormSheetState extends State<_DeliveryOptionFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _costController = TextEditingController();
  final _minDaysController = TextEditingController();
  final _maxDaysController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _costController.dispose();
    _minDaysController.dispose();
    _maxDaysController.dispose();
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
                  '${l10n.add} ${l10n.delivery}',
                  style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: l10n.name),
                  validator: Validatorless.required(l10n.required_field),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _costController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: l10n.cost),
                  validator: Validatorless.multiple([Validatorless.required(l10n.required_field), Validatorless.number(l10n.required_field)]),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _minDaysController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: l10n.company_delivery_estimated_days_min),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _maxDaysController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: l10n.company_delivery_estimated_days_max),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(labelText: l10n.description),
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
                                DeliveryOptionFormModel(
                                  name: _nameController.text.trim(),
                                  cost: double.tryParse(_costController.text.trim()) ?? 0,
                                  estimatedDaysMin: int.tryParse(_minDaysController.text.trim()),
                                  estimatedDaysMax: int.tryParse(_maxDaysController.text.trim()),
                                  description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
                                ),
                              );
                              if (!mounted) return;
                              Navigator.of(this.context).pop();
                            } finally {
                              if (mounted) setState(() => _isSubmitting = false);
                            }
                          },
                    child: Text(_isSubmitting ? l10n.loading : l10n.save),
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
