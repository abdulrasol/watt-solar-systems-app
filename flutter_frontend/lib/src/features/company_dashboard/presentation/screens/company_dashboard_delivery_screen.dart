import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/layout/app_breakpoints.dart';
import 'package:solar_hub/src/core/theme/app_colors.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/controllers/company_delivery_controller.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/company_management_widgets.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/delivery/delivery_option_card.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/forms/delivery_option_form_sheet.dart';
import 'package:solar_hub/src/services/toast_service.dart';
import 'package:solar_hub/src/shared/domain/company/delivery_option.dart';
import 'package:solar_hub/src/shared/widgets/shared_widgets.dart';

/// Company delivery options management screen.
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
    final colors = ref.watch(appColorsProvider);
    final state = ref.watch(companyDeliveryProvider);
    final company = ref.watch(authProvider).company;
    final companyId = company?.id;
    final canManage = company?.canManageWorkspace ?? false;

    if (companyId == null) {
      return AdminEmptyState(icon: Icons.local_shipping_outlined, title: l10n.delivery, subtitle: l10n.company_workspace_no_company);
    }

    if (state.isLoading && state.items.isEmpty) {
      return AdminLoadingState(icon: Icons.local_shipping_outlined, message: l10n.loading);
    }

    if (state.error != null && state.items.isEmpty) {
      return AdminErrorState(error: state.error!, onRetry: _load);
    }

    return RefreshIndicator(
      color: colors.primary,
      backgroundColor: colors.surface,
      onRefresh: _load,
      notificationPredicate: (notification) => notification.depth == 0,
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: AppBreakpoints.pagePadding(context).copyWith(bottom: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: AppBreakpoints.contentMaxWidth(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CompanySectionIntro(
                  title: l10n.delivery,
                  subtitle: l10n.section_label(l10n.delivery),
                  action: AppButton(
                    text: '${l10n.add} ${l10n.delivery}',
                    icon: Iconsax.add_circle,
                    onPressed: canManage ? () => _openOptionSheet(context, companyId) : null,
                    width: null,
                  ),
                ),
                const SizedBox(height: 20),
                if (state.items.isEmpty)
                  AppEmptyState(
                    icon: Icons.local_shipping_outlined,
                    title: l10n.delivery,
                    subtitle: l10n.no_data_available,
                    actionTitle: canManage ? '${l10n.add} ${l10n.delivery}' : null,
                    onActionPressed: canManage ? () => _openOptionSheet(context, companyId) : null,
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.items.length,
                    itemBuilder: (context, index) {
                      final option = state.items[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: DeliveryOptionCard(
                          option: option,
                          onDelete: canManage ? () => _deleteOption(context, companyId, option) : null,
                        ),
                      );
                    },
                  ),
                if (state.isLoadingMore)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: AppLoadingIndicator(size: 24)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _deleteOption(BuildContext context, int companyId, DeliveryOption option) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showCompanyDeleteDialog(
      context: context,
      title: l10n.delete,
      message: l10n.company_delivery_delete_message(option.name),
    );
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
      builder: (context) => DeliveryOptionFormSheet(
        onSubmit: (payload) async {
          await ref.read(companyDeliveryProvider.notifier).createOption(companyId, payload);
        },
      ),
    );
  }
}
