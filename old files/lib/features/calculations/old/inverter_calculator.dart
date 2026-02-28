import 'package:flutter/material.dart';

import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/calculations/home_solar_system_calculator.dart';
// import 'package:solar_hub/controllers/data_controller.dart';
import 'package:validatorless/validatorless.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../lib/src/features/calculations/presentation/widgets/input_text.dart';
import '../../../../../lib/src/features/calculations/presentation/widgets/text_helper_card.dart';
import 'package:solar_hub/utils/app_constants.dart';

// final DataController dataContrller = Get.find();

class InverterCalculator extends StatefulWidget {
  const InverterCalculator({super.key});

  @override
  State<InverterCalculator> createState() => _InverterCalculatorState();
}

class _InverterCalculatorState extends State<InverterCalculator> {
  final currentInput = TextEditingController(text: '0');
  final batteryVoltage = TextEditingController(text: '0');
  final batteryCapacity = TextEditingController(text: '0');
  final batteryCount = TextEditingController(text: '0');
  final chargeCurrent = TextEditingController(text: '0');

  num systemVoltage = 230;
  String batteryType = 'Lithium';
  num depthOfDischarge = 80;

  num inverterSize = 0;
  num chargingTime = 0;
  num dischargingTime = 0;
  num recommendedChargeCurrent = 0;

  GlobalKey<FormState> key = GlobalKey<FormState>();

  @override
  void dispose() {
    currentInput.dispose();
    batteryVoltage.dispose();
    batteryCapacity.dispose();
    batteryCount.dispose();
    chargeCurrent.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Initialize defaults or load if needed
  }

