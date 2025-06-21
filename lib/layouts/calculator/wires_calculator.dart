// import 'dart:math';

// import 'package:flutter/material.dart';
// import 'package:icons_plus/icons_plus.dart';
// import 'package:solar_hub/utils/app_constants.dart';
// import 'package:solar_hub/views/widgets/input_text.dart';
// import 'package:solar_hub/views/widgets/text_helper_card.dart';
// import 'package:validatorless/validatorless.dart';

// class WiresCalculator extends StatefulWidget {
//   const WiresCalculator({super.key});

//   @override
//   State<WiresCalculator> createState() => _WiresCalculatorState();
// }

// class _WiresCalculatorState extends State<WiresCalculator> {
//   // Solar Wires
//   final solarCurrent = TextEditingController();
//   final solarVoltage = TextEditingController();
//   final solarPanelCount = TextEditingController();
//   final solarLength = TextEditingController();

//   // Battery Wires
//   final batteryVoltage = TextEditingController();
//   final chargeVoltage = TextEditingController();
//   final chargeCurrent = TextEditingController();
//   final batteryLength = TextEditingController();
//   double systemVoltage = 15;

//   // AC Wires
//   final acInputCurrent = TextEditingController();
//   final acLoadCurrent = TextEditingController();
//   final acLength = TextEditingController();

//   // Results
//   double solarWireSize = 0;
//   double batteryWireSize = 0;
//   double acWireSize = 0;

//   Widget divider = verSpace(space: 20);

//   List<bool> isOpenListIndex = [
//     true,
//     false,
//     false,
//   ];

//   String? _calculateSolar() {
//     final solarI = double.tryParse(solarCurrent.text) ?? 0;
//     final solarN = double.tryParse(solarPanelCount.text) ?? 1;
//     final solarV = double.tryParse(solarVoltage.text) ?? 1;
//     final solarL = double.tryParse(solarLength.text) ?? 0;

//     final vDropAllowed = (solarV * solarN) * (1 / 100);
//     final K = 1.7241 * pow(10, -8);

//     setState(() {
//       solarWireSize = (solarI * solarL * K * 2) / (vDropAllowed) * pow(10, 6);
//     });

//     // const resistivity = 1.7241e-8; // Ohm meter
//     // final vDropAllowed = ((solarV * solarN) * 0.03); // بالـ Volts

//     // final areaM2 = (2 * solarI * solarL * resistivity) / vDropAllowed;
//     // final areaMm2 = areaM2 * 1e6; // حولها إلى mm²

//     // setState(() {
//     //   solarWireSize = areaMm2;
//     // });
//     return null;
//   }

//   String? _calculateBattery() {
//     final chargeI = double.tryParse(chargeCurrent.text) ?? 0;
//     final battL = double.tryParse(batteryLength.text) ?? 0;

//     // final vDropAllowed = systemVoltage * 0.03; // 3% من الفولتية، كما في المواقع
//     final K = 1.68 * pow(10, -8); // مقاومة النحاس (أدق من القيمة السابقة)

//     setState(() {
//       batteryWireSize = ((K * chargeI * battL * 2) / 1) * pow(10, 6);
//     });
//     return null;
//   }

//   String? _calculateAC() {
//     final acI = (double.tryParse(acInputCurrent.text) ?? 0) +
//         (double.tryParse(acLoadCurrent.text) ?? 0);
//     final acL = double.tryParse(acLength.text) ?? 0;

//     setState(() {
//       acWireSize = (acI * acL * 2) / (56 * 0.022);
//     });
//     return null;
//   }

