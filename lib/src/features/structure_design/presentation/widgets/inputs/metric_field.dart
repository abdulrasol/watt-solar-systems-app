import 'package:flutter/material.dart';
import 'package:solar_hub/l10n/app_localizations.dart';

class MetricField extends StatelessWidget {
  const MetricField({
    super.key,
    required this.label,
    required this.initialValue,
    required this.onChanged,
    this.decoration,
  });

  final String label;
  final double initialValue;
  final ValueChanged<double> onChanged;
  final InputDecoration? decoration;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        initialValue: initialValue.toStringAsFixed(2),
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
          signed: true,
        ),
        decoration: decoration ??
            InputDecoration(
              labelText: label,
              suffixText: AppLocalizations.of(context)!.metres,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Theme.of(context).cardColor,
            ),
        onChanged: (value) => onChanged(double.tryParse(value) ?? 0.0),
      ),
    );
  }
}
