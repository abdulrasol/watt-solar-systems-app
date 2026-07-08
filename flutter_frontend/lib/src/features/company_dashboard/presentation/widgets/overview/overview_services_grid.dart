import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:watt/l10n/app_localizations.dart';
import 'package:watt/src/core/theme/app_colors.dart';
import 'package:watt/src/features/company_dashboard/presentation/widgets/company_workspace_service_card.dart';
import 'package:watt/src/utils/app_theme.dart';

/// Responsive services grid displayed on the company dashboard overview page.
class OverviewServicesGrid extends ConsumerWidget {
  final dynamic summary;
  final dynamic company;

  const OverviewServicesGrid({super.key, required this.summary, required this.company});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = ref.watch(appColorsProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final services = [...?summary?.services];
        final preview = services.take(width >= 1100 ? 4 : 2).toList();

        if (preview.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.border),
            ),
            child: Column(
              children: [
                Icon(Iconsax.category, size: 48, color: colors.textTertiary),
                const SizedBox(height: 12),
                Text(
                  l10n.services,
                  style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 16, fontWeight: FontWeight.w700, color: colors.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.section_label(l10n.services),
                  style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: colors.textSecondary),
                ),
              ],
            ),
          );
        }

        final columns = width >= 1180 ? 5 : width >= 760 ? 3 : 2;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: preview.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: columns == 2 ? 0.75 : 1.0,
          ),
          itemBuilder: (context, index) {
            return CompanyWorkspaceServiceCard(
              service: preview[index],
              companyId: company?.id,
              canManageActions: company?.canManageWorkspace ?? false,
            );
          },
        );
      },
    );
  }
}
