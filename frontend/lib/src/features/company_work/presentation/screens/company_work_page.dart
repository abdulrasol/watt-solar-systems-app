import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/layout/app_breakpoints.dart';
import 'package:solar_hub/src/core/theme/app_colors.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/providers/summary_provider.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/company_management_widgets.dart';
import 'package:solar_hub/src/features/company_work/domain/entities/company_work.dart';
import 'package:solar_hub/src/features/company_work/presentation/providers/company_work_provider.dart';
import 'package:solar_hub/src/features/company_work/presentation/widgets/company_work_card.dart';
import 'package:solar_hub/src/features/company_work/presentation/widgets/company_work_page_header.dart';
import 'package:solar_hub/src/services/toast_service.dart';
import 'package:solar_hub/src/shared/widgets/shared_widgets.dart';
import 'package:solar_hub/src/utils/app_strings.dart';

/// List screen for company works (portfolio/showcase).
///
/// Can be used standalone (with its own scaffold) or embedded inside the
/// company dashboard shell.
class CompanyWorkPage extends ConsumerStatefulWidget {
  final bool embedded;

  const CompanyWorkPage({super.key, this.embedded = false});

  @override
  ConsumerState<CompanyWorkPage> createState() => _CompanyWorkPageState();
}

class _CompanyWorkPageState extends ConsumerState<CompanyWorkPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 300) {
      ref.read(companyWorkNotifierProvider.notifier).nextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(companyWorkNotifierProvider);
    final summaryState = ref.watch(companySummaryProvider);
    final hasWritePermission = summaryState.hasWritePermission(AppStrings.projectsPermission);

    final content = _buildBody(context, l10n, state, hasWritePermission);

    if (widget.embedded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CompanyWorkPageHeader(hasWritePermission: hasWritePermission),
          const SizedBox(height: 20),
          Expanded(child: content),
        ],
      );
    }

    return BaseScreen(
      title: l10n.company_work_title,
      actions: hasWritePermission
          ? [
              AppButton(
                text: l10n.company_work_add,
                icon: Iconsax.add_circle,
                variant: AppButtonVariant.secondary,
                onPressed: () => context.push('/company-work/add'),
              ),
            ]
          : null,
      child: content,
    );
  }

  Widget _buildBody(
    BuildContext context,
    AppLocalizations l10n,
    CompanyWorkState state,
    bool hasWritePermission,
  ) {
    if (state.isLoading && state.works.isEmpty) {
      return const AppLoadingOverlay();
    }

    if (state.error != null && state.works.isEmpty) {
      return AppErrorState(
        subtitle: state.error!,
        onRetry: () => ref.read(companyWorkNotifierProvider.notifier).fetchWorks(isRefresh: true),
      );
    }

    if (state.works.isEmpty) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: AppBreakpoints.pagePadding(context).copyWith(top: 80),
          child: AppEmptyState(
            icon: Iconsax.gallery,
            title: l10n.company_work_empty_title,
            subtitle: l10n.company_work_empty_subtitle,
            actionTitle: hasWritePermission ? l10n.company_work_add : null,
            onActionPressed: hasWritePermission ? () => _navigateToAdd(context) : null,
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: ref.watch(appColorsProvider).primary,
      backgroundColor: ref.watch(appColorsProvider).surface,
      onRefresh: () => ref.read(companyWorkNotifierProvider.notifier).fetchWorks(isRefresh: true),
      child: GridView.builder(
        controller: _scrollController,
        padding: AppBreakpoints.pagePadding(context),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: AppBreakpoints.adaptiveGridCount(
            context,
            mobile: 1,
            tablet: 2,
            desktop: 3,
          ),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: AppBreakpoints.isMobile(context) ? 0.95 : 0.84,
        ),
        itemCount: state.works.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.works.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: AppLoadingIndicator(size: 24)),
            );
          }

          final work = state.works[index];
          return CompanyWorkCard(
            work: work,
            onTap: () => context.push('/company-work/${work.id}', extra: work),
            onEdit: hasWritePermission ? () => _navigateToEdit(context, work) : null,
            onDelete: hasWritePermission ? () => _deleteWork(context, work.id) : null,
          );
        },
      ),
    );
  }

  void _navigateToAdd(BuildContext context) {
    final route = widget.embedded
        ? '/companies/dashboard/content/works/add'
        : '/company-work/add';
    context.push(route);
  }

  void _navigateToEdit(BuildContext context, CompanyWork work) {
    final route = widget.embedded
        ? '/companies/dashboard/content/works/edit/${work.id}'
        : '/company-work/edit/${work.id}';
    context.push(route, extra: work);
  }

  Future<void> _deleteWork(BuildContext context, int workId) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showCompanyDeleteDialog(
      context: context,
      title: l10n.company_work_delete_title,
      message: l10n.company_work_delete_message,
    );

    if (confirmed != true || !mounted) return;

    try {
      await ref.read(companyWorkNotifierProvider.notifier).deleteWork(workId);
      if (!context.mounted) return;
      ToastService.success(context, l10n.success, l10n.company_work_deleted);
    } catch (e) {
      if (!context.mounted) return;
      ToastService.error(context, l10n.error, e.toString());
    }
  }
}
