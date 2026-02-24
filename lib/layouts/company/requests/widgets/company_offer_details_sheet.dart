import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_hub/controllers/offer_requests_controller.dart';
import 'package:solar_hub/features/orders/controllers/company_order_controller.dart';
import 'package:solar_hub/features/orders/screens/create_order_company.dart';
import 'package:solar_hub/features/orders/screens/order_details_company.dart';
import 'package:solar_hub/layouts/shared/chat/chat_page.dart';
import 'package:solar_hub/layouts/shared/widgets/offer_details_view.dart';
import 'package:solar_hub/utils/app_theme.dart';

class CompanyOfferDetailsSheet extends StatelessWidget {
  final Map<String, dynamic> offer;

  const CompanyOfferDetailsSheet({super.key, required this.offer});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OfferRequestsController>();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
      child: Column(
        children: [
          // Header
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              margin: const EdgeInsets.only(bottom: 24),
            ),
          ),

          Text('my_offer_details'.tr, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Details Card
                  OfferDetailsView(offer: offer),
                  const SizedBox(height: 24),
                  const SizedBox(height: 32),

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              Get.to(() => ChatPage(entityId: offer['id'], entityType: 'offer', title: offer['offer_requests']?['title'] ?? 'Chat')),
                          icon: const Icon(Icons.chat_bubble_rounded),
                          label: Text('chat_customer'.tr), // Shortened label
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (offer['status'] == 'pending') ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.redAccent),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.delete_outline),
                        label: Text('delete_offer'.tr),
                        onPressed: () {
                          // Using standard dialog to avoid GetX nesting issues
                          showDialog(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              title: Text('delete_offer'.tr),
                              content: Text('confirm_delete_offer'.tr),
                              actions: [
                                TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: Text('cancel'.tr)),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                                  onPressed: () {
                                    Navigator.of(dialogContext).pop(); // Close dialog
                                    Navigator.of(context).pop(); // Close sheet
                                    controller.deleteOffer(offer['id']);
                                  },
                                  child: Text('delete'.tr),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  if (offer['status'] == 'accepted') ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'offer_accepted_msg'.tr,
                              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Check for existing order
                    // Check for existing order
                    Builder(
                      builder: (context) {
                        final orderCtrl = Get.put(CompanyOrderController());
                        orderCtrl.fetchCompanyOrders();

                        return Obx(() {
                          // Find order related to this offer
                          final existingOrder = orderCtrl.companyOrders.firstWhereOrNull((o) => o.offerId == offer['id']);

                          if (existingOrder != null) {
                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Get.to(() => CompanyOrderDetailsPage(order: existingOrder));
                                },
                                icon: const Icon(Icons.receipt_long),
                                label: const Text("View Order"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueGrey,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            );
                          }

                          return SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Get.to(() => CompanyCreateOrderPage(offer: offer, request: offer['offer_requests'] ?? {}));
                              },
                              icon: const Icon(Icons.add_shopping_cart),
                              label: const Text("Create Order"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          );
                        });
                      },
                    ),
                  ],

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
