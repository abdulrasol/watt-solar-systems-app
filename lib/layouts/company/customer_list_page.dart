import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_hub/controllers/customer_controller.dart';
import 'package:solar_hub/layouts/company/add_edit_customer_dialog.dart';
import 'package:solar_hub/layouts/company/customer_details_page.dart';
import 'package:solar_hub/features/company_dashboard/controllers/main_dashboard_controller.dart';

class CustomerListPage extends StatefulWidget {
  const CustomerListPage({super.key});

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  final controller = Get.put(CustomerController());
  final mainController = Get.find<MainDashboardController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      mainController.actions.assignAll([IconButton(icon: const Icon(Icons.add), onPressed: () => Get.dialog(const AddEditCustomerDialog()))]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.customers.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.people_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('No customers found'),
              ElevatedButton(onPressed: () => Get.dialog(const AddEditCustomerDialog()), child: const Text('Add First Customer')),
            ],
          ),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: controller.customers.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final customer = controller.customers[index];
          return ListTile(
            leading: CircleAvatar(child: Text(customer.fullName[0].toUpperCase())),
            title: Text(customer.fullName),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(customer.phoneNumber ?? customer.email ?? 'No contact info'),
                const SizedBox(height: 4),
                Text(
                  "Sales: ${controller.effectiveCurrency.symbol}${customer.totalSales.toStringAsFixed(2)}  |  Paid: ${controller.effectiveCurrency.symbol}${customer.totalPaid.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text("Credit (Left)", style: TextStyle(fontSize: 10, color: Colors.grey)),
                    Text(
                      "${controller.effectiveCurrency.symbol}${customer.balance.toStringAsFixed(2)}",
                      style: TextStyle(color: customer.balance > 0 ? Colors.red : Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () => Get.dialog(AddEditCustomerDialog(customer: customer)),
                ),
              ],
            ),
            onTap: () {
              Get.to(() => CustomerDetailsPage(customer: customer));
            },
          );
        },
      );
    });
  }
}
