import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_hub/features/admin/controllers/admin_orders_controller.dart';
import 'package:solar_hub/utils/app_theme.dart';
import 'package:icons_plus/icons_plus.dart';

class AdminOrdersPage extends StatelessWidget {
  const AdminOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminOrdersController());

    return Scaffold(
      appBar: AppBar(
        title: Text("orders".tr),
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).textTheme.bodyLarge?.color),
        titleTextStyle: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.orders.isEmpty) {
          return Center(child: Text("no_orders_found".tr));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.orders.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final order = controller.orders[index];
            final status = order['status'] ?? 'pending';
            final total = order['total_amount'] ?? 0;
            final createdAt = DateTime.tryParse(order['created_at'] ?? '');

            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: Icon(Iconsax.box_bold, color: AppTheme.primaryColor),
                ),
                title: Text(
                  "${'order_label'.tr} #${order['order_number'] ?? order['id'].toString().substring(0, 8).toUpperCase()}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(createdAt != null ? "${createdAt.toLocal()}".split('.')[0] : "N/A", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    const SizedBox(height: 4),
                    _buildStatusBadge(status),
                  ],
                ),
                trailing: Text("$total SAR", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'completed':
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(
        status.tr.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
