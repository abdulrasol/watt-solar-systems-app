import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_hub/features/orders/models/order_model.dart';
import 'package:solar_hub/models/enums.dart'; // Provide OrderStatus if needed (usually in order_model or enums)
import 'package:intl/intl.dart';
import 'package:solar_hub/utils/app_theme.dart';
import 'package:solar_hub/features/systems/models/system_model.dart';
import 'package:solar_hub/features/systems/screens/system_form_page.dart';
import 'package:solar_hub/services/supabase_service.dart';
import 'package:solar_hub/models/offer_model.dart';
import 'package:solar_hub/features/systems/screens/system_details_page.dart';
import 'package:solar_hub/utils/price_format_utils.dart';

class UserOrderDetailsPage extends StatelessWidget {
  final OrderModel order;

  const UserOrderDetailsPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(order.orderNumber != null ? "${'order_details'.tr} #${order.orderNumber}" : 'order_details'.tr), elevation: 0),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Status Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _getStatusColor(order.status).withValues(alpha: 0.1),
                border: Border(bottom: BorderSide(color: _getStatusColor(order.status).withValues(alpha: 0.2))),
              ),
              child: Column(
                children: [
                  Icon(_getStatusIcon(order.status), size: 48, color: _getStatusColor(order.status)),
                  const SizedBox(height: 16),
                  Text(
                    order.status.name.tr,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _getStatusColor(order.status)),
                  ),
                  const SizedBox(height: 8),
                  Text("${'placed_on'.tr}: ${DateFormat('yyyy-MM-dd').format(order.createdAt ?? DateTime.now())}", style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),

            // Stepper / Timeline (Simplified)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStep(Icons.receipt_long, "pending".tr, order.status == OrderStatus.pending || order.status.index >= OrderStatus.pending.index),
                  _buildLine(order.status.index > OrderStatus.pending.index),
                  _buildStep(
                    Icons.build_circle_outlined,
                    "mark_in_progress".tr,
                    order.status == OrderStatus.processing || order.status == OrderStatus.in_progress || order.status.index >= OrderStatus.processing.index,
                  ),
                  _buildLine(order.status == OrderStatus.completed || order.status == OrderStatus.done),
                  _buildStep(Icons.check_circle, "completed".tr, order.status == OrderStatus.completed || order.status == OrderStatus.done),
                ],
              ),
            ),

            const Divider(height: 1),

            // Financials
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("payment_summary".tr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildDetailRow("total_amount".tr, order.totalAmount.toPriceWithCurrency(order.currencySymbol), isBold: true),
                  _buildDetailRow("status".tr, order.paymentStatus.name.tr),
                  _buildDetailRow("tax".tr, order.taxAmount.toPriceWithCurrency(order.currencySymbol)),
                  _buildDetailRow("discount".tr, "-${order.discountAmount.toPriceWithCurrency(order.currencySymbol)}", color: Colors.green),
                ],
              ),
            ),

            const Divider(height: 1),

            // System / Item Details
            if (order.items.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("items".tr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    ...order.items.map(
                      (item) => Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.solar_power, color: AppTheme.primaryColor),
                          title: Text(item.productNameSnapshot ?? "system_package".tr),
                          subtitle: Text("${'qty'.tr}: ${item.quantity}"),
                          trailing: Text(item.totalLinePrice.toPriceWithCurrency(order.currencySymbol)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // System Actions
            if (order.offerId != null && (order.status == OrderStatus.completed || order.status == OrderStatus.done))
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _handleSystemAction(context),
                    icon: const Icon(Icons.settings_system_daydream),
                    label: Text("manage_system".tr),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(IconData icon, String label, bool isActive) {
    return Column(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: isActive ? AppTheme.primaryColor : Colors.grey[300],
          child: Icon(icon, size: 20, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(fontSize: 12, fontWeight: isActive ? FontWeight.bold : FontWeight.normal, color: isActive ? AppTheme.primaryColor : Colors.grey),
        ),
      ],
    );
  }

  Widget _buildLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        color: isActive ? AppTheme.primaryColor : Colors.grey[300],
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 20), // Align with circle center roughly
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 16, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: Colors.grey[800]),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              style: TextStyle(fontSize: 16, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: color ?? Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.processing:
        return Colors.blue;
      case OrderStatus.completed:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.hourglass_empty;
      case OrderStatus.processing:
        return Icons.settings_suggest;
      case OrderStatus.completed:
        return Icons.check_circle;
      case OrderStatus.cancelled:
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  void _handleSystemAction(BuildContext context) async {
    try {
      // 1. Check if system exists
      final systemRes = await SupabaseService().client.from('systems').select().eq('order_id', order.id).maybeSingle();

      if (systemRes != null) {
        // Go to Details
        final system = SystemModel.fromJson(systemRes);
        Get.to(() => SystemDetailsPage(system: system));
      } else {
        // 2. Fetch Offer to pre-fill
        final offerRes = await SupabaseService().client.from('offers').select().eq('id', order.offerId!).single();
        final offer = OfferModel.fromJson(offerRes);

        // 3. Map to SystemModel
        final newSystem = SystemModel(
          userId: order.buyerUserId,
          installedBy: order.sellerCompanyId,
          orderId: order.id,
          pv: SystemComponent(count: offer.pvSpecs.count, capacity: offer.pvSpecs.capacity.toDouble(), mark: offer.pvSpecs.mark),
          battery: SystemComponent(count: offer.batterySpecs.count, capacity: offer.batterySpecs.capacity, mark: offer.batterySpecs.mark),
          inverter: SystemComponent(
            count: offer.inverterSpecs.count,
            capacity: offer.inverterSpecs.capacity,
            mark: offer.inverterSpecs.mark,
            phase: offer.inverterSpecs.phase,
          ),
          companyStatus: 'accepted', // Since it comes from an accepted offer/order, we can assume some intent
        );

        // Go to Form
        Get.to(() => SystemFormPage(system: newSystem, isUserView: true));
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load system info: $e");
    }
  }
}
