import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:solar_hub/controllers/offer_requests_controller.dart';
import 'package:solar_hub/layouts/shared/widgets/system_details_view.dart';
import 'package:solar_hub/models/system_model.dart';
import 'package:solar_hub/utils/app_theme.dart';
import 'package:solar_hub/layouts/shared/chat/chat_page.dart';
import 'package:solar_hub/layouts/company/requests/widgets/company_offer_details_sheet.dart';
import 'package:solar_hub/layouts/company/requests/widgets/company_offer_form_sheet.dart';

class RequestDetailsPage extends StatelessWidget {
  final Map<String, dynamic> requestData;

  const RequestDetailsPage({super.key, required this.requestData});

  @override
  Widget build(BuildContext context) {
    // Parse the system model from the requirements JSON
    // Parse the system model from usage details or requirements
    // Parse the system model from specs or requirements
    SystemModel? system;
    if (requestData['specs'] != null) {
      try {
        // If specs is the new RequestSpecs structure, we might need to wrap it or parse valid fields
        // Assuming SystemModel can handle the map, or we treat it as the 'specs' property of SystemModel
        // But SystemModel probably expects { 'system_name': ..., 'specs': ... } or just the parsing info.
        // Let's try to create a SystemModel wrapper around the specs if direct parsing fails or if it's just component list.
        final specsMap = Map<String, dynamic>.from(requestData['specs']);

        // If specsMap contains "panels", "battery" etc directly, it matches the new structure.
        // SystemDetailsView expects a SystemModel.
        // Let's check SystemModel definition in next step, but for now allow direct specs usage.

        system = SystemModel(
          id: requestData['id'] ?? 'unknown',
          systemName: requestData['title'] ?? 'System Request',
          specs: specsMap, // Pass the JSONB directly as specs
          totalCapacityKw: ((requestData['pv_total'] as num?)?.toDouble() ?? 0) / 1000,
          createdAt: requestData['created_at'] != null ? DateTime.tryParse(requestData['created_at']) : null,
        );
      } catch (e) {
        // print('Error parsing system from specs: $e');
      }
    } else if (requestData['requirements'] != null) {
      try {
        system = SystemModel.fromJson(Map<String, dynamic>.from(requestData['requirements']));
      } catch (e) {
        // print('Error parsing system from requirements: $e');
      }
    }

    final userProfile = requestData['profiles'];
    final String title = requestData['title'] ?? 'Offer Request';
    final String description = requestData['description'] ?? 'No description provided';
    final DateTime createdAt = DateTime.parse(requestData['created_at']);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Header
            if (userProfile != null) ...[
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: userProfile['avatar_url'] != null ? CachedNetworkImageProvider(userProfile['avatar_url']) : null,
                    child: userProfile['avatar_url'] == null ? const Icon(Icons.person) : null,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(userProfile['full_name'] ?? 'Unknown User', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text("Posted on ${_formatDate(createdAt)}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ],
              ),
              const Divider(height: 32),
            ],

            // Description
            Text("description".tr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(description, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, height: 1.4)),
            const SizedBox(height: 24),

            // System Specs
            if (system != null) ...[
              Text("system_requirements".tr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              SystemDetailsView(system: system),
            ] else
              Text("no_requirements".tr, style: const TextStyle(fontStyle: FontStyle.italic)),

            const SizedBox(height: 80), // Space for FAB
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor, // Dark mode fix
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: GetBuilder<OfferRequestsController>(
          // Use GetBuilder or FutureBuilder, but we need the controller instance
          init: OfferRequestsController(),
          builder: (controller) {
            return FutureBuilder<Map<String, dynamic>?>(
              future: controller.getMyOfferForRequest(requestData['id']),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LinearProgressIndicator();
                }

                final existingOffer = snapshot.data;

                if (existingOffer != null) {
                  return Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Get.bottomSheet(CompanyOfferDetailsSheet(offer: existingOffer), isScrollControlled: true),
                          icon: const Icon(Icons.visibility_outlined),
                          label: Text("view_offer".tr),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Get.to(() => ChatPage(entityId: existingOffer['id'], entityType: 'offer', title: requestData['title'] ?? 'Chat')),
                          icon: const Icon(Icons.chat_bubble_rounded),
                          label: Text("chat".tr),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return ElevatedButton.icon(
                  onPressed: () => _showOfferDialog(context, requestData['id'], requestData['user_id'] ?? ''),
                  icon: const Icon(Iconsax.money_send_bold),
                  label: Text("make_offer".tr),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    return "${d.day}/${d.month}/${d.year}";
  }

  void _showOfferDialog(BuildContext context, String requestId, String requestUserId) {
    // Try to extract system specs if available, otherwise just basic params
    final specs = requestData['specs'] ?? requestData['requirements'];
    Get.bottomSheet(
      CompanyOfferFormSheet(requestId: requestId, requestUserId: requestUserId, requestSpecs: specs is Map<String, dynamic> ? specs : null),
      isScrollControlled: true,
    );
  }
}

// Extension to help with SystemModel compatibility if needed,
// though we handle lists manually above.
extension SystemModelHelpers on SystemModel {
  List<Map<String, dynamic>> get noteBoards {
    // Just a placeholder if properties exist on SystemModel not in JSON
    return [];
  }
}
