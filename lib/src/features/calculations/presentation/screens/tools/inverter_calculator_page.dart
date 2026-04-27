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

class InverterCalculatorPage extends ConsumerStatefulWidget {
  const InverterCalculatorPage({super.key});

  @override
  ConsumerState<InverterCalculatorPage> createState() =>
      _InverterCalculatorPageState();
}

class _InverterCalculatorPageState
    extends ConsumerState<InverterCalculatorPage> {
  late final CalculatorNotifier controller;

  @override
  void initState() {
    super.initState();
    controller = ref.read(calculatorProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final box = GetStorage();
      if (box.read('inverter_calc_help_viewed') != true) {
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
        title: Text(l10n.inverter_calc),
        actions: [
          ExplanationButton(
            explanations: AppExplanations(context).getInverterExplanations(),
            storageKey: 'inverter_calc_help_viewed',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Hero(
              tag: 'inverter_hero',
              child: Icon(
                Iconsax.flash_bold,
                size: 80,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.inverter_calc_intro,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 30),

            // Inputs
            // Inputs
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CalcInputRow(
                    label: l10n.total_load_amps,
                    suffix: l10n.amps,
                    hint: l10n.example_10,
                    initialValue: controller.inverterCalcAmps,
                    onChanged: (v) {
                      controller.inverterCalcAmps = double.tryParse(v) ?? 0;
                      controller.calculateInverter();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ExplanationButton(explanations: [AppExplanations(context).getInverterExplanations()[0]]),
              ],
            ),

            // AC System Voltage Selection
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.ac_system_voltage,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DropdownButton<double>(
                    value: controller.acSystemVoltage,
                    items: controller.acVoltageOptions
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text("${e.toStringAsFixed(0)} V"),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      controller.acSystemVoltage = v ?? 230.0;
                      controller.calculateInverter();
                    },
                  ),
                  const SizedBox(width: 8),
                  ExplanationButton(explanations: [AppExplanations(context).getInverterExplanations()[1]]),
                ],
              ),
            ),

            const SizedBox(height: 10),
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
                          Text(
                            l10n.safety_factor_oversizing,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "x${controller.inverterCalcSafetyFactor.toStringAsFixed(2)}",
                          ),
                        ],
                      ),
                      Slider(
                        value: controller.inverterCalcSafetyFactor,
                        min: 1.0,
                        max: 2.0,
                        divisions: 20,
                        label:
                            "x${controller.inverterCalcSafetyFactor.toStringAsFixed(2)}",
                        onChanged: (v) {
                          controller.inverterCalcSafetyFactor = v;
                          controller.calculateInverter();
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ExplanationButton(explanations: [AppExplanations(context).getInverterExplanations()[2]]),
              ],
            ),

            const SizedBox(height: 30),

            // Result
            ResultCard(
              title: l10n.recommended_inverter_size,
              value: "${controller.inverterCalcResult.toStringAsFixed(1)} kVA",
              subtitle: l10n.approx_watts(
                (controller.inverterCalcResult * 1000).toStringAsFixed(0),
              ),
              icon: Iconsax.flash_1_bold,
              color: Colors.redAccent,
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
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    l10n.inverter_calc_tip_text,
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog() {
    final explanations = AppExplanations(context).getInverterExplanations();
    ExplanationDialog.show(
      context,
      explanations: explanations,
      showDontShowAgain: true,
      storageKey: 'inverter_calc_help_viewed',
    );
  }
}
