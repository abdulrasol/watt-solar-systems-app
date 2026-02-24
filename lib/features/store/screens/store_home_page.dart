import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_hub/features/store/controllers/cart_controller.dart';
import 'package:solar_hub/features/store/controllers/store_controller.dart';
import 'package:solar_hub/features/store/screens/product_details_page.dart';
import 'package:solar_hub/features/store/screens/company_store_page.dart';
import 'package:solar_hub/features/store/widgets/store_image.dart';

class Store extends StatelessWidget {
  const Store({super.key});

  @override
  Widget build(BuildContext context) {
    final StoreController controller = Get.put(StoreController());
    final CartController cartController = Get.put(CartController());

    // final List<String> sliderImages = [
    //   'assets/slider1.png',
    //   // 'assets/slider2.png', // Add more real assets or fetch from DB
    // ];

    return RefreshIndicator(
      onRefresh: () async {
        await controller.refreshData();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 80), // Space for Nav Bar
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search & Sort
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: controller.search,
                      decoration: InputDecoration(
                        hintText: 'Search panels, batteries...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12)),
                    child: IconButton(icon: const Icon(Icons.sort), onPressed: () => _showSortOptions(context, controller)),
                  ),
                ],
              ),
            ),

            // Categories
            SizedBox(
              height: 50,
              child: Obx(
                () => ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.categories.length,
                  itemBuilder: (context, index) {
                    final cat = controller.categories[index];
                    return Obx(() {
                      final isSelected = controller.selectedCategory.value == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (_) => controller.filterByCategory(cat),
                          backgroundColor: Theme.of(context).cardColor,
                          selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                          labelStyle: TextStyle(
                            color: isSelected ? Theme.of(context).primaryColor : null,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      );
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Shops / Companies Horizontal List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Top Shops', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  // TextButton(onPressed: (){}, child: Text('See All'))
                ],
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 100,
              child: Obx(() {
                if (controller.companies.isEmpty) return const SizedBox.shrink();
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.companies.length,
                  itemBuilder: (context, index) {
                    final company = controller.companies[index];
                    return GestureDetector(
                      onTap: () => Get.to(() => ShopPage(company: company)),
                      child: Container(
                        width: 80,
                        margin: const EdgeInsets.only(right: 12),
                        child: Column(
                          children: [
                            StoreImage(url: company.logoUrl, isCircle: true, width: 60, height: 60, backgroundColor: Theme.of(context).cardColor),
                            const SizedBox(height: 4),
                            Text(company.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12), textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),

            const SizedBox(height: 20),

            // Slider (Optional promo)
            // if (sliderImages.isNotEmpty) ...[
            //    CarouselSlider(items: ..., options: ...),
            //    SizedBox(height: 20),
            // ]

            // Products Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Just For You', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),
            Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()),
                );
              }
              if (controller.products.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Text('No products found', style: TextStyle(color: Colors.grey)),
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: controller.products.length,
                itemBuilder: (context, index) {
                  final product = controller.products[index];
                  return GestureDetector(
                    onTap: () => Get.to(() => ProductPage(product: product)),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image
                          Expanded(
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                  child: StoreImage(url: product.imageUrl, width: double.infinity, height: double.infinity, fit: BoxFit.cover),
                                ),
                                if (product.stockQuantity == 0)
                                  Positioned(
                                    top: 8,
                                    left: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      color: Colors.black54,
                                      child: const Text('Out of Stock', style: TextStyle(color: Colors.white, fontSize: 10)),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          // Info
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${product.currency?.symbol ?? '\$'}${product.retailPrice.toStringAsFixed(0)}',
                                  style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  height: 32,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                      foregroundColor: Theme.of(context).primaryColor,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    onPressed: product.stockQuantity > 0 ? () => cartController.addToCart(product) : null,
                                    child: const Text('Add'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showSortOptions(BuildContext context, StoreController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Wrap(
          children: [
            ListTile(title: Text('Sort By', style: Theme.of(context).textTheme.titleLarge), enabled: false),
            Obx(
              () => ListTile(
                leading: const Icon(Icons.new_releases),
                title: const Text('Newest'),
                trailing: controller.sortOption.value == 'newest' ? Icon(Icons.check, color: Theme.of(context).primaryColor) : null,
                onTap: () {
                  controller.sortOption.value = 'newest';
                  controller.fetchProducts();
                  Navigator.of(context).pop();
                },
              ),
            ),
            Obx(
              () => ListTile(
                leading: const Icon(Icons.arrow_upward),
                title: const Text('Price: Low to High'),
                trailing: controller.sortOption.value == 'price_asc' ? Icon(Icons.check, color: Theme.of(context).primaryColor) : null,
                onTap: () {
                  controller.sortOption.value = 'price_asc';
                  controller.fetchProducts();
                  Navigator.of(context).pop();
                },
              ),
            ),
            Obx(
              () => ListTile(
                leading: const Icon(Icons.arrow_downward),
                title: const Text('Price: High to Low'),
                trailing: controller.sortOption.value == 'price_desc' ? Icon(Icons.check, color: Theme.of(context).primaryColor) : null,
                onTap: () {
                  controller.sortOption.value = 'price_desc';
                  controller.fetchProducts();
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
