import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/features/calculations/controllers/calculator_controller.dart';
import 'package:solar_hub/features/calculations/widgets/calculator_widgets.dart';
import 'package:solar_hub/utils/app_theme.dart';

import 'package:solar_hub/utils/app_explanations.dart';
import 'package:get_storage/get_storage.dart';

class PanelCalculatorPage extends StatefulWidget {
  const PanelCalculatorPage({super.key});

  @override
  State<PanelCalculatorPage> createState() => _PanelCalculatorPageState();
}

class _PanelCalculatorPageState extends State<PanelCalculatorPage> {
  final CalculatorController controller = Get.put(CalculatorController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final box = GetStorage();
      if (box.read('panel_calc_help_viewed') != true) {
        _showHelpDialog();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text("panels_calc".tr),
        actions: [IconButton(onPressed: _showHelpDialog, icon: const Icon(Icons.help_outline))],
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
            Text(
              "Calculate required solar panels based on your daily energy usage.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 30),

            // Inputs
            CalcInputRow(
              label: "Total Daily Usage",
              suffix: "Ah",
              hint: "e.g. 100",
              onChanged: (v) => controller.panelCalcDailyUsage.value = double.tryParse(v) ?? 0,
            ),

            // Voltage Selection
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text("System Voltage", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Obx(
                    () => DropdownButton<double>(
                      value: controller.panelCalcVoltage.value,
                      items: [
                        12.0,
                        24.0,
                        48.0,
                        110.0,
                        220.0,
                        230.0,
                        380.0,
                      ].map((e) => DropdownMenuItem(value: e, child: Text("${e.toStringAsFixed(0)} V"))).toList(),
                      onChanged: (v) => controller.panelCalcVoltage.value = v ?? 12.0,
                    ),
                  ),
                ],
              ),
            ),

            CalcInputRow(label: "Panel Wattage", suffix: "W", initialValue: 450, onChanged: (v) => controller.panelCalcWattage.value = double.tryParse(v) ?? 0),

            // Efficiency Slider
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("System Efficiency / Loss Factor", style: TextStyle(fontWeight: FontWeight.bold)),
                    Obx(() => Text("${(controller.panelCalcEfficiency.value * 100).toInt()}%")),
                  ],
                ),
                Obx(
                  () => Slider(
                    value: controller.panelCalcEfficiency.value,
                    min: 0.65,
                    max: 1.0,
                    divisions: 35,
                    label: "${(controller.panelCalcEfficiency.value * 100).toInt()}%",
                    onChanged: (v) => controller.panelCalcEfficiency.value = v,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: controller.calculatePanels, // Logic updated in Controller
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, minimumSize: Size(double.infinity, 50)),
              child: Text("calculate".tr, style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
            const SizedBox(height: 30),

            // Result
            Obx(
              () => ResultCard(
                title: "Required Panels",
                value: "${controller.panelCalcResult.value}",
                subtitle: "Total Array: ${(controller.panelCalcTotalWattage.value / 1000).toStringAsFixed(2)} kW",
                icon: Iconsax.sun_1_bold,
                color: Colors.amber,
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
                    "• Ah (Amp-hours) = Watts ÷ Voltage.\n"
                    "• E.g., 1000Wh daily load on a 12V system = 83.3 Ah.\n"
                    "• We factor in efficiency (losses) to ensure your system performs well even on cloudy days.",
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
    final explanations = AppExplanations.getPanelExplanations();
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
                      GetStorage().write('panel_calc_help_viewed', true);
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
