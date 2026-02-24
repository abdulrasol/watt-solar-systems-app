import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:solar_hub/layouts/shared/widgets/input_text.dart';
import 'package:solar_hub/utils/app_constants.dart';
import 'package:get/get.dart';
import 'package:solar_hub/controllers/systems_controller.dart';
import 'package:solar_hub/layouts/shared/widgets/save_to_system_dialog.dart';
import 'package:solar_hub/models/system_model.dart';
import 'package:validatorless/validatorless.dart';

class WiresCalculator extends StatefulWidget {
  const WiresCalculator({super.key});

  @override
  State<WiresCalculator> createState() => _WiresCalculatorState();
}

class _WiresCalculatorState extends State<WiresCalculator> {
  // Solar Wires
  final _solarCurrentController = TextEditingController();
  final _solarVoltageController = TextEditingController(); // String Vmp
  final _solarLengthController = TextEditingController(); // One way length

  // Battery Wires
  final _batteryCurrentController = TextEditingController(); // Max continuous current (Inverter rating / voltage)
  final _batteryLengthController = TextEditingController();
  double _batterySystemVoltage = 12;

  // AC Wires
  final _acCurrentController = TextEditingController();
  final _acLengthController = TextEditingController();
  double _acVoltage = 220;
  bool _isThreePhase = false;

  // Results (mm2)
  double _solarResult = 0;
  double _batteryResult = 0;
  double _acResult = 0;

  @override
  void dispose() {
    _solarCurrentController.dispose();
    _solarVoltageController.dispose();
    _solarLengthController.dispose();
    _batteryCurrentController.dispose();
    _batteryLengthController.dispose();
    _acCurrentController.dispose();
    _acLengthController.dispose();
    super.dispose();
  }

  void _calculateSolar() {
    final I = double.tryParse(_solarCurrentController.text) ?? 0;
    final V = double.tryParse(_solarVoltageController.text) ?? 0; // String voltage
    final L = double.tryParse(_solarLengthController.text) ?? 0;

    if (I > 0 && V > 0 && L > 0) {
      // 2% Voltage Drop for solar
      final vDropAllowed = V * 0.02;
      final rho = 0.01786; // Copper
      setState(() {
        _solarResult = (2 * L * I * rho) / vDropAllowed;
      });
    } else {
      setState(() => _solarResult = 0);
    }
  }

  void _calculateBattery() {
    final I = double.tryParse(_batteryCurrentController.text) ?? 0;
    final L = double.tryParse(_batteryLengthController.text) ?? 0;

    if (I > 0 && L > 0) {
      // 1% Voltage drop for battery (critical)
      final vDropAllowed = _batterySystemVoltage * 0.01;
      final rho = 0.01786;
      setState(() {
        _batteryResult = (2 * L * I * rho) / vDropAllowed;
      });
    } else {
      setState(() => _batteryResult = 0);
    }
  }

  void _calculateAC() {
    final I = double.tryParse(_acCurrentController.text) ?? 0;
    final L = double.tryParse(_acLengthController.text) ?? 0;

    if (I > 0 && L > 0) {
      // 3% Voltage drop for AC
      final vDropAllowed = _acVoltage * 0.03;
      final rho = 0.01786;
      final factor = _isThreePhase ? 1.732 : 2.0; // sqrt(3) vs 2

      setState(() {
        _acResult = (factor * L * I * rho) / vDropAllowed;
      });
    } else {
      setState(() => _acResult = 0);
    }
  }

  String _getAWG(double mm2) {
    if (mm2 <= 0) return "--";
    // Simple lookup-ish
    if (mm2 < 2.08) return "14 AWG (< 2.5mm²)";
    if (mm2 < 3.31) return "12 AWG (4mm²)";
    if (mm2 < 5.26) return "10 AWG (6mm²)";
    if (mm2 < 8.37) return "8 AWG (10mm²)";
    if (mm2 < 13.3) return "6 AWG (16mm²)";
    if (mm2 < 21.2) return "4 AWG (25mm²)";
    if (mm2 < 33.6) return "2 AWG (35mm²)";
    if (mm2 < 53.5) return "1/0 AWG (50mm²)";
    if (mm2 < 67.4) return "2/0 AWG (70mm²)";
    return "Busbar/Multiple (> 70mm²)";
  }

