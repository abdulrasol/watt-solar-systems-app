import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/layout/app_breakpoints.dart';
import 'package:solar_hub/src/core/theme/app_colors.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/controllers/company_categories_controller.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/categories/category_chip.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/company_management_widgets.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/forms/category_form_sheet.dart';
import 'package:solar_hub/src/services/toast_service.dart';
import 'package:solar_hub/src/shared/domain/company/company_category.dart';
import 'package:solar_hub/src/shared/widgets/shared_widgets.dart';

/// Company product categories management screen.
class CompanyDashboardCategoriesScreen extends ConsumerStatefulWidget {
  final bool embedded;

  const CompanyDashboardCategoriesScreen({super.key, this.embedded = false});

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
    final colors = ref.watch(appColorsProvider);
    final state = ref.watch(companyCategoriesProvider);
    final company = ref.watch(authProvider).company;
    final companyId = company?.id;
    final canManage = company?.canManageWorkspace ?? false;

    if (companyId == null) {
      return AdminEmptyState(icon: Iconsax.tag, title: l10n.categories, subtitle: l10n.company_categories_no_company);
    }

    if (state.isLoading && state.categories.isEmpty) {
      return AdminLoadingState(icon: Iconsax.tag, message: l10n.company_categories_loading);
    }

    if (state.error != null && state.categories.isEmpty) {
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
                  title: l10n.categories,
                  subtitle: l10n.company_categories_subtitle,
                  action: AppButton(
                    text: l10n.company_categories_add,
                    icon: Iconsax.add_circle,
                    onPressed: canManage ? () => _openCategorySheet(context, companyId) : null,
                    width: null,
                  ),
                ),
                const SizedBox(height: 20),
                if (state.categories.isEmpty)
                  AppEmptyState(
                    icon: Iconsax.tag,
                    title: l10n.company_categories_empty_title,
                    subtitle: l10n.company_categories_empty_subtitle,
                    actionTitle: canManage ? l10n.company_categories_add : null,
                    onActionPressed: canManage ? () => _openCategorySheet(context, companyId) : null,
                  )
                else
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      for (final category in state.categories)
                        CategoryChip(
                          category: category,
                          onDelete: canManage ? () => _deleteCategory(context, companyId, category) : null,
                        ),
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
      builder: (context) => CategoryFormSheet(
        onSubmit: (payload) async {
          await ref.read(companyCategoriesProvider.notifier).createCategory(companyId, payload);
        },
      ),
    );
  }
}
