import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/layout/app_breakpoints.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/entities/company_system.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/controllers/company_systems_controller.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/company_management_widgets.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/company_page_scaffold.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

/// Read-only list of solar systems this company has installed for
/// customers. There's no create/edit/delete here by design — systems are
/// created through the customer-facing self-service `/systems/` endpoints,
/// not by the installing company (confirmed by reading the backend: the
/// only company-scoped systems endpoint is this one GET).
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
    final state = ref.watch(companySystemsProvider);
    final companyId = ref.watch(authProvider).company?.id;

    final content = companyId == null
        ? AdminEmptyState(icon: Iconsax.flash_1, title: l10n.systems, subtitle: l10n.company_workspace_no_company)
        : state.isLoading && state.items.isEmpty
        ? AdminLoadingState(icon: Iconsax.flash_1, message: l10n.loading)
        : state.error != null && state.items.isEmpty
        ? AdminErrorState(error: state.error!, onRetry: _load)
        : RefreshIndicator(
            onRefresh: _load,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: AppBreakpoints.pagePadding(context),
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
                          style: const TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w800, fontSize: 18),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (state.items.isEmpty)
                        AdminEmptyState(icon: Iconsax.flash_1, title: l10n.systems, subtitle: l10n.no_data_available)
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.items.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: _SystemCard(system: state.items[index]),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );

    if (widget.embedded) {
      return content;
    }

    return CompanyPageScaffold(child: content);
  }
}

class _SystemCard extends StatelessWidget {
  const _SystemCard({required this.system});

  final CompanySystem system;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final location = [system.address, system.city, system.country].where((s) => (s ?? '').isNotEmpty).join(', ');
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
                child: const Icon(Iconsax.flash_1, color: AppTheme.primaryColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${system.totalPanelKw.toStringAsFixed(2)} kWp · ${system.systemType}',
                  style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 16,
            runSpacing: 6,
            children: [
              _MetaChip(label: l10n.panels, value: '${system.panelCount} × ${system.panelPower}W'),
              _MetaChip(label: l10n.battery, value: '${system.batteryCount} × ${system.batteryPower.toStringAsFixed(1)}kWh'),
              _MetaChip(label: l10n.inverter, value: '${system.inverterCount} × ${system.inverterPower}kW'),
            ],
          ),
          if (location.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              location,
              style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: Theme.of(context).hintColor),
            ),
          ],
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, color: Theme.of(context).hintColor),
        ),
        Text(
          value,
          style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
