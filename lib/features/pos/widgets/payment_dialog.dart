import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_hub/controllers/company_controller.dart';
import 'package:solar_hub/models/customer_model.dart';
import 'package:solar_hub/utils/price_format_utils.dart';

class PaymentDialog extends StatefulWidget {
  final double totalAmount;
  final CustomerModel? customer;

  const PaymentDialog({super.key, required this.totalAmount, this.customer});

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  String selectedMethod = 'cash'; // cash, card
  final TextEditingController _amountController = TextEditingController();
  double remainingBalance = 0.0;
  String infoText = '';

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_updateInfo);
    // Default remaining balance is total (assuming 0 input initially)
    remainingBalance = widget.totalAmount;
    _updateInfo();
  }

  void _updateInfo() {
    final input = double.tryParse(_amountController.text) ?? 0.0;

    setState(() {
      if (input >= widget.totalAmount) {
        remainingBalance = 0;
        infoText = 'full_payment'.tr;
      } else {
        remainingBalance = widget.totalAmount - input;
        if (remainingBalance > 0) {
          if (widget.customer == null) {
            infoText = 'guest_must_pay_full'.tr;
          } else {
            infoText = input == 0
                ? 'full_credit_charged'.tr
                : 'remaining_credit_charged'.trParams({'amount': remainingBalance.toPriceWithCurrency(Get.find<CompanyController>().effectiveCurrency.symbol)});
          }
        }
      }
    });
  }

  void _submit() {
    final input = double.tryParse(_amountController.text);
    if (input == null) {
      Get.snackbar('Error', 'enter_valid_amount'.tr, duration: const Duration(seconds: 2));
      return;
    }

    if (widget.customer == null && input < widget.totalAmount) {
      Get.snackbar('Error', 'guest_must_pay_full'.tr, backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    // Return result structure: {method, amount}
    // If input is 0, logic in controller effectively treats it as full credit
    // If input < total, logic treats as partial
    // Payment Method (cash/card) applies to the 'Paid Now' portion.

    Navigator.of(context).pop({'method': input == 0 ? 'on_account' : selectedMethod, 'amount': input});
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('confirm_pay'.tr),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total
            Center(
              child: Column(
                children: [
                  Text('total_amount'.tr, style: const TextStyle(color: Colors.grey)),
                  Text(
                    widget.totalAmount.toPriceWithCurrency(Get.find<CompanyController>().effectiveCurrency.symbol),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                ],
              ),
            ),
            const Divider(height: 30),

            // Method Selection
            Text('select_payment_method'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [const Icon(Icons.money, size: 18), const SizedBox(width: 8), Text('cash'.tr)],
                    ),
                    selected: selectedMethod == 'cash',
                    onSelected: (val) => setState(() => selectedMethod = 'cash'),
                    selectedColor: Colors.green.withValues(alpha: 0.2),
                    labelStyle: TextStyle(color: selectedMethod == 'cash' ? Colors.green : Colors.black),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ChoiceChip(
                    label: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [const Icon(Icons.credit_card, size: 18), const SizedBox(width: 8), Text('card'.tr)],
                    ),
                    selected: selectedMethod == 'card',
                    onSelected: (val) => setState(() => selectedMethod = 'card'),
                    selectedColor: Colors.blue.withValues(alpha: 0.2),
                    labelStyle: TextStyle(color: selectedMethod == 'card' ? Colors.blue : Colors.black),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Amount Input
            Text('paid_now'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: 'Enter 0 for full credit',
                prefixText: '${Get.find<CompanyController>().effectiveCurrency.symbol} ',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(icon: const Icon(Icons.clear), onPressed: () => _amountController.clear()),
              ),
            ),

            // Info / Validation Text
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (widget.customer == null && remainingBalance > 0) ? Colors.red.shade50 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(infoText, style: TextStyle(color: (widget.customer == null && remainingBalance > 0) ? Colors.red : Colors.black87, fontSize: 12)),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('cancel'.tr)),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
          child: Text('confirm_pay_btn'.tr),
        ),
      ],
    );
  }
}
