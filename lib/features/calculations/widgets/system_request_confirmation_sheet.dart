import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_hub/features/calculations/controllers/calculator_controller.dart';
import 'package:solar_hub/utils/app_theme.dart';

class SystemRequestConfirmationSheet extends StatelessWidget {
  const SystemRequestConfirmationSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CalculatorController>();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              margin: const EdgeInsets.only(bottom: 24),
            ),
          ),
          Text('confirm_request_details'.tr, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          _buildSummaryRow("Panels", "${controller.panelCount.value}x ${controller.selectedPanelWattage.value}W"),
          _buildSummaryRow("Inverter", "${controller.inverterCount.value}x ${controller.selectedInverterKva.value}kW"),
          _buildSummaryRow("Batteries", "${controller.batteryCount.value}x ${controller.selectedBatteryAmp.value}Ah"),

          const SizedBox(height: 16),
          TextField(
            onChanged: (val) => controller.requestNotes.value = val,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Add any notes or specific constraints...",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Theme.of(context).cardColor,
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Get.back(); // Close sheet
                controller.submitRequest();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text("confirm_submit".tr),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
