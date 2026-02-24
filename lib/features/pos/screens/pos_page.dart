import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:solar_hub/controllers/company_controller.dart';
import 'package:solar_hub/features/pos/controllers/pos_controller.dart';
import 'package:solar_hub/utils/app_theme.dart';
import 'package:solar_hub/models/customer_model.dart';
import 'package:solar_hub/features/pos/widgets/customer_selection_dialog.dart';
import 'package:solar_hub/features/pos/widgets/payment_dialog.dart';
import 'package:solar_hub/utils/price_format_utils.dart';

class PosPage extends StatelessWidget {
  const PosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PosController());

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800; // Tablet landscape / Desktop

        if (isWide) {
          return Row(
            children: [
              Expanded(flex: 3, child: _buildProductSection(context, controller)),
              const VerticalDivider(width: 1),
              Expanded(flex: 2, child: _buildCartSection(context, controller)),
            ],
          );
        } else {
          return Column(
            children: [
              Expanded(child: _buildProductSection(context, controller)),
              _buildMobileCartSummary(context, controller),
            ],
          );
        }
      },
    );
  }

  // =========================================
  // LEFT: PRODUCT LIST
  // =========================================
  Widget _buildProductSection(BuildContext context, PosController controller) {
    return Column(
      children: [
        // Search & Filters
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'search_products'.tr,
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (val) => controller.searchQuery.value = val,
                ),
              ),
              const SizedBox(width: 8),
              // Clear Cart Button (Moved here since AppBar is gone)
              IconButton(
                icon: const Icon(Icons.delete_sweep, color: Colors.orange),
                onPressed: () => controller.cart.clear(),
                tooltip: 'clear_cart'.tr,
              ),
            ],
          ),
        ),
        // Filter Chips (Separated row for better layout)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Text("${'filter'.tr}: "),
              Expanded(
                child: Obx(
                  () => DropdownButton<String>(
                    isExpanded: true,
                    underline: Container(height: 1, color: Colors.grey[300]),
                    value: controller.categories.contains(controller.selectedCategory.value) ? controller.selectedCategory.value : 'All',
                    items: controller.categories.map((c) => DropdownMenuItem(value: c, child: Text(c == 'All' ? 'all'.tr : c))).toList(),
                    onChanged: (v) => controller.selectedCategory.value = v ?? 'All',
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Grid
        Expanded(
          child: Obx(() {
            final products = controller.filteredProducts;
            if (products.isEmpty) {
              return Center(child: Text('no_products'.tr));
            }
            return GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                childAspectRatio: 0.8,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                final isOutOfStock = product.stockQuantity <= 0;

                return GestureDetector(
                  onTap: () => controller.addToCart(product),
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    elevation: 2,
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                color: Colors.grey[200],
                                width: double.infinity,
                                child: product.imageUrl != null
                                    ? CachedNetworkImage(
                                        imageUrl: product.imageUrl!,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => Container(color: Colors.grey[200]),
                                        errorWidget: (context, url, error) => const Icon(Icons.solar_power, size: 50, color: Colors.grey),
                                      )
                                    : Icon(_getProductIcon(product), size: 50, color: Colors.grey[400]),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    product.retailPrice.toPriceWithCurrency(Get.find<CompanyController>().effectiveCurrency.symbol),
                                    style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${product.stockQuantity} ${'in_stock'.tr}",
                                    style: TextStyle(fontSize: 12, color: isOutOfStock ? Colors.red : Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (isOutOfStock)
                          Container(
                            color: Colors.white.withValues(alpha: 0.7),
                            child: Center(
                              child: Transform.rotate(
                                angle: -0.5,
                                child: Text(
                                  'out_of_stock'.tr,
                                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  // =========================================
  // RIGHT: CART
  // =========================================
  Widget _buildCartSection(BuildContext context, PosController controller) {
    return Container(
      color: Theme.of(context).cardColor,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.primaryColor,
            width: double.infinity,
            child: Text(
              'current_sale'.tr,
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),

          // Customer Selection
          InkWell(
            onTap: () async {
              final customer = await Get.dialog<CustomerModel>(const CustomerSelectionDialog());
              if (customer != null) {
                controller.selectedCustomer.value = customer;
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Obx(
                      () => Text(controller.selectedCustomer.value?.fullName ?? 'Guest Customer', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  if (controller.selectedCustomer.value != null)
                    IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () => controller.selectedCustomer.value = null)
                  else
                    Text('select'.tr, style: TextStyle(color: AppTheme.primaryColor)),
                ],
              ),
            ),
          ),

          Expanded(
            child: Obx(() {
              if (controller.cart.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text('cart_empty'.tr, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: controller.cart.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final item = controller.cart[index];
                  final originalPrice = item.product.retailPrice;
                  final hasDiscount = item.unitPrice < originalPrice;

                  return Row(
                    children: [
                      // Qty Controls
                      Column(
                        children: [
                          InkWell(onTap: () => controller.updateQuantity(index, item.quantity + 1), child: const Icon(Icons.arrow_drop_up, size: 28)),
                          Text("${item.quantity}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          InkWell(onTap: () => controller.updateQuantity(index, item.quantity - 1), child: const Icon(Icons.arrow_drop_down, size: 28)),
                        ],
                      ),
                      const SizedBox(width: 16),

                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            if (hasDiscount)
                              Text(
                                'tier_price_applied'.tr,
                                style: const TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold),
                              ),
                          ],
                        ),
                      ),

                      // Price
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            item.total.toPriceWithCurrency(Get.find<CompanyController>().effectiveCurrency.symbol),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "${item.unitPrice.toPrice()} /unit",
                            style: TextStyle(fontSize: 11, color: Colors.grey, decoration: hasDiscount ? null : null),
                          ),
                          if (hasDiscount)
                            Text(
                              originalPrice.toPriceWithCurrency(Get.find<CompanyController>().effectiveCurrency.symbol),
                              style: const TextStyle(fontSize: 11, color: Colors.red, decoration: TextDecoration.lineThrough),
                            ),
                        ],
                      ),
                    ],
                  );
                },
              );
            }),
          ),

          // Totals & Checkout
          _buildCheckoutFooter(context, controller),
        ],
      ),
    );
  }

  Widget _buildCheckoutFooter(BuildContext context, PosController controller) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Obx(
        () => Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('total'.tr, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    controller.total.toPriceWithCurrency(Get.find<CompanyController>().effectiveCurrency.symbol),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: controller.cart.isEmpty ? null : () => _processCheckout(context, controller),
                icon: const Icon(Icons.check_circle_outline),
                label: Text('pay_now'.tr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Mobile Bottom Bar
  Widget _buildMobileCartSummary(BuildContext context, PosController controller) {
    return Obx(() {
      if (controller.cart.isEmpty) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, -2))],
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${controller.cart.length} ${'items'.tr}", style: const TextStyle(color: Colors.grey)),
                Text(
                  controller.total.toPriceWithCurrency(Get.find<CompanyController>().effectiveCurrency.symbol),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                // Show BottomSheet with full cart
                Get.bottomSheet(
                  SizedBox(height: MediaQuery.of(context).size.height * 0.8, child: _buildCartSection(context, controller)),
                  isScrollControlled: true,
                );
              },
              child: Text('view_cart'.tr),
            ),
          ],
        ),
      );
    });
  }

  void _processCheckout(BuildContext context, PosController controller) async {
    // Show new Payment Dialog
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PaymentDialog(totalAmount: controller.total, customer: controller.selectedCustomer.value),
    );

    if (result != null) {
      final String method = result['method'];
      final double amount = result['amount'];

      final success = await controller.checkout(paymentMethod: method, paidAmount: amount);
      if (success) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${'sale_completed'.tr}: ${'receipt_sent'.tr}'), backgroundColor: Colors.green, duration: const Duration(seconds: 4)),
          );
        }
      }
    }
  }

  IconData _getProductIcon(dynamic product) {
    if (product.category == null) return Icons.solar_power;
    final cat = product.category!.toLowerCase();
    if (cat.contains('battery') || cat.contains('batteries')) return Icons.battery_charging_full;
    if (cat.contains('panel') || cat.contains('solar')) return Icons.solar_power;
    if (cat.contains('inverter')) return Icons.electric_bolt;
    if (cat.contains('wire') || cat.contains('cable')) return Icons.cable;
    return Icons.grid_view;
  }
}
