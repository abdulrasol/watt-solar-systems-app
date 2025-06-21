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

class CountCalculator extends StatefulWidget {
  const CountCalculator({super.key});

  @override
  State<CountCalculator> createState() => _CountCalculatorState();
}

class _CountCalculatorState extends State<CountCalculator> {
  // Controllers for input fields
  // final current = TextEditingController(
  //     text:
  //         dataContrller.batteryCalculatedData.value['user-current'].toString());
  // final batteryVoltage = TextEditingController(
  //     text: dataContrller.batteryCalculatedData.value['user-battery-voltage']
  //         .toString());
  // final batteryCurrent = TextEditingController(
  //     text: dataContrller.batteryCalculatedData.value['user-battery-ampere']
  //         .toString());

  // final time = TextEditingController(
  //     text: dataContrller.batteryCalculatedData.value['user-battery-runtime']
  //         .toString());

  // Default value for Depth of Discharge (DoD)
  // num depthOfDischarge =
  //     dataContrller.batteryCalculatedData.value['user-battery-depht'];

  // num systemVoltage =
  //     dataContrller.batteryCalculatedData.value['ac-voltage-system'];

  final current = TextEditingController(text: '0');
  final batteryVoltage = TextEditingController(text: '0');
  final batteryCurrent = TextEditingController(text: '0');

  final time = TextEditingController(text: '0');

  //  Default value for Depth of Discharge (DoD)
  num depthOfDischarge = 80;

  num systemVoltage = 230;

  num batteryCount = 0;
  num batteryAh = 0;

  Widget divider = verSpace(space: 18);

  // String? _updateBatteryCount(String? v) {

  //   final ampereInput = num.tryParse(current.text) ?? 0;
  //   final voltageInput = num.tryParse(batteryVoltage.text) ?? 0;
  //   final currentInput = num.tryParse(batteryCurrent.text) ?? 0;
  //   final timeInput = num.tryParse(time.text) ?? 0;
  //   final dod = depthOfDischarge;
  //   final userPower = ampereInput * systemVoltage;
  //   if (userPower > 0 &&
  //       voltageInput > 0 &&
  //       currentInput > 0 &&
  //       timeInput > 0) {
  //     // update data controller
  //     // dataContrller.batteryCalculatedData.value['user-current'] = ampereInput;
  //     // dataContrller.batteryCalculatedData.value['ac-voltage-system'] =
  //     //     systemVoltage;
  //     // dataContrller.batteryCalculatedData.value['user-battery-voltage'] =
  //     //     voltageInput;
  //     // dataContrller.batteryCalculatedData.value['user-battery-ampere'] =
  //     //     currentInput;
  //     // dataContrller.batteryCalculatedData.value['user-battery-runtime'] =
  //     //     timeInput;
  //     // dataContrller.batteryCalculatedData.value['user-battery-depht'] = dod;

  //     final requiredEnergy = userPower * timeInput;
  //     final batteryCapacity = voltageInput * currentInput * (dod / 100);

  //     final result = requiredEnergy / batteryCapacity;

  //     setState(() {
  //       batteryCount = result.ceil(); // تقريب للأعلى
  //     });
  //   } else {
  //     setState(() {
  //       batteryCount = 0;
  //     });
  //   }
  //   return null;
  // }

  String? _updateBatteryCount(String? v) {
    final ampereInput = num.tryParse(current.text) ?? 0;
    final voltageInput = num.tryParse(batteryVoltage.text) ?? 0;
    final currentInput = num.tryParse(batteryCurrent.text) ?? 0;
    final timeInput = num.tryParse(time.text) ?? 0;
    final dod = depthOfDischarge;
    num dailyUsageKWh = ampereInput * systemVoltage * timeInput;
    if (dailyUsageKWh > 0 &&
        voltageInput > 0 &&
        currentInput > 0 &&
        timeInput > 0) {
      Map batterybank = HomeSolarSystemCalculator.calculateBatteryBank(
        dailyUsageKWh: dailyUsageKWh.toDouble(),
        batteryVoltage: voltageInput.toDouble(),
        batteryCapacityAh: currentInput.toDouble(),
        dod: dod.toDouble(),
      );
      batteryAh = batterybank['totalAhNeeded'];
      batteryCount = batterybank['batteryCount'];
    } else {
      setState(() {
        batteryCount = 0;
      });
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _updateBatteryCount(null);
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
                  verSpace(space: 65),
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
                        'Ah Capacity ${batteryAh.ceil()}, $batteryCount Batteries',
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
        controller: current,
        validator: Validatorless.multiple([
          Validatorless.required('required'.tr),
          Validatorless.number('numbers'.tr),
        ]),
        onChanged: _updateBatteryCount,
      ),
      _buildSystemVoltageSelector(),
      divider,
      textHelperCard(
        context,
        text:
            'Enter your load in Ampere and select AC Voltage System. Usually load calculate by: Voltage × Current. For example, 10A × 230V = 2300W.',
      ),
      divider,
      inputField(
        context: context,
        null,
        label: 'battery-amperes'.tr,
        hintText: 'e.g., 100 or 200',
        icon: FontAwesome.i_solid,
        controller: batteryCurrent,
        validator: Validatorless.multiple([
          Validatorless.required('required'.tr),
          Validatorless.number('numbers'.tr),
        ]),
        onChanged: _updateBatteryCount,
      ),
      inputField(
        context: context,
        null,
        label: 'battrey-voltage'.tr,
        hintText: 'e.g., 12, 24, 48 or 51.2',
        icon: FontAwesome.v_solid,
        controller: batteryVoltage,
        validator: Validatorless.multiple([
          Validatorless.required('required'.tr),
          Validatorless.number('numbers'.tr),
        ]),
        onChanged: _updateBatteryCount,
      ),
      // divider,
      inputField(
        context: context,
        'How many hours do you need your system to run on batteries?',
        label: 'Required Runtime (hours)',
        hintText: 'e.g., 5 or 8',
        icon: IonIcons.timer,
        controller: time,
        validator: Validatorless.multiple([
          Validatorless.required('required'.tr),
          Validatorless.number('numbers'.tr),
        ]),
        onChanged: _updateBatteryCount,
      ),
      verSpace(),
      textHelperCard(
        context,
        text:
            'The number of batteries needed is calculated as:\n\n'
            '(Power × Time) ÷ (Battery Voltage × Capacity × DoD)\n\n'
            'Example: (2300W × 5h) ÷ (12V × 100Ah × 0.2) = ~8 batteries\n\n'
            'This helps determine how many batteries you need to meet a specific load and runtime.',
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
            _updateBatteryCount('value');
          });
        },
      ),
      verSpace(space: 4),
      textHelperCard(
        context,
        text:
            'Set the Depth of Discharge (DoD) percentage.\n\nTypical values range from 20% to 80% depending on battery type.\n\n• 20% for Lithium/Tubular\n• 50% for AGM/Gel\nCheck your battery\'s datasheet for best accuracy.',
      ),
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
          _updateBatteryCount(null);
        });
      },
    );
  }
}
