import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_hub/controllers/company_controller.dart';
import 'package:solar_hub/controllers/customer_controller.dart';
import 'package:solar_hub/models/customer_model.dart';
import 'package:solar_hub/layouts/shared/widgets/custom_text_field.dart';

class AddEditCustomerDialog extends StatefulWidget {
  final CustomerModel? customer;

  const AddEditCustomerDialog({super.key, this.customer});

  @override
  State<AddEditCustomerDialog> createState() => _AddEditCustomerDialogState();
}

class _AddEditCustomerDialogState extends State<AddEditCustomerDialog> {
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final addressCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.customer != null) {
      nameCtrl.text = widget.customer!.fullName;
      phoneCtrl.text = widget.customer!.phoneNumber ?? '';
      emailCtrl.text = widget.customer!.email ?? '';
      addressCtrl.text = widget.customer!.address ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.customer == null ? 'Add Customer' : 'Edit Customer'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(controller: nameCtrl, hintText: 'Full Name *'),
            const SizedBox(height: 12),
            CustomTextField(controller: phoneCtrl, hintText: 'Phone Number', keyboardType: TextInputType.phone),
            const SizedBox(height: 12),
            CustomTextField(controller: emailCtrl, hintText: 'Email Address', keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 12),
            CustomTextField(controller: addressCtrl, hintText: 'Address'),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(onPressed: _submit, child: Text(widget.customer == null ? 'Add' : 'Save')),
      ],
    );
  }

  void _submit() async {
    if (nameCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name is required')));
      return;
    }

    final controller = Get.find<CustomerController>();
    final companyId = Get.find<CompanyController>().company.value?.id;

    if (companyId == null) return;

    bool success = false;
    if (widget.customer == null) {
      final newCustomer = CustomerModel(
        companyId: companyId,
        fullName: nameCtrl.text,
        phoneNumber: phoneCtrl.text.isNotEmpty ? phoneCtrl.text : null,
        email: emailCtrl.text.isNotEmpty ? emailCtrl.text : null,
        address: addressCtrl.text.isNotEmpty ? addressCtrl.text : null,
      );
      success = await controller.addCustomer(newCustomer);
    } else {
      final updates = {
        'full_name': nameCtrl.text,
        'phone_number': phoneCtrl.text.isNotEmpty ? phoneCtrl.text : null,
        'email': emailCtrl.text.isNotEmpty ? emailCtrl.text : null,
        'address': addressCtrl.text.isNotEmpty ? addressCtrl.text : null,
      };
      success = await controller.updateCustomer(widget.customer!.id!, updates);
    }

    if (mounted) {
      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(widget.customer == null ? 'Customer added' : 'Customer updated'), backgroundColor: Colors.green));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Operation failed'), backgroundColor: Colors.red));
      }
    }
  }
}
