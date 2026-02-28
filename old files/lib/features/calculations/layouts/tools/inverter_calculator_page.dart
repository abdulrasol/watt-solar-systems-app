import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/features/calculations/controllers/calculator_controller.dart';
import 'package:solar_hub/features/calculations/widgets/calculator_widgets.dart';
import 'package:solar_hub/utils/app_theme.dart';

import 'package:solar_hub/utils/app_explanations.dart';
import 'package:get_storage/get_storage.dart';

class InverterCalculatorPage extends StatefulWidget {
  const InverterCalculatorPage({super.key});

  @override
  State<InverterCalculatorPage> createState() => _InverterCalculatorPageState();
}

class _InverterCalculatorPageState extends State<InverterCalculatorPage> {
  final CalculatorController controller = Get.put(CalculatorController());

  @override
  void initState() {
    super.initState();
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
        title: Text("inverter_calc".tr),
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
            Text("Size your inverter to handle peak loads safely.", textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 30),

            // Inputs
            // Inputs
            CalcInputRow(
              label: "Total Load Amps",
              suffix: "Amps",
              hint: "e.g. 10",
              initialValue: controller.inverterCalcAmps.value,
              onChanged: (v) => controller.inverterCalcAmps.value = double.tryParse(v) ?? 0,
            ),

            // AC System Voltage Selection
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text("AC System Voltage", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Obx(
                    () => DropdownButton<double>(
                      value: controller.acSystemVoltage.value,
                      items: controller.acVoltageOptions.map((e) => DropdownMenuItem(value: e, child: Text("${e.toStringAsFixed(0)} V"))).toList(),
                      onChanged: (v) => controller.acSystemVoltage.value = v ?? 230.0,
                    ),
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
                    Text("Safety Factor (Over-sizing)", style: TextStyle(fontWeight: FontWeight.bold)),
                    Obx(() => Text("x${controller.inverterCalcSafetyFactor.value.toStringAsFixed(2)}")),
                  ],
                ),
                Obx(
                  () => Slider(
                    value: controller.inverterCalcSafetyFactor.value,
                    min: 1.0,
                    max: 2.0,
                    divisions: 20,
                    label: "x${controller.inverterCalcSafetyFactor.value.toStringAsFixed(2)}",
                    onChanged: (v) => controller.inverterCalcSafetyFactor.value = v,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: controller.calculateInverter,
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, minimumSize: Size(double.infinity, 50)),
              child: Text("calculate".tr, style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
            const SizedBox(height: 30),

            // Result
            Obx(
              () => ResultCard(
                title: "Recommended Inverter Size",
                value: "${controller.inverterCalcResult.value.toStringAsFixed(1)} kVA",
                subtitle: "(Approx. ${(controller.inverterCalcResult.value * 1000).toStringAsFixed(0)} Watts)",
                icon: Iconsax.flash_1_bold,
                color: Colors.redAccent,
              ),
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
    final explanations = AppExplanations.getInverterExplanations();
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
                      GetStorage().write('inverter_calc_help_viewed', true);
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
