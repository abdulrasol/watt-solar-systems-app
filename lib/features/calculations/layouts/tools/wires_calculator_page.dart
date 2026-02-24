import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/features/calculations/controllers/calculator_controller.dart';
import 'package:solar_hub/features/calculations/widgets/calculator_widgets.dart';
import 'package:solar_hub/utils/app_theme.dart';

import 'package:solar_hub/utils/app_explanations.dart';
import 'package:get_storage/get_storage.dart';

class WiresCalculatorPage extends StatefulWidget {
  const WiresCalculatorPage({super.key});

  @override
  State<WiresCalculatorPage> createState() => _WiresCalculatorPageState();
}

class _WiresCalculatorPageState extends State<WiresCalculatorPage> {
  final CalculatorController controller = Get.put(CalculatorController());

  @override
  void initState() {
    super.initState();
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
        title: Text("wires_calc".tr),
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
            Text("Select your application type to get recommended wire gauge.", textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 30),

            // Application Type Selector
            DropdownButtonFormField<String>(
              initialValue: controller.wireCalcType.value,
              decoration: InputDecoration(
                labelText: "Application Type",
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
              ),
              items: ["DC Solar", "DC Battery", "AC Single Phase", "AC Three Phase"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) {
                if (v == null) return;
                controller.wireCalcType.value = v;
                // Set Defaults based on selection
                if (v == "DC Solar") {
                  controller.wireCalcVoltage.value = 40.0;
                  controller.wireCalcVoltageDrop.value = 3.0; // Standard PV drop
                } else if (v == "DC Battery") {
                  controller.wireCalcVoltage.value = 12.0;
                  controller.wireCalcVoltageDrop.value = 1.0; // Critical for battery
                } else if (v.startsWith("AC")) {
                  controller.wireCalcVoltage.value = v == "AC Single Phase" ? 220.0 : 380.0;
                  controller.wireCalcVoltageDrop.value = 3.0;
                }
              },
            ),
            const SizedBox(height: 20),

            // Inputs
            Obx(
              () => CalcInputRow(
                label: "System Voltage",
                suffix: "Volts",
                initialValue: controller.wireCalcVoltage.value,
                onChanged: (v) => controller.wireCalcVoltage.value = double.tryParse(v) ?? 0,
              ),
            ),

            CalcInputRow(label: "Current", suffix: "Amps", hint: "e.g. 10", onChanged: (v) => controller.wireCalcCurrent.value = double.tryParse(v) ?? 0),

            CalcInputRow(
              label: "Distance (One Way)",
              suffix: "Metres",
              hint: "e.g. 15",
              onChanged: (v) => controller.wireCalcLength.value = double.tryParse(v) ?? 0,
            ),

            // Voltage Drop Slider
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Allowable Voltage Drop", style: TextStyle(fontWeight: FontWeight.bold)),
                    Obx(() => Text("${controller.wireCalcVoltageDrop.value.toStringAsFixed(1)}%")),
                  ],
                ),
                Obx(
                  () => Slider(
                    value: controller.wireCalcVoltageDrop.value,
                    min: 0.5,
                    max: 10.0,
                    divisions: 19,
                    label: "${controller.wireCalcVoltageDrop.value}%",
                    onChanged: (v) => controller.wireCalcVoltageDrop.value = v,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: controller.calculateWire,
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, minimumSize: Size(double.infinity, 50)),
              child: Text("calculate".tr, style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
            const SizedBox(height: 30),

            Obx(() => ResultCard(title: "Recommended Wire Size", value: controller.wireCalcResult.value, icon: Iconsax.mask_1_bold, color: Colors.blueGrey)),

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
                    "Did you know?",
                    style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "• Keeping voltage drop low is critical for efficiency.\n"
                    "• For Battery cables, aim for < 1% drop to prevent inverter cut-offs.\n"
                    "• For Solar PV, 3% is generally acceptable.",
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
    final explanations = AppExplanations.getWiresExplanations();
    RxBool dontShowAgain = true.obs;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          height: 600,
          child: Column(
            children: [
              Text("guide".tr, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: explanations.length,
                  separatorBuilder: (_, __) => const Divider(),
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
                  Obx(() => Checkbox(value: dontShowAgain.value, onChanged: (val) => dontShowAgain.value = val ?? false, activeColor: AppTheme.primaryColor)),
                  Text("dont_show_again".tr),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (dontShowAgain.value) {
                      GetStorage().write('wires_calc_help_viewed', true);
                    }
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text("close".tr),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
