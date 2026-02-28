import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_hub/features/admin/controllers/admin_systems_controller.dart';
import 'package:solar_hub/utils/app_theme.dart';
import 'package:solar_hub/features/store/widgets/store_image.dart';
import 'package:icons_plus/icons_plus.dart';

class AdminSystemsPage extends StatelessWidget {
  const AdminSystemsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminSystemsController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("All Systems"),
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).textTheme.bodyLarge?.color),
        titleTextStyle: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.systems.isEmpty) {
          return const Center(child: Text("No systems found"));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.systems.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final system = controller.systems[index];
            final company = system['companies'] as Map?;
            final companyName = company != null ? company['name'] : 'Unknown Company';

            // Handle image depending on how it's stored.
            // Often system might have an image_url or images array.
            // Assuming image_url for now or images[0] if exists.
            String? imageUrl;
            if (system['images'] != null && (system['images'] as List).isNotEmpty) {
              imageUrl = system['images'][0];
            } else if (system['image_url'] != null) {
              imageUrl = system['image_url'];
            }

            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: StoreImage(
                  url: imageUrl,
                  width: 60,
                  height: 60,
                  borderRadius: 8,
                  // Fallback icon if no image
                  fallback: imageUrl == null ? Icon(Iconsax.sun_1_bold, color: Colors.yellow[700]) : null,
                ),
                title: Text(system['name'] ?? 'System', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(companyName, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    if (system['capacity_kw'] != null)
                      Text(
                        "${system['capacity_kw']} kW",
                        style: TextStyle(color: AppTheme.primaryColor, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                onTap: () {
                  // Potential detail view later
                },
              ),
            );
          },
        );
      }),
    );
  }
}
