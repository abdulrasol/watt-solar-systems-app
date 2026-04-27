import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/layout/app_breakpoints.dart';
import 'package:solar_hub/src/core/widgets/pre_scaffold.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:solar_hub/src/features/company_work/presentation/providers/company_work_provider.dart';
import 'package:solar_hub/src/features/company_work/presentation/widgets/company_work_card.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/company_management_widgets.dart';
import 'package:solar_hub/src/services/toast_service.dart';

class CompanyWorkPage extends ConsumerStatefulWidget {
  const CompanyWorkPage({super.key});

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

    return PreScaffold(
      title: l10n.company_work_title,
      actions: [
        IconButton(
          onPressed: () => context.push('/company-work/add'),
          icon: const Icon(Icons.add_circle_outline_rounded),
          tooltip: l10n.company_work_add,
        ),
      ],
      child: RefreshIndicator(
        onRefresh: () => ref
            .read(companyWorkNotifierProvider.notifier)
            .fetchWorks(isRefresh: true),
        child: state.isLoading && state.works.isEmpty
            ? Center(
                child: AdminLoadingState(
                  icon: Icons.work_outline_rounded,
                  message: l10n.company_work_loading,
                ),
              )
            : state.error != null && state.works.isEmpty
            ? Center(
                child: AdminErrorState(
                  error: state.error!,
                  onRetry: () => ref
                      .read(companyWorkNotifierProvider.notifier)
                      .fetchWorks(isRefresh: true),
                ),
              )
            : state.works.isEmpty
            ? ListView(
                children: [
                  SizedBox(height: 80.h),
                  AdminEmptyState(
                    icon: Icons.work_outline_rounded,
                    title: l10n.company_work_empty_title,
                    subtitle: l10n.company_work_empty_subtitle,
                  ),
                ],
              )
            : GridView.builder(
                controller: _scrollController,
                padding: AppBreakpoints.pagePadding(context),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: AppBreakpoints.adaptiveGridCount(
                    context,
                    mobile: 1,
                    tablet: 2,
                    desktop: 3,
                  ),
                  crossAxisSpacing: 16.r,
                  mainAxisSpacing: 16.r,
                  childAspectRatio: AppBreakpoints.isMobile(context)
                      ? 0.95
                      : 0.84,
                ),
                itemCount: state.works.length + (state.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == state.works.length) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final work = state.works[index];
                  return CompanyWorkCard(
                    work: work,
                    onTap: () =>
                        context.push('/company-work/${work.id}', extra: work),
                    onEdit: () => context.push(
                      '/company-work/edit/${work.id}',
                      extra: work,
                    ),
                    onDelete: () => _deleteWork(context, work.id),
                  );
                },
              ),
      ),
    );
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
