import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/theme/app_colors.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/entities/company_system.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

/// Card widget displaying an installed solar system.
class SystemCard extends ConsumerWidget {
  final CompanySystem system;

  const SystemCard({super.key, required this.system});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = ref.watch(appColorsProvider);
    final location = [system.address, system.city, system.country].where((s) => (s ?? '').isNotEmpty).join(', ');

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Iconsax.flash_1, color: colors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${system.totalPanelKw.toStringAsFixed(2)} kWp · ${system.systemType}',
                  style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 15, fontWeight: FontWeight.w700, color: colors.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 16,
            runSpacing: 6,
            children: [
              _MetaChip(label: l10n.panels, value: '${system.panelCount} × ${system.panelPower}W', colors: colors),
              _MetaChip(label: l10n.battery, value: '${system.batteryCount} × ${system.batteryPower.toStringAsFixed(1)}kWh', colors: colors),
              _MetaChip(label: l10n.inverter, value: '${system.inverterCount} × ${system.inverterPower}kW', colors: colors),
            ],
          ),
          if (location.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              location,
              style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: colors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label, required this.value, required this.colors});

  final String label;
  final String value;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 10, color: colors.textTertiary),
        ),
        Text(
          value,
          style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w700, color: colors.textPrimary),
        ),
      ],
    );
  }
}
