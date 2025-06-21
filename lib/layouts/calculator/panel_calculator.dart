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

  Widget divider = verSpace(space: 18);

  GlobalKey<FormState> key = GlobalKey<FormState>();

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
      // to check required values
      if (loadinput <= 0 || panelWattageInput <= 0 || activeHoursInput <= 0) {
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
  void initState() {
    super.initState();

    // gridCharge =
    //     dataContrller.userCalculatedSystem.value['panels']['grid-charge'];
    // gridFeed = dataContrller.userCalculatedSystem.value['panels']['grid-feed'];
    // panelEfficiencyValue = dataContrller
    //     .userCalculatedSystem
    //     .value['panels']['efficiency']
    //     .toDouble();

    batteryCharge = false;
    gridFeed = false;
    panelEfficiencyValue = 70;
    _updatePanelsNum('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('panel-calculator'.tr),
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
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Form(
          key: key,
          child: Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      verSpace(),
                      Hero(
                        tag: '/panel',
                        child: Image.asset(
                          'assets/png/cards/panels.png',
                          height: 180,
                        ),
                      ).animate().fade(duration: 500.ms).slideY(begin: -0.1),
                      verSpace(space: 25),
                      ..._buildFormFields()
                          .animate(interval: 100.ms)
                          .fadeIn()
                          .slideY(),
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
                            '${panels.ceil().toString()} Panels',
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
        ),
      ),
    );
  }

  List<Widget> _buildFormFields() {
    return [
      // Panel Wattage
      inputField(
        context: context,
        'Panel wattage (in Watts), usually written on the label or datasheet.',
        label: 'panel-wattage'.tr,
        hintText: 'e.g., 450',
        icon: FontAwesome.solar_panel_solid,
        controller: panelWattage,
        validator: Validatorless.multiple([
          Validatorless.required('Required'),
          Validatorless.number('Numbers only'),
        ]),
        onChanged: _updatePanelsNum,
      ),
      Text(
        'Panel Efficiency ($panelEfficiencyValue%)',
        style: Theme.of(context).textTheme.titleMedium,
        textAlign: TextAlign.start,
      ),
      verSpace(space: 8),
      Slider(
        value: panelEfficiencyValue.toDouble(),
        min: 65,
        max: 100,
        divisions: 35,
        label: '${panelEfficiencyValue.toStringAsFixed(0)}%',
        onChanged: (value) {
          setState(() {
            panelEfficiencyValue = value;
            _updatePanelsNum(value);
          });
        },
      ),
      verSpace(space: 4),
      textHelperCard(
        context,
        text:
            'Typical values range from 70% to 90% depending on factors like dirt, temperature, and wiring. Use 70% if unsure.',
      ),
      verSpace(),
      divider,

      // Load during daytime
      inputField(
        'How many amperes you need in daytime (sunlight hours).',
        context: context,
        label: 'day-load-in-ampere'.tr,
        hintText: 'e.g., 10',
        icon: Icons.electrical_services,
        controller: dayLoad,
        validator: Validatorless.multiple([
          Validatorless.required('Required'),
          Validatorless.number('Numbers only'),
        ]),
        onChanged: _updatePanelsNum,
      ),

      divider,

      // Active solar hours
      inputField(
        'Number of active sun hours per day. Average in Iraq is 6 hours.',
        context: context,
        label: 'active-pv-hours-in-h'.tr,
        hintText: 'e.g., 6',
        icon: FontAwesome.sun,
        controller: activeHours,
        validator: Validatorless.multiple([
          Validatorless.required('Required'),
          Validatorless.number('Numbers only'),
        ]),
        onChanged: _updatePanelsNum,
      ),

      divider,

      // Battery Charge section
      Text(
        'battery-charge-section'.tr,
        style: Theme.of(context).textTheme.titleMedium,
        textAlign: TextAlign.start,
      ),
      divider,

      // battery charge toggle
      Row(
        children: [
          Text('battery-charge-or-not?'.tr),
          const Spacer(),
          Checkbox(
            value: batteryCharge,
            onChanged: (value) {
              batteryCharge = value!;
              setState(() {
                _updatePanelsNum(value);
              });
            },
          ),
        ],
      ),
      divider,
      inputField(
        'Battery capacity in watts (Ampere × Voltage × Numbers of batteries). For example: 100A × 51.2V × 1 = 5120W',
        context: context,
        enabled: batteryCharge,
        label: 'battery-charge-in-w'.tr,
        hintText: 'e.g., 5120',
        icon: IonIcons.battery_charging,
        controller: batteryCapacity,
        validator: Validatorless.multiple([
          Validatorless.required('Required'),
          Validatorless.number('Numbers only'),
        ]),
        onChanged: _updatePanelsNum,
      ),

      divider,

      // Grid charge current and hours
      verSpace(),
      Row(
        children: [
          Expanded(
            child: inputField(
              null,
              enabled: batteryCharge,
              context: context,
              label: 'grid-charge-current'.tr,
              hintText: 'e.g., 15',
              icon: FontAwesome.plug_circle_bolt_solid,
              controller: gridChargeCurrent,
              validator: Validatorless.multiple([
                Validatorless.number('Numbers only'),
              ]),
              onChanged: _updatePanelsNum,
            ),
          ),
          horSpace(space: 5),
          Expanded(
            child: inputField(
              null,
              context: context,
              enabled: batteryCharge,
              label: 'grid-charge-hours'.tr,
              hintText: 'e.g., 4',
              icon: IonIcons.time,
              controller: gridChargeHours,
              validator: Validatorless.multiple([
                Validatorless.number('Numbers only'),
              ]),
              onChanged: _updatePanelsNum,
            ),
          ),
        ],
      ),

      verSpace(),
      textHelperCard(
        context,
        text:
            'Enable this option if you want the battery to be charged from the grid during the day.',
      ),

      divider,

      // Grid feed toggle
      Row(
        children: [
          Text('grid-feed-or-not?'.tr),
          const Spacer(),
          Checkbox(
            value: gridFeed,
            onChanged: (value) {
              setState(() {
                gridFeed = value!;
                _updatePanelsNum(value);
              });
            },
          ),
        ],
      ),

      verSpace(),

      // Grid feed capacity
      inputField(
        'Enter how much power (in Watt) you want to feed back to the grid.\nNote: Not all countries allow feeding electricity back into the grid.',
        context: context,
        enabled: gridFeed,
        label: 'grid-feed-power'.tr,
        hintText: 'e.g., 1000',
        icon: FontAwesome.seedling_solid,
        controller: gridFeedCapacity,
        validator: Validatorless.multiple([
          Validatorless.number('Numbers only'),
        ]),
        onChanged: _updatePanelsNum,
      ),

      verSpace(space: 75),
    ];
  }

  void _updateData() async {
    if (key.currentState!.validate()) {
      final num panel = num.parse(panelWattage.text);
      final num efficiency = panelEfficiencyValue;

      final num dayLoadAmpere = num.parse(dayLoad.text);
      final num activeSunHours = num.parse(activeHours.text);

      final num battery = num.parse(batteryCapacity.text);

      final bool gridChargeData = batteryCharge;
      final num gridChrgeCurrent = num.parse(gridChargeCurrent.text);
      final num gridChrgeTime = num.parse(gridChargeHours.text);

      final bool gridFeddeData = gridFeed;
      final num gridFeedData = num.parse(gridFeedCapacity.text);

      final num panelsData = panels.ceil();

      final data = {
        'power': panel,
        'count': panelsData,
        'efficiency': efficiency.ceil(),
        'user-power': dayLoadAmpere,
        'active-hours': activeSunHours,
        'user-battery-capacity': battery,
        'grid-charge': gridChargeData,
        'grid-charge-current': gridChrgeCurrent,
        'grid-charge-hours': gridChrgeTime,
        'grid-feed': gridFeddeData,
        'grid-feed-power': gridFeedData,
      };

      //   await dataContrller
      //       .updateUserCalculatedSystemData(UserSystemDataPart.panels, data)
      //       .then(
      //         (onValue) => Get.snackbar(
      //           'Inverter',
      //           'data saved successfully',
      //           icon: Icon(IonIcons.save),
      //         ),
      //       );
      // } else {
      //   Get.snackbar(
      //     'Error',
      //     'data enterd invalid value',
      //     icon: Icon(IonIcons.warning),
      //   );
    }
  }
}
  // String? _updatePanelsNum(value) {
  //   setState(() {
  //     num loadinput = num.tryParse(dayLoad.text) ?? 0;
  //     num activeHoursInput = num.tryParse(activeHours.text) ?? 0;
  //     num batteryCapacityInput = num.tryParse(batteryCapacity.text) ?? 0;
  //     num panelWattageInput = num.tryParse(panelWattage.text) ?? 0;
  //     num gridFeedCapacityInput = num.tryParse(gridFeedCapacity.text) ?? 0;
  //     num gridChargeHoursInput = num.tryParse(gridChargeHours.text) ?? 0;
  //     num gridChargeCurrentInput = num.tryParse(gridChargeCurrent.text) ?? 0;
  //     num effativepanelWatts = panelWattageInput * (panelEfficiencyValue / 100);
  //     // to check required values
  //     if (loadinput <= 0 || panelWattageInput <= 0 || activeHoursInput <= 0) {
  //       return;
  //     }

  //     panels = ((loadinput * 230) / effativepanelWatts) +
  //         ((batteryCapacityInput / activeHoursInput) / effativepanelWatts);

  //     if (gridCharge) {
  //       num gridChrgeWattage =
  //           ((gridChargeCurrentInput * 230 * gridChargeHoursInput));
  //       num battreyRemainToCharge = batteryCapacityInput - gridChrgeWattage;
  //       switch (battreyRemainToCharge) {
  //         case > 0:
  //           panels -= ((batteryCapacityInput / activeHoursInput) /
  //               effativepanelWatts);
  //           panels += (((batteryCapacityInput - gridChrgeWattage) /
  //                   activeHoursInput) /
  //               effativepanelWatts);
  //           break;
  //         case <= 0:
  //           panels -= ((batteryCapacityInput / activeHoursInput) /
  //               effativepanelWatts);
  //           break;
  //         default:
  //       }
  //     }

  //     if (gridFeed) {
  //       panels +=
  //           (gridFeedCapacityInput / activeHoursInput) / effativepanelWatts;
  //     }
  //   });
  //   return null;
  // }
   // final activeHours = TextEditingController(
  //   text: dataContrller.userCalculatedSystem.value['panels']['active-hours']
  //       .toString(),
  // );
  // final dayLoad = TextEditingController(
  //   text: dataContrller.userCalculatedSystem.value['panels']['user-power']
  //       .toString(),
  // );
  // final batteryCapacity = TextEditingController(
  //   text: dataContrller
  //       .userCalculatedSystem
  //       .value['panels']['user-battery-capacity']
  //       .toString(),
  // );
  // final panelWattage = TextEditingController(
  //   text: dataContrller.userCalculatedSystem.value['panels']['power']
  //       .toString(),
  // );

  // final gridFeedCapacity = TextEditingController(
  //   text: dataContrller.userCalculatedSystem.value['panels']['grid-feed-power']
  //       .toString(),
  // );
  // final gridChargeHours = TextEditingController(
  //   text: dataContrller
  //       .userCalculatedSystem
  //       .value['panels']['grid-charge-hours']
  //       .toString(),
  // );
  // final gridChargeCurrent = TextEditingController(
  //   text: dataContrller
  //       .userCalculatedSystem
  //       .value['panels']['grid-charge-current']
  //       .toString(),
  // );