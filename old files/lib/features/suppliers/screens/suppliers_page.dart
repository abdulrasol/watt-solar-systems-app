import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/features/suppliers/controllers/suppliers_controller.dart';
import 'package:solar_hub/models/company_model.dart';
import 'package:solar_hub/features/suppliers/screens/supplier_shop_page.dart';

class SuppliersPage extends StatelessWidget {
  const SuppliersPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is initialized
    final SuppliersController controller = Get.put(SuppliersController());

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.wholesalers.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Iconsax.shop_bold, size: 64, color: Theme.of(context).disabledColor),
              const SizedBox(height: 16),
              Text('no_wholesalers_found'.tr, style: TextStyle(fontSize: 18, color: Theme.of(context).disabledColor)),
            ],
          ),
        );
      }

      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 300,
          childAspectRatio: 0.75, // Changed from 1.1 to fit content
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: controller.wholesalers.length,
        itemBuilder: (context, index) {
          final company = controller.wholesalers[index];
          return _buildWholesalerCard(context, company);
        },
      );
    });
  }

  Widget _buildWholesalerCard(BuildContext context, CompanyModel company) {
    return Card(
      elevation: 2,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => Get.to(() => SupplierShopPage(wholesaler: company)),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12), // Reduced padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 26, // Reduced from 30
                backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                backgroundImage: (company.logoUrl != null && company.logoUrl!.startsWith('http')) ? CachedNetworkImageProvider(company.logoUrl!) : null,
                child: company.logoUrl == null
                    ? Text(
                        company.name[0].toUpperCase(),
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                      )
                    : null,
              ),
              const SizedBox(height: 10), // Reduced from 16
              Text(
                company.name,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4), // Reduced from 8
              if (company.address != null)
                Text(
                  company.address!,
                  style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 36, // Fixed smaller height
                child: OutlinedButton(
                  onPressed: () => Get.to(() => SupplierShopPage(wholesaler: company)),
                  style: OutlinedButton.styleFrom(padding: EdgeInsets.zero),
                  child: Text('view_catalog'.tr, style: const TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
