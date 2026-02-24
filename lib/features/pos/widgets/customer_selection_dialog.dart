import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_hub/controllers/customer_controller.dart';
import 'package:solar_hub/layouts/company/add_edit_customer_dialog.dart';

class CustomerSelectionDialog extends StatelessWidget {
  const CustomerSelectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CustomerController());

    return AlertDialog(
      title: Text('pos_select_customer'.tr),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'pos_search_customer'.tr, prefixIcon: const Icon(Icons.search), border: const OutlineInputBorder()),
              onChanged: (val) {},
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.customers.isEmpty) {
                  return Center(child: Text("pos_no_customers".tr));
                }

                return ListView.separated(
                  itemCount: controller.customers.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final customer = controller.customers[index];
                    return ListTile(
                      leading: CircleAvatar(child: Text(customer.fullName[0].toUpperCase())),
                      title: Text(customer.fullName),
                      subtitle: Text(customer.phoneNumber ?? ''),
                      onTap: () => Navigator.of(context).pop(customer),
                    );
                  },
                );
              }),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () async {
                await showDialog(context: context, builder: (_) => const AddEditCustomerDialog());
                // Controller auto-refreshes
              },
              icon: const Icon(Icons.add),
              label: Text('pos_new_customer'.tr),
            ),
          ],
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('cancel'.tr))],
    );
  }
}
