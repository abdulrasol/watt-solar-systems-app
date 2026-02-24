import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/models/company_model.dart';
import 'package:solar_hub/services/supabase_service.dart';
import 'package:solar_hub/utils/app_theme.dart';

class WholesalerProductsPage extends StatefulWidget {
  final CompanyModel wholesaler;

  const WholesalerProductsPage({super.key, required this.wholesaler});

  @override
  State<WholesalerProductsPage> createState() => _WholesalerProductsPageState();
}

class _WholesalerProductsPageState extends State<WholesalerProductsPage> {
  final _supabase = SupabaseService().client;
  final isLoading = true.obs;
  final products = <Map<String, dynamic>>[].obs;

  @override
  void initState() {
    super.initState();
    fetchCatalog();
  }

  Future<void> fetchCatalog() async {
    try {
      isLoading.value = true;
      // Fetch products from this company where wholesale_price > 0 and status is active
      final response = await _supabase
          .from('products')
          .select('*, currencies(symbol)')
          .eq('company_id', widget.wholesaler.id)
          .eq('status', 'active')
          .gt('wholesale_price', 0)
          .order('name', ascending: true);

      products.assignAll(List<Map<String, dynamic>>.from(response));
    } catch (e) {
      // print('Error fetching catalog: $e');
      Get.snackbar('Error', 'Failed to load catalog');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.wholesaler.name} Catalog'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey.withValues(alpha: 0.2), height: 1.0),
        ),
      ),
      body: Obx(() {
        if (isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Iconsax.box_search_bold, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text('no_wholesale_products'.tr, style: const TextStyle(fontSize: 18, color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: products.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final product = products[index];
            return _buildProductRow(product);
          },
        );
      }),
    );
  }

  Widget _buildProductRow(Map<String, dynamic> product) {
    final wholesalePrice = (product['wholesale_price'] as num?)?.toDouble() ?? 0.0;
    final retailPrice = (product['retail_price'] as num?)?.toDouble() ?? 0.0;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                image: product['image_url'] != null ? DecorationImage(image: CachedNetworkImageProvider(product['image_url']), fit: BoxFit.cover) : null,
              ),
              child: product['image_url'] == null ? const Icon(Iconsax.box_bold, color: Colors.grey) : null,
            ),
            const SizedBox(width: 16),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product['name'] ?? 'Unknown Product', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('SKU: ${product['sku'] ?? '-'}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                        child: Text(
                          'Wholesale: ${product['currencies']?['symbol'] ?? '\$'}${wholesalePrice.toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Retail: ${product['currencies']?['symbol'] ?? '\$'}${retailPrice.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.grey, fontSize: 12, decoration: TextDecoration.lineThrough),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Action
            // Future improvement: Add "Purchase Order" flow here
            IconButton(
              onPressed: () {
                // Determine if we show a "Contact" dialog or "Add to PO"
                // For now, simple contact
                Get.snackbar('Coming Soon', 'Purchase Orders will be available soon.');
              },
              icon: const Icon(Iconsax.add_circle_bold, color: AppTheme.primaryColor),
              tooltip: 'order_stock'.tr,
            ),
          ],
        ),
      ),
    );
  }
}
