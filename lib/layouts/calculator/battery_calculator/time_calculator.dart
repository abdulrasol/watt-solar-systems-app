import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/calculations/home_solar_system_calculator.dart';
//import 'package:solar_hub/controllers/data_controller.dart';

import 'package:solar_hub/utils/app_constants.dart';
import 'package:solar_hub/layouts/widgets/input_text.dart';
import 'package:solar_hub/layouts/widgets/text_helper_card.dart';
import 'package:validatorless/validatorless.dart';
import 'package:flutter_animate/flutter_animate.dart';

//final DataController dataContrller = Get.find();

class TimeCalculator extends StatefulWidget {
  const TimeCalculator({super.key});

  @override
  State<TimeCalculator> createState() => _TimeCalculatorState();
}

class _TimeCalculatorState extends State<TimeCalculator> {
  final userCurrent = TextEditingController(text: '0');
  final voltage = TextEditingController(text: '0');
  final current = TextEditingController(text: '0');
  final numbers = TextEditingController(text: '0');

  // Default value for Depth of Discharge (DoD)
  num depthOfDischarge = 80;
  num systemVoltage = 230;
  // Result value: running time in hours
  num runningTime = 0;

  /// Divider widget for spacing
  Widget divider = verSpace(space: 18);

  /// Recalculates battery running time based on input fields
  String? _updateRunningTime(String? v) {
    final ampereInput = num.tryParse(userCurrent.text) ?? 0;
    final voltageInput = num.tryParse(voltage.text) ?? 0;
    final currentInput = num.tryParse(current.text) ?? 0;
    final numbersInput = num.tryParse(numbers.text) ?? 0;
    final dod = depthOfDischarge;

    if (ampereInput > 0 &&
        voltageInput > 0 &&
        currentInput > 0 &&
        numbersInput > 0) {
      num dailyUsageKWh = 0;
      setState(() {
        if (systemVoltage == 380) {
          dailyUsageKWh = sqrt(3) * ampereInput * systemVoltage;
        } else {
          dailyUsageKWh = ampereInput * systemVoltage;
        }
        runningTime = HomeSolarSystemCalculator.calculateBatteryBankTimeRunning(
          dailyUsageKWh: dailyUsageKWh.toDouble(),
          batteryVoltage: voltageInput.toDouble(),
          batteryCapacityAh: currentInput.toDouble(),
          dod: dod.toDouble(),
          batteryCount: numbersInput.toInt(),
        );
      });
    } else {
      setState(() {
        runningTime = 0;
      });

      // var a = {
      //   'user-power': 0,
      //   'user-battery-voltage': 0,
      //   'user-battery-ampere': 0,
      //   'user-battery-count': 0,
      //   'user-battery-depht': 80,
      //   'user-battery-runtime': 0,
      //   'user-charge-current': 0,
      // };
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _updateRunningTime(null);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  //  verSpace(),
                  Hero(
                    tag: '/battery',
                    child: Image.asset(
                      'assets/png/cards/battery.png',
                      height: 180,
                    ),
                  ),
                  verSpace(),
                  ..._buildFormFields()
                      .animate(interval: 100.ms)
                      .fadeIn()
                      .slideY(),

                  // Display calculated result
                  //  verSpace(space: 20),
                  verSpace(space: 50),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 10,
            right: 10,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${runningTime.toStringAsFixed(2)} hours',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              // fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFormFields() {
    return [
      // Hero(
      //     tag: '/battery',
      //     child: Image.asset('assets/png/cards/battery.png', height: 180)),
      inputField(
        null,
        context: context,
        label: 'your-load-ampere'.tr,
        hintText: 'e.g., 10',
        icon: FontAwesome.bolt_solid,
        controller: userCurrent,
        validator: Validatorless.multiple([
          Validatorless.required('required'.tr),
          Validatorless.number('numbers'.tr),
        ]),
        onChanged: _updateRunningTime,
      ),
      _buildSystemVoltageSelector(),
      divider,
      textHelperCard(
        context,
        text:
            'Enter your load in Ampere and select AC Voltage System. Usually load calculate by: Voltage × Current. For example, 10A × 230V = 2300W.',
      ),
      divider,
      Column(
        children: [
          inputField(
            context: context,
            null,
            label: 'battery-amperes'.tr,
            hintText: 'e.g., 100 or 200',
            icon: FontAwesome.i_solid,
            controller: current,
            validator: Validatorless.multiple([
              Validatorless.required('required'.tr),
              Validatorless.number('numbers'.tr),
            ]),
            onChanged: _updateRunningTime,
          ),
          horSpace(space: 5),
          inputField(
            context: context,
            null,
            label: 'battrey-voltage'.tr,
            hintText: 'e.g., 12, 24, 48 or 51.2 for lithum',
            icon: FontAwesome.v_solid,
            controller: voltage,
            validator: Validatorless.multiple([
              Validatorless.required('required'.tr),
              Validatorless.number('numbers'.tr),
            ]),
            onChanged: _updateRunningTime,
          ),
          horSpace(space: 5),
          inputField(
            context: context,
            null,
            label: 'battrey-count'.tr,
            hintText: 'one or more',
            icon: FontAwesome.n_solid,
            controller: numbers,
            validator: Validatorless.multiple([
              Validatorless.required('required'.tr),
              Validatorless.number('numbers'.tr),
            ]),
            onChanged: _updateRunningTime,
          ),
        ],
      ),
      verSpace(),
      textHelperCard(
        context,
        text:
            'Enter the battery\'s capacity (Ah), voltage (V), and the number of batteries you have.\n'
            'The system\'s total energy is calculated as:\n'
            'Voltage × Capacity × Number of Batteries × Depth of Discharge.\n\n'
            '• Example: 4 batteries × 12V × 100Ah × 0.2 (for 20% DoD) = 960Wh\n'
            'This value is used to estimate how long the battery system can power your load.',
      ),
      divider,
      Text(
        'Depth of Discharge of Battery ($depthOfDischarge%)',
        style: Theme.of(context).textTheme.titleMedium,
        textAlign: TextAlign.start,
      ),
      verSpace(space: 8),
      Slider(
        value: depthOfDischarge.toDouble(),
        min: 0,
        max: 100,
        divisions: 100,
        label: '${depthOfDischarge.toStringAsFixed(0)}%',
        onChanged: (value) {
          setState(() {
            depthOfDischarge = value;
            _updateRunningTime('value');
          });
        },
      ),
      verSpace(space: 4),
      textHelperCard(
        context,
        text:
            'Set the Depth of Discharge (DoD) percentage for the battery.\n\nTypical values range between 50%–80% depending on battery type, temperature, and manufacturer details.\n\n• Use 20% for Lithium or Tubular batteries.\n• Use 50% for AGM/Gel batteries.\nRefer to the datasheet or label if unsure.',
      ),
      verSpace(),
      verSpace(space: 25),
    ];
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
          _updateRunningTime(null);
        });
      },
    );
  }
}
 // Controllers for input fields
  // final userCurrent = TextEditingController(
  //     text:
  //         dataContrller.batteryCalculatedData.value['user-current'].toString());
  // final voltage = TextEditingController(
  //     text: dataContrller.batteryCalculatedData.value['user-battery-voltage']
  //         .toString());
  // final current = TextEditingController(
  //     text: dataContrller.batteryCalculatedData.value['user-battery-ampere']
  //         .toString());
  // final numbers = TextEditingController(
  //     text: dataContrller.batteryCalculatedData.value['user-battery-count']
  //         .toString());

  // // Default value for Depth of Discharge (DoD)
  // num depthOfDischarge =
  //     dataContrller.batteryCalculatedData.value['user-battery-depht'];
  // num systemVoltage =
  //     dataContrller.batteryCalculatedData.value['ac-voltage-system'];
  // // Result value: running time in hours
  // num runningTime = 0;
