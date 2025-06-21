import 'package:flutter/material.dart';
import 'package:solar_hub/utils/app_constants.dart';
import 'package:solar_hub/layouts/widgets/text_helper_card.dart';

Widget inputField(
  String? helpText, {
  required String label,
  required String hintText,
  required IconData icon,
  Color iconColor = Colors.orangeAccent,
  required TextEditingController controller,
  required String? Function(String?)? validator,
  required String? Function(String?)? onChanged,
  TextInputType type = TextInputType.number,
  required BuildContext context,
  bool enabled = true,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextFormField(
        keyboardType: type,
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          prefixIcon: Icon(icon, color: iconColor),
        ),
        validator: validator,
        onChanged: onChanged,
        enabled: enabled,
      ),
      if (helpText != null) ...[
        verSpace(space: 10),
        textHelperCard(context, text: helpText),
      ],
      verSpace(),
    ],
  );
}
