import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/src/features/calculations/presentation/providers/calculator_controller.dart';
import 'package:solar_hub/src/features/calculations/presentation/providers/systems_provider.dart';
import 'package:solar_hub/src/features/calculations/domain/entities/system_model.dart';
import 'package:solar_hub/src/utils/app_theme.dart';
import 'package:toastification/toastification.dart';
import 'package:solar_hub/src/utils/app_explanations.dart';
import 'package:get_storage/get_storage.dart';

class OfferRequestWizard extends ConsumerStatefulWidget {
  const OfferRequestWizard({super.key});

  @override
  ConsumerState<OfferRequestWizard> createState() => _OfferRequestWizardState();
}

class _OfferRequestWizardState extends ConsumerState<OfferRequestWizard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final box = GetStorage();
      if (box.read('offer_request_wizard_help_viewed') != true) {
        _showHelpDialog();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(calculatorProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('request_offer_wizard'),
        elevation: 0,
        actions: [IconButton(onPressed: _showHelpDialog, icon: const Icon(Icons.help_outline))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('request_offer_desc', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 24),

            // Panels
            _buildSectionHeader(context, 'panels_calc', Iconsax.sun_1_bold, Colors.amber),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _cardDecoration(context),
              child: Column(
                children: [
                  _buildIntInputRow(
                    context,
                    label: 'panel_wattage',
                    value: controller.selectedPanelWattage.toDouble(),
                    suffix: "W",
                    onChanged: (val) => controller.updateField(() => controller.selectedPanelWattage = int.tryParse(val) ?? 0),
                  ),
                  const SizedBox(height: 12),
                  _buildNoteField(context, controller.panelNote, "Notes (optional)", (val) => controller.updateField(() => controller.panelNote = val)),
                  const Divider(),
                  _buildCounterRow(
                    context,
                    label: 'count',
                    value: controller.panelCount,
                    onDecrement: () => controller.updateField(() => controller.panelCount > 0 ? controller.panelCount-- : null),
                    onIncrement: () => controller.updateField(() => controller.panelCount++),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Inverter
            _buildSectionHeader(context, 'inverter_calc', Iconsax.flash_bold, Colors.red),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _cardDecoration(context),
              child: Column(
                children: [
                  Builder(
                    builder: (context) {
                      return _buildInputRow(
                        context,
                        label: 'capacity_kw',
                        value: controller.selectedInverterKva,
                        suffix: "kW",
                        onChanged: (val) => controller.updateField(() => controller.selectedInverterKva = double.tryParse(val) ?? 0.0),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildStringDropdownRow(
                    context,
                    label: 'voltage_type',
                    value: controller.selectedInverterVoltType,
                    items: ['Low Voltage', 'High Voltage'],
                    onChanged: (val) => controller.updateField(() => controller.selectedInverterVoltType = val ?? 'Low Voltage'),
                  ),
                  const SizedBox(height: 12),
                  _buildStringDropdownRow(
                    context,
                    label: 'phase',
                    value: controller.selectedInverterPhase,
                    items: ['Single Phase', 'three_phase'],
                    onChanged: (val) => controller.updateField(() => controller.selectedInverterPhase = val ?? 'Single Phase'),
                  ),
                  const SizedBox(height: 12),
                  _buildStringDropdownRow(
                    context,
                    label: "Type",
                    value: controller.selectedInverterType,
                    items: ['Hybrid', 'On-Grid', 'Off-Grid'],
                    onChanged: (val) => controller.updateField(() => controller.selectedInverterType = val ?? 'Hybrid'),
                  ),
                  const SizedBox(height: 12),
                  _buildNoteField(
                    context,
                    controller.inverterNote,
                    "Notes (Brand, specific models...)",
                    (val) => controller.updateField(() => controller.inverterNote = val),
                  ),
                  const Divider(),
                  _buildCounterRow(
                    context,
                    label: 'count',
                    value: controller.inverterCount,
                    onDecrement: () => controller.updateField(() => controller.inverterCount > 0 ? controller.inverterCount-- : null),
                    onIncrement: () => controller.updateField(() => controller.inverterCount++),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Batteries
            _buildSectionHeader(context, 'battery_calc', Iconsax.battery_charging_bold, Colors.green),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _cardDecoration(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStringDropdownRow(
                    context,
                    label: "Type",
                    value: controller.selectedBatteryType,
                    items: ['Lithium', 'Gel / Lead-Acid / Tubular'],
                    onChanged: (val) => controller.updateField(() => controller.selectedBatteryType = val ?? 'Lithium'),
                  ),
                  const SizedBox(height: 12),
                  Builder(
                    builder: (context) {
                      bool isHVInverter = controller.selectedInverterVoltType == 'High Voltage';
                      if (isHVInverter) {
                        return const SizedBox.shrink(); // Hide voltage selection if HV Inverter
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('battery_voltage'),
                          const SizedBox(height: 4),
                          Builder(
                            builder: (context) {
                              String type = controller.selectedBatteryType;
                              List<double> voltages = type == 'Lithium' ? [12.8, 25.6, 51.2] : [2.0, 6.0, 12.0];
                              return Wrap(
                                spacing: 8,
                                children: voltages
                                    .map(
                                      (v) => ChoiceChip(
                                        label: Text("${v.toString().replaceAll('.0', '')}V"),
                                        selected: controller.selectedBatteryVoltage == v,
                                        onSelected: (s) {
                                          if (s) controller.updateField(() => controller.selectedBatteryVoltage = v);
                                        },
                                      ),
                                    )
                                    .toList(),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                        ],
                      );
                    },
                  ),
                  Text('battery_type_hint', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                  const SizedBox(height: 12),
                  Builder(
                    builder: (context) {
                      bool isHVInverter = controller.selectedInverterVoltType == 'High Voltage';
                      return _buildInputRow(
                        context,
                        label: isHVInverter ? 'capacity_kw' : 'battery_amp',
                        value: controller.selectedBatteryAmp,
                        suffix: isHVInverter ? "kW" : "Ah",
                        onChanged: (val) => controller.updateField(() => controller.selectedBatteryAmp = double.tryParse(val) ?? 0.0),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildNoteField(
                    context,
                    controller.batteryNote,
                    "Notes (Brand, Specific type...)",
                    (val) => controller.updateField(() => controller.batteryNote = val),
                  ),
                  const Divider(),
                  Builder(
                    builder: (context) {
                      bool isHVInverter = controller.selectedInverterVoltType == 'High Voltage';
                      return _buildCounterRow(
                        context,
                        label: isHVInverter ? 'bank' : 'count',
                        value: controller.batteryCount,
                        onDecrement: () => controller.updateField(() => controller.batteryCount > 0 ? controller.batteryCount-- : null),
                        onIncrement: () => controller.updateField(() => controller.batteryCount++),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Details
            Text('notes_details', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              onChanged: (val) => controller.updateField(() => controller.requestNotes = val),
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Specific installation constraints, location notes, or other requests...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
            ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (controller.panelCount == 0 && controller.inverterCount == 0 && controller.batteryCount == 0) {
                    toastification.show(
                      title: const Text("Error"),
                      description: const Text("Please add at least one component (Panel, Inverter, or Battery)"),
                      type: ToastificationType.error,
                      style: ToastificationStyle.flat,
                      autoCloseDuration: const Duration(seconds: 3),
                    );
                    return;
                  }

                  final system = SystemModel(
                    id: '',
                    systemName: "System Request: ${controller.selectedInverterKva}kW",
                    totalCapacityKw: controller.selectedInverterKva,
                    notes: controller.requestNotes,
                    specs: {
                      'panels': {'count': controller.panelCount, 'capacity': controller.selectedPanelWattage, 'note': controller.panelNote},
                      'battery': {
                        'count': controller.batteryCount,
                        'capacity': controller.selectedBatteryAmp,
                        'type': controller.selectedBatteryType,
                        'voltageType': controller.selectedInverterVoltType == 'High Voltage' ? 'HV' : 'LV',
                        'note': controller.batteryNote,
                        'voltage': controller.systemVoltage,
                      },
                      'inverter': {
                        'count': controller.inverterCount,
                        'power': controller.selectedInverterKva,
                        'note': controller.inverterNote,
                        'voltageType': controller.selectedInverterVoltType == 'High Voltage' ? 'HV' : 'LV',
                        'type': controller.selectedInverterType,
                        'phase': controller.selectedInverterPhase,
                      },
                    },
                  );
                  ref.read(systemsProvider.notifier).requestOffers(system);

                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('submit_request', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5)],
    );
  }

  Widget _buildStringDropdownRow(
    BuildContext context, {
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        DropdownButton<String>(
          value: value,
          underline: const SizedBox(),
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildIntInputRow(
    BuildContext context, {
    required String label,
    required double value,
    required String suffix,
    required ValueChanged<String> onChanged,
  }) {
    return Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
        SizedBox(
          width: 100,
          child: TextFormField(
            initialValue: value.toString(),
            keyboardType: TextInputType.number,
            textAlign: TextAlign.end,
            decoration: InputDecoration(
              suffixText: suffix,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              isDense: true,
            ),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildInputRow(BuildContext context, {required String label, required double value, required String suffix, required ValueChanged<String> onChanged}) {
    return Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
        SizedBox(
          width: 120,
          child: TextFormField(
            key: ValueKey(label + suffix), // Ensure field updates when label/suffix changes
            initialValue: value.toString(),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.start,
            decoration: InputDecoration(
              suffixText: suffix,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              isDense: true,
            ),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildNoteField(BuildContext context, String value, String hint, ValueChanged<String> onChanged) {
    return TextFormField(
      initialValue: value,
      onChanged: onChanged,

      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 12, color: Colors.grey[400]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        isDense: true,
      ),
    );
  }

  Widget _buildCounterRow(
    BuildContext context, {
    required String label,
    required int value,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Container(
          decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Row(
            children: [
              IconButton(onPressed: onDecrement, icon: const Icon(Icons.remove, size: 16)),
              Text("${value}", style: const TextStyle(fontWeight: FontWeight.bold)),
              IconButton(onPressed: onIncrement, icon: const Icon(Icons.add, size: 16)),
            ],
          ),
        ),
      ],
    );
  }

  void _showHelpDialog() {
    final explanations = AppExplanations(context).getOfferRequestExplanations();
    bool dontShowAgain = true;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          height: 600,
          child: Column(
            children: [
              Text('guide', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: explanations.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final item = explanations[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
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
                  StatefulBuilder(
                    builder: (context, setStateBuilder) {
                      return Checkbox(
                        value: dontShowAgain,
                        onChanged: (val) {
                          setStateBuilder(() {
                            dontShowAgain = val ?? false;
                          });
                        },
                        activeColor: AppTheme.primaryColor,
                      );
                    },
                  ),
                  Text('dont_show_again'),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (dontShowAgain) {
                      GetStorage().write('offer_request_wizard_help_viewed', true);
                    }
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
