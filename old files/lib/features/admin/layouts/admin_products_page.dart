import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_hub/features/admin/controllers/admin_products_controller.dart';
import 'package:solar_hub/utils/app_theme.dart';
import 'package:solar_hub/features/store/widgets/store_image.dart';

class AdminProductsPage extends StatelessWidget {
  const AdminProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminProductsController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("All Products"),
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).textTheme.bodyLarge?.color),
        titleTextStyle: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.products.isEmpty) {
          return const Center(child: Text("No products found"));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.products.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final product = controller.products[index];
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: StoreImage(url: product.imageUrl, width: 60, height: 60, borderRadius: 8),
                title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text("Stock: ${product.stockQuantity}", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    // If we had company name fetched in a way we could display it, we would here.
                    // For now, let's just show price.
                  ],
                ),
                trailing: Text(
                  "${product.retailPrice} SAR",
                  style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
