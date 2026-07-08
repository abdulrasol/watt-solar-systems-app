import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:watt/l10n/app_localizations.dart';
import 'package:watt/src/core/layout/app_breakpoints.dart';
import 'package:watt/src/core/theme/app_colors.dart';
import 'package:watt/src/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:watt/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:watt/src/features/company_dashboard/presentation/controllers/company_systems_controller.dart';
import 'package:watt/src/features/company_dashboard/presentation/widgets/company_management_widgets.dart';
import 'package:watt/src/features/company_dashboard/presentation/widgets/systems/system_card.dart';
import 'package:watt/src/shared/widgets/shared_widgets.dart';
import 'package:watt/src/utils/app_theme.dart';

/// Read-only list of solar systems this company has installed for customers.
class CompanyDashboardSystemsScreen extends ConsumerStatefulWidget {
  final bool embedded;

  const CompanyDashboardSystemsScreen({super.key, this.embedded = false});

  @override
  ConsumerState<CompanyDashboardSystemsScreen> createState() => _CompanyDashboardSystemsScreenState();
}

class _CompanyDashboardSystemsScreenState extends ConsumerState<CompanyDashboardSystemsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    final companyId = ref.read(authProvider).company?.id;
    if (companyId != null) {
      await ref.read(companySystemsProvider.notifier).fetchSystems(companyId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = ref.watch(appColorsProvider);
    final state = ref.watch(companySystemsProvider);
    final companyId = ref.watch(authProvider).company?.id;

    if (companyId == null) {
      return AdminEmptyState(icon: Iconsax.flash_1, title: l10n.systems, subtitle: l10n.company_workspace_no_company);
    }

    if (state.isLoading && state.items.isEmpty) {
      return AdminLoadingState(icon: Iconsax.flash_1, message: l10n.loading);
    }

    if (state.error != null && state.items.isEmpty) {
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
                  title: l10n.systems,
                  subtitle: l10n.section_label(l10n.systems),
                  action: Text(
                    '${state.items.length}',
                    style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w800, fontSize: 18, color: colors.textPrimary),
                  ),
                ),
                const SizedBox(height: 20),
                if (state.items.isEmpty)
                  AppEmptyState(icon: Iconsax.flash_1, title: l10n.systems, subtitle: l10n.no_data_available)
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.items.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: SystemCard(system: state.items[index]),
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
}
