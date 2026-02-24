import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_hub/controllers/company_controller.dart';
import 'package:solar_hub/features/orders/controllers/company_order_controller.dart';
import 'package:solar_hub/services/supabase_service.dart';

class AddPaymentDialog extends StatefulWidget {
  final String? initialCustomerId;
  final double? initialAmount;

  const AddPaymentDialog({super.key, this.initialCustomerId, this.initialAmount});

  @override
  State<AddPaymentDialog> createState() => _AddPaymentDialogState();
}

class _AddPaymentDialogState extends State<AddPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _dbService = SupabaseService();
  final companyId = Get.find<CompanyController>().company.value!.id;

  String? selectedCustomerId;
  double amount = 0.0;
  String paymentMethod = 'cash';
  bool isLoading = false;
  String? notes;

  List<Map<String, dynamic>> customers = [];

  @override
  void initState() {
    super.initState();
    selectedCustomerId = widget.initialCustomerId;
    amount = widget.initialAmount ?? 0.0;
    _fetchCustomers();
  }

  Future<void> _fetchCustomers() async {
    try {
      final res = await _dbService.client.from('customers').select('id, full_name, balance').eq('company_id', companyId).order('full_name');
      setState(() {
        customers = List<Map<String, dynamic>>.from(res);
      });
    } catch (e) {
      debugPrint('Error fetching customers: $e');
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (selectedCustomerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('select_customer_warn'.tr), backgroundColor: Colors.red));
      return;
    }

    setState(() => isLoading = true);

    try {
      // 1. Record Transaction
      await _dbService.client.from('financial_transactions').insert({
        'company_id': companyId,
        'type': 'income', // Payment from customer
        'category': 'customer_payment',
        'amount': amount,
        'description': notes ?? 'customer_payment_desc'.tr,
        'payment_method': paymentMethod,
        'reference_id': selectedCustomerId, // Linked to customer
        'date': DateTime.now().toIso8601String(),
      });

      // 2. Update Customer Balance (Reduce Debt) using professional RPC
      final orderController = Get.isRegistered<CompanyOrderController>() ? Get.find<CompanyOrderController>() : Get.put(CompanyOrderController());

      debugPrint('[PAYMENT_FLOW] [START] Initiating balance update for customer $selectedCustomerId');
      // In payment, saleAmount is 0 (no new sale), and paidAmount is the payment amount.
      await orderController.updateCustomerStats(selectedCustomerId!, 0.0, amount);
      debugPrint('[PAYMENT_FLOW] [SUCCESS] Payment recorded and balance updated for customer $selectedCustomerId');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('payment_recorded_success'.tr), backgroundColor: Colors.green));
        Navigator.of(context).pop(true); // Return true using Navigator
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('failed_save_payment'.trParams({'error': e.toString()})), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('receive_payment'.tr, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'customer'.tr, border: const OutlineInputBorder()),
                initialValue: selectedCustomerId,
                isExpanded: true,
                items: customers.map((c) {
                  return DropdownMenuItem(
                    value: c['id'] as String,
                    child: Text(
                      "${c['full_name']} (${'balance'.tr}: ${Get.find<CompanyController>().effectiveCurrency.symbol}${c['balance'] ?? 0})",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => selectedCustomerId = val),
                validator: (val) => val == null ? 'required'.tr : null,
              ),
              const SizedBox(height: 16),

              // Amount
              TextFormField(
                initialValue: amount > 0 ? amount.toStringAsFixed(2) : null,
                decoration: InputDecoration(
                  labelText: 'amount'.tr,
                  prefixText: Get.find<CompanyController>().effectiveCurrency.symbol,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'required'.tr;
                  if (double.tryParse(val) == null) return 'invalid_number'.tr;
                  return null;
                },
                onSaved: (val) => amount = double.parse(val!),
              ),
              const SizedBox(height: 16),

              // Method
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'payment_method_label'.tr, border: const OutlineInputBorder()),
                initialValue: paymentMethod,
                items: [
                  DropdownMenuItem(value: 'cash', child: Text('cash'.tr)),
                  DropdownMenuItem(value: 'bank_transfer', child: Text('bank_transfer'.tr)),
                  DropdownMenuItem(value: 'check', child: Text('check'.tr)),
                  DropdownMenuItem(value: 'pos', child: Text('pos_card'.tr)),
                ],
                onChanged: (val) => setState(() => paymentMethod = val!),
              ),
              const SizedBox(height: 16),

              // Notes
              TextFormField(
                decoration: InputDecoration(labelText: 'notes_optional'.tr, border: const OutlineInputBorder()),
                onSaved: (val) => notes = val,
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: isLoading ? const CircularProgressIndicator(color: Colors.white) : Text('save_payment'.tr),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
