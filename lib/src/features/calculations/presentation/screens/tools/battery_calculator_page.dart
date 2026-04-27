import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/src/features/calculations/presentation/providers/calculator_controller.dart';
import 'package:solar_hub/src/features/calculations/presentation/widgets/calculator_widgets.dart';
import 'package:solar_hub/src/features/calculations/presentation/widgets/explanation_button.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

import 'package:solar_hub/src/utils/app_explanations.dart';
import 'package:solar_hub/l10n/app_localizations.dart';

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
  }

  void _recalc() {
    controller.calculateBattery();
    controller.calculateBatteryRuntime();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(calculatorProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.battery_calc),
          actions: [ExplanationButton(explanations: AppExplanations(context).getBatteryExplanations(), storageKey: 'battery_calc_help_viewed')],
          bottom: TabBar(
            tabs: [
              Tab(text: AppLocalizations.of(context)!.find_battery_count),
              Tab(text: AppLocalizations.of(context)!.find_backup_time),
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
            tag: 'battery_hero',
            child: Icon(Iconsax.battery_charging_bold, size: 70.sp, color: Colors.green),
          ),
          const SizedBox(height: 20),
          Text(AppLocalizations.of(context)!.how_many_batteries_need, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 30),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CalcInputRow(
                  label: AppLocalizations.of(context)!.total_load_amps,
                  suffix: AppLocalizations.of(context)!.amps,
                  hint: "e.g. 5",
                  initialValue: controller.batteryCalcAmps,
                  onChanged: (v) {
                    controller.batteryCalcAmps = double.tryParse(v) ?? 0;
                    _recalc();
                  },
                ),
              ),
              const SizedBox(width: 8),
              ExplanationButton(explanations: [AppExplanations(context).getBatteryExplanations()[0]]),
            ],
          ),

          // AC System Voltage Selection
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(AppLocalizations.of(context)!.ac_system_voltage, style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                DropdownButton<double>(
                  value: controller.acSystemVoltage,
                  items: controller.acVoltageOptions.map((e) => DropdownMenuItem(value: e, child: Text("${e.toStringAsFixed(0)} V"))).toList(),
                  onChanged: (v) {
                    controller.acSystemVoltage = v ?? 230.0;
                    _recalc();
                  },
                ),
              ],
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CalcInputRow(
                  label: AppLocalizations.of(context)!.required_backup_time,
                  suffix: AppLocalizations.of(context)!.hours,
                  hint: AppLocalizations.of(context)!.example_5,
                  onChanged: (v) {
                    controller.batteryCalcHours = double.tryParse(v) ?? 0;
                    _recalc();
                  },
                ),
              ),
              const SizedBox(width: 8),
              ExplanationButton(explanations: [AppExplanations(context).getBatteryExplanations()[1]]),
            ],
          ),

          const SizedBox(height: 10),
          _buildDropdowns(context),

          // DoD Slider
          const SizedBox(height: 10),
          _buildDoDSlider(context),

          const SizedBox(height: 30),

          ResultCard(
            title: AppLocalizations.of(context)!.required_batteries,
            value: AppLocalizations.of(context)!.batteries_count_value(controller.batteryCalcResult),
            subtitle: AppLocalizations.of(context)!.battery_for_spec(controller.batteryCalcAmp.toInt(), controller.batteryCalcVoltage.toInt()),
            icon: Iconsax.battery_charging_bold,
            color: Colors.green,
          ),

          SizedBox(height: 20),
          _buildHint(context, isDark, AppLocalizations.of(context)!.battery_count_formula_hint),
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
            tag: 'battery_hero',
            child: Icon(Iconsax.timer_1_bold, size: 70.sp, color: Colors.blue),
          ),
          const SizedBox(height: 20),
          Text(AppLocalizations.of(context)!.how_long_batteries_last, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 30),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CalcInputRow(
                  label: AppLocalizations.of(context)!.total_load_amps,
                  suffix: AppLocalizations.of(context)!.amps,
                  hint: "e.g. 5",
                  initialValue: controller.batteryCalcAmps,
                  onChanged: (v) {
                    controller.batteryCalcAmps = double.tryParse(v) ?? 0;
                    _recalc();
                  },
                ),
              ),
              const SizedBox(width: 8),
              ExplanationButton(explanations: [AppExplanations(context).getBatteryExplanations()[0]]),
            ],
          ),

          // AC System Voltage Selection
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(AppLocalizations.of(context)!.ac_system_voltage, style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                DropdownButton<double>(
                  value: controller.acSystemVoltage,
                  items: controller.acVoltageOptions.map((e) => DropdownMenuItem(value: e, child: Text("${e.toStringAsFixed(0)} V"))).toList(),
                  onChanged: (v) {
                    controller.acSystemVoltage = v ?? 230.0;
                    _recalc();
                  },
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
                  child: Text(AppLocalizations.of(context)!.number_of_batteries, style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                SizedBox(
                  width: 100,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(isDense: true, border: OutlineInputBorder(), hintText: "1"),
                    onChanged: (v) {
                      controller.batteryCalcCountCount = int.tryParse(v) ?? 1;
                      _recalc();
                    },
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

          const SizedBox(height: 30),

          ResultCard(
            title: AppLocalizations.of(context)!.estimated_runtime,
            value: AppLocalizations.of(context)!.runtime_hours_value(controller.batteryCalcRuntimeResult.toStringAsFixed(1)),
            icon: Iconsax.timer_1_bold,
            color: Colors.blue,
          ),

          SizedBox(height: 20),
          _buildHint(context, isDark, AppLocalizations.of(context)!.battery_runtime_formula_hint),
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
              child: Text(AppLocalizations.of(context)!.battery_voltage_label, style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            DropdownButton<double>(
              value: controller.batteryCalcVoltage,
              items: controller.batteryVoltageOptions.map((e) => DropdownMenuItem(value: e, child: Text("$e V"))).toList(),
              onChanged: (v) {
                controller.batteryCalcVoltage = v ?? 12.0;
                _recalc();
              },
            ),
          ],
        ),
        SizedBox(height: 10),
        CalcInputRow(
          label: AppLocalizations.of(context)!.battery_capacity_ah,
          suffix: "Ah",
          hint: "e.g. 200",
          initialValue: controller.batteryCalcAmp,
          onChanged: (v) {
            controller.batteryCalcAmp = double.tryParse(v) ?? 0;
            _recalc();
          },
        ),
      ],
    );
  }

  Widget _buildDoDSlider(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppLocalizations.of(context)!.depth_of_discharge_dod, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text("${controller.batteryCalcDoD.toInt()}%"),
                ],
              ),
              Slider(
                value: controller.batteryCalcDoD,
                min: 10,
                max: 90,
                divisions: 80,
                label: "${controller.batteryCalcDoD.toInt()}%",
                onChanged: (v) {
                  controller.batteryCalcDoD = v;
                  _recalc();
                },
              ),
              Text(AppLocalizations.of(context)!.typical_dod_hint, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        ExplanationButton(explanations: [AppExplanations(context).getBatteryExplanations()[2]]),
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
            AppLocalizations.of(context)!.did_you_know,
            style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
          ),
          const SizedBox(height: 5),
          Text(text, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  // Note: old _showHelpDialog method removed because it's replaced by the new ExplanationButton component.
}
