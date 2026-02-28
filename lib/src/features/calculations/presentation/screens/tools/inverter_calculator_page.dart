import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/src/features/calculations/presentation/providers/calculator_controller.dart';
import 'package:solar_hub/src/features/calculations/presentation/widgets/calculator_widgets.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

import 'package:solar_hub/src/utils/app_explanations.dart';
import 'package:get_storage/get_storage.dart';

class InverterCalculatorPage extends ConsumerStatefulWidget {
  const InverterCalculatorPage({super.key});

  @override
  ConsumerState<InverterCalculatorPage> createState() => _InverterCalculatorPageState();
}

class _InverterCalculatorPageState extends ConsumerState<InverterCalculatorPage> {
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

    return Scaffold(
      appBar: AppBar(
        title: Text('inverter_calc'), // TODO: translate
        actions: [IconButton(onPressed: _showHelpDialog, icon: const Icon(Icons.help_outline))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Hero(
              tag: 'inverter_hero',
              child: Icon(Iconsax.flash_bold, size: 80, color: Colors.blueAccent),
            ),
            const SizedBox(height: 20),
            Text(
              "Size your inverter to handle peak loads safely.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ), // TODO: translate
            const SizedBox(height: 30),

            // Inputs
            // Inputs
            CalcInputRow(
              label: "Total Load Amps", // TODO: translate
              suffix: "Amps", // TODO: translate
              hint: "e.g. 10", // TODO: translate
              initialValue: controller.inverterCalcAmps,
              onChanged: (v) => controller.inverterCalcAmps = double.tryParse(v) ?? 0,
            ),

            // AC System Voltage Selection
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text("AC System Voltage", style: TextStyle(fontWeight: FontWeight.bold)), // TODO: translate
                  ),
                  DropdownButton<double>(
                    value: controller.acSystemVoltage,
                    items: controller.acVoltageOptions.map((e) => DropdownMenuItem(value: e, child: Text("${e.toStringAsFixed(0)} V"))).toList(),
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
                    Text("Safety Factor (Over-sizing)", style: TextStyle(fontWeight: FontWeight.bold)), // TODO: translate
                    Text("x${controller.inverterCalcSafetyFactor.toStringAsFixed(2)}"),
                  ],
                ),
                Slider(
                  value: controller.inverterCalcSafetyFactor,
                  min: 1.0,
                  max: 2.0,
                  divisions: 20,
                  label: "x${controller.inverterCalcSafetyFactor.toStringAsFixed(2)}",
                  onChanged: (v) => controller.inverterCalcSafetyFactor = v,
                ),
              ],
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: controller.calculateInverter,
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, minimumSize: Size(double.infinity, 50)),
              child: Text('calculate', style: TextStyle(color: Colors.white, fontSize: 16)), // TODO: translate
            ),
            const SizedBox(height: 30),

            // Result
            ResultCard(
              title: "Recommended Inverter Size", // TODO: translate
              value: "${controller.inverterCalcResult.toStringAsFixed(1)} kVA",
              subtitle: "(Approx. ${(controller.inverterCalcResult * 1000).toStringAsFixed(0)} Watts)", // TODO: translate
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
                    "Did you know?",
                    style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "• Inverters should be sized 20-30% larger than your continuously running load.\n"
                    "• This 'Safety Factor' prevents overheating and handles startup surges from motors (like fridges or pumps).",
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
                      GetStorage().write('inverter_calc_help_viewed', true);
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
