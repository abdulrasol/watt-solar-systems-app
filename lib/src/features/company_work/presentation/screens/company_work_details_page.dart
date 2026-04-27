import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/widgets/pre_scaffold.dart';
import 'package:solar_hub/src/features/company_work/domain/entities/company_work.dart';
import 'package:solar_hub/src/features/company_work/presentation/providers/company_work_provider.dart';
import 'package:solar_hub/src/features/company_work/presentation/widgets/work_gallery_sheet.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/company_management_widgets.dart';
import 'package:solar_hub/src/services/toast_service.dart';

class CompanyWorkDetailsPage extends ConsumerWidget {
  const CompanyWorkDetailsPage({
    super.key,
    required this.workId,
    this.initialWork,
  });

  final int workId;
  final CompanyWork? initialWork;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(companyWorkNotifierProvider);
    final work = initialWork ?? state.byId(workId);

    if (work == null) {
      return PreScaffold(
        title: l10n.company_work_title,
        child: Center(child: Text(l10n.company_work_not_found)),
      );
    }

    return PreScaffold(
      title: work.title,
      actions: [
        IconButton(
          onPressed: () =>
              context.push('/company-work/edit/${work.id}', extra: work),
          icon: const Icon(Icons.edit_outlined),
        ),
        IconButton(
          onPressed: () => _delete(context, ref, work.id),
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
        ),
      ],
      child: WorkGallerySheet(work: work, embedded: true),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, int workId) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showCompanyDeleteDialog(
      context: context,
      title: l10n.company_work_delete_title,
      message: l10n.company_work_delete_message,
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(companyWorkNotifierProvider.notifier).deleteWork(workId);
      if (!context.mounted) return;
      ToastService.success(context, l10n.success, l10n.company_work_deleted);
      context.pop();
    } catch (e) {
      if (!context.mounted) return;
      ToastService.error(context, l10n.error, e.toString());
    }
  }
}
