import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_hub/controllers/data_controller.dart';
import 'package:solar_hub/features/requests/screens/user_request_details_page.dart';
import 'package:solar_hub/utils/app_theme.dart';

class UserRequestsPage extends StatefulWidget {
  const UserRequestsPage({super.key});

  @override
  State<UserRequestsPage> createState() => _UserRequestsPageState();
}

class _UserRequestsPageState extends State<UserRequestsPage> {
  final DataController controller = Get.find();

  @override
  void initState() {
    super.initState();
    controller.fetchMyRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Offer Requests")),
      body: Obx(() {
        if (controller.myRequests.isEmpty) {
          // Check if loading? DataController doesn't expose loading for this specific fetch nicely yet,
          // usually fetch is fast or we can add isLoading state later.
          // For now assume empty means empty or loading initially.
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.description_outlined, size: 60, color: Colors.grey),
                const SizedBox(height: 16),
                const Text("No requests sent yet.", style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Get.back(), // Go back to Hub to create one
                  child: const Text("Create System & Request"),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.myRequests.length,
          itemBuilder: (context, index) {
            final req = controller.myRequests[index];
            final isOpen = req['status'] == 'open';
            final date = DateTime.tryParse(req['created_at']) ?? DateTime.now();

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                onTap: () => Get.to(() => UserRequestDetailsPage(request: req)),
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  backgroundColor: isOpen ? AppTheme.primaryColor.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                  child: Icon(isOpen ? Icons.lock_open : Icons.lock, color: isOpen ? AppTheme.primaryColor : Colors.grey),
                ),
                title: Text(req['title'] ?? 'Untitled Request', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(req['description'] ?? 'No description', maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text("${date.day}/${date.month}/${date.year}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isOpen ? Colors.green.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    (req['status'] as String).toUpperCase(),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isOpen ? Colors.green : Colors.grey),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
