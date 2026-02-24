import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_hub/features/orders/controllers/company_order_controller.dart';
import 'package:solar_hub/features/orders/models/order_model.dart';
import 'package:solar_hub/models/enums.dart';
import 'package:intl/intl.dart';
import 'package:solar_hub/services/pdf_service.dart';
import 'package:solar_hub/controllers/company_controller.dart';
import 'package:solar_hub/services/supabase_service.dart';
import 'package:solar_hub/features/systems/models/system_model.dart';
import 'package:solar_hub/features/systems/screens/system_form_page.dart';
import 'package:solar_hub/models/offer_model.dart';
import 'package:solar_hub/features/systems/screens/system_details_page.dart';
import 'package:solar_hub/utils/app_theme.dart';
import 'package:solar_hub/utils/price_format_utils.dart';

class CompanyOrderDetailsPage extends StatefulWidget {
  final OrderModel order;
  const CompanyOrderDetailsPage({super.key, required this.order});

  @override
  State<CompanyOrderDetailsPage> createState() => _CompanyOrderDetailsPageState();
}

class _CompanyOrderDetailsPageState extends State<CompanyOrderDetailsPage> {
  late OrderModel order;
  final controller = Get.find<CompanyOrderController>();
  final reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    order = widget.order;
  }

  void _showCancelDialog() {
    reasonController.clear();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text("cancel_order".tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("cancel_order_confirm".tr),
            const SizedBox(height: 10),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(labelText: "cancellation_reason".tr, border: const OutlineInputBorder()),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: Text("back".tr)),
          ElevatedButton(
            onPressed: () async {
              if (reasonController.text.isEmpty) {
                // effective context for ScaffoldMessenger can be page context
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("please_enter_reason".tr)));
                return;
              }
              Navigator.of(dialogContext).pop(); // close dialog

              try {
                await controller.updateOrderStatus(order.id, OrderStatus.cancelled, cancellationReason: reasonController.text);
                if (mounted) {
                  Navigator.of(context).pop(true); // close page with success (using Page context)
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to cancel order: $e')));
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: Text("confirm_cancel".tr),
          ),
        ],
      ),
    );
  }

  void _updateStatus(OrderStatus newStatus) async {
    try {
      await controller.updateOrderStatus(order.id, newStatus);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update status: $e')));
      }
    }
  }

  Future<void> _printInvoice() async {
    try {
      // 1. Buyer Info
      Map<String, dynamic> buyerInfo = {'name': order.effectiveCustomerName};
      if (order.customer != null) {
        buyerInfo['phone'] = order.customer!['phone_number'];
        buyerInfo['address'] = order.customer!['address'];
      } else if (order.buyerProfile != null) {
        buyerInfo['phone'] = order.buyerProfile!['phone_number'];
      }

      // 2. Seller Info
      Map<String, dynamic> sellerInfo = {};

      // Check if we are the seller (Company Mode)
      if (Get.isRegistered<CompanyController>() && Get.find<CompanyController>().company.value?.id == order.sellerCompanyId) {
        final comp = Get.find<CompanyController>().company.value!;
        sellerInfo = {'name': comp.name, 'address': comp.address, 'contact_phone': comp.contactPhone};
      } else if (order.sellerCompanyId != null) {
        // We are User or viewing external order, fetch seller details
        try {
          final resp = await SupabaseService().client.from('companies').select().eq('id', order.sellerCompanyId!).single();
          sellerInfo = {'name': resp['name'], 'address': resp['address'], 'contact_phone': resp['contact_phone']};
        } catch (_) {}
      }

      final items = order.items.map((e) => e.toJson()).toList();

      final pdfData = await PdfService().generateInvoice(
        orderId: order.id,
        orderNumber: order.orderNumber,
        sellerInfo: sellerInfo,
        buyerInfo: buyerInfo,
        items: items,
        total: order.totalAmount,
        date: order.createdAt ?? DateTime.now(),
        paidAmount: order.paidAmount,
        paymentMethod: order.paymentMethod,
        currencySymbol: order.currencySymbol,
      );

      await PdfService().printInvoice(pdfData);
    } catch (e) {
      debugPrint("Print Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("failed_load_requests".tr)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('order_details_title'.tr),
        actions: [IconButton(icon: const Icon(Icons.print), onPressed: _printInvoice, tooltip: 'print_invoice'.tr)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Status Card
            Card(
              child: ListTile(
                title: Text(
                  order.orderNumber != null ? "${'order_label'.tr} #${order.orderNumber}" : "${'order_label'.tr} #${order.id.substring(0, 8)}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("${'placed_on'.tr} ${DateFormat('yyyy-MM-dd HH:mm').format(order.createdAt ?? DateTime.now())}"),
                trailing: Chip(
                  label: Text(order.status.name.tr),
                  backgroundColor: _getStatusColor(order.status),
                  labelStyle: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Customer Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("customer_details".tr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Divider(),
                    Text("${'full_name'.tr}: ${order.effectiveCustomerName}"),
                    // We could fetch customer details if we have ID, but storing name on order is common.
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Items
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("items".tr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Divider(),
                    ...order.items.map(
                      (item) => ListTile(
                        title: Text(item.productNameSnapshot ?? "system_package".tr),
                        subtitle: Text("${item.quantity} x ${item.unitPrice.toPriceWithCurrency(order.currencySymbol)}"),
                        trailing: Text(item.totalLinePrice.toPriceWithCurrency(order.currencySymbol), style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Financials
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("payment_details".tr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Divider(),
                    _buildRow("total_amount".tr, order.totalAmount.toPriceWithCurrency(order.currencySymbol), isBold: true),
                    _buildRow("paid_amount".tr, order.paidAmount.toPriceWithCurrency(order.currencySymbol), color: Colors.green),
                    _buildRow("balance_due".tr, (order.totalAmount - order.paidAmount).toPriceWithCurrency(order.currencySymbol), color: Colors.red),
                    _buildRow("payment_method".tr, order.paymentMethod?.tr ?? 'unknown'.tr),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Actions
            if (order.status != OrderStatus.cancelled && order.status != OrderStatus.done) ...[
              Text("update_status".tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                children: [
                  if (order.status == OrderStatus.waiting || order.status == OrderStatus.pending)
                    ElevatedButton(onPressed: () => _updateStatus(OrderStatus.in_progress), child: Text("mark_in_progress".tr)),
                  if (order.status == OrderStatus.in_progress || order.status == OrderStatus.processing)
                    ElevatedButton(onPressed: () => _updateStatus(OrderStatus.completed), child: Text("mark_completed".tr)),
                ],
              ),
              const SizedBox(height: 20),
            ],

            if (order.status != OrderStatus.cancelled)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _showCancelDialog,
                  icon: const Icon(Icons.cancel, color: Colors.red),
                  label: Text("cancel_order".tr, style: const TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                ),
              ),

            if (order.status == OrderStatus.cancelled && order.cancellationReason != null)
              Container(
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.all(10),
                color: Colors.red.shade50,
                child: Text("${'cancelled'.tr}: ${order.cancellationReason}", style: const TextStyle(color: Colors.red)),
              ),
            // System Actions
            if (order.offerId != null && (order.status == OrderStatus.completed || order.status == OrderStatus.done))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _handleSystemAction(),
                    icon: const Icon(Icons.settings_system_daydream),
                    label: Text("create_view_system".tr),
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

  void _handleSystemAction() async {
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
          userPhone: order.buyerProfile?['phone_number'] ?? order.customer?['phone_number'], // Pass phone number
          userStatus: order.buyerUserId != null ? 'accepted' : 'pending',
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
          companyStatus: 'accepted',
        );

        // Go to Form (Company View: isUserView = false)
        Get.to(() => SystemFormPage(system: newSystem, isUserView: false, companyId: order.sellerCompanyId));
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load system info: $e");
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.completed:
      case OrderStatus.done:
        return Colors.green;
      case OrderStatus.pending:
      case OrderStatus.waiting:
        return Colors.orange;
      case OrderStatus.in_progress:
        return Colors.blue;
      case OrderStatus.cancelled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(label, style: TextStyle(color: Colors.grey[600])),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: color),
            ),
          ),
        ],
      ),
    );
  }
}
