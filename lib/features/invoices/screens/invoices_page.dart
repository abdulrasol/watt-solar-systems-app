import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_hub/features/orders/controllers/company_order_controller.dart';

import 'package:solar_hub/features/orders/models/order_model.dart';
import 'package:solar_hub/utils/app_theme.dart';
import 'package:solar_hub/utils/price_format_utils.dart';
import 'package:intl/intl.dart';
import 'package:solar_hub/features/invoices/screens/invoice_details_page.dart';

class InvoicesPage extends StatelessWidget {
  const InvoicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final CompanyOrderController controller = Get.put(CompanyOrderController());

    // Ensure loaded
    Future.delayed(Duration.zero, () => controller.fetchCompanyOrders());

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final orders = controller.companyOrders;

      if (orders.isEmpty) {
        return Center(child: Text("no_open_requests".tr));
      }

      return LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 800) {
            return _buildDesktopTable(context, orders);
          } else {
            return _buildMobileList(context, orders);
          }
        },
      );
    });
  }

  Widget _buildDesktopTable(BuildContext context, List<OrderModel> orders) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
              columns: [
                DataColumn(
                  label: Text("${'invoice'.tr} #", style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                DataColumn(
                  label: Text('invoice_date'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                DataColumn(
                  label: Text('bill_to'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                DataColumn(
                  label: Text('total_amount'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                DataColumn(
                  label: Text('offer_status'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                const DataColumn(label: Text('')),
              ],
              rows: orders.map((order) {
                return DataRow(
                  cells: [
                    DataCell(
                      Text(order.orderNumber?.toString() ?? order.id.substring(0, 8).toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    DataCell(Text(DateFormat('yyyy-MM-dd').format(order.createdAt ?? DateTime.now()))),
                    DataCell(Text(order.effectiveCustomerName)),
                    DataCell(Text(order.totalAmount.toPriceWithCurrency(order.currencySymbol))),
                    DataCell(_buildStatusChip(order.status.name)),
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.remove_red_eye_outlined, color: AppTheme.primaryColor),
                        onPressed: () => Get.to(() => InvoiceDetailsPage(order: order)),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileList(BuildContext context, List<OrderModel> orders) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            onTap: () => Get.to(() => InvoiceDetailsPage(order: order)),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${'invoice'.tr} #${order.orderNumber?.toString() ?? order.id.substring(0, 8).toUpperCase()}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  order.totalAmount.toPriceWithCurrency(order.currencySymbol),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text("${'bill_to'.tr}: ${order.effectiveCustomerName}"),
                const SizedBox(height: 4),
                Text(DateFormat('yyyy-MM-dd').format(order.createdAt ?? DateTime.now()), style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                const SizedBox(height: 8),
                _buildStatusChip(order.status.name),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    Color color = Colors.grey;
    if (['completed', 'paid', 'done'].contains(status)) color = Colors.green;
    if (['pending', 'waiting'].contains(status)) color = Colors.orange;
    if (['cancelled'].contains(status)) color = Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        status.tr.toUpperCase(),
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
