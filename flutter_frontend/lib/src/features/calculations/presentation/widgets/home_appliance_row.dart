import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_hub/src/features/calculations/domain/entities/appliance_entity.dart';
import 'package:solar_hub/src/features/calculations/presentation/providers/calculator_controller.dart';
import 'package:solar_hub/l10n/app_localizations.dart';

class HomeApplianceRow extends ConsumerWidget {
  const HomeApplianceRow({
    super.key,
    required this.app,
    required this.controller,
  });

  final ApplianceEntity app;
  final CalculatorNotifier controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          spacing: 10,
          children: [_wdTitle(context), const Divider(), _wdValues(context)],
        ),
      ),
    );
  }

  Widget _wdValues(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            initialValue: app.power.toString(),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.power_watts,
              suffixText: "W",
            ),
            onChanged: (val) => app.power = double.tryParse(val) ?? 0,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            initialValue: app.quantity.toString(),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.quantity,
            ),
            onChanged: (val) => app.quantity = int.tryParse(val) ?? 1,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            initialValue: app.hours.toString(),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.hours_per_day,
              suffixText: "h",
            ),
            onChanged: (val) => app.hours = double.tryParse(val) ?? 0,
          ),
        ),
      ],
    );
  }

  Row _wdTitle(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.devices, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: TextFormField(
            initialValue: app.name,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.appliance_name,
              border: InputBorder.none,
            ),
            onChanged: (val) => app.name = val,
          ),
        ),
        IconButton(
          onPressed: () =>
              controller.removeAppliance(controller.appliances.indexOf(app)),
          icon: const Icon(Icons.delete, color: Colors.red),
        ),
      ],
    );
  }
}
