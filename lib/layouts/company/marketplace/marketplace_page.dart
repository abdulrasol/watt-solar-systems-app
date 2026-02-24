import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/layouts/company/marketplace/wholesaler_products_page.dart';
import 'package:solar_hub/models/company_model.dart';
import 'package:solar_hub/services/supabase_service.dart';
import 'package:solar_hub/utils/app_theme.dart';

class MarketplacePage extends StatefulWidget {
  const MarketplacePage({super.key});

  @override
  State<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> {
  final _supabase = SupabaseService().client;
  final isLoading = true.obs;
  final wholesalers = <CompanyModel>[].obs;

  @override
  void initState() {
    super.initState();
    fetchWholesalers();
  }

  Future<void> fetchWholesalers() async {
    try {
      isLoading.value = true;
      // Fetch companies that are flagged as 'wholesaler' or 'distributor'
      // Assuming 'tier' or a role distinguishes them. Reviewing schema:
      // companies table has 'tier'.

      final response = await _supabase
          .from('companies')
          .select()
          .eq('tier', 'wholesaler') // Adjust if tier name handles casing
          .order('name', ascending: true);

      final List<dynamic> data = response;
      wholesalers.assignAll(data.map((json) => CompanyModel.fromJson(json)).toList());
    } catch (e) {
      // print('Error fetching wholesalers: $e');
      Get.snackbar('Error', 'Failed to load suppliers');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('suppliers'.tr)),
      body: Obx(() {
        if (isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (wholesalers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Iconsax.shop_bold, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text('no_wholesalers_found'.tr, style: const TextStyle(fontSize: 18, color: Colors.grey)),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 300,
            childAspectRatio: 1.1,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: wholesalers.length,
          itemBuilder: (context, index) {
            final company = wholesalers[index];
            return _buildWholesalerCard(company);
          },
        );
      }),
    );
  }

  Widget _buildWholesalerCard(CompanyModel company) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => Get.to(() => WholesalerProductsPage(wholesaler: company)),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                backgroundImage: company.logoUrl != null ? CachedNetworkImageProvider(company.logoUrl!) : null,
                child: company.logoUrl == null
                    ? Text(
                        company.name[0].toUpperCase(),
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                      )
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                company.name,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              if (company.address != null)
                Text(
                  company.address!,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Get.to(() => WholesalerProductsPage(wholesaler: company)),
                  child: Text('view_catalog'.tr),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
