import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_hub/src/features/calculations/presentation/providers/calculator_controller.dart';
import 'package:solar_hub/src/features/calculations/presentation/widgets/calculator_widgets.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

import 'package:solar_hub/src/utils/app_explanations.dart';
import 'package:get_storage/get_storage.dart';

class PumpCalculator extends ConsumerStatefulWidget {
  const PumpCalculator({super.key});

  @override
  ConsumerState<PumpCalculator> createState() => _PumpCalculatorState();
}

class _PumpCalculatorState extends ConsumerState<PumpCalculator> {
  late final CalculatorNotifier controller;

  @override
  void initState() {
    super.initState();
    controller = ref.read(calculatorProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final box = GetStorage();
      if (box.read('pump_calc_help_viewed') != true) {
        _showHelpDialog();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('pump_calc'), // TODO: translate
        actions: [IconButton(onPressed: _showHelpDialog, icon: const Icon(Icons.help_outline))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Hero(
              tag: 'pump_hero',
              child: Icon(Icons.water_drop, size: 80, color: Colors.blueAccent),
            ),
            const SizedBox(height: 20),
            Text("Calculate solar power for your water pump system.", textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 30),

            // Inputs
            CalcInputRow(
              label: "Daily Water Volume",
              suffix: "m³",
              hint: "e.g. 10 (10000 L)",
              initialValue: controller.pumpDailyWater,
              onChanged: (v) => controller.pumpDailyWater = double.tryParse(v) ?? 0,
            ),
            CalcInputRow(
              label: "Total Dynamic Head (TDH)",
              suffix: "m",
              hint: "e.g. 50 (Vertical + Friction)",
              initialValue: controller.pumpTDH,
              onChanged: (v) => controller.pumpTDH = double.tryParse(v) ?? 0,
            ),
            CalcInputRow(
              label: "Pumping Hours",
              suffix: "h",
              hint: "e.g. 6",
              initialValue: controller.pumpDailyHours,
              onChanged: (v) => controller.pumpDailyHours = double.tryParse(v) ?? 0,
            ),
            CalcInputRow(
              label: "Location Peak Sun Hours (PSH)",
              suffix: "h",
              hint: "e.g. 5",
              initialValue: controller.pumpPeakSunHours,
              onChanged: (v) => controller.pumpPeakSunHours = double.tryParse(v) ?? 0,
            ),
            CalcInputRow(
              label: "Solar Panel Wattage",
              suffix: "W",
              hint: "e.g. 550",
              initialValue: controller.pumpPanelWattage,
              onChanged: (v) => controller.pumpPanelWattage = double.tryParse(v) ?? 0,
            ),

            // Pump Efficiency Slider
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Pump Efficiency", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("${(controller.pumpEfficiency * 100.toInt())}%"),
                  ],
                ),
                Slider(
                  value: controller.pumpEfficiency,
                  min: 0.1,
                  max: 0.9,
                  divisions: 80,
                  label: "${(controller.pumpEfficiency * 100.toInt())}%",
                  onChanged: (v) => controller.pumpEfficiency = v,
                ),
              ],
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: controller.calculatePump,
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, minimumSize: const Size(double.infinity, 50)),
              child: Text('calculate', style: const TextStyle(color: Colors.white, fontSize: 16)), // TODO: translate
            ),
            const SizedBox(height: 30),

            // Results
            ResultCard(
              title: "Required Solar Panels",
              value: "${controller.pumpRequiredPanelCount}",
              subtitle: "Total Array: ${controller.pumpRequiredPanelKw.toStringAsFixed(2)} kWp",
              icon: Icons.solar_power,
              color: Colors.orange,
            ),

            const SizedBox(height: 16),
            ResultCard(
              title: "Hydraulic Power Est.",
              value: "${(controller.pumpHydraulicPowerW / 1000).toStringAsFixed(2)} kW", // Display kW
              subtitle: "(~${(controller.pumpHydraulicPowerW / 745.7).toStringAsFixed(1)} HP) Motor",
              icon: Icons.settings,
              color: Colors.blueGrey,
            ),

            const SizedBox(height: 20),
            // Educational Hint
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Definitions / تعريفات",
                    style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                  ),
                  const SizedBox(height: 10),
                  _buildDefinitionRow(
                    "Total Dynamic Head (TDH)",
                    "Vertical Lift + Friction Losses + Pressure.\nالارتفاع الكلي + فاقد الاحتكاك + الضغط المطلوب.",
                  ),
                  _buildDefinitionRow("Flow Rate", "Volume of water per day (e.g., m³ or 1000 Liters).\nكمية المياه المطلوبة يومياً (بالمتر المكعب)."),
                  _buildDefinitionRow(
                    "Peak Sun Hours (PSH)",
                    "Equivalent hours of full sun intensity (usually 4-6h).\nساعات ذروة الشمس في منطقتك (عادة ٤-٦ ساعات).",
                  ),
                  _buildDefinitionRow("Hydraulic Power", "Power required to lift water (before motor efficiency).\nالقدرة الهيدروليكية اللازمة لرفع الماء."),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefinitionRow(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("• $title:", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Text(desc, style: const TextStyle(fontSize: 12, height: 1.4, color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    final explanations = AppExplanations(context).getPumpExplanations();
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
                      GetStorage().write('pump_calc_help_viewed', true);
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
