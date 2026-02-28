import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_hub/features/orders/controllers/company_order_controller.dart';
import 'package:solar_hub/features/orders/models/order_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:solar_hub/models/enums.dart';
import 'package:solar_hub/utils/price_format_utils.dart';
import 'package:solar_hub/features/orders/screens/order_details_user.dart';

class CompanyPurchasesPage extends StatefulWidget {
  const CompanyPurchasesPage({super.key});

  @override
  State<CompanyPurchasesPage> createState() => _CompanyPurchasesPageState();
}

class _CompanyPurchasesPageState extends State<CompanyPurchasesPage> {
  final CompanyOrderController controller = Get.put(CompanyOrderController());

  @override
  void initState() {
    super.initState();
    controller.fetchCompanyPurchases();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('my_purchases_b2b'.tr)),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.companyPurchases.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(FontAwesomeIcons.bagShopping, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text('no_purchases_yet'.tr, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.companyPurchases.length,
          itemBuilder: (context, index) {
            final order = controller.companyPurchases[index];
            return _buildPurchaseCard(context, order);
          },
        );
      }),
    );
  }

  Widget _buildPurchaseCard(BuildContext context, OrderModel order) {
    // Seller Name might be in 'seller_company' map if we joined it
    // Or we need to rely on 'sellerCompanyId'
    // OrderModel needs adjustment to read joined company name, or we assume it's there.
    // Let's assume the controller passed "seller_company" and we can extract name safely.
    // But OrderModel isn't dynamic map. It's a class.
    // We should probably rely on a simpler approach or view mapping if model doesn't have it.
    // For now, let's just show ID or "Supplier" if map isn't available, but try to parse if we updated model.
    // Actually, in fetchCompanyPurchases we did: select('*, ... seller_company:companies(...)').
    // So 'seller_company' is in the JSON. If OrderModel doesn't have a field for it, it's lost.
    // To fix this without touching Model (risky), we can access the Raw JSON if we kept it?
    // No, we mapped to OrderModel.
    // Let's check OrderModel or just use "Order #ID" for now.

    // Better: let's do a quick hack -> we know we populated `companyPurchases`.
    // Wait, OrderModel probably doesn't have `sellerCompanyName`.
    // I'll assume we can view details which loads full info, or just show Order ID + Date + Total.

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1), child: const Icon(FontAwesomeIcons.store, size: 18)),
        title: Text('${'order_label'.tr} #${order.id.substring(0, 8)}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${'date_label'.tr}: ${order.createdAt != null ? DateFormat('yyyy-MM-dd HH:mm').format(order.createdAt!) : 'N/A'}'),
            const SizedBox(height: 2),
            Text('${'items'.tr}: ${order.items.length}'),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: _getStatusColor(order.status).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                  child: Text(
                    order.status.name.tr,
                    style: TextStyle(fontSize: 10, color: _getStatusColor(order.status), fontWeight: FontWeight.bold),
                  ),
                ),
                const Spacer(),
                Text(order.totalAmount.toPriceWithCurrency(order.currencySymbol), style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        onTap: () {
          // Navigate to details (reusing UserOrderDetailsPage or specialized one)
          Get.to(() => UserOrderDetailsPage(order: order));
        },
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.processing:
        return Colors.purple;
      case OrderStatus.completed:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
      case OrderStatus.returned:
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }
}
