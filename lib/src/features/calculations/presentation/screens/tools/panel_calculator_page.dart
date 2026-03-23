import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/src/features/calculations/presentation/providers/calculator_controller.dart';
import 'package:solar_hub/src/features/calculations/presentation/widgets/calculator_widgets.dart';
import 'package:solar_hub/src/features/calculations/presentation/widgets/explanation_button.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

import 'package:solar_hub/src/utils/app_explanations.dart';
import 'package:get_storage/get_storage.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/calculations/presentation/widgets/explanation_dialog.dart';

class PanelCalculatorPage extends ConsumerStatefulWidget {
  const PanelCalculatorPage({super.key});

  @override
  ConsumerState<PanelCalculatorPage> createState() => _PanelCalculatorPageState();
}

class _PanelCalculatorPageState extends ConsumerState<PanelCalculatorPage> {
  late final CalculatorNotifier controller;

  @override
  void initState() {
    super.initState();
    controller = ref.read(calculatorProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final box = GetStorage();
      if (box.read('panel_calc_help_viewed') != true) {
        _showHelpDialog();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(calculatorProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.panels_calc),
        actions: [ExplanationButton(explanations: AppExplanations(context).getPanelExplanations(), storageKey: 'panel_calc_help_viewed')],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Hero(
              tag: 'panel_hero',
              child: Icon(Iconsax.sun_1_bold, size: 80, color: Colors.orange),
            ),
            const SizedBox(height: 20),
            Text(l10n.panel_calc_intro, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 30),

            // Inputs
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CalcInputRow(
                    label: l10n.total_daily_usage,
                    suffix: "Ah", // TODO: translate
                    hint: l10n.example_100_or_200,
                    onChanged: (v) {
                      controller.panelCalcDailyUsage = double.tryParse(v) ?? 0;
                      controller.calculatePanels();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ExplanationButton(explanations: [AppExplanations(context).getPanelExplanations()[0]]),
              ],
            ),

            // Voltage Selection
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(l10n.system_voltage, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  DropdownButton<double>(
                    value: controller.panelCalcVoltage,
                    items: [
                      12.0,
                      24.0,
                      48.0,
                      110.0,
                      220.0,
                      230.0,
                      380.0,
                    ].map((e) => DropdownMenuItem(value: e, child: Text("${e.toStringAsFixed(0)} V"))).toList(),
                    onChanged: (v) {
                      controller.panelCalcVoltage = v ?? 12.0;
                      controller.calculatePanels();
                    },
                  ),
                  const SizedBox(width: 8),
                  ExplanationButton(explanations: [AppExplanations(context).getPanelExplanations()[1]]),
                ],
              ),
            ),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CalcInputRow(
                    label: l10n.panel_wattage,
                    suffix: "W",
                    initialValue: 450,
                    onChanged: (v) {
                      controller.panelCalcWattage = double.tryParse(v) ?? 0;
                      controller.calculatePanels();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ExplanationButton(explanations: [AppExplanations(context).getPanelExplanations()[2]]),
              ],
            ),

            // Efficiency Slider
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(l10n.system_efficiency_loss_factor, style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text("${(controller.panelCalcEfficiency * 100).toInt()}%"),
                            ],
                          ),
                          Slider(
                            value: controller.panelCalcEfficiency,
                            min: 0.65,
                            max: 1.0,
                            divisions: 35,
                            label: "${(controller.panelCalcEfficiency * 100).toInt()}%",
                            onChanged: (v) {
                              controller.panelCalcEfficiency = v;
                              controller.calculatePanels();
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ExplanationButton(explanations: [AppExplanations(context).getPanelExplanations()[3]]),
                  ],
                ),

                const SizedBox(height: 30),

                // Result
                ResultCard(
                  title: l10n.required_panels,
                  value: "${controller.panelCalcResult}",
                  subtitle: l10n.total_array_kw((controller.panelCalcTotalWattage / 1000).toStringAsFixed(2)),
                  icon: Iconsax.sun_1_bold,
                  color: Colors.amber,
                ),

                const SizedBox(height: 20),
                // Educational Hint
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.did_you_know,
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                      ),
                      const SizedBox(height: 5),
                      Text(l10n.panel_calc_tip_text, style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog() {
    final explanations = AppExplanations(context).getPanelExplanations();
    ExplanationDialog.show(context, explanations: explanations, showDontShowAgain: true, storageKey: 'panel_calc_help_viewed');
  }
}
