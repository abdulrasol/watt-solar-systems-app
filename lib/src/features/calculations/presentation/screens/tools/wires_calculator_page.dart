import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/src/features/calculations/presentation/providers/calculator_controller.dart';
import 'package:solar_hub/src/features/calculations/presentation/widgets/calculator_widgets.dart';
import 'package:solar_hub/src/utils/app_theme.dart';
import 'package:solar_hub/src/utils/app_explanations.dart';
import 'package:get_storage/get_storage.dart';
import 'package:solar_hub/l10n/app_localizations.dart';

class WiresCalculatorPage extends ConsumerStatefulWidget {
  const WiresCalculatorPage({super.key});

  @override
  ConsumerState<WiresCalculatorPage> createState() =>
      _WiresCalculatorPageState();
}

class _WiresCalculatorPageState extends ConsumerState<WiresCalculatorPage> {
  late final CalculatorNotifier controller;

  @override
  void initState() {
    super.initState();
    controller = ref.read(calculatorProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final box = GetStorage();
      if (box.read('wires_calc_help_viewed') != true) {
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
        title: Text(l10n.wires_calc),
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
              tag: 'wire_hero',
              child: Icon(Iconsax.mask_bold, size: 80, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.wires_calc_intro,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ), // TODO: translate
            const SizedBox(height: 30),

            // Application Type Selector
            DropdownButtonFormField<String>(
              initialValue: controller.wireCalcType,
              decoration: InputDecoration(
                labelText: l10n.application_type,
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 15,
                ),
              ),
              items:
                  [
                        ("DC Solar", l10n.dc_solar),
                        ("DC Battery", l10n.dc_battery),
                        ("AC Single Phase", l10n.ac_single_phase),
                        ("AC Three Phase", l10n.ac_three_phase),
                      ]
                      .map(
                        (e) => DropdownMenuItem(value: e.$1, child: Text(e.$2)),
                      )
                      .toList(),
              onChanged: (v) {
                if (v == null) return;
                controller.wireCalcType = v;
                // Set Defaults based on selection
                if (v == "DC Solar") {
                  controller.wireCalcVoltage = 40.0;
                  controller.wireCalcVoltageDrop = 3.0; // Standard PV drop
                } else if (v == "DC Battery") {
                  controller.wireCalcVoltage = 12.0;
                  controller.wireCalcVoltageDrop = 1.0; // Critical for battery
                } else if (v.startsWith("AC")) {
                  controller.wireCalcVoltage = v == "AC Single Phase"
                      ? 220.0
                      : 380.0;
                  controller.wireCalcVoltageDrop = 3.0;
                }
              },
            ),
            const SizedBox(height: 20),

            // Inputs
            CalcInputRow(
              label: l10n.system_voltage,
              suffix: l10n.volts,
              initialValue: controller.wireCalcVoltage,
              onChanged: (v) =>
                  controller.wireCalcVoltage = double.tryParse(v) ?? 0,
            ),

            CalcInputRow(
              label: l10n.current,
              suffix: l10n.amps,
              hint: l10n.example_10,
              onChanged: (v) =>
                  controller.wireCalcCurrent = double.tryParse(v) ?? 0,
            ), // TODO: translate

            CalcInputRow(
              label: l10n.distance_one_way,
              suffix: l10n.metres,
              hint: "e.g. 15", // TODO: translate
              onChanged: (v) =>
                  controller.wireCalcLength = double.tryParse(v) ?? 0,
            ),

            // Voltage Drop Slider
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.allowable_voltage_drop,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "${controller.wireCalcVoltageDrop.toStringAsFixed(1)}%",
                    ),

                    Slider(
                      value: controller.wireCalcVoltageDrop,
                      min: 0.5,
                      max: 10.0,
                      divisions: 19,
                      label: "${controller.wireCalcVoltageDrop}%",
                      onChanged: (v) => controller.wireCalcVoltageDrop = v,
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: controller.calculateWire,
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

                ResultCard(
                  title: l10n.recommended_wire_size,
                  value: controller.wireCalcResult,
                  icon: Iconsax.mask_1_bold,
                  color: Colors.blueGrey,
                ), // TODO: translate

                const SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.3),
                    ),
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
                        l10n.wires_calc_tip_text,
                        style: TextStyle(fontSize: 12),
                      ),
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
    final explanations = AppExplanations(context).getWiresExplanations();
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
                      GetStorage().write('wires_calc_help_viewed', true);
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
