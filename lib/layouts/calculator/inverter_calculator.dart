import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
//import 'package:solar_hub/controllers/data_controller.dart';
import 'package:validatorless/validatorless.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:solar_hub/layouts/widgets/input_text.dart';
import 'package:solar_hub/layouts/widgets/text_helper_card.dart';
import 'package:solar_hub/utils/app_constants.dart';

//final DataController dataContrller = Get.find();

class InverterCalculator extends StatefulWidget {
  const InverterCalculator({super.key});

  @override
  State<InverterCalculator> createState() => _InverterCalculatorState();
}

class _InverterCalculatorState extends State<InverterCalculator> {
  // final currentInput = TextEditingController(
  //     text: dataContrller.userCalculatedSystem.value['inverter']['user-current']
  //         .toString());
  // final batteryVoltage = TextEditingController(
  //     text: dataContrller
  //         .userCalculatedSystem.value['inverter']['user-battery-voltage']
  //         .toString());
  // final batteryCapacity = TextEditingController(
  //     text: dataContrller
  //         .userCalculatedSystem.value['inverter']['user-battery-capacity']
  //         .toString());
  // final batteryCount = TextEditingController(
  //     text: dataContrller
  //         .userCalculatedSystem.value['inverter']['user-battery-count']
  //         .toString());
  // final chargeCurrent = TextEditingController(
  //     text: dataContrller
  //         .userCalculatedSystem.value['inverter']['user-charge-current']
  //         .toString());

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
  void initState() {
    super.initState();
    // systemVoltage = dataContrller
    //     .userCalculatedSystem
    //     .value['inverter']['ac-voltage-system'];
    // batteryType = dataContrller
    //     .userCalculatedSystem
    //     .value['inverter']['user-battery-type'];
    // depthOfDischarge = dataContrller
    //     .userCalculatedSystem
    //     .value['inverter']['user-battery-depht'];
  }

