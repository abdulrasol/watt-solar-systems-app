import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/src/features/calculations/presentation/providers/calculator_controller.dart';
import 'package:solar_hub/src/features/calculations/presentation/widgets/calculator_widgets.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

import 'package:solar_hub/src/utils/app_explanations.dart';
import 'package:get_storage/get_storage.dart';
import 'package:solar_hub/l10n/app_localizations.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.inverter_calc),
        actions: [
          IconButton(
            onPressed: _showHelpDialog,
            icon: const Icon(Icons.help_outline),
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
            ), // TODO: translate
            const SizedBox(height: 30),

            // Inputs
            // Inputs
            CalcInputRow(
              label: l10n.total_load_amps,
              suffix: l10n.amps,
              hint: l10n.example_10,
              initialValue: controller.inverterCalcAmps,
              onChanged: (v) =>
                  controller.inverterCalcAmps = double.tryParse(v) ?? 0,
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
                    onChanged: (v) => controller.acSystemVoltage = v ?? 230.0,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.safety_factor_oversizing,
                      style: TextStyle(fontWeight: FontWeight.bold),
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
                  onChanged: (v) => controller.inverterCalcSafetyFactor = v,
                ),
              ],
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: controller.calculateInverter,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text(
                l10n.calculate,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
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
    bool dontShowAgain = true;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          height: 600,
          child: Column(
            children: [
              Text(
                AppLocalizations.of(context)!.guide,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: explanations.length,
                  separatorBuilder: (_, _) => const Divider(),
                  itemBuilder: (context, index) {
                    final item = explanations[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.description,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: dontShowAgain,
                    onChanged: (val) => dontShowAgain = val ?? false,
                    activeColor: AppTheme.primaryColor,
                  ),
                  Text(AppLocalizations.of(context)!.dont_show_again),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (dontShowAgain) {
                      GetStorage().write('inverter_calc_help_viewed', true);
                    }
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(AppLocalizations.of(context)!.close),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
