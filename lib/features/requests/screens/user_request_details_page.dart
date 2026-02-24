import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:solar_hub/controllers/offer_requests_controller.dart';
import 'package:solar_hub/layouts/shared/chat/chat_page.dart';
import 'package:solar_hub/layouts/shared/widgets/offer_details_view.dart';
import 'package:solar_hub/layouts/shared/widgets/system_details_view.dart';
import 'package:solar_hub/models/system_model.dart';
import 'package:solar_hub/utils/app_theme.dart';

class UserRequestDetailsPage extends StatefulWidget {
  final Map<String, dynamic> request;

  const UserRequestDetailsPage({super.key, required this.request});

  @override
  State<UserRequestDetailsPage> createState() => _UserRequestDetailsPageState();
}

class _UserRequestDetailsPageState extends State<UserRequestDetailsPage> {
  late OfferRequestsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(OfferRequestsController());
    controller.fetchOffersForRequest(widget.request['id']);
  }

  @override
  Widget build(BuildContext context) {
    SystemModel? system;
    if (widget.request['requirements'] != null) {
      try {
        system = SystemModel.fromJson(Map<String, dynamic>.from(widget.request['requirements']));
      } catch (e) {
        // print(e);
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Request Details")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.request['title'] ?? 'Request', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(widget.request['description'] ?? '', style: TextStyle(color: Colors.grey[800])),
            const SizedBox(height: 20),

            // Offers Section
            Obx(() {
              if (controller.isRequestOffersLoading.value) return const Center(child: CircularProgressIndicator());

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.local_offer, color: AppTheme.primaryColor),
                      const SizedBox(width: 8),
                      Text("Received Offers (${controller.requestOffers.length})", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 10),

                  if (controller.requestOffers.isEmpty)
                    const Text(
                      "No offers received yet.",
                      style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.requestOffers.length,
                      itemBuilder: (context, index) {
                        final offer = controller.requestOffers[index];
                        final company = offer['companies'] ?? {};
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: company['logo_url'] != null ? CachedNetworkImageProvider(company['logo_url']) : null,
                                      child: company['logo_url'] == null ? const Icon(Icons.business) : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(company['name'] ?? 'Unknown Company', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    ),
                                    Text(
                                      "${company['currencies'] != null ? company['currencies']['symbol'] : '\$'}${offer['price']}",
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green),
                                    ),
                                  ],
                                ),
                                const Divider(height: 24),
                                if (offer['notes'] != null) ...[
                                  Text("offer_notes".tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                  Text(offer['notes'], style: TextStyle(color: Colors.grey[800])),
                                  const SizedBox(height: 12),
                                ],
                                OfferDetailsView(offer: offer),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () => _openChat(context, offer['id'], company['name'] ?? 'Chat'),
                                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white),
                                    icon: const Icon(Icons.chat_bubble_outline, size: 18),
                                    label: Text("chat_with_company".tr),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (offer['status'] == 'accepted')
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                                    child: Center(
                                      child: Text(
                                        "Offer Accepted",
                                        style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  )
                                else if (offer['status'] == 'pending')
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text("Accept Offer"),
                                            content: const Text("Are you sure you want to accept this offer?"),
                                            actions: [
                                              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Cancel")),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                  controller.acceptOffer(offer['id'], widget.request['id']);
                                                },
                                                child: const Text("Accept"),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.green,
                                        side: const BorderSide(color: Colors.green),
                                      ),
                                      icon: const Icon(Icons.check_circle_outline, size: 18),
                                      label: const Text("Accept Offer"),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              );
            }),

            const SizedBox(height: 30),
            // Reuse System Specs View if system data is present
            if (system != null) ...[
              const Divider(),
              const Text("Your System Specs", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              SystemDetailsView(system: system),
            ],
          ],
        ),
      ),
    );
  }

  void _openChat(BuildContext context, String offerId, String companyName) {
    Get.to(() => ChatPage(entityId: offerId, entityType: 'offer', title: companyName));
  }
}
