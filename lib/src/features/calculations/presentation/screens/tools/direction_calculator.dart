import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/src/features/calculations/presentation/providers/calculator_controller.dart';
import 'package:solar_hub/src/utils/app_theme.dart';
import 'package:solar_hub/src/utils/app_explanations.dart';
import 'package:get_storage/get_storage.dart';
import 'package:solar_hub/l10n/app_localizations.dart';

class DirectionCalculator extends ConsumerStatefulWidget {
  const DirectionCalculator({super.key});

  @override
  ConsumerState<DirectionCalculator> createState() => _DirectionCalculatorState();
}

class _DirectionCalculatorState extends ConsumerState<DirectionCalculator> {
  late TextEditingController _textController;
  late final CalculatorNotifier controller;
  StreamSubscription<CompassEvent>? _compassSubscription;

  @override
  void initState() {
    super.initState();
    controller = ref.read(calculatorProvider);

    // Initialize text controller with current value
    String initialText = controller.orientationLat == 0 ? '' : controller.orientationLat.toString();
    _textController = TextEditingController(text: initialText);

    // Listen to compass
    _compassSubscription = FlutterCompass.events?.listen((event) {
      if (mounted) {
        setState(() {
          controller.compassHeading = event.heading ?? 0;
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final box = GetStorage();
      if (box.read('direction_calc_help_viewed') != true) {
        _showHelpDialog();
      }
    });
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    ref.watch(calculatorProvider);

    // Update text controller if location was auto-detected
    String controllerText = controller.orientationLat == 0 ? '' : controller.orientationLat.toString();
    if (_textController.text != controllerText && !controller.locationLoading) {
       // Only update if parsing result is different to avoid cursor jump while typing
       if (double.tryParse(_textController.text) != controller.orientationLat) {
         _textController.text = controllerText;
         _textController.selection = TextSelection.collapsed(offset: controllerText.length);
       }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.orientation_calc),
        actions: [IconButton(onPressed: _showHelpDialog, icon: const Icon(Icons.help_outline))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Hero(
              tag: 'direction_hero',
              child: Icon(Iconsax.map_1_bold, size: 80, color: Colors.teal),
            ),
            const SizedBox(height: 20),
            Text(l10n.align_panels_efficiency, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 30),

            // Location Input
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(l10n.your_latitude, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      controller.locationLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : TextButton.icon(onPressed: controller.fetchLocation, icon: const Icon(Icons.my_location, size: 18), label: Text(l10n.auto_detect)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _textController,
                    keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                    decoration: InputDecoration(
                      labelText: l10n.latitude_label,
                      hintText: l10n.latitude_hint,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.location_on),
                    ),
                    onChanged: (val) {
                      controller.orientationLat = double.tryParse(val) ?? 0;
                      controller.calculateOrientation();
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(l10n.hemisphere_hint, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Compass Visual
            Builder(builder: (context) {
              if (controller.orientationLat == 0) return const SizedBox.shrink();

              double targetHeading = controller.optimalDirection == "South" ? 180 : 0; // 0 is North
              double currentHeading = controller.compassHeading;
              double diff = (currentHeading - targetHeading).abs();
              bool isAligned = diff < 5 || diff > 355; // Tolerance 5 degrees

              return Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Compass Background
                      Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? Colors.grey[900] : Colors.grey[200],
                          boxShadow: [BoxShadow(color: isAligned ? Colors.green.withValues(alpha: 0.3) : Colors.black12, blurRadius: 20, spreadRadius: 5)],
                          border: Border.all(color: isAligned ? Colors.green : Colors.grey, width: 4),
                        ),
                        child: Stack(
                          children: [
                            // Markers
                            Align(
                              alignment: Alignment.topCenter,
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: Text(l10n.north[0], style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: Text(l10n.south[0], style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: Text(l10n.east[0], style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: Text(l10n.west[0], style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Transform.rotate(
                        angle: -currentUserHeadingRad(currentHeading),
                        child: Icon(Icons.navigation, size: 200, color: Colors.grey.withValues(alpha: 0.2)),
                      ),

                      Transform.rotate(
                        angle: -currentUserHeadingRad(currentHeading),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.arrow_upward, size: 50, color: Colors.red),
                            Text(
                              l10n.north[0],
                              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 50), // Spacing
                          ],
                        ),
                      ),

                      // Target Indicator (Optimal Direction)
                      Transform.rotate(
                        angle: -currentUserHeadingRad(currentHeading) + (controller.optimalDirection == "South" ? math.pi : 0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.arrow_upward, size: 50, color: Colors.green),
                            Text(
                              l10n.optimal,
                              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 50), // Spacing
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    isAligned ? l10n.perfect_alignment : l10n.rotate_phone_align,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isAligned ? Colors.green : Colors.orange),
                    textAlign: TextAlign.center,
                  ),
                  Text(l10n.current_heading(currentHeading.toStringAsFixed(0))),
                ],
              );
            }),

            const SizedBox(height: 30),

            // Results Card
            controller.orientationLat != 0
                  ? Container(
                      padding: const EdgeInsets.all(20),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: AppTheme.primaryColor.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5))],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(l10n.optimal_tilt, style: const TextStyle(color: Colors.white70)),
                                  Text(
                                    "${controller.optimalTilt.toStringAsFixed(1)}°",
                                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Container(height: 40, width: 1, color: Colors.white24),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(l10n.face_direction, style: const TextStyle(color: Colors.white70)),
                                  Text(
                                    _getLocalizedDirection(controller.optimalDirection, l10n),
                                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(10)),
                            child: Text(
                              l10n.best_performance_desc(
                                controller.optimalTilt.toStringAsFixed(1),
                                _getLocalizedDirection(controller.optimalDirection, l10n),
                              ),
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),

            const SizedBox(height: 20),
            // Educational Hint
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.why_orientation_matters,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                  ),
                  const SizedBox(height: 10),
                  _buildDefinitionRow(
                    l10n.azimuth_title,
                    l10n.azimuth_desc,
                  ),
                  _buildDefinitionRow(
                    l10n.tilt_angle_title,
                    l10n.tilt_angle_desc,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double currentUserHeadingRad(double heading) {
    return heading * (math.pi / 180);
  }

  String _getLocalizedDirection(String direction, AppLocalizations l10n) {
    switch (direction) {
      case "South":
        return l10n.south;
      case "North":
        return l10n.north;
      case "Equator":
        return l10n.equator;
      default:
        return direction;
    }
  }

  Widget _buildDefinitionRow(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("• $title:", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Text(desc, style: const TextStyle(fontSize: 12, height: 1.4, color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    final l10n = AppLocalizations.of(context)!;
    final explanations = AppExplanations(context).getDirectionExplanations();
    bool dontShowAgain = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(20),
            height: 600,
            child: Column(
              children: [
                Text(l10n.guide, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    itemCount: explanations.length,
                    separatorBuilder: (_, _) => const Divider(),
                    itemBuilder: (context, index) {
                      final item = explanations[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                          ),
                          const SizedBox(height: 4),
                          Text(item.description, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(value: dontShowAgain, onChanged: (val) => setDialogState(() => dontShowAgain = val ?? false), activeColor: AppTheme.primaryColor),
                    Text(l10n.dont_show_again),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (dontShowAgain) {
                        GetStorage().write('direction_calc_help_viewed', true);
                      }
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(l10n.close_button),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
