import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:solar_hub/controllers/inventory_controller.dart';
import 'package:solar_hub/features/company_dashboard/controllers/main_dashboard_controller.dart';
import 'package:solar_hub/layouts/company/add_product_page.dart';
import 'package:solar_hub/layouts/company/product_details_page.dart';
import 'package:solar_hub/controllers/company_controller.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:solar_hub/utils/price_format_utils.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final ScrollController _scrollController = ScrollController();
  final InventoryController controller = Get.put(InventoryController());
  final mainController = Get.find<MainDashboardController>();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (['owner', 'manager', 'inventory_manager'].contains(Get.find<CompanyController>().currentRole.value)) {
        mainController.actions.assignAll([IconButton(icon: const Icon(Icons.add), onPressed: _navigateToAddProduct)]);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!controller.isLoading.value && !controller.isMoreLoading.value && controller.hasMore.value) {
        controller.fetchMyProducts();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value && controller.products.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(FontAwesomeIcons.boxesStacked, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text('no_products_in_stock'.tr),
                ElevatedButton(onPressed: _navigateToAddProduct, child: Text('add_first_product'.tr)),
              ],
            ),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (val) {
                      controller.searchQuery.value = val;
                      // Debounce done by restartable call or manually, for now simple trigger
                      Future.delayed(const Duration(milliseconds: 500), () {
                        if (controller.searchQuery.value == val) {
                          controller.fetchMyProducts(isRefresh: true);
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: StockFilter.values.map((filter) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Obx(() {
                            final isSelected = controller.stockFilter.value == filter;
                            return ChoiceChip(
                              label: Text(_getFilterName(filter)),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  controller.stockFilter.value = filter;
                                  controller.fetchMyProducts(isRefresh: true);
                                }
                              },
                            );
                          }),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: controller.products.length + (controller.isMoreLoading.value ? 1 : 0),
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  if (index == controller.products.length) {
                    return const Center(
                      child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()),
                    );
                  }

                  final product = controller.products[index];

                  final bool isOutOfStock = product.stockQuantity == 0;
                  final bool isLowStock = product.stockQuantity <= (product.minStockAlert);

                  Color statusColor = Colors.green;
                  String statusText = 'in_stock'.tr;
                  if (isOutOfStock) {
                    statusColor = Colors.red;
                    statusText = 'out_of_stock'.tr;
                  } else if (isLowStock) {
                    statusColor = Colors.orange;
                    statusText = 'low_stock'.tr;
                  }

                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () async {
                        final result = await Get.to(() => ProductDetailsPage(product: product));
                        if (result == true) {
                          controller.fetchMyProducts(isRefresh: true);
                          Get.snackbar('success'.tr, 'product_updated_success'.tr, snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(16));
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Image
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                                image: (product.imageUrl?.isNotEmpty ?? false)
                                    ? DecorationImage(image: CachedNetworkImageProvider(product.imageUrl!), fit: BoxFit.cover)
                                    : null,
                              ),
                              child: (product.imageUrl?.isEmpty ?? true) ? const Icon(Icons.image, size: 40, color: Colors.grey) : null,
                            ),
                            const SizedBox(width: 16),

                            // Product Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text('${'sku'.tr}: ${product.sku ?? "N/A"}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                  const SizedBox(height: 8),
                                  // Prices
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 4,
                                    children: [
                                      Text(
                                        '${'retail_price'.tr}: ${product.retailPrice.toPriceWithCurrency(Get.find<CompanyController>().effectiveCurrency.symbol)}',
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green[700]),
                                      ),
                                      Text(
                                        '${'cost_price'.tr}: ${product.costPrice.toPriceWithCurrency(Get.find<CompanyController>().effectiveCurrency.symbol)}',
                                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  // Tags / Badges
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 4,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: statusColor.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                                        ),
                                        child: Text(
                                          statusText,
                                          style: TextStyle(fontSize: 10, color: statusColor, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      if (product.category != null)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(color: Colors.blue.withValues(alpha: 0.5)),
                                          ),
                                          child: Text(
                                            product.category!,
                                            style: TextStyle(fontSize: 10, color: Colors.blue[700], fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      if (product.hasDiscount)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.red.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
                                          ),
                                          child: Text(
                                            '-${product.discountPercentage.round()}%',
                                            style: const TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Price & Actions
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                '${'qty'.tr}: ${product.stockQuantity}',
                                style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  String _getFilterName(StockFilter filter) {
    switch (filter) {
      case StockFilter.all:
        return 'all'.tr;
      case StockFilter.inStock:
        return 'in_stock'.tr;
      case StockFilter.outOfStock:
        return 'out_of_stock'.tr;
      case StockFilter.lowStock:
        return 'low_stock'.tr;
    }
  }

  void _navigateToAddProduct() async {
    final result = await Get.to(() => const AddProductPage());
    if (result == true) {
      controller.fetchMyProducts(isRefresh: true);
      Get.snackbar('success'.tr, 'product_added_success'.tr, snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(16));
    }
  }
}
