import 'package:flutter/material.dart';
import 'package:watt/l10n/app_localizations.dart';

class NumberField extends StatelessWidget {
  const NumberField({
    super.key,
    required this.controller,
    required this.label,
    required this.suffix,
    required this.onChanged,
    this.minValue,
    this.allowZero = false,
    this.allowAnyNumeric = false,
    this.decoration,
  });

  final TextEditingController controller;
  final String label;
  final String suffix;
  final ValueChanged<double> onChanged;
  final double? minValue;
  final bool allowZero;
  final bool allowAnyNumeric;
  final InputDecoration? decoration;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
          signed: true,
        ),
        decoration: decoration ??
            InputDecoration(
              labelText: label,
              suffixText: suffix,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Theme.of(context).cardColor,
            ),
        validator: (value) {
          final parsed = double.tryParse(value ?? '');
          if (parsed == null) {
            return AppLocalizations.of(context)!.structure_validation_positive;
          }
          if (allowAnyNumeric) {
            return null;
          }
          if (!allowZero && parsed == 0) {
            return AppLocalizations.of(context)!.structure_validation_positive;
          }
          if (minValue != null && parsed < minValue!) {
            return AppLocalizations.of(context)!.structure_validation_positive;
          }
          return null;
        },
        onChanged: (value) => onChanged(double.tryParse(value) ?? 0.0),
      ),
    );
  }
}
