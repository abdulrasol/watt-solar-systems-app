import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/layout/app_breakpoints.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:solar_hub/src/shared/domain/company/company_category.dart';
import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/models/company_category_form_model.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/controllers/company_categories_controller.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/company_management_widgets.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/company_page_scaffold.dart';
import 'package:solar_hub/src/services/toast_service.dart';
import 'package:solar_hub/src/utils/app_theme.dart';
import 'package:validatorless/validatorless.dart';

class CompanyDashboardCategoriesScreen extends ConsumerStatefulWidget {
  const CompanyDashboardCategoriesScreen({super.key});

  @override
  ConsumerState<CompanyDashboardCategoriesScreen> createState() => _CompanyDashboardCategoriesScreenState();
}

class _CompanyDashboardCategoriesScreenState extends ConsumerState<CompanyDashboardCategoriesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    final companyId = ref.read(authProvider).company?.id;
    if (companyId != null) {
      await ref.read(companyCategoriesProvider.notifier).fetchCategories(companyId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(companyCategoriesProvider);
    final company = ref.watch(authProvider).company;
    final companyId = company?.id;
    final canManage = company?.canManageWorkspace ?? false;

    return CompanyPageScaffold(
      child: companyId == null
          ? AdminEmptyState(icon: Iconsax.tag_bold, title: l10n.categories, subtitle: l10n.company_categories_no_company)
          : state.isLoading && state.categories.isEmpty
          ? AdminLoadingState(icon: Iconsax.tag_bold, message: l10n.company_categories_loading)
          : state.error != null && state.categories.isEmpty
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
                        title: l10n.categories,
                        subtitle: l10n.company_categories_subtitle,
                        action: FilledButton.icon(
                          onPressed: canManage ? () => _openCategorySheet(context, companyId) : null,
                          icon: const Icon(Iconsax.add_circle_bold),
                          label: Text(l10n.company_categories_add),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (state.categories.isEmpty)
                        AdminEmptyState(icon: Iconsax.tag_bold, title: l10n.company_categories_empty_title, subtitle: l10n.company_categories_empty_subtitle)
                      else
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            for (final category in state.categories)
                              _CategoryChip(category: category, onDelete: canManage ? () => _deleteCategory(context, companyId, category) : null),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Future<void> _deleteCategory(BuildContext context, int companyId, CompanyCategory category) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showCompanyDeleteDialog(
      context: context,
      title: l10n.company_categories_delete_title,
      message: l10n.company_categories_delete_message(category.name),
    );
    if (confirmed != true || !mounted) return;

    try {
      await ref.read(companyCategoriesProvider.notifier).deleteCategory(companyId, category.id);
      if (!context.mounted) return;
      ToastService.success(context, l10n.success, l10n.company_categories_deleted);
    } catch (e) {
      if (!context.mounted) return;
      ToastService.error(context, l10n.error, e.toString());
    }
  }

  Future<void> _openCategorySheet(BuildContext context, int companyId) async {
    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CategoryFormSheet(
        onSubmit: (payload) async {
          await ref.read(companyCategoriesProvider.notifier).createCategory(companyId, payload);
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category, required this.onDelete});

  final CompanyCategory category;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            category.name,
            style: const TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 10),
          InkWell(
            onTap: onDelete,
            child: const Icon(Iconsax.close_circle_bold, color: Colors.redAccent),
          ),
        ],
      ),
    );
  }
}

class _CategoryFormSheet extends StatefulWidget {
  const _CategoryFormSheet({required this.onSubmit});

  final Future<void> Function(CompanyCategoryFormModel payload) onSubmit;

  @override
  State<_CategoryFormSheet> createState() => _CategoryFormSheetState();
}

class _CategoryFormSheetState extends State<_CategoryFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
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
                  l10n.company_categories_add,
                  style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: l10n.company_categories_name),
                  validator: Validatorless.required(l10n.company_categories_name_required),
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
                              await widget.onSubmit(CompanyCategoryFormModel(name: _nameController.text.trim()));
                              if (!mounted) return;
                              Navigator.of(this.context).pop();
                            } finally {
                              if (mounted) {
                                setState(() => _isSubmitting = false);
                              }
                            }
                          },
                    child: Text(_isSubmitting ? l10n.loading : l10n.company_categories_save),
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
