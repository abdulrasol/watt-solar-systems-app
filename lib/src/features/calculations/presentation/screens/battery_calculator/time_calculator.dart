import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/src/features/calculations/domain/usecases/home_solar_system_calculator.dart';
//import 'package:solar_hub/controllers/data_controller.dart';

import 'package:solar_hub/src/utils/app_constants.dart';
import 'package:solar_hub/src/features/calculations/presentation/widgets/input_text.dart';
import 'package:solar_hub/src/features/calculations/presentation/widgets/text_helper_card.dart';
import 'package:validatorless/validatorless.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:solar_hub/l10n/app_localizations.dart';

//final DataController dataContrller = Get.find();

class TimeCalculator extends ConsumerStatefulWidget {
  const TimeCalculator({super.key});

  @override
  ConsumerState<TimeCalculator> createState() => _TimeCalculatorState();
}

class _TimeCalculatorState extends ConsumerState<TimeCalculator> {
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
                  // Hero(
                  //   tag: '/battery',
                  //   child: Image.asset(
                  //     'assets/png/cards/battery.png',
                  //     height: 180,
                  //   ),
                  // ),
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
                        AppLocalizations.of(context)!.runtime_hours_precise(
                          runningTime.toStringAsFixed(2),
                        ),
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
        label: AppLocalizations.of(context)!.your_load_ampere,
        hintText: AppLocalizations.of(context)!.example_10,
        icon: FontAwesome.bolt_solid,
        controller: userCurrent,
        validator: Validatorless.multiple([
          Validatorless.required(AppLocalizations.of(context)!.required_field),
          Validatorless.number(AppLocalizations.of(context)!.numbers_only),
        ]),
        onChanged: _updateRunningTime,
      ),
      _buildSystemVoltageSelector(context),
      divider,
      textHelperCard(
        context,
        text: AppLocalizations.of(context)!.load_ampere_helper,
      ),
      divider,
      Column(
        children: [
          inputField(
            context: context,
            null,
            label: AppLocalizations.of(context)!.battery_amperes,
            hintText: AppLocalizations.of(context)!.example_100_or_200,
            icon: FontAwesome.i_solid,
            controller: current,
            validator: Validatorless.multiple([
              Validatorless.required(
                AppLocalizations.of(context)!.required_field,
              ),
              Validatorless.number(AppLocalizations.of(context)!.numbers_only),
            ]),
            onChanged: _updateRunningTime,
          ),
          horSpace(space: 5),
          inputField(
            context: context,
            null,
            label: AppLocalizations.of(context)!.battery_voltage_label,
            hintText: AppLocalizations.of(context)!.example_12_24_48_512,
            icon: FontAwesome.v_solid,
            controller: voltage,
            validator: Validatorless.multiple([
              Validatorless.required(
                AppLocalizations.of(context)!.required_field,
              ),
              Validatorless.number(AppLocalizations.of(context)!.numbers_only),
            ]),
            onChanged: _updateRunningTime,
          ),
          horSpace(space: 5),
          inputField(
            context: context,
            null,
            label: AppLocalizations.of(context)!.battery_count_label,
            hintText: AppLocalizations.of(context)!.battery_count_hint,
            icon: FontAwesome.n_solid,
            controller: numbers,
            validator: Validatorless.multiple([
              Validatorless.required(
                AppLocalizations.of(context)!.required_field,
              ),
              Validatorless.number(AppLocalizations.of(context)!.numbers_only),
            ]),
            onChanged: _updateRunningTime,
          ),
        ],
      ),
      verSpace(),
      textHelperCard(
        context,
        text: AppLocalizations.of(context)!.battery_runtime_explanation,
      ),
      divider,
      Text(
        AppLocalizations.of(
          context,
        )!.depth_of_discharge_with_value(depthOfDischarge.toStringAsFixed(0)),
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
        text: AppLocalizations.of(context)!.dod_guidance_runtime,
      ),
      verSpace(),
      verSpace(space: 25),
    ];
  }

  Widget _buildSystemVoltageSelector(BuildContext context) {
    return DropdownButtonFormField<num>(
      initialValue: systemVoltage,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        labelText: AppLocalizations.of(context)!.ac_system_voltage,
        prefixIcon: const Icon(Icons.electrical_services_rounded),
      ),
      items: [
        DropdownMenuItem(
          value: 110,
          child: Text(AppLocalizations.of(context)!.voltage_110),
        ),
        DropdownMenuItem(
          value: 230,
          child: Text(AppLocalizations.of(context)!.voltage_230),
        ),
        DropdownMenuItem(
          value: 380,
          child: Text(AppLocalizations.of(context)!.voltage_380_three_phase),
        ),
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
//         dataContrller.batteryCalculatedData['user-current'].toString());
// final voltage = TextEditingController(
//     text: dataContrller.batteryCalculatedData['user-battery-voltage']
//         .toString());
// final current = TextEditingController(
//     text: dataContrller.batteryCalculatedData['user-battery-ampere']
//         .toString());
// final numbers = TextEditingController(
//     text: dataContrller.batteryCalculatedData['user-battery-count']
//         .toString());

// // Default value for Depth of Discharge (DoD)
// num depthOfDischarge =
//     dataContrller.batteryCalculatedData['user-battery-depht'];
// num systemVoltage =
//     dataContrller.batteryCalculatedData['ac-voltage-system'];
// // Result value: running time in hours
// num runningTime = 0;
