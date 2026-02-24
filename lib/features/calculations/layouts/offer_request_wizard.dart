import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/features/calculations/controllers/calculator_controller.dart';
import 'package:solar_hub/utils/app_theme.dart';
import 'package:toastification/toastification.dart';
import 'package:solar_hub/utils/app_explanations.dart';
import 'package:get_storage/get_storage.dart';

class OfferRequestWizard extends StatefulWidget {
  const OfferRequestWizard({super.key});

  @override
  State<OfferRequestWizard> createState() => _OfferRequestWizardState();
}

class _OfferRequestWizardState extends State<OfferRequestWizard> {
  final CalculatorController controller = Get.put(CalculatorController());

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
    return Scaffold(
      appBar: AppBar(
        title: Text("request_offer_wizard".tr),
        elevation: 0,
        actions: [IconButton(onPressed: _showHelpDialog, icon: const Icon(Icons.help_outline))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("request_offer_desc".tr, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 24),

            // Panels
            _buildSectionHeader(context, "panels_calc".tr, Iconsax.sun_1_bold, Colors.amber),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _cardDecoration(context),
              child: Column(
                children: [
                  _buildIntInputRow(context, label: "panel_wattage".tr, value: controller.selectedPanelWattage, suffix: "W"),
                  const SizedBox(height: 12),
                  _buildNoteField(context, controller.panelNote, "Notes (optional)"),
                  const Divider(),
                  _buildCounterRow(context, label: "count".tr, value: controller.panelCount),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Inverter
            _buildSectionHeader(context, "inverter_calc".tr, Iconsax.flash_bold, Colors.red),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _cardDecoration(context),
              child: Column(
                children: [
                  Obx(() {
                    return _buildInputRow(context, label: "capacity_kw".tr, value: controller.selectedInverterKva, suffix: "kW");
                  }),
                  const SizedBox(height: 12),
                  _buildStringDropdownRow(
                    context,
                    label: "voltage_type".tr,
                    value: controller.selectedInverterVoltType,
                    items: ['Low Voltage', 'High Voltage'],
                  ),
                  const SizedBox(height: 12),
                  _buildStringDropdownRow(context, label: "phase".tr, value: controller.selectedInverterPhase, items: ['Single Phase', 'three_phase'.tr]),
                  const SizedBox(height: 12),
                  _buildStringDropdownRow(context, label: "Type", value: controller.selectedInverterType, items: ['Hybrid', 'On-Grid', 'Off-Grid']),
                  const SizedBox(height: 12),
                  _buildNoteField(context, controller.inverterNote, "Notes (Brand, specific models...)"),
                  const Divider(),
                  _buildCounterRow(context, label: "count".tr, value: controller.inverterCount),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Batteries
            _buildSectionHeader(context, "battery_calc".tr, Iconsax.battery_charging_bold, Colors.green),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _cardDecoration(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStringDropdownRow(context, label: "Type", value: controller.selectedBatteryType, items: ['Lithium', 'Gel / Lead-Acid / Tubular']),
                  const SizedBox(height: 12),
                  Obx(() {
                    bool isHVInverter = controller.selectedInverterVoltType.value == 'High Voltage';
                    if (isHVInverter) {
                      return const SizedBox.shrink(); // Hide voltage selection if HV Inverter
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("battery_voltage".tr),
                        const SizedBox(height: 4),
                        Obx(() {
                          String type = controller.selectedBatteryType.value;
                          List<double> voltages = type == 'Lithium' ? [12.8, 25.6, 51.2] : [2.0, 6.0, 12.0];
                          return Wrap(
                            spacing: 8,
                            children: voltages
                                .map(
                                  (v) => ChoiceChip(
                                    label: Text("${v.toString().replaceAll('.0', '')}V"),
                                    selected: controller.selectedBatteryVoltage.value == v,
                                    onSelected: (s) => s ? controller.selectedBatteryVoltage.value = v : null,
                                  ),
                                )
                                .toList(),
                          );
                        }),
                        const SizedBox(height: 8),
                      ],
                    );
                  }),
                  Text("battery_type_hint".tr, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                  const SizedBox(height: 12),
                  Obx(() {
                    bool isHVInverter = controller.selectedInverterVoltType.value == 'High Voltage';
                    return _buildInputRow(
                      context,
                      label: isHVInverter ? "capacity_kw".tr : "battery_amp".tr,
                      value: controller.selectedBatteryAmp,
                      suffix: isHVInverter ? "kW" : "Ah",
                    );
                  }),
                  const SizedBox(height: 12),
                  _buildNoteField(context, controller.batteryNote, "Notes (Brand, Specific type...)"),
                  const Divider(),
                  Obx(() {
                    bool isHVInverter = controller.selectedInverterVoltType.value == 'High Voltage';
                    return _buildCounterRow(context, label: isHVInverter ? "bank".tr : "count".tr, value: controller.batteryCount);
                  }),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Details
            Text("notes_details".tr, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              onChanged: (val) => controller.requestNotes.value = val,
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
                  if (controller.panelCount.value == 0 && controller.inverterCount.value == 0 && controller.batteryCount.value == 0) {
                    toastification.show(
                      title: const Text("Error"),
                      description: const Text("Please add at least one component (Panel, Inverter, or Battery)"),
                      type: ToastificationType.error,
                      style: ToastificationStyle.flat,
                      autoCloseDuration: const Duration(seconds: 3),
                    );
                    return;
                  }
                  controller.submitRequest();
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text("submit_request".tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

  Widget _buildStringDropdownRow(BuildContext context, {required String label, required RxString value, required List<String> items}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Obx(
          () => DropdownButton<String>(
            value: value.value,
            underline: const SizedBox(),
            items: items
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(e, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                )
                .toList(),
            onChanged: (val) {
              if (val != null) value.value = val;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildIntInputRow(BuildContext context, {required String label, required RxInt value, required String suffix}) {
    return Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
        SizedBox(
          width: 100,
          child: TextFormField(
            initialValue: value.value.toString(),
            keyboardType: TextInputType.number,
            textAlign: TextAlign.end,
            decoration: InputDecoration(
              suffixText: suffix,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              isDense: true,
            ),
            onChanged: (val) {
              value.value = int.tryParse(val) ?? 0;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInputRow(BuildContext context, {required String label, required RxDouble value, required String suffix}) {
    return Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
        SizedBox(
          width: 120,
          child: TextFormField(
            key: ValueKey(label + suffix), // Ensure field updates when label/suffix changes
            initialValue: value.value.toString(),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.start,
            decoration: InputDecoration(
              suffixText: suffix,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              isDense: true,
            ),
            onChanged: (val) {
              value.value = double.tryParse(val) ?? 0.0;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNoteField(BuildContext context, RxString controllerNote, String hint) {
    return TextFormField(
      onChanged: (val) => controllerNote.value = val,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 12, color: Colors.grey[400]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        isDense: true,
      ),
    );
  }

  Widget _buildCounterRow(BuildContext context, {required String label, required RxInt value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Container(
          decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Row(
            children: [
              IconButton(onPressed: () => value.value > 0 ? value.value-- : null, icon: const Icon(Icons.remove, size: 16)),
              Obx(() => Text("${value.value}", style: const TextStyle(fontWeight: FontWeight.bold))),
              IconButton(onPressed: () => value.value++, icon: const Icon(Icons.add, size: 16)),
            ],
          ),
        ),
      ],
    );
  }

  void _showHelpDialog() {
    final explanations = AppExplanations.getOfferRequestExplanations();
    RxBool dontShowAgain = true.obs;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          height: 600,
          child: Column(
            children: [
              Text("guide".tr, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                  Obx(() => Checkbox(value: dontShowAgain.value, onChanged: (val) => dontShowAgain.value = val ?? false, activeColor: AppTheme.primaryColor)),
                  Text("dont_show_again".tr),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (dontShowAgain.value) {
                      GetStorage().write('offer_request_wizard_help_viewed', true);
                    }
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text("close".tr),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
