import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/calculations/home_solar_system_calculator.dart';
import 'package:solar_hub/layouts/shared/widgets/input_text.dart';
import 'package:solar_hub/layouts/shared/widgets/text_helper_card.dart';
import 'package:solar_hub/utils/app_constants.dart';
import 'package:validatorless/validatorless.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PanelCalculator extends StatefulWidget {
  const PanelCalculator({super.key});

  @override
  State<PanelCalculator> createState() => _PanelCalculatorState();
}

class _PanelCalculatorState extends State<PanelCalculator> {
  final activeHours = TextEditingController(text: '0');
  final dayLoad = TextEditingController(text: '0');
  final batteryCapacity = TextEditingController(text: '0');
  final panelWattage = TextEditingController(text: '0');

  final gridFeedCapacity = TextEditingController(text: '0');
  final gridChargeHours = TextEditingController(text: '0');
  final gridChargeCurrent = TextEditingController(text: '0');

  bool batteryCharge = true;
  bool gridFeed = false;
  double panelEfficiencyValue = 80;

  num panels = 0;

  GlobalKey<FormState> key = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    batteryCharge = false;
    gridFeed = false;
    panelEfficiencyValue = 70;
    _updatePanelsNum('');
  }

  @override
  void dispose() {
    activeHours.dispose();
    dayLoad.dispose();
    batteryCapacity.dispose();
    panelWattage.dispose();
    gridFeedCapacity.dispose();
    gridChargeHours.dispose();
    gridChargeCurrent.dispose();
    super.dispose();
  }

  String? _updatePanelsNum(value) {
    setState(() {
      num loadinput = num.tryParse(dayLoad.text) ?? 0;
      num activeHoursInput = num.tryParse(activeHours.text) ?? 0;
      num batteryCapacityInput = num.tryParse(batteryCapacity.text) ?? 0;
      num panelWattageInput = num.tryParse(panelWattage.text) ?? 0;
      num gridFeedCapacityInput = num.tryParse(gridFeedCapacity.text) ?? 0;
      num gridChargeHoursInput = num.tryParse(gridChargeHours.text) ?? 0;
      num gridChargeCurrentInput = num.tryParse(gridChargeCurrent.text) ?? 0;

      num effativepanelWatts = panelWattageInput * (panelEfficiencyValue / 100);

      if (loadinput <= 0 || panelWattageInput <= 0 || activeHoursInput <= 0) {
        panels = 0; // Reset if invalid
        return;
      }

      panels = HomeSolarSystemCalculator.calculatePanelCount(
        dayloadAmpere: loadinput,
        activeHours: activeHoursInput,
        batteryCapacityInput: batteryCapacityInput,
        panelWattage: panelWattageInput,
        gridFeedWattge: gridFeedCapacityInput,
        gridChargeCurrent: gridChargeCurrentInput,
        gridChargeHours: gridChargeHoursInput,
        effativepanelWatts: effativepanelWatts,
        batteryCharge: batteryCharge,
        gridFeed: gridFeed,
      );
    });
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Colors.teal; // Theme color for this calculator

    return Scaffold(
      body: Form(
        key: key,
        child: CustomScrollView(
          slivers: [
            // Hero AppBar
            SliverAppBar(
              expandedHeight: 200.0,
              pinned: true,
              backgroundColor: isDark ? Colors.grey[900] : primaryColor,
              flexibleSpace: FlexibleSpaceBar(
                title: Text('panel-calculator'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [primaryColor.withValues(alpha: 0.8), primaryColor.withValues(alpha: 0.2)],
                        ),
                      ),
                    ),
                    Center(
                      child: Hero(tag: '/calculator/panel', child: Image.asset('assets/png/cards/panels.png', height: 120)),
                    ),
                  ],
                ),
              ),
            ),
            // Content
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Result Card (Top for visibility)
                  _buildResultCard(context, primaryColor),
                  verSpace(space: 16),

                  // Section 1: Panel Specifications
                  _buildSectionCard(
                    context,
                    title: 'Panel Specifications',
                    icon: FontAwesome.solar_panel_solid,
                    color: primaryColor,
                    children: [
                      inputField(
                        context: context,
                        'Panel wattage (in Watts), usually written on the label or datasheet.',
                        label: 'panel-wattage'.tr,
                        hintText: 'e.g., 450',
                        icon: FontAwesome.bolt_solid,
                        controller: panelWattage,
                        validator: Validatorless.multiple([Validatorless.required('Required'), Validatorless.number('Numbers only')]),
                        onChanged: _updatePanelsNum,
                      ),
                      verSpace(),
                      Text('Panel Efficiency: ${panelEfficiencyValue.toInt()}%', style: const TextStyle(fontWeight: FontWeight.w500)),
                      Slider(
                        value: panelEfficiencyValue.toDouble(),
                        min: 60,
                        max: 100,
                        divisions: 40,
                        activeColor: primaryColor,
                        label: '${panelEfficiencyValue.toStringAsFixed(0)}%',
                        onChanged: (value) {
                          setState(() {
                            panelEfficiencyValue = value;
                            _updatePanelsNum(value);
                          });
                        },
                      ),
                      textHelperCard(context, text: 'Typical efficiency is 70-80% taking losses into account.'),
                    ],
                  ),
                  verSpace(space: 16),

                  // Section 2: Load & Usage
                  _buildSectionCard(
                    context,
                    title: 'Consumption & Sunlight',
                    icon: Icons.wb_sunny_rounded,
                    color: Colors.orange,
                    children: [
                      inputField(
                        'How many amperes required during daytime.',
                        context: context,
                        label: 'day-load-in-ampere'.tr,
                        hintText: 'e.g., 10',
                        icon: Icons.electrical_services,
                        controller: dayLoad,
                        validator: Validatorless.multiple([Validatorless.required('Required'), Validatorless.number('Numbers only')]),
                        onChanged: _updatePanelsNum,
                      ),
                      verSpace(),
                      inputField(
                        'Active sun hours (peak sun hours). ~6 hours in average regions.',
                        context: context,
                        label: 'active-pv-hours-in-h'.tr,
                        hintText: 'e.g., 6',
                        icon: Icons.access_time_filled,
                        controller: activeHours,
                        validator: Validatorless.multiple([Validatorless.required('Required'), Validatorless.number('Numbers only')]),
                        onChanged: _updatePanelsNum,
                      ),
                    ],
                  ),
                  verSpace(space: 16),

                  // Section 3: Battery & Grid
                  _buildSectionCard(
                    context,
                    title: 'Battery & Grid Options',
                    icon: Icons.battery_charging_full,
                    color: Colors.blue,
                    children: [
                      // Battery Toggle
                      SwitchListTile(
                        title: Text('battery-charge-or-not?'.tr, style: const TextStyle(fontWeight: FontWeight.w500)),
                        value: batteryCharge,
                        activeTrackColor: primaryColor,
                        onChanged: (value) {
                          setState(() {
                            batteryCharge = value;
                            _updatePanelsNum(value);
                          });
                        },
                      ),
                      if (batteryCharge) ...[
                        inputField(
                          'Total battery capacity in Watts (Volts x Amps x Count).',
                          context: context,
                          label: 'battery-charge-in-w'.tr,
                          hintText: 'e.g., 5120',
                          icon: Icons.battery_std,
                          controller: batteryCapacity,
                          validator: Validatorless.number('Numbers only'),
                          onChanged: _updatePanelsNum,
                        ),
                        verSpace(),
                        Row(
                          children: [
                            Expanded(
                              child: inputField(
                                null,
                                context: context,
                                label: 'grid-charge-current'.tr,
                                hintText: 'e.g., 15A',
                                icon: Icons.power_input,
                                controller: gridChargeCurrent,
                                validator: Validatorless.number('Numbers only'),
                                onChanged: _updatePanelsNum,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: inputField(
                                null,
                                context: context,
                                label: 'grid-charge-hours'.tr,
                                hintText: 'e.g., 4h',
                                icon: Icons.timer,
                                controller: gridChargeHours,
                                validator: Validatorless.number('Numbers only'),
                                onChanged: _updatePanelsNum,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const Divider(),
                      // Grid Feed Toggle
                      SwitchListTile(
                        title: Text('grid-feed-or-not?'.tr, style: const TextStyle(fontWeight: FontWeight.w500)),
                        value: gridFeed,
                        activeTrackColor: primaryColor,
                        onChanged: (value) {
                          setState(() {
                            gridFeed = value;
                            _updatePanelsNum(value);
                          });
                        },
                      ),
                      if (gridFeed)
                        inputField(
                          'Power to export to grid (Watts).',
                          context: context,
                          label: 'grid-feed-power'.tr,
                          hintText: 'e.g., 1000',
                          icon: Icons.outbond,
                          controller: gridFeedCapacity,
                          validator: Validatorless.number('Numbers only'),
                          onChanged: _updatePanelsNum,
                        ),
                    ],
                  ),
                  verSpace(space: 40),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(BuildContext context, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text('Required Panels', style: TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 8),
            Text(
              '${panels.ceil()}',
              style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const Text('Units', style: TextStyle(color: Colors.white70, fontSize: 14)),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).moveY(begin: 20);
  }

  Widget _buildSectionCard(BuildContext context, {required String title, required IconData icon, required Color color, required List<Widget> children}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const Divider(height: 24),
          ...children,
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).moveX(begin: -10);
  }
}
