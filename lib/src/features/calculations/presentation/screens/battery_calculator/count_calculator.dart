import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/src/features/calculations/domain/usecases/home_solar_system_calculator.dart';
import 'package:solar_hub/src/features/calculations/presentation/widgets/input_text.dart';
import 'package:solar_hub/src/features/calculations/presentation/widgets/save_to_system_dialog.dart';
import 'package:solar_hub/src/features/calculations/presentation/widgets/text_helper_card.dart';
import 'package:solar_hub/src/utils/app_constants.dart';
import 'package:solar_hub/src/features/calculations/presentation/providers/systems_provider.dart';
import 'package:solar_hub/src/features/calculations/domain/entities/system_model.dart';
import 'package:solar_hub/src/utils/helper_methods.dart';
import 'package:validatorless/validatorless.dart';
import 'package:solar_hub/l10n/app_localizations.dart';

class CountCalculator extends ConsumerStatefulWidget {
  const CountCalculator({super.key});

  @override
  ConsumerState<CountCalculator> createState() => _CountCalculatorState();
}

class _CountCalculatorState extends ConsumerState<CountCalculator> {
  final current = TextEditingController(text: '0');
  final batteryVoltage = TextEditingController(text: '0');
  final batteryCurrent = TextEditingController(text: '0');

  final time = TextEditingController(text: '0');

  //  Default value for Depth of Discharge (DoD)
  num depthOfDischarge = 80;

  num systemVoltage = 230;

  num batteryCount = 0;
  num batteryAh = 0;

  Widget divider = verSpace(space: 18.h);

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
  //     // dataContrller.batteryCalculatedData['user-current'] = ampereInput;
  //     // dataContrller.batteryCalculatedData['ac-voltage-system'] =
  //     //     systemVoltage;
  //     // dataContrller.batteryCalculatedData['user-battery-voltage'] =
  //     //     voltageInput;
  //     // dataContrller.batteryCalculatedData['user-battery-ampere'] =
  //     //     currentInput;
  //     // dataContrller.batteryCalculatedData['user-battery-runtime'] =
  //     //     timeInput;
  //     // dataContrller.batteryCalculatedData['user-battery-depht'] = dod;

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
      setState(() {
        batteryAh = batterybank['totalAhNeeded'];
        batteryCount = batterybank['batteryCount'];
      });
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

  Future<void> _saveSystem() async {
    final controller = ref.read(systemsProvider.notifier);
    final dialogResult = await showDialog(
      context: context,
      builder: (context) => const SaveToSystemDialog(),
    );

    if (dialogResult != null && dialogResult is Map) {
      final isNew = dialogResult['isNew'] as bool;
      final existingSystem = dialogResult['system'] as SystemModel?;
      final newName = dialogResult['name'] as String?;
      final companyId = dialogResult['companyId'] as String?;

      controller.saveSystemPart(
        existingSystem: isNew ? null : existingSystem,
        newSystemName: newName,
        companyId: companyId,
        partName: 'batteries',
        data: {
          'count': batteryCount,
          'capacity_ah': double.tryParse(batteryCurrent.text) ?? 0,
          'voltage': double.tryParse(batteryVoltage.text) ?? 0,
          'type': depthOfDischarge >= 50 ? 'Gel/AGM' : 'Lithium/Tubular',
          'brand': 'Unknown',
          'notes':
              'DoD: ${depthOfDischarge.toInt()}%, System Voltage: $systemVoltage V',
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final systemsEnabled = isEnabled(ref, 'systems');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Hero(tag: '/battery', child: Image.asset('assets/png/cards/battery.png', height: 180)),
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
                        AppLocalizations.of(
                          context,
                        )!.batteries_count_value(batteryCount),
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              // fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (systemsEnabled && batteryCount > 0)
                      IconButton(
                        onPressed: () => _saveSystem(),
                        icon: const Icon(Iconsax.save_2_bold),
                        tooltip: AppLocalizations.of(context)!.save_to_system,
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
        controller: current,
        validator: Validatorless.multiple([
          Validatorless.required(AppLocalizations.of(context)!.required_field),
          Validatorless.number(AppLocalizations.of(context)!.numbers_only),
        ]),
        onChanged: _updateBatteryCount,
      ),
      _buildSystemVoltageSelector(context),
      divider,
      textHelperCard(
        context,
        text: AppLocalizations.of(context)!.load_ampere_helper,
      ),
      divider,
      inputField(
        context: context,
        null,
        label: AppLocalizations.of(context)!.battery_amperes,
        hintText: AppLocalizations.of(context)!.example_100_or_200,
        icon: FontAwesome.i_solid,
        controller: batteryCurrent,
        validator: Validatorless.multiple([
          Validatorless.required(AppLocalizations.of(context)!.required_field),
          Validatorless.number(AppLocalizations.of(context)!.numbers_only),
        ]),
        onChanged: _updateBatteryCount,
      ),
      inputField(
        context: context,
        null,
        label: AppLocalizations.of(context)!.battery_voltage_label,
        hintText: AppLocalizations.of(context)!.example_12_24_48_512,
        icon: FontAwesome.v_solid,
        controller: batteryVoltage,
        validator: Validatorless.multiple([
          Validatorless.required(AppLocalizations.of(context)!.required_field),
          Validatorless.number(AppLocalizations.of(context)!.numbers_only),
        ]),
        onChanged: _updateBatteryCount,
      ),
      // divider,
      inputField(
        context: context,
        AppLocalizations.of(context)!.runtime_question,
        label: AppLocalizations.of(context)!.required_runtime_hours,
        hintText: AppLocalizations.of(context)!.example_5_or_8,
        icon: IonIcons.timer,
        controller: time,
        validator: Validatorless.multiple([
          Validatorless.required(AppLocalizations.of(context)!.required_field),
          Validatorless.number(AppLocalizations.of(context)!.numbers_only),
        ]),
        onChanged: _updateBatteryCount,
      ),
      verSpace(),
      textHelperCard(
        context,
        text: AppLocalizations.of(context)!.battery_count_explanation,
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
            _updateBatteryCount('value');
          });
        },
      ),
      verSpace(space: 4),
      textHelperCard(context, text: AppLocalizations.of(context)!.dod_guidance),
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
          _updateBatteryCount(null);
        });
      },
    );
  }
}
