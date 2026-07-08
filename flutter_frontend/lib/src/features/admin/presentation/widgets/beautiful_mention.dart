import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A custom text input widget that supports mention-style functionality
/// with customizable input decoration.
class BeautifulMention extends StatelessWidget {
  const BeautifulMention({
    super.key,
    required this.controller,
    this.enabled = true,
    this.maxLines = 1,
    this.style,
    required this.inputDecoration,
    this.validator,
    this.onChanged,
    this.textInputAction,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.none,
    this.textInputType = TextInputType.text,
  });

  final TextEditingController controller;
  final bool enabled;
  final int maxLines;
  final TextStyle? style;
  final InputDecoration inputDecoration;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final TextInputAction? textInputAction;
  final bool autofocus;
  final TextCapitalization textCapitalization;
  final TextInputType textInputType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      style: style,
      decoration: inputDecoration,
      validator: validator,
      onChanged: onChanged,
      textInputAction: textInputAction,
      autofocus: autofocus,
      textCapitalization: textCapitalization,
      keyboardType: textInputType,
      inputFormatters: [
        LengthLimitingTextInputFormatter(maxLines == 1 ? 100 : 500),
      ],
    );
  }
}