//   Widget _animatedResult(String title, double value) {
//     return AnimatedSwitcher(
//       duration: const Duration(milliseconds: 400),
//       transitionBuilder: (child, anim) =>
//           FadeTransition(opacity: anim, child: child),
//       child: Text(
//         '$title: ${value.toStringAsFixed(2)} mm²',
//         key: ValueKey(value),
//         style: const TextStyle(fontWeight: FontWeight.bold),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Wire Sizing Calculator')),
//       body: Stack(
//         children: [
//           Positioned.fill(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(12),
//               child: Column(
//                 children: [
//                   Hero(
//                     tag: '/wires',
//                     child:
//                         Image.asset('assets/png/cards/wiring.png', height: 150),
//                   ),
//                   divider,
//                   // === SOLAR SECTION ===
//                   ExpansionPanelList(
//                       expansionCallback: (index, isOpen) {
//                         setState(() {
//                           isOpenListIndex[index] = isOpen;
//                         });
//                       },
//                       animationDuration: const Duration(seconds: 1),
//                       expandedHeaderPadding: const EdgeInsets.all(8),
//                       dividerColor: Colors.purple,
//                       elevation: 2,
//                       expandIconColor: Colors.purpleAccent,
//                       materialGapSize: 16.0,
//                       children: [
//                         // === PANELS SECTION ===
//                         ExpansionPanel(
//                           body: SectionCard(
//                             title: 'Solar Wires',
//                             description:
//                                 'Solar Wires carry DC current from the panels. Wire size depends on the total current, voltage, panel count, and wire length.',
//                             inputs: [
//                               verSpace(),
//                               inputField(
//                                 context: context,
//                                 'Current per panel',
//                                 label: 'Solar Panel Current (A)',
//                                 hintText: '',
//                                 icon: FontAwesome.solar_panel_solid,
//                                 controller: solarCurrent,
//                                 validator:
//                                     Validatorless.number('Enter valid number'),
//                                 onChanged: (_) => _calculateSolar(),
//                               ),
//                               inputField(
//                                 context: context,
//                                 'Voltage per panel',
//                                 label: 'Solar Panel Voltage (V)',
//                                 icon: FontAwesome.bolt_solid,
//                                 hintText: '',
//                                 controller: solarVoltage,
//                                 validator:
//                                     Validatorless.number('Enter valid number'),
//                                 onChanged: (_) => _calculateSolar(),
//                               ),
//                               inputField(
//                                 context: context,
//                                 'Number of panels in string',
//                                 label: 'Panel Count',
//                                 icon: FontAwesome.calculator_solid,
//                                 hintText: '',
//                                 controller: solarPanelCount,
//                                 validator:
//                                     Validatorless.number('Enter valid number'),
//                                 onChanged: (_) => _calculateSolar(),
//                               ),
//                               inputField(
//                                 context: context,
//                                 'Cable length',
//                                 label: 'Cable Length (m)',
//                                 icon: FontAwesome.ruler_solid,
//                                 hintText: '',
//                                 controller: solarLength,
//                                 validator:
//                                     Validatorless.number('Enter valid number'),
//                                 onChanged: (_) => _calculateSolar(),
//                               ),
//                             ],
//                             resultWidget: _animatedResult(
//                                 'Solar Wire Size', solarWireSize),
//                           ),
//                           canTapOnHeader: true,
//                           isExpanded: isOpenListIndex[0],
//                           headerBuilder:
//                               (BuildContext context, bool isExpanded) {
//                             return Padding(
//                               padding: const EdgeInsets.all(8),
//                               child: Text('Solar Panels Wires Calculator',
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .headlineSmall),
//                             );
//                           },
//                         ),
//                         // === BATTERY SECTION ===
//                         ExpansionPanel(
//                           body: SectionCard(
//                             title: 'Battery Wires',
//                             description:
//                                 'Battery wires carry DC current from charger to batteries. Use correct voltage and length for accurate sizing.',
//                             inputs: [
//                               // inputField(
//                               //   context: context,
//                               //   'Battery Voltage',
//                               //   label: 'Battery Voltage (V)',
//                               //   icon: FontAwesome.battery_half_solid,
//                               //   hintText: '',
//                               //   controller: batteryVoltage,
//                               //   validator:
//                               //       Validatorless.number('Enter valid number'),
//                               //   onChanged: (_) => _calculateBattery(),
//                               // ),
//                               verSpace(),
//                               DropdownButtonFormField<double>(
//                                 value: systemVoltage,
//                                 decoration: InputDecoration(
//                                   border: const OutlineInputBorder(),
//                                   contentPadding: const EdgeInsets.symmetric(
//                                       horizontal: 12, vertical: 10),
//                                   labelText: 'Inverter Battery Voltage System',
//                                   prefixIcon: const Icon(
//                                       Icons.electrical_services_rounded),
//                                 ),
//                                 items: const [
//                                   DropdownMenuItem(
//                                       value: 15, child: Text('12 V')),
//                                   DropdownMenuItem(
//                                       value: 30, child: Text('24 V')),
//                                   DropdownMenuItem(
//                                       value: 60, child: Text('48 V')),
//                                 ],
//                                 onChanged: (value) {
//                                   systemVoltage = value ?? 0.0;

