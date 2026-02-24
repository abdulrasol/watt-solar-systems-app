import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/features/orders/controllers/company_order_controller.dart';
import 'package:solar_hub/features/orders/screens/order_details_user.dart';
import 'package:intl/intl.dart';
import 'package:solar_hub/utils/app_theme.dart';
import 'package:solar_hub/utils/price_format_utils.dart';

class UserOrderListPage extends StatefulWidget {
  const UserOrderListPage({super.key});

  @override
  State<UserOrderListPage> createState() => _UserOrderListPageState();
}

class _UserOrderListPageState extends State<UserOrderListPage> {
  late CompanyOrderController controller;

  @override
  void initState() {
    super.initState();
    // Safely register or find the controller
    if (!Get.isRegistered<CompanyOrderController>()) {
      controller = Get.put(CompanyOrderController());
    } else {
      controller = Get.find<CompanyOrderController>();
    }
    // Fetch data safely
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchUserOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    // No need to check registration here as it's handled in initState

    return Scaffold(
      appBar: AppBar(title: Text('my_orders'.tr)),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.userOrders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(FontAwesome.receipt_solid, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text('no_orders_yet'.tr, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchUserOrders,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.userOrders.length,
            separatorBuilder: (c, i) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final order = controller.userOrders[index];
              return Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                    child: const Icon(Icons.solar_power, color: AppTheme.primaryColor),
                  ),
                  title: Text(order.orderNumber != null ? "${'order_label'.tr} #${order.orderNumber}" : "${'order_label'.tr} #${order.id.substring(0, 8)}"),
                  subtitle: Text(DateFormat('yyyy-MM-dd').format(order.createdAt ?? DateTime.now())),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(order.totalAmount.toPriceWithCurrency(order.currencySymbol), style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(order.status.name.tr, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                  onTap: () => Get.to(() => UserOrderDetailsPage(order: order)),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
