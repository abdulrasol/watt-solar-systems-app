import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:solar_hub/features/store/controllers/cart_controller.dart';
import 'package:solar_hub/features/store/models/cart_item_model.dart';
import 'package:solar_hub/features/store/widgets/store_image.dart';

class CartPage extends StatelessWidget {
  final String? filterCompanyId;

  const CartPage({super.key, this.filterCompanyId});

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.put(CartController());

    return Scaffold(
      appBar: AppBar(
        title: filterCompanyId == null
            ? const Text('Shopping Cart')
            : Obx(() {
                final item = cartController.cartItems.firstWhereOrNull((i) => i.product.companyId == filterCompanyId);
                if (item != null && item.product.companyName != null) {
                  return Text('Shopping Cart - ${item.product.companyName}');
                }
                return const Text('Shopping Cart');
              }),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              if (cartController.cartItems.isNotEmpty) {
                // If filtering, we should probably only clear items for that company or warn user.
                // For simplicity, we'll keep global clear but maybe we should technically only clear filtered items if filtered?
                // Let's stick to global clear for now as it's safer than partial clear implementation complexity without user request.
                // OR better: if filtered, only clear that company's items?
                // The prompt didn't specify "clear cart" behavior change, so let's keep it simple for now or just warn.
                _showClearCartDialog(context, cartController);
              }
            },
          ),
        ],
      ),
      body: Obx(() {
        var itemsToShow = cartController.cartItems.toList();

        // Filter if requested
        if (filterCompanyId != null) {
          itemsToShow = itemsToShow.where((i) => i.product.companyId == filterCompanyId).toList();
        }

        if (itemsToShow.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(FontAwesomeIcons.cartPlus, size: 80, color: Colors.grey),
                const SizedBox(height: 20),
                Text('Your cart is empty', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey)),
                const SizedBox(height: 10),
                ElevatedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Go Shopping')),
              ],
            ),
          );
        }

        // Group items by Company
        final groupedItems = <String, List<CartItemModel>>{};
        for (var item in itemsToShow) {
          final id = item.product.companyId ?? 'Unknown';
          groupedItems.putIfAbsent(id, () => []).add(item);
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: groupedItems.length,
                itemBuilder: (context, index) {
                  final companyId = groupedItems.keys.elementAt(index);
                  final items = groupedItems[companyId]!;
                  final companyName = items.first.product.companyName ?? 'Unknown Seller';

                  return _buildCompanySection(context, companyId, companyName, items, cartController);
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildCompanySection(BuildContext context, String companyId, String companyName, List<CartItemModel> items, CartController controller) {
    // Calculate subtotal for this company
    final subtotal = items.fold(0.0, (sum, item) => sum + item.totalPrice);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(FontAwesomeIcons.store, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(companyName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const Divider(height: 24),

          // Items
          ...items.map((item) => _buildCartItem(context, item, controller)),

          const Divider(height: 24),

          // Shipping Address Input
          const Text(
            'Delivery Address',
            style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            onChanged: (val) => controller.updateAddress(companyId, val),
            decoration: const InputDecoration(
              hintText: 'Enter address for this order',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              isDense: true,
            ),
            controller: TextEditingController(text: controller.deliveryAddressMap[companyId] ?? '')
              ..selection = TextSelection.fromPosition(TextPosition(offset: (controller.deliveryAddressMap[companyId] ?? '').length)),
          ),
          const SizedBox(height: 16),

          // Payment Method
          const Text(
            'Payment Method',
            style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Obx(() {
            return DropdownButtonFormField<String>(
              initialValue: controller.selectedPaymentMap[companyId] ?? 'cash',
              decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8), border: OutlineInputBorder(), isDense: true),
              items: const [DropdownMenuItem(value: 'cash', child: Text('Cash on Delivery'))],
              onChanged: (val) => controller.updatePayment(companyId, val!),
            );
          }),
          const SizedBox(height: 16),

          // Shipping Options
          Text(
            'Shipping Method',
            style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Obx(() {
            final options = controller.availableDeliveryOptions[companyId] ?? [];
            if (options.isEmpty) {
              return const Text("No shipping options available", style: TextStyle(color: Colors.red, fontSize: 12));
            }

            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: options.map((opt) {
                final isSelected = controller.selectedDeliveryMap[companyId] == opt.id;
                final currencySymbol = items.isNotEmpty ? items.first.product.currency?.symbol ?? '\$' : '\$';

                return ChoiceChip(
                  label: Text('${opt.name} ($currencySymbol${opt.cost.toStringAsFixed(0)})'),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected && opt.id != null) {
                      controller.selectedDeliveryMap[companyId] = opt.id!;
                      controller.selectedDeliveryMap.refresh();
                    }
                  },
                );
              }).toList(),
            );
          }),

          const SizedBox(height: 16),
          // Company Totals & Checkout
          Obx(() {
            final currencySymbol = items.isNotEmpty ? items.first.product.currency?.symbol ?? '\$' : '\$';
            final shippingCost = controller.getShippingCost(companyId);
            final total = subtotal + shippingCost;

            return CommonButton(companyId: companyId, total: total, controller: controller, currencySymbol: currencySymbol);
          }),
        ],
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartItemModel item, CartController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StoreImage(url: item.product.imageUrl, width: 60, height: 60, borderRadius: 8),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.w600), maxLines: 2),
                if (item.selectedOptions.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Wrap(
                      spacing: 4,
                      children: item.selectedOptions
                          .map((opt) => Text('${opt['option_name']}: ${opt['value']}', style: const TextStyle(fontSize: 11, color: Colors.grey)))
                          .toList(),
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  '${item.product.currency?.symbol ?? '\$'}${item.totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, size: 20),
                onPressed: () => controller.decreaseQuantity(item),
                color: Colors.grey,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 20),
                onPressed: () => controller.increaseQuantity(item),
                color: Theme.of(context).primaryColor,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CommonButton extends StatelessWidget {
  const CommonButton({super.key, required this.companyId, required this.total, required this.controller, required this.currencySymbol});

  final String companyId;
  final double total;
  final CartController controller;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Total:", style: TextStyle(color: Colors.grey, fontSize: 12)),
            Text(
              '$currencySymbol${total.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
            ),
          ],
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
          onPressed: controller.isLoading.value ? null : () => controller.checkout(companyId),
          child: controller.isLoading.value
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text("Checkout"),
        ),
      ],
    );
  }
}

void _showClearCartDialog(BuildContext context, CartController controller) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Clear Cart', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text(
              'Are you sure you want to remove all items?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    controller.clearCart();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    elevation: 0,
                  ),
                  child: const Text('Yes, Clear', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orangeAccent,
                    side: const BorderSide(color: Colors.orangeAccent),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