  String? _calculate([String? v]) {
    final current = num.tryParse(currentInput.text) ?? 0;
    final load = current * systemVoltage;

    final battVolt = num.tryParse(batteryVoltage.text) ?? 0;
    final capacityAh = num.tryParse(batteryCapacity.text) ?? 0;
    final count = num.tryParse(batteryCount.text) ?? 0;
    final userChargeCurrent = num.tryParse(chargeCurrent.text) ?? 0;

    setState(() {
      if (current > 0 && battVolt > 0 && capacityAh > 0 && count > 0) {
        Map data = HomeSolarSystemCalculator.calculateInverterSize(
          peakLoadWatt: load.toDouble(),
          batteryAh: capacityAh.toDouble(),
          batteryVoltage: battVolt.toDouble(),
          batteryCount: count.toDouble(),
          batteryUserChargeCurrent: userChargeCurrent.toDouble(),
          batteryType: batteryType,
          dod: depthOfDischarge.toDouble(),
        );
        inverterSize = data['inverterSize'];
        chargingTime = data['chargingTime'];
        dischargingTime = data['dischargingTime'];
        recommendedChargeCurrent = data['recommendedChargeCurrent'];
      } else {
        inverterSize = 0;
        chargingTime = 0;
        dischargingTime = 0;
        recommendedChargeCurrent = 0;
      }
    });

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Colors.blue;

    return Scaffold(
      body: Form(
        key: key,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200.0,
              pinned: true,
              backgroundColor: isDark ? Colors.grey[900] : primaryColor,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text('Inverter & Charging', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                      child: Hero(tag: '/calculator/inverter', child: Image.asset('assets/png/cards/inverter.png', height: 120)),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (inverterSize > 0) _buildResultCard(context, primaryColor),
                  verSpace(space: 16),

                  // Section 1: System Load
                  _buildSectionCard(
                    context,
                    title: 'System Loads',
                    icon: Icons.electric_bolt,
                    color: primaryColor,
                    children: [
                      inputField(
                        context: context,
                        'Enter your current in amperes. Power = Current × System Voltage',
                        label: 'Current (A)',
                        hintText: 'e.g., 10',
                        icon: FontAwesome.i_solid,
                        controller: currentInput,
                        validator: Validatorless.multiple([Validatorless.required('Required'), Validatorless.number('Numbers only')]),
                        onChanged: _calculate,
                      ),
                      verSpace(),
                      _buildSystemVoltageSelector(),
                    ],
                  ),
                  verSpace(space: 16),

                  // Section 2: Battery Configuration
                  _buildSectionCard(
                    context,
                    title: 'Battery Bank',
                    icon: Icons.battery_full,
                    color: Colors.purple,
                    children: [
                      _buildBatteryTypeDropdown(),
                      verSpace(),
                      inputField(
                        context: context,
                        null,
                        label: 'Battery Voltage (V)',
                        hintText: 'e.g., 12, 24, 48',
                        icon: FontAwesome.v_solid,
                        controller: batteryVoltage,
                        validator: Validatorless.multiple([Validatorless.required('Required'), Validatorless.number('Numbers only')]),
                        onChanged: _calculate,
                      ),
                      inputField(
                        context: context,
                        null,
                        label: 'Battery Capacity (Ah)',
                        hintText: 'e.g., 100',
                        icon: FontAwesome.battery_half_solid,
                        controller: batteryCapacity,
                        validator: Validatorless.multiple([Validatorless.required('Required'), Validatorless.number('Numbers only')]),
                        onChanged: _calculate,
                      ),
                      inputField(
                        context: context,
                        null,
                        label: 'Battery Count',
                        hintText: 'e.g., 4',
                        icon: FontAwesome.n_solid,
                        controller: batteryCount,
                        validator: Validatorless.multiple([Validatorless.required('Required'), Validatorless.number('Numbers only')]),
                        onChanged: _calculate,
                      ),
                      verSpace(),
                      Text('Depth of Discharge: ${depthOfDischarge.toInt()}%', style: const TextStyle(fontWeight: FontWeight.w500)),
                      Slider(
                        value: depthOfDischarge.toDouble(),
                        min: 10,
                        max: 100,
                        divisions: 90,
                        activeColor: primaryColor,
                        label: '${depthOfDischarge.toStringAsFixed(0)}%',
                        onChanged: (value) {
                          setState(() {
                            depthOfDischarge = value;
                            _calculate();
                          });
                        },
                      ),
                      textHelperCard(context, title: 'Recommended DoD: 20% for Lithium, 50% for AGM/Gel.'),
                    ],
                  ),
                  verSpace(space: 16),

                  // Section 3: Charging
                  _buildSectionCard(
                    context,
                    title: 'Charging Parameters',
                    icon: Icons.charging_station,
                    color: Colors.green,
                    children: [
                      inputField(
                        context: context,
                        'Optional: Leave empty to auto-calculate based on battery type.',
                        label: 'Charge Current (A)',
                        hintText: 'e.g., 20',
                        icon: FontAwesome.charging_station_solid,
                        controller: chargeCurrent,
                        validator: Validatorless.number('Numbers only'),
                        onChanged: _calculate,
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
      color: Colors.white,
      surfaceTintColor: color,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildResultItem('Inverter Size', '${inverterSize.toStringAsFixed(1)} KW', color),
                _buildResultItem('Charge Current', '${recommendedChargeCurrent.toStringAsFixed(1)} A', Colors.green),
              ],
            ),
            const Divider(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildResultItem('Charge Time', '${chargingTime.toStringAsFixed(1)} hrs', Colors.orange),
                _buildResultItem('Discharge Time', '${dischargingTime.toStringAsFixed(1)} hrs', Colors.red),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn().moveY(begin: 20);
  }

  Widget _buildResultItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
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

  Widget _buildBatteryTypeDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: batteryType,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        labelText: 'Battery Type',
        prefixIcon: const Icon(Icons.battery_charging_full_rounded),
      ),
      items: const [
        DropdownMenuItem(value: 'Lithium', child: Text('Lithium')),
        DropdownMenuItem(value: 'Lead-Acid', child: Text('Lead-Acid')),
      ],
      onChanged: (value) {
        setState(() {
          batteryType = value!;
          _calculate();
        });
      },
    );
  }

  Widget _buildSystemVoltageSelector() {
    return DropdownButtonFormField<num>(
      initialValue: systemVoltage,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        labelText: 'System Voltage (AC)',
        prefixIcon: const Icon(Icons.electrical_services_rounded),
      ),
      items: const [
        DropdownMenuItem(value: 110, child: Text('110 V')),
        DropdownMenuItem(value: 230, child: Text('230 V')),
        DropdownMenuItem(value: 380, child: Text('380 V (Three-phase)')),
      ],
      onChanged: (value) {
        setState(() {
          systemVoltage = value ?? 230;
          _calculate();
        });
      },
    );
  }
}
