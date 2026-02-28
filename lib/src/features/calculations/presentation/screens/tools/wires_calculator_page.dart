import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/src/features/calculations/presentation/providers/calculator_controller.dart';
import 'package:solar_hub/src/features/calculations/presentation/widgets/calculator_widgets.dart';
import 'package:solar_hub/src/utils/app_theme.dart';
import 'package:solar_hub/src/utils/app_explanations.dart';
import 'package:get_storage/get_storage.dart';

class WiresCalculatorPage extends ConsumerStatefulWidget {
  const WiresCalculatorPage({super.key});

  @override
  ConsumerState<WiresCalculatorPage> createState() => _WiresCalculatorPageState();
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

    return Scaffold(
      appBar: AppBar(
        title: Text('wires_calc'), // TODO: translate
        actions: [IconButton(onPressed: _showHelpDialog, icon: const Icon(Icons.help_outline))],
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
              "Select your application type to get recommended wire gauge.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ), // TODO: translate
            const SizedBox(height: 30),

            // Application Type Selector
            DropdownButtonFormField<String>(
              initialValue: controller.wireCalcType,
              decoration: InputDecoration(
                labelText: "Application Type", // TODO: translate
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
              ),
              items: [
                "DC Solar",
                "DC Battery",
                "AC Single Phase",
                "AC Three Phase",
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), // TODO: translate
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
                  controller.wireCalcVoltage = v == "AC Single Phase" ? 220.0 : 380.0;
                  controller.wireCalcVoltageDrop = 3.0;
                }
              },
            ),
            const SizedBox(height: 20),

            // Inputs
            CalcInputRow(
              label: "System Voltage", // TODO: translate
              suffix: "Volts", // TODO: translate
              initialValue: controller.wireCalcVoltage,
              onChanged: (v) => controller.wireCalcVoltage = double.tryParse(v) ?? 0,
            ),

            CalcInputRow(
              label: "Current",
              suffix: "Amps",
              hint: "e.g. 10",
              onChanged: (v) => controller.wireCalcCurrent = double.tryParse(v) ?? 0,
            ), // TODO: translate

            CalcInputRow(
              label: "Distance (One Way)", // TODO: translate
              suffix: "Metres", // TODO: translate
              hint: "e.g. 15", // TODO: translate
              onChanged: (v) => controller.wireCalcLength = double.tryParse(v) ?? 0,
            ),

            // Voltage Drop Slider
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Allowable Voltage Drop", style: TextStyle(fontWeight: FontWeight.bold)), // TODO: translate
                    Text("${controller.wireCalcVoltageDrop.toStringAsFixed(1)}%"),

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
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, minimumSize: Size(double.infinity, 50)),
                  child: Text('calculate', style: TextStyle(color: Colors.white, fontSize: 16)), // TODO: translate
                ),
                const SizedBox(height: 30),

                ResultCard(
                  title: "Recommended Wire Size",
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
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Did you know?", // TODO: translate
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "• Keeping voltage drop low is critical for efficiency.\n" // TODO: translate
                        "• For Battery cables, aim for < 1% drop to prevent inverter cut-offs.\n" // TODO: translate
                        "• For Solar PV, 3% is generally acceptable.", // TODO: translate
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
              Text('guide', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), // TODO: translate
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
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                        ),
                        const SizedBox(height: 4),
                        Text(item.description, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(value: dontShowAgain, onChanged: (val) => dontShowAgain = val ?? false, activeColor: AppTheme.primaryColor),
                  Text('dont_show_again'), // TODO: translate
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('close'), // TODO: translate
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
