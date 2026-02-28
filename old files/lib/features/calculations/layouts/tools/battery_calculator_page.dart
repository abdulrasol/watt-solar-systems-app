import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/features/calculations/controllers/calculator_controller.dart';
import 'package:solar_hub/features/calculations/widgets/calculator_widgets.dart';
import 'package:solar_hub/utils/app_theme.dart';

import 'package:solar_hub/utils/app_explanations.dart';
import 'package:get_storage/get_storage.dart';

class BatteryCalculatorPage extends StatefulWidget {
  const BatteryCalculatorPage({super.key});

  @override
  State<BatteryCalculatorPage> createState() => _BatteryCalculatorPageState();
}

class _BatteryCalculatorPageState extends State<BatteryCalculatorPage> {
  final CalculatorController controller = Get.put(CalculatorController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final box = GetStorage();
      if (box.read('battery_calc_help_viewed') != true) {
        _showHelpDialog();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("battery_calc".tr),
          actions: [IconButton(onPressed: _showHelpDialog, icon: const Icon(Icons.help_outline))],
          bottom: const TabBar(
            tabs: [
              Tab(text: "Find Battery Count"),
              Tab(text: "Find Backup Time"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Calculate Count (How many batteries needed?)
            _buildCountTab(context, isDark),
            // Tab 2: Calculate Time (How long will they last?)
            _buildTimeTab(context, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildCountTab(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Hero(
            tag: 'battery_hero_count',
            child: Icon(Iconsax.battery_charging_bold, size: 70, color: Colors.green),
          ),
          const SizedBox(height: 20),
          Text("How many batteries do you need?", textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 30),

          CalcInputRow(
            label: "Total Load Amps",
            suffix: "Amps",
            hint: "e.g. 5",
            initialValue: controller.batteryCalcAmps.value,
            onChanged: (v) => controller.batteryCalcAmps.value = double.tryParse(v) ?? 0,
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
          CalcInputRow(
            label: "Required Backup Time",
            suffix: "Hours",
            hint: "e.g. 5",
            onChanged: (v) => controller.batteryCalcHours.value = double.tryParse(v) ?? 0,
          ),

          const SizedBox(height: 10),
          _buildDropdowns(context),

          // DoD Slider
          const SizedBox(height: 10),
          _buildDoDSlider(),

          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: controller.calculateBattery,
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, minimumSize: Size(double.infinity, 50)),
            child: Text("calculate".tr, style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
          const SizedBox(height: 30),

          Obx(
            () => ResultCard(
              title: "Required Batteries",
              value: "${controller.batteryCalcResult.value} Batteries",
              subtitle: "For ${controller.batteryCalcAmp.value.toInt()}Ah @ ${controller.batteryCalcVoltage.value.toInt()}V",
              icon: Iconsax.battery_charging_bold,
              color: Colors.green,
            ),
          ),

          SizedBox(height: 20),
          _buildHint(context, isDark, "Formula: (Load × Time) ÷ (Battery Voltage × Capacity × DoD)"),
        ],
      ),
    );
  }

  Widget _buildTimeTab(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Hero(
            tag: 'battery_hero_time',
            child: Icon(Iconsax.timer_1_bold, size: 70, color: Colors.blue),
          ),
          const SizedBox(height: 20),
          Text("How long will your batteries last?", textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 30),

          CalcInputRow(
            label: "Total Load Amps",
            suffix: "Amps",
            hint: "e.g. 5",
            initialValue: controller.batteryCalcAmps.value,
            onChanged: (v) => controller.batteryCalcAmps.value = double.tryParse(v) ?? 0,
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

          // Number of batteries input
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: Text("Number of Batteries", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                SizedBox(
                  width: 100,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(isDense: true, border: OutlineInputBorder(), hintText: "1"),
                    onChanged: (v) => controller.batteryCalcCountCount.value = int.tryParse(v) ?? 1,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),
          _buildDropdowns(context),

          // DoD Slider
          const SizedBox(height: 10),
          _buildDoDSlider(),

          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: controller.calculateBatteryRuntime,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, minimumSize: Size(double.infinity, 50)),
            child: Text("calculate".tr, style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
          const SizedBox(height: 30),

          Obx(
            () => ResultCard(
              title: "Estimated Runtime",
              value: "${controller.batteryCalcRuntimeResult.value.toStringAsFixed(1)} Hours",
              icon: Iconsax.timer_1_bold,
              color: Colors.blue,
            ),
          ),

          SizedBox(height: 20),
          _buildHint(context, isDark, "Calculates how long the battery bank can sustain the load before reaching defined Depth of Discharge."),
        ],
      ),
    );
  }

  Widget _buildDropdowns(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text("Battery Voltage", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Obx(
              () => DropdownButton<double>(
                value: controller.batteryCalcVoltage.value,
                items: controller.batteryVoltageOptions.map((e) => DropdownMenuItem(value: e, child: Text("$e V"))).toList(),
                onChanged: (v) => controller.batteryCalcVoltage.value = v ?? 12.0,
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        CalcInputRow(
          label: "Battery Capacity (Ah)",
          suffix: "Ah",
          hint: "e.g. 200",
          initialValue: controller.batteryCalcAmp.value,
          onChanged: (v) => controller.batteryCalcAmp.value = double.tryParse(v) ?? 0,
        ),
      ],
    );
  }

  Widget _buildDoDSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Depth of Discharge (DoD)", style: TextStyle(fontWeight: FontWeight.bold)),
            Obx(() => Text("${controller.batteryCalcDoD.value.toInt()}%")),
          ],
        ),
        Obx(
          () => Slider(
            value: controller.batteryCalcDoD.value,
            min: 10,
            max: 90,
            divisions: 80,
            label: "${controller.batteryCalcDoD.value.toInt()}%",
            onChanged: (v) => controller.batteryCalcDoD.value = v,
          ),
        ),
        Text("Typical: 50% for Gel/AGM, 80% for Lithium, 20-30% for Lead-Acid", style: TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildHint(BuildContext context, bool isDark, String text) {
    return Container(
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
          Text(text, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    final explanations = AppExplanations.getBatteryExplanations();
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
                      GetStorage().write('battery_calc_help_viewed', true);
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
