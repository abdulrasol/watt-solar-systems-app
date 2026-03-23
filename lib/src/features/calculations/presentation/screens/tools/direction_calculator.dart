// import 'dart:math' as math;
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:solar_hub/src/features/calculations/presentation/providers/calculator_controller.dart';
// import 'package:solar_hub/src/utils/app_theme.dart';
// import 'package:solar_hub/src/utils/app_explanations.dart';
// import 'package:get_storage/get_storage.dart';

// class DirectionCalculator extends ConsumerStatefulWidget {
//   const DirectionCalculator({super.key});

//   @override
//   ConsumerState<DirectionCalculator> createState() => _DirectionCalculatorState();
// }

// class _DirectionCalculatorState extends ConsumerState<DirectionCalculator> {
//   late TextEditingController _textController;
//   Worker? _worker;
//     late final CalculatorNotifier controller;

//   @override
//   void initState() {
//     super.initState();
//     controller = ref.read(calculatorProvider);

//     // Initialize text controller with current value
//     String initialText = controller.orientationLat == 0 ? '' : controller.orientationLat.toString();
//     _textController = TextEditingController(text: initialText);

//     // Listen to changes in the controller (e.g. from Auto Detect)
//     _worker = ever(controller.orientationLat, (val) {
//       String newText = val == 0 ? '' : val.toString();
//       // Only update text if it's different to avoid cursor issues when user is blindly typing
//       if (_textController.text != newText) {
//         // Check if the difference is just formatting (e.g. user typed "33." and val is 33.0)
//         // double.tryParse("33.") is 33.0. val is 33.0.
//         // we should NOT update text if parsing result is same.
//         if (double.tryParse(_textController.text) != val) {
//           _textController.text = newText;
//           _textController.selection = TextSelection.collapsed(offset: newText.length);
//         }
//       }
//     });

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final box = GetStorage();
//       if (box.read('direction_calc_help_viewed') != true) {
//         _showHelpDialog();
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _worker?.dispose();
//     _textController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('orientation_calc'), // TODO: translate
//         actions: [IconButton(onPressed: _showHelpDialog, icon: const Icon(Icons.help_outline))],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             Hero(
//               tag: 'direction_hero',
//               child: Icon(Icons.explore, size: 80, color: Colors.teal),
//             ),
//             const SizedBox(height: 20),
//             Text("Align your solar panels for maximum efficiency.", textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium), // TODO: translate
//             const SizedBox(height: 30),

//             // Location Input
//             Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Theme.of(context).cardColor,
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
//               ),
//               child: Column(
//                 children: [
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Text("Your Latitude", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//                       ),
//                       controller.locationLoading
//                             ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)
//                             : TextButton.icon(onPressed: controller.fetchLocation, icon: Icon(Icons.my_location, size: 18), label: Text("Auto Detect")),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 10),
//                   TextFormField(
//                     controller: _textController,
//                     keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
//                     decoration: InputDecoration(
//                       labelText: "Latitude (e.g. 33.3)",
//                       hintText: "Enter manually if needed",
//                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                       prefixIcon: const Icon(Icons.location_on),
//                     ),
//                     onChanged: (val) {
//                       // Update controller value without forcing a text update back
//                       controller.orientationLat = double.tryParse(val) ?? 0;
//                       controller.calculateOrientation();
//                     },
//                   ),
//                   const SizedBox(height: 8),
//                   Text("Positive (+) = North Hemisphere\nNegative (-) = South Hemisphere", style: TextStyle(fontSize: 12, color: Colors.grey)),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 30),

//             // Compass Visual
//             Builder(builder: (context) {
//               if (controller.orientationLat == 0) return SizedBox.shrink();

//               double targetHeading = controller.optimalDirection == "South" ? 180 : 0; // 0 is North
//               double currentHeading = controller.compassHeading;
//               double diff = (currentHeading - targetHeading).abs();
//               bool isAligned = diff < 5 || diff > 355; // Tolerance 5 degrees

//               return Column(
//                 children: [
//                   Stack(
//                     alignment: Alignment.center,
//                     children: [
//                       // Compass Background
//                       Container(
//                         width: 250,
//                         height: 250,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: isDark ? Colors.grey[900] : Colors.grey[200],
//                           boxShadow: [BoxShadow(color: isAligned ? Colors.green.withValues(alpha: 0.3) : Colors.black12, blurRadius: 20, spreadRadius: 5)],
//                           border: Border.all(color: isAligned ? Colors.green : Colors.grey, width: 4),
//                         ),
//                         child: Stack(
//                           children: [
//                             // Markers
//                             Align(
//                               alignment: Alignment.topCenter,
//                               child: Padding(
//                                 padding: EdgeInsets.all(8),
//                                 child: Text("N", style: TextStyle(fontWeight: FontWeight.bold)),
//                               ),
//                             ),
//                             Align(
//                               alignment: Alignment.bottomCenter,
//                               child: Padding(
//                                 padding: EdgeInsets.all(8),
//                                 child: Text("S", style: TextStyle(fontWeight: FontWeight.bold)),
//                               ),
//                             ),
//                             Align(
//                               alignment: Alignment.centerRight,
//                               child: Padding(
//                                 padding: EdgeInsets.all(8),
//                                 child: Text("E", style: TextStyle(fontWeight: FontWeight.bold)),
//                               ),
//                             ),
//                             Align(
//                               alignment: Alignment.centerLeft,
//                               child: Padding(
//                                 padding: EdgeInsets.all(8),
//                                 child: Text("W", style: TextStyle(fontWeight: FontWeight.bold)),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),

//                       Transform.rotate(
//                         angle: -currentUserHeadingRad(currentHeading),
//                         child: Icon(Icons.navigation, size: 200, color: Colors.grey.withValues(alpha: 0.2)),
//                       ),

//                       Transform.rotate(
//                         angle: -currentUserHeadingRad(currentHeading),
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Icon(Icons.arrow_upward, size: 50, color: Colors.red),
//                             Text(
//                               "N",
//                               style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
//                             ),
//                             SizedBox(height: 50), // Spacing
//                           ],
//                         ),
//                       ),

//                       // Target Indicator (Optimal Direction)
//                       Transform.rotate(
//                         angle: -currentUserHeadingRad(currentHeading) + (controller.optimalDirection == "South" ? math.pi : 0),
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Icon(Icons.arrow_upward, size: 50, color: Colors.green),
//                             Text(
//                               "Optimal",
//                               style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
//                             ),
//                             SizedBox(height: 50), // Spacing
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 20),
//                   Text(
//                     isAligned ? "Perfect Alignment! ✅" : "Rotate phone to align Green Arrow",
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isAligned ? Colors.green : Colors.orange),
//                   ),
//                   Text("Current Heading: ${currentHeading.toStringAsFixed(0)}°"),
//                 ],
//               );
//             }),

