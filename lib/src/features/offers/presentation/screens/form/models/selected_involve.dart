import 'package:flutter/material.dart';

class SelectedTemplateInvolve {
  int? templateId;
  final TextEditingController quantityController;

  SelectedTemplateInvolve({this.templateId, int quantity = 1}) : quantityController = TextEditingController(text: quantity.toString());

  int get quantity => int.tryParse(quantityController.text.trim()) ?? 1;

  void dispose() {
    quantityController.dispose();
  }
}