  String? _calculate([String? v]) {
    final current = num.tryParse(currentInput.text) ?? 0;
    final load = current * systemVoltage;

    final battVolt = num.tryParse(batteryVoltage.text) ?? 0;
    final capacity = num.tryParse(batteryCapacity.text) ?? 0;
    final count = num.tryParse(batteryCount.text) ?? 0;
    final userChargeCurrent = num.tryParse(chargeCurrent.text) ?? 0;

    final totalCapacity = capacity * count;

    if (current > 0 && battVolt > 0 && capacity > 0 && count > 0) {
      inverterSize = load * 1.25;

      if (batteryType == 'Lithium') {
        recommendedChargeCurrent = totalCapacity / 3;
      } else if (batteryType == 'Lead-Acid') {
        recommendedChargeCurrent = totalCapacity * 0.1;
      }

      final usedChargeCurrent = userChargeCurrent > 0
          ? userChargeCurrent
          : recommendedChargeCurrent;

      chargingTime = usedChargeCurrent > 0
          ? totalCapacity / usedChargeCurrent
          : 0;

      final energy = battVolt * totalCapacity;
      dischargingTime =
          energy * (depthOfDischarge / 100) / load; // DoD used here
    } else {
      inverterSize = 0;
      chargingTime = 0;
      dischargingTime = 0;
      recommendedChargeCurrent = 0;
    }

    setState(() {});
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inverter and Charging Calculator'),
        actions: [
          TextButton.icon(
            onPressed: () {
              _updateData();
            },
            label: Text('Save'),
            icon: Icon(IonIcons.save),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                child: Form(
                  key: key,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Hero(
                        tag: '/inverter',
                        child: Image.asset(
                          'assets/png/cards/inverter.png',
                          height: 180,
                        ),
                      ),
                      verSpace(),
                      ..._buildFormFields()
                          .animate(interval: 100.ms)
                          .fadeIn()
                          .slideY(),
                      verSpace(space: inverterSize > 0 ? 135 : 65),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 10,
              right: 10,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: _buildResults(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFormFields() {
    return [
      inputField(
        context: context,
        'Enter your current in amperes. Power = Current × System Voltage',
        label: 'Current (A)',
        hintText: 'e.g., 10',
        icon: FontAwesome.i_solid,
        controller: currentInput,
        validator: Validatorless.multiple([
          Validatorless.required('Required'),
          Validatorless.number('Numbers only'),
        ]),
        onChanged: _calculate,
      ),
      verSpace(),
      _buildSystemVoltageSelector(),
      verSpace(),
      _buildBatteryTypeDropdown(),
      verSpace(),
      inputField(
        context: context,
        null,
        label: 'Battery Voltage (V)',
        hintText: 'e.g., 12, 24, 48',
        icon: FontAwesome.v_solid,
        controller: batteryVoltage,
        validator: Validatorless.multiple([
          Validatorless.required('Required'),
          Validatorless.number('Numbers only'),
        ]),
        onChanged: _calculate,
      ),
      inputField(
        context: context,
        null,
        label: 'Battery Capacity (Ah)',
        hintText: 'e.g., 100',
        icon: FontAwesome.battery_half_solid,
        controller: batteryCapacity,
        validator: Validatorless.multiple([
          Validatorless.required('Required'),
          Validatorless.number('Numbers only'),
        ]),
        onChanged: _calculate,
      ),
      inputField(
        context: context,
        null,
        label: 'Battery Count',
        hintText: 'e.g., 4',
        icon: FontAwesome.n_solid,
        controller: batteryCount,
        validator: Validatorless.multiple([
          Validatorless.required('Required'),
          Validatorless.number('Numbers only'),
        ]),
        onChanged: _calculate,
      ),
      verSpace(),
      Text(
        'Depth of Discharge (%)',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      Slider(
        value: depthOfDischarge.toDouble(),
        min: 10,
        max: 100,
        divisions: 90,
        label: '${depthOfDischarge.toStringAsFixed(0)}%',
        onChanged: (value) {
          setState(() {
            depthOfDischarge = value;
            _calculate();
          });
        },
      ),
      textHelperCard(
        context,
        title:
            'Set the Depth of Discharge (DoD) percentage for the battery.\n\nTypical values range between 50%–80% depending on battery type, temperature, and manufacturer details.\n\n• Use 20% for Lithium or Tubular batteries.\n• Use 50% for AGM/Gel batteries.\nRefer to the datasheet or label if unsure.',
      ),
      verSpace(),
      inputField(
        context: context,
        'Optional: Leave empty to auto-calculate based on battery type.\n\n'
        '- Lead-Acid: Use recommended C-rate (e.g., C/10 = 10% of total Ah).\n'
        '- Lithium: Use datasheet value or 0.5 × total Ah × battery count.\n\n'
        'Examples:\n• 200Ah Lead-Acid → C/10 ≈ 20A\n• 100Ah Lithium ×4 → 200A',
        label: 'Charge Current (A)',
        hintText: 'e.g., 20',
        icon: FontAwesome.charging_station_solid,
        controller: chargeCurrent,
        validator: Validatorless.number('Numbers only'),
        onChanged: _calculate,
      ),
      verSpace(),
      textHelperCard(
        context,
        title:
            'Enter your AC load current and select the system voltage.\nThen fill battery specs and select type.\nResults will auto-update.',
      ),
    ];
  }

  Widget _buildBatteryTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: batteryType,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
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
      value: systemVoltage,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
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

  Widget _buildResults(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          inverterSize > 0
              ? 'Estimated Inverter Size: ${(inverterSize / 1000).toStringAsFixed(1)} KW (${(inverterSize / 1000).ceil()}KW)'
              : 'Fill inputs to calculate inverter size.',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (recommendedChargeCurrent > 0)
          Text(
            'Recommended Charge Current: ${recommendedChargeCurrent.toStringAsFixed(1)} A',
          ),
        if (chargingTime > 0)
          Text('Charging Time: ${chargingTime.toStringAsFixed(2)} hrs'),
        if (dischargingTime > 0)
          Text(
            'Discharging Time (with DoD ${depthOfDischarge.toInt()}%): ${dischargingTime.toStringAsFixed(2)} hrs',
          ),
      ],
    );
  }

  void _updateData() async {
    if (key.currentState!.validate()) {
      num userChargeCurrent = 0;
      //set charge cureent
      if (!chargeCurrent.text.isNum || chargeCurrent.text == '') {
        chargeCurrent.text = '0';
      } else {
        userChargeCurrent = num.parse(chargeCurrent.text);
      }
      final acVoltageSystem = systemVoltage;
      final userCurrent = num.parse(currentInput.text);

      final batteryVoltageSystem = num.parse(batteryVoltage.text);
      final userBatteryType = batteryType;
      final userBatteryVoltage = num.parse(batteryVoltage.text);
      final userBatteryCapacity = num.parse(batteryCapacity.text);
      final userBatteryCount = num.parse(batteryCount.text);
      final userBatteryDepht = depthOfDischarge;
      final power = inverterSize;

      final data = {
        'power': power,
        'battery-voltage-system': batteryVoltageSystem,
        'ac-voltage-system': acVoltageSystem,
        'user-current': userCurrent,
        'user-battery-type': userBatteryType,
        'user-battery-voltage': userBatteryVoltage,
        'user-battery-capacity': userBatteryCapacity,
        'user-battery-count': userBatteryCount,
        'user-battery-depht': userBatteryDepht,
        'user-charge-current': userChargeCurrent,
      };

      // await dataContrller
      //     .updateUserCalculatedSystemData(UserSystemDataPart.inverter, data)
      //     .then(
      //       (onValue) => Get.snackbar(
      //         'Inverter',
      //         'data saved successfully',
      //         icon: Icon(IonIcons.save),
      //       ),
      //     );
    } else {
      Get.snackbar(
        'Error',
        'data enterd invalid value',
        icon: Icon(IonIcons.warning),
      );
    }
  }
}
