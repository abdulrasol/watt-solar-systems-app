import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_hub/features/calculations/controllers/calculator_controller.dart';

class HomeApplianceRow extends StatelessWidget {
  const HomeApplianceRow({super.key, required this.app, required this.controller});

  final ApplianceModel app;
  final CalculatorController controller;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(spacing: 10, children: [_wdTitle(), const Divider(), _wdValues()]),
      ),
    );
  }

  Widget _wdValues() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            initialValue: app.power.toString(),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: "power_watts".tr, suffixText: "W"),
            onChanged: (val) => app.power = double.tryParse(val) ?? 0,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            initialValue: app.quantity.toString(),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: "quantity".tr),
            onChanged: (val) => app.quantity = int.tryParse(val) ?? 1,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            initialValue: app.hours.toString(),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: "hours_per_day".tr, suffixText: "h"),
            onChanged: (val) => app.hours = double.tryParse(val) ?? 0,
          ),
        ),
      ],
    );
  }

  Row _wdTitle() {
    return Row(
      children: [
        const Icon(Icons.devices, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: TextFormField(
            initialValue: app.name,
            decoration: InputDecoration(labelText: "appliance_name".tr, border: InputBorder.none),
            onChanged: (val) => app.name = val,
          ),
        ),
        IconButton(
          onPressed: () => controller.removeAppliance(controller.appliances.indexOf(app)),
          icon: const Icon(Icons.delete, color: Colors.red),
        ),
      ],
    );
  }
}