//             const SizedBox(height: 30),

//             // Results Card
//             controller.orientationLat != 0
//                   ? Container(
//                       padding: const EdgeInsets.all(20,
//                       width: double.infinity,
//                       decoration: BoxDecoration(
//                         color: AppTheme.primaryColor,
//                         borderRadius: BorderRadius.circular(20),
//                         boxShadow: [BoxShadow(color: AppTheme.primaryColor.withValues(alpha: 0.3), blurRadius: 10, offset: Offset(0, 5))],
//                       ),
//                       child: Column(
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text("Optimal Tilt", style: TextStyle(color: Colors.white70)),
//                                   Text(
//                                     "${controller.optimalTilt.toStringAsFixed(1)}°",
//                                     style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
//                                   ),
//                                 ],
//                               ),
//                               Container(height: 40, width: 1, color: Colors.white24),
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.end,
//                                 children: [
//                                   Text("Face Direction", style: TextStyle(color: Colors.white70)),
//                                   Text(
//                                     controller.optimalDirection,
//                                     style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 16),
//                           Container(
//                             padding: EdgeInsets.all(10),
//                             decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(10)),
//                             child: Text(
//                               "For best year-round performance, tilt panels at ${controller.optimalTilt.toStringAsFixed(1)}° facing ${controller.optimalDirection}.",
//                               textAlign: TextAlign.center,
//                               style: TextStyle(color: Colors.white),
//                             ),
//                           ),
//                         ],
//                       ),
//                     )
//                   : SizedBox.shrink(),
//             ),

//             const SizedBox(height: 20),
//             // Educational Hint
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: isDark ? Colors.grey[800] : Colors.grey[100],
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     "Why Orientation Matters? / أهمية التوجيه",
//                     style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
//                   ),
//                   const SizedBox(height: 10),
//                   _buildDefinitionRow(
//                     "Azimuth (Direction)",
//                     "Panels should face the equator (South in North Hemisphere) to catch sun all day.\nيجب توجيه الألواح نحو خط الاستواء (الجنوب في نصف الكرة الشمالي).",
//                   ),
//                   _buildDefinitionRow(
//                     "Tilt Angle",
//                     "Angle from horizontal. Usually equals your Latitude for year-round average.\nزاوية الميل عن الأفق، وعادة ما تساوي خط العرض للحصول على أفضل متوسط سنوي.",
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   double currentUserHeadingRad(double heading) {
//     return heading * (math.pi / 180);
//   }

//   Widget _buildDefinitionRow(String title, String desc) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text("• $title:", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
//           Padding(
//             padding: const EdgeInsets.only(left: 12.0),
//             child: Text(desc, style: const TextStyle(fontSize: 12, height: 1.4, color: Colors.grey)),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showHelpDialog() {
//     final explanations = AppExplanations(context).getDirectionExplanations();
//     bool dontShowAgain = true;

//     showDialog(
//       context: context,
//       builder: (context) => Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         child: Container(
//           padding: const EdgeInsets.all(20),
//           height: 600,
//           child: Column(
//             children: [
//               Text('guide', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), // TODO: translate
//               const SizedBox(height: 16),
//               Expanded(
//                 child: ListView.separated(
//                   itemCount: explanations.length,
//                   separatorBuilder: (_, _) => const Divider(),
//                   itemBuilder: (context, index) {
//                     final item = explanations[index];
//                     return Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           item.title,
//                           style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(item.description, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
//                       ],
//                     );
//                   },
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Row(
//                 children: [
//                   Checkbox(value: dontShowAgain, onChanged: (val) => dontShowAgain = val ?? false, activeColor: AppTheme.primaryColor),
//                   Text('dont_show_again'), // TODO: translate
//                 ],
//               ),
//               const SizedBox(height: 8),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     if (dontShowAgain) {
//                       GetStorage().write('direction_calc_help_viewed', true);
//                     }
//                     Navigator.pop(context);
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppTheme.primaryColor,
//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                   ),
//                   child: Text('close'), // TODO: translate
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