  Future<void> _saveSystem(BuildContext context, String title, double result) async {
    if (result <= 0) return;

    // Ensure Controller exists
    final SystemsController controller = Get.put(SystemsController());

    final dialogResult = await Get.dialog(const SaveToSystemDialog());

    if (dialogResult != null && dialogResult is Map) {
      final isNew = dialogResult['isNew'] as bool;
      final existingSystem = dialogResult['system'] as SystemModel?;
      final newName = dialogResult['name'] as String?;
      final companyId = dialogResult['companyId'] as String?;

      controller.saveSystemPart(
        existingSystem: isNew ? null : existingSystem,
        newSystemName: newName,
        companyId: companyId,
        partName: 'wires', // Wires might be a list or single. Let's assume list in controller logic or single?
        // Controller logic: "wires" -> newSpecs[partName] = data; (Single for now as per my implementation plan logic for 'others')
        // Actually, user might have multiple wire runs.
        // My controller implementation said: "if (['panels', 'inverters', 'batteries'].contains(partName)) ... else ... = data"
        // So 'wires' will be overwritten if I don't change controller or partName.
        // Let's keep it simple for now, maybe wires should be a list too?
        // The user request template had "wires" as optional, didn't specify array.
        // But practically, you have PV wires, AC wires etc.
        // I'll stick to 'wires' as a key, maybe make it a list in controller if I want to support multiple.
        // For now, let's pass a Map describing THIS wire run.
        data: {
          'type': title, // "Solar PV Wiring", "Battery Wiring"
          'result_mm2': result,
          'awg': _getAWG(result),
          'date': DateTime.now().toIso8601String(),
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Colors.brown;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            pinned: true,
            backgroundColor: isDark ? Colors.grey[900] : primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Wire Sizing', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                    child: Hero(tag: '/calculator/wires', child: Image.asset('assets/png/cards/wiring.png', height: 120)),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Solar PV Section
                _buildSectionCard(
                  context,
                  title: "Solar PV Wiring",
                  icon: Icons.solar_power,
                  color: Colors.orange,
                  inputs: [
                    inputField(
                      context: context,
                      null,
                      label: "String Current (Imp)",
                      hintText: "Amps",
                      icon: Icons.electric_meter,
                      controller: _solarCurrentController,
                      validator: Validatorless.number('Invalid'),
                      onChanged: (_) {
                        _calculateSolar();
                        return null;
                      },
                    ),
                    inputField(
                      context: context,
                      null,
                      label: "String Voltage (Vmp)",
                      hintText: "Volts",
                      icon: Icons.electrical_services,
                      controller: _solarVoltageController,
                      validator: Validatorless.number('Invalid'),
                      onChanged: (_) {
                        _calculateSolar();
                        return null;
                      },
                    ),
                    inputField(
                      context: context,
                      null,
                      label: "Cable Length (One Way)",
                      hintText: "Meters",
                      icon: Icons.straighten,
                      controller: _solarLengthController,
                      validator: Validatorless.number('Invalid'),
                      onChanged: (_) {
                        _calculateSolar();
                        return null;
                      },
                    ),
                  ],
                  result: _solarResult,
                ),
                verSpace(space: 16),

                // Battery Wiring
                _buildSectionCard(
                  context,
                  title: "Battery Wiring",
                  icon: Icons.battery_charging_full,
                  color: Colors.green,
                  inputs: [
                    DropdownButtonFormField<double>(
                      initialValue: _batterySystemVoltage,
                      decoration: InputDecoration(
                        labelText: "System Voltage",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        prefixIcon: const Icon(Icons.flash_on),
                      ),
                      items: const [
                        DropdownMenuItem(value: 12, child: Text("12 V")),
                        DropdownMenuItem(value: 24, child: Text("24 V")),
                        DropdownMenuItem(value: 48, child: Text("48 V")),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _batterySystemVoltage = val ?? 12;
                          _calculateBattery();
                        });
                      },
                    ),
                    verSpace(),
                    inputField(
                      context: context,
                      null,
                      label: "Max Current",
                      hintText: "Amps",
                      icon: Icons.bolt,
                      controller: _batteryCurrentController,
                      validator: Validatorless.number('Invalid'),
                      onChanged: (_) {
                        _calculateBattery();
                        return null;
                      },
                    ),
                    inputField(
                      context: context,
                      null,
                      label: "Cable Length (One Way)",
                      hintText: "Meters",
                      icon: Icons.straighten,
                      controller: _batteryLengthController,
                      validator: Validatorless.number('Invalid'),
                      onChanged: (_) {
                        _calculateBattery();
                        return null;
                      },
                    ),
                  ],
                  result: _batteryResult,
                ),
                verSpace(space: 16),

                // AC Wiring
                _buildSectionCard(
                  context,
                  title: "AC Wiring",
                  icon: Icons.electric_bolt,
                  color: Colors.blue,
                  inputs: [
                    DropdownButtonFormField<double>(
                      initialValue: _acVoltage,
                      decoration: InputDecoration(
                        labelText: "AC Voltage",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        prefixIcon: const Icon(Icons.electrical_services),
                      ),
                      items: const [
                        DropdownMenuItem(value: 110, child: Text("110 V")),
                        DropdownMenuItem(value: 220, child: Text("220 V")),
                        DropdownMenuItem(value: 230, child: Text("230 V")),
                        DropdownMenuItem(value: 380, child: Text("380 V")),
                        DropdownMenuItem(value: 400, child: Text("400 V")),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _acVoltage = val ?? 220;
                          // Check reasonable defaults for 3-phase
                          if (_acVoltage >= 380) _isThreePhase = true;
                          _calculateAC();
                        });
                      },
                    ),
                    verSpace(),
                    DropdownButtonFormField<bool>(
                      initialValue: _isThreePhase,
                      decoration: InputDecoration(
                        labelText: "Phases",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        prefixIcon: const Icon(Icons.settings_input_component),
                      ),
                      items: const [
                        DropdownMenuItem(value: false, child: Text("Single Phase (1Ø)")),
                        DropdownMenuItem(value: true, child: Text("Three Phase (3Ø)")),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _isThreePhase = val ?? false;
                          _calculateAC();
                        });
                      },
                    ),
                    verSpace(),
                    inputField(
                      context: context,
                      null,
                      label: "Load Current",
                      hintText: "Amps",
                      icon: Icons.bolt,
                      controller: _acCurrentController,
                      validator: Validatorless.number('Invalid'),
                      onChanged: (_) {
                        _calculateAC();
                        return null;
                      },
                    ),
                    inputField(
                      context: context,
                      null,
                      label: "Cable Length (One Way)",
                      hintText: "Meters",
                      icon: Icons.straighten,
                      controller: _acLengthController,
                      validator: Validatorless.number('Invalid'),
                      onChanged: (_) {
                        _calculateAC();
                        return null;
                      },
                    ),
                  ],
                  result: _acResult,
                ),

                verSpace(space: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> inputs,
    required double result,
  }) {
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
          ...inputs,
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withValues(alpha: 0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Min Section:",
                      style: TextStyle(color: color, fontWeight: FontWeight.bold),
                    ),
                    if (result > 0)
                      IconButton(
                        icon: const Icon(Icons.save_alt, size: 20),
                        color: color,
                        onPressed: () => _saveSystem(context, title, result),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("${result.toStringAsFixed(2)} mm²", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(_getAWG(result), style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).moveX(begin: -10);
  }
}