//                                   _calculateBattery();
//                                 },
//                               ),
//                               verSpace(),
//                               inputField(
//                                 context: context,
//                                 'Charging Current',
//                                 label: 'Charge Current (A)',
//                                 icon: FontAwesome.charging_station_solid,
//                                 hintText: '',
//                                 controller: chargeCurrent,
//                                 validator:
//                                     Validatorless.number('Enter valid number'),
//                                 onChanged: (_) => _calculateBattery(),
//                               ),
//                               inputField(
//                                 context: context,
//                                 'Cable length',
//                                 label: 'Cable Length (m)',
//                                 icon: FontAwesome.ruler_solid,
//                                 hintText: '',
//                                 controller: batteryLength,
//                                 validator:
//                                     Validatorless.number('Enter valid number'),
//                                 onChanged: (_) => _calculateBattery(),
//                               ),
//                             ],
//                             resultWidget: _animatedResult(
//                                 'Battery Wire Size', batteryWireSize),
//                           ),
//                           isExpanded: isOpenListIndex[1],
//                           headerBuilder:
//                               (BuildContext context, bool isExpanded) {
//                             return Padding(
//                               padding: const EdgeInsets.all(12),
//                               child: Text(
//                                 'Battery Wires Calculator',
//                                 style:
//                                     Theme.of(context).textTheme.headlineSmall,
//                               ),
//                             );
//                           },
//                         ),
//                         // === AC SECTION ===
//                         ExpansionPanel(
//                           body: SectionCard(
//                             title: 'AC Wires',
//                             description:
//                                 'AC wires are used for inverter input/output. Wire size depends on total current and distance.',
//                             inputs: [
//                               inputField(
//                                 context: context,
//                                 'AC Grid Current',
//                                 label: 'AC Input Current (A)',
//                                 icon: FontAwesome.plug_circle_bolt_solid,
//                                 hintText: '',
//                                 controller: acInputCurrent,
//                                 validator:
//                                     Validatorless.number('Enter valid number'),
//                                 onChanged: (_) => _calculateAC(),
//                               ),
//                               inputField(
//                                 context: context,
//                                 'AC Load Current',
//                                 label: 'AC Load Current (A)',
//                                 icon: FontAwesome.plug_solid,
//                                 hintText: '',
//                                 controller: acLoadCurrent,
//                                 validator:
//                                     Validatorless.number('Enter valid number'),
//                                 onChanged: (_) => _calculateAC(),
//                               ),
//                               inputField(
//                                 context: context,
//                                 'AC Cable Length',
//                                 label: 'Cable Length (m)',
//                                 icon: FontAwesome.ruler_combined_solid,
//                                 hintText: '',
//                                 controller: acLength,
//                                 validator:
//                                     Validatorless.number('Enter valid number'),
//                                 onChanged: (_) => _calculateAC(),
//                               ),
//                             ],
//                             resultWidget:
//                                 _animatedResult('AC Wire Size', acWireSize),
//                           ),
//                           isExpanded: isOpenListIndex[2],
//                           headerBuilder:
//                               (BuildContext context, bool isExpanded) {
//                             return Padding(
//                               padding: const EdgeInsets.all(12),
//                               child: Text('AC Wires Calculator',
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .headlineSmall),
//                             );
//                           },
//                         ),
//                       ]),

//                   divider,

//                   verSpace(space: 90),
//                 ],
//               ),
//             ),
//           ),
//           Positioned(
//             bottom: 0,
//             left: 10,
//             right: 10,
//             child: Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: Column(
//                         children: [
//                           Text(
//                             'Solar Wire Size: $solarWireSize mm²',
//                             style: Theme.of(context).textTheme.headlineSmall,
//                           ),
//                           Text(
//                             'Battery Wire Size: $batteryWireSize mm²',
//                             style: Theme.of(context).textTheme.headlineSmall,
//                           ),
//                           Text(
//                             'AC Wire Size: $acWireSize mm²',
//                             style: Theme.of(context).textTheme.headlineSmall,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }

// class SectionCard extends StatelessWidget {
//   final String title;
//   final String description;
//   final List<Widget> inputs;
//   final Widget resultWidget;

//   const SectionCard({
//     super.key,
//     required this.title,
//     required this.description,
//     required this.inputs,
//     required this.resultWidget,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 3,
//       margin: const EdgeInsets.only(bottom: 12),
//       child: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             textHelperCard(context, title: title, text: description),
//             ...inputs,
//             verSpace(space: 10),
//             resultWidget,
//           ],
//         ),
//       ),
//     );
//   }
// }
