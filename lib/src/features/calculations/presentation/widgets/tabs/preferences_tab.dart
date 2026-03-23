import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/calculations/presentation/providers/calculator_controller.dart';
import 'package:solar_hub/src/utils/app_explanations.dart';
import 'package:solar_hub/src/features/calculations/presentation/widgets/section_card.dart';
import 'package:solar_hub/src/features/calculations/presentation/widgets/slider_tile.dart';
import 'package:solar_hub/src/features/calculations/presentation/widgets/voltage_chips.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class SystemPreferencesTab extends ConsumerWidget {
  const SystemPreferencesTab({super.key, required this.controller});
  final CalculatorNotifier controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final explanations = AppExplanations(context).getExplanations();

    // Compute system voltage options from selected battery voltage.
    final battV = controller.systemCalcSingleBatteryVoltage;
    final voltageOptions = battV == 25.6
        ? const [24.0]
        : battV == 51.2
        ? const [48.0]
        : const [12.0, 24.0, 48.0];

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppTheme.accentColor.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: AppTheme.accentColor,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.system_wizard_desc,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white70 : Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Sliders
          SectionCard(
            icon: Icons.tune_rounded,
            title: l10n.system_parameters,
            child: Column(
              children: [
                SliderTile(
                  label: l10n.autonomy_hours,
                  value: controller.autonomyHours,
                  explanation: explanations[1],
                  min: 0,
                  max: 24,
                  divisions: 24,
                  suffix: 'h',
                  onChanged: (v) => ref
                      .read(calculatorProvider)
                      .updateField(
                        () => ref.read(calculatorProvider).autonomyHours = v,
                      ),
                ),
                const Divider(height: 24),
                SliderTile(
                  label: l10n.sun_hours,
                  value: controller.sunPeakHours,
                  explanation: explanations[2],
                  min: 2,
                  max: 10,
                  divisions: 16,
                  suffix: 'h',
                  onChanged: (v) => ref
                      .read(calculatorProvider)
                      .updateField(
                        () => ref.read(calculatorProvider).sunPeakHours = v,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Panel wattage input
          SectionCard(
            icon: Iconsax.sun_1_bold,
            title: l10n.panel_wattage,
            explanation: explanations[3],
            child: TextFormField(
              initialValue: controller.selectedPanelWattage.toString(),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                suffixText: 'W',
                hintText: '570',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (val) {
                final parsed = int.tryParse(val);
                if (parsed != null) {
                  ref
                      .read(calculatorProvider)
                      .updateField(
                        () =>
                            ref.read(calculatorProvider).selectedPanelWattage =
                                parsed,
                      );
                }
              },
            ),
          ),
          const SizedBox(height: 16),

          // Single battery voltage
          SectionCard(
            icon: Iconsax.battery_charging_bold,
            title: l10n.single_battery_voltage,
            explanation: explanations[4],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                VoltageChips(
                  options: const [12.0, 12.8, 25.6, 51.2],
                  selected: controller.systemCalcSingleBatteryVoltage,
                  onSelected: (v) {
                    ref.read(calculatorProvider).updateField(() {
                      final c = ref.read(calculatorProvider);
                      c.systemCalcSingleBatteryVoltage = v;
                      if (v == 25.6) c.systemVoltage = 24.0;
                      if (v == 51.2) c.systemVoltage = 48.0;
                    });
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.battery_type_hint,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // System voltage
          SectionCard(
            icon: Icons.flash_on_rounded,
            title: l10n.system_voltage,
            explanation: explanations[5],
            child: VoltageChips(
              options: voltageOptions,
              selected: controller.systemVoltage,
              onSelected: (v) => ref
                  .read(calculatorProvider)
                  .updateField(
                    () => ref.read(calculatorProvider).systemVoltage = v,
                  ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
