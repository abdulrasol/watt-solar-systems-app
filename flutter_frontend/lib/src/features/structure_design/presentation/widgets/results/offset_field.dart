import 'package:flutter/material.dart';
import 'package:watt/l10n/app_localizations.dart';

class OffsetField extends StatelessWidget {
  const OffsetField({
    super.key,
    required this.label,
    required this.initialValue,
    required this.onChanged,
  });

  final String label;
  final double initialValue;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        initialValue: initialValue.toStringAsFixed(2),
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
          signed: true,
        ),
        decoration: InputDecoration(
          labelText: label,
          suffixText: AppLocalizations.of(context)!.metres,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Theme.of(context).cardColor,
          isDense: true,
        ),
        onChanged: (value) => onChanged(double.tryParse(value) ?? 0.0),
      ),
    );
  }
}
