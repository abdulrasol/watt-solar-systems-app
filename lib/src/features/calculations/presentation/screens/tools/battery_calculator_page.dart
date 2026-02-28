import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/src/features/calculations/presentation/providers/calculator_controller.dart';
import 'package:solar_hub/src/features/calculations/presentation/widgets/calculator_widgets.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

import 'package:solar_hub/src/utils/app_explanations.dart';
import 'package:get_storage/get_storage.dart';

class BatteryCalculatorPage extends ConsumerStatefulWidget {
  const BatteryCalculatorPage({super.key});

  @override
  ConsumerState<BatteryCalculatorPage> createState() => _BatteryCalculatorPageState();
}

class _BatteryCalculatorPageState extends ConsumerState<BatteryCalculatorPage> {
  late final CalculatorNotifier controller;

  @override
  void initState() {
    super.initState();
    controller = ref.read(calculatorProvider);
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
          title: Text('battery_calc'), // TODO: translate
          actions: [IconButton(onPressed: _showHelpDialog, icon: const Icon(Icons.help_outline))],
          bottom: const TabBar(
            tabs: [
              Tab(text: "Find Battery Count"), // TODO: translate
              Tab(text: "Find Backup Time"), // TODO: translate
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
            initialValue: controller.batteryCalcAmps,
            onChanged: (v) => controller.batteryCalcAmps = double.tryParse(v) ?? 0,
          ),

          // AC System Voltage Selection
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: Text("AC System Voltage", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                DropdownButton<double>(
                  value: controller.acSystemVoltage,
                  items: controller.acVoltageOptions.map((e) => DropdownMenuItem(value: e, child: Text("${e.toStringAsFixed(0)} V"))).toList(),
                  onChanged: (v) => controller.acSystemVoltage = v ?? 230.0,
                ),
              ],
            ),
          ),
          CalcInputRow(
            label: "Required Backup Time", // TODO: translate
            suffix: "Hours", // TODO: translate
            hint: "e.g. 5", // TODO: translate
            onChanged: (v) => controller.batteryCalcHours = double.tryParse(v) ?? 0,
          ),

          const SizedBox(height: 10),
          _buildDropdowns(context),

          // DoD Slider
          const SizedBox(height: 10),
          _buildDoDSlider(context),

          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: controller.calculateBattery,
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, minimumSize: Size(double.infinity, 50)),
            child: Text('calculate', style: TextStyle(color: Colors.white, fontSize: 16)), // TODO: translate
          ),
          const SizedBox(height: 30),

          ResultCard(
            title: "Required Batteries", // TODO: translate
            value: "${controller.batteryCalcResult} Batteries",
            subtitle: "For ${controller.batteryCalcAmp.toInt()}Ah @ ${controller.batteryCalcVoltage.toInt()}V",
            icon: Iconsax.battery_charging_bold,
            color: Colors.green,
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
            initialValue: controller.batteryCalcAmps,
            onChanged: (v) => controller.batteryCalcAmps = double.tryParse(v) ?? 0,
          ),

          // AC System Voltage Selection
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: Text("AC System Voltage", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                DropdownButton<double>(
                  value: controller.acSystemVoltage,
                  items: controller.acVoltageOptions.map((e) => DropdownMenuItem(value: e, child: Text("${e.toStringAsFixed(0)} V"))).toList(),
                  onChanged: (v) => controller.acSystemVoltage = v ?? 230.0,
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
                  child: Text("Number of Batteries", style: TextStyle(fontWeight: FontWeight.bold)), // TODO: translate
                ),
                SizedBox(
                  width: 100,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(isDense: true, border: OutlineInputBorder(), hintText: "1"),
                    onChanged: (v) => controller.batteryCalcCountCount = int.tryParse(v) ?? 1,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),
          _buildDropdowns(context),

          // DoD Slider
          const SizedBox(height: 10),
          _buildDoDSlider(context),

          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: controller.calculateBatteryRuntime,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, minimumSize: Size(double.infinity, 50)),
            child: Text('calculate', style: TextStyle(color: Colors.white, fontSize: 16)), // TODO: translate
          ),
          const SizedBox(height: 30),

          ResultCard(
            title: "Estimated Runtime",
            value: "${controller.batteryCalcRuntimeResult.toStringAsFixed(1)} Hours",
            icon: Iconsax.timer_1_bold,
            color: Colors.blue,
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
            DropdownButton<double>(
              value: controller.batteryCalcVoltage,
              items: controller.batteryVoltageOptions.map((e) => DropdownMenuItem(value: e, child: Text("$e V"))).toList(),
              onChanged: (v) => controller.batteryCalcVoltage = v ?? 12.0,
            ),
          ],
        ),
        SizedBox(height: 10),
        CalcInputRow(
          label: "Battery Capacity (Ah)",
          suffix: "Ah",
          hint: "e.g. 200",
          initialValue: controller.batteryCalcAmp,
          onChanged: (v) => controller.batteryCalcAmp = double.tryParse(v) ?? 0,
        ),
      ],
    );
  }

  Widget _buildDoDSlider(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Depth of Discharge (DoD)", style: TextStyle(fontWeight: FontWeight.bold)), // TODO: translate
            Text("${controller.batteryCalcDoD.toInt()}%"), // TODO: translate

            Slider(
              value: controller.batteryCalcDoD,
              min: 10,
              max: 90,
              divisions: 80,
              label: "${controller.batteryCalcDoD.toInt()}%",
              onChanged: (v) => controller.batteryCalcDoD = v,
            ),
          ],
        ),

        Text("Typical: 50% for Gel/AGM, 80% for Lithium, 20-30% for Lead-Acid", style: TextStyle(fontSize: 10, color: Colors.grey)), // TODO: translate
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
    final explanations = AppExplanations(context).getBatteryExplanations();
    bool dontShowAgain = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
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
                    Checkbox(value: dontShowAgain, onChanged: (val) => setState(() => dontShowAgain = val ?? false), activeColor: AppTheme.primaryColor),
                    Text('dont_show_again'), // TODO: translate
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (dontShowAgain) {
                        GetStorage().write('battery_calc_help_viewed', true);
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
      ),
    );
  }
}
