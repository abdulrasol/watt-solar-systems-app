import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PvNumberField extends StatefulWidget {
  const PvNumberField({
    super.key,
    required this.label,
    required this.controller,
    required this.suffix,
    this.min,
    this.max,
    this.onChanged,
    this.infoText,
  });

  final String label;
  final TextEditingController controller;
  final String suffix;
  final double? min;
  final double? max;
  final ValueChanged<double>? onChanged;
  final String? infoText;

  @override
  State<PvNumberField> createState() => _PvNumberFieldState();
}

class _PvNumberFieldState extends State<PvNumberField> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) _applyValue();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _applyValue() {
    final text = widget.controller.text.trim();
    if (text.isEmpty) return;
    final value = double.tryParse(text);
    if (value == null) return;
    if (widget.min != null && value < widget.min!) return;
    if (widget.max != null && value > widget.max!) return;
    widget.onChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: widget.label,
          suffixText: widget.suffix,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) return null;
          final parsed = double.tryParse(value.trim());
          if (parsed == null) return 'Invalid number';
          if (widget.min != null && parsed < widget.min!) return 'Min: ${widget.min}';
          if (widget.max != null && parsed > widget.max!) return 'Max: ${widget.max}';
          return null;
        },
        onFieldSubmitted: (_) => _applyValue(),
      ),
    );
  }
}
