import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_hub/src/features/calculations/presentation/providers/calculator_controller.dart';
import 'package:solar_hub/src/features/calculations/presentation/widgets/calculator_widgets.dart';
import 'package:solar_hub/src/features/calculations/presentation/widgets/explanation_button.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

import 'package:solar_hub/src/utils/app_explanations.dart';
import 'package:solar_hub/l10n/app_localizations.dart';

class PumpCalculator extends ConsumerStatefulWidget {
  const PumpCalculator({super.key});

  @override
  ConsumerState<PumpCalculator> createState() => _PumpCalculatorState();
}

class _PumpCalculatorState extends ConsumerState<PumpCalculator> {
  late final CalculatorNotifier controller;

  @override
  void initState() {
    super.initState();
    controller = ref.read(calculatorProvider);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(calculatorProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.pump_calc),
        actions: [ExplanationButton(explanations: AppExplanations(context).getPumpExplanations(), storageKey: 'pump_calc_help_viewed')],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Hero(
              tag: 'pump_hero',
              child: Icon(Icons.water_drop, size: 80, color: Colors.blueAccent),
            ),
            const SizedBox(height: 20),
            Text(l10n.pump_calc_intro, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 30),

            // Inputs
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CalcInputRow(
                    label: l10n.daily_water_volume,
                    suffix: "m³",
                    hint: "e.g. 10 (10000 L)",
                    initialValue: controller.pumpDailyWater,
                    onChanged: (v) {
                      controller.pumpDailyWater = double.tryParse(v) ?? 0;
                      controller.calculatePump();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ExplanationButton(explanations: [AppExplanations(context).getPumpExplanations()[0]]),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CalcInputRow(
                    label: l10n.total_dynamic_head,
                    suffix: "m",
                    hint: "e.g. 50 (Vertical + Friction)",
                    initialValue: controller.pumpTDH,
                    onChanged: (v) {
                      controller.pumpTDH = double.tryParse(v) ?? 0;
                      controller.calculatePump();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ExplanationButton(explanations: [AppExplanations(context).getPumpExplanations()[1]]),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CalcInputRow(
                    label: l10n.pumping_hours,
                    suffix: "h",
                    hint: "e.g. 6",
                    initialValue: controller.pumpDailyHours,
                    onChanged: (v) {
                      controller.pumpDailyHours = double.tryParse(v) ?? 0;
                      controller.calculatePump();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ExplanationButton(explanations: [AppExplanations(context).getPumpExplanations()[2]]),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CalcInputRow(
                    label: l10n.location_peak_sun_hours,
                    suffix: "h",
                    hint: "e.g. 5",
                    initialValue: controller.pumpPeakSunHours,
                    onChanged: (v) {
                      controller.pumpPeakSunHours = double.tryParse(v) ?? 0;
                      controller.calculatePump();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ExplanationButton(explanations: [AppExplanations(context).getPumpExplanations()[3]]),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CalcInputRow(
                    label: l10n.solar_panel_wattage,
                    suffix: "W",
                    hint: "e.g. 550",
                    initialValue: controller.pumpPanelWattage,
                    onChanged: (v) {
                      controller.pumpPanelWattage = double.tryParse(v) ?? 0;
                      controller.calculatePump();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ExplanationButton(explanations: [AppExplanations(context).getPanelExplanations()[2]]),
              ],
            ),

            // Pump Efficiency Slider
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.pump_efficiency, style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("${(controller.pumpEfficiency * 100.toInt())}%"),
                  ],
                ),
                Slider(
                  value: controller.pumpEfficiency,
                  min: 0.1,
                  max: 0.9,
                  divisions: 80,
                  label: "${(controller.pumpEfficiency * 100.toInt())}%",
                  onChanged: (v) {
                    controller.pumpEfficiency = v;
                    controller.calculatePump();
                  },
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Results
            ResultCard(
              title: l10n.required_solar_panels,
              value: "${controller.pumpRequiredPanelCount}",
              subtitle: "Total Array: ${controller.pumpRequiredPanelKw.toStringAsFixed(2)} kWp",
              icon: Icons.solar_power,
              color: Colors.orange,
            ),

            const SizedBox(height: 16),
            ResultCard(
              title: l10n.hydraulic_power_est,
              value: "${(controller.pumpHydraulicPowerW / 1000).toStringAsFixed(2)} kW", // Display kW
              subtitle: l10n.motor_hp_estimate((controller.pumpHydraulicPowerW / 745.7).toStringAsFixed(1)),
              icon: Icons.settings,
              color: Colors.blueGrey,
            ),

            const SizedBox(height: 20),
            // Educational Hint
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.definitions,
                    style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                  ),
                  const SizedBox(height: 10),
                  _buildDefinitionRow(l10n.total_dynamic_head, l10n.definition_tdh),
                  _buildDefinitionRow(l10n.flow_rate, l10n.definition_flow_rate),
                  _buildDefinitionRow(l10n.peak_sun_hours, l10n.definition_psh),
                  _buildDefinitionRow(l10n.hydraulic_power, l10n.definition_hydraulic_power),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefinitionRow(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("• $title:", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Text(desc, style: const TextStyle(fontSize: 12, height: 1.4, color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  // Note: old _showHelpDialog method removed because it's replaced by the ExplanationButton.
}
