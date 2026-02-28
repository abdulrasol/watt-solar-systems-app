import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_hub/controllers/company_controller.dart';
import 'package:solar_hub/controllers/inventory_controller.dart';
import 'package:solar_hub/features/store/models/product_model.dart';
import 'package:solar_hub/models/customer_model.dart';
import 'package:solar_hub/features/orders/controllers/company_order_controller.dart';
import 'package:solar_hub/models/enums.dart';

class CartItem {
  final ProductModel product;
  int quantity;
  double unitPrice; // Dynamic based on tier

  CartItem({required this.product, this.quantity = 1, required this.unitPrice});

  double get total => quantity * unitPrice;
}

class PosController extends GetxController {
  // Safe initialization: Put it if not present
  final InventoryController inventoryController = Get.put(InventoryController());

  final cart = <CartItem>[].obs;
  final searchQuery = ''.obs;
  final selectedCategory = 'All'.obs;

  // Customer Selection
  final Rxn<CustomerModel> selectedCustomer = Rxn<CustomerModel>();

  // Computed
  double get subtotal => cart.fold(0, (sum, item) => sum + item.total);
  double get discount => 0; // Future: Global discount
  double get tax => 0; // Future: Global tax
  double get total => subtotal - discount + tax;

  // Filtered Products
  List<ProductModel> get filteredProducts {
    // Accessing reactive variables to register dependency
    final query = searchQuery.value.toLowerCase();
    final category = selectedCategory.value;

    return inventoryController.products.where((p) {
      final matchesSearch = p.name.toLowerCase().contains(query) || (p.sku?.toLowerCase().contains(query) ?? false);
      final matchesCategory = category == 'All' || p.category == category || p.companyCategories.any((c) => c['name'] == category);

      return matchesSearch && matchesCategory;
    }).toList();
  }

  List<String> get categories {
    final cats = <String>{'All'};
    for (var p in inventoryController.products) {
      if (p.category != null) cats.add(p.category!);
      for (var c in p.companyCategories) {
        cats.add(c['name'] as String);
      }
    }
    return cats.toList();
  }

  void addToCart(ProductModel product) {
    if (product.stockQuantity <= 0) {
      Get.showSnackbar(
        GetSnackBar(title: 'err_out_of_stock'.tr, message: 'msg_out_of_stock'.tr, backgroundColor: Colors.red, duration: const Duration(seconds: 2)),
      );
      return;
    }

    final index = cart.indexWhere((item) => item.product.id == product.id);
    if (index != -1) {
      // Update existing
      final currentQty = cart[index].quantity;
      if (currentQty + 1 > product.stockQuantity) {
        Get.showSnackbar(
          GetSnackBar(
            title: 'err_stock_limit'.tr,
            message: 'msg_stock_limit'.trParams({'qty': product.stockQuantity.toString()}),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      }
      updateQuantity(index, currentQty + 1);
    } else {
      // Add new
      final price = _calculateTierPrice(product, 1);
      cart.add(CartItem(product: product, quantity: 1, unitPrice: price));
    }
  }

  void updateQuantity(int index, int newQty) {
    if (newQty <= 0) {
      cart.removeAt(index);
      return;
    }

    final item = cart[index];
    if (newQty > item.product.stockQuantity) {
      Get.showSnackbar(
        GetSnackBar(
          title: 'err_stock_limit'.tr,
          message: 'msg_stock_limit'.trParams({'qty': item.product.stockQuantity.toString()}),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // Recalculate price based on new quantity (Tiered Pricing)
    final newPrice = _calculateTierPrice(item.product, newQty);

    // Create new object to trigger reactivity if needed, or just update fields
    // Updating fields in Obx list might not trigger update of the item itself unless we refresh list
    item.quantity = newQty;
    item.unitPrice = newPrice;
    cart.refresh();
  }

  // Tiered Pricing Logic
  double _calculateTierPrice(ProductModel product, int qty) {
    double bestPrice = product.retailPrice;

    for (var tier in product.pricingTiers) {
      if (qty >= tier.minQuantity) {
        // Assuming tiers are unit prices. If we have multiple matching tiers, we want the lowest price (usually highest qty)
        if (tier.unitPrice < bestPrice) {
          bestPrice = tier.unitPrice;
        }
      }
    }
    return bestPrice;
  }

  Future<bool> checkout({String paymentMethod = 'cash', double? paidAmount}) async {
    if (cart.isEmpty) return false;

    final companyId = Get.find<CompanyController>().company.value?.id;
    if (companyId == null) return false;

    final CompanyOrderController orderController = Get.put(CompanyOrderController());

    // Prepare Items
    final items = cart.map((item) {
      return {
        'product_id': item.product.id,
        'quantity': item.quantity,
        'unit_price': item.unitPrice,
        'total_line_price': item.total,
        'product_name_snapshot': item.product.name,
      };
    }).toList();

    // Determine Paid Amount logic logic is handled in OrderController mostly,
    // but we need to pass the explicit amount if "Split" or "Partial" was chosen in dialog.
    // The dialog returns 'amount' which is the PAID amount.

    double finalPaidAmount = 0.0;
    if (paymentMethod == 'cash' || paymentMethod == 'card') {
      finalPaidAmount = total;
    } else if (paymentMethod == 'on_account') {
      finalPaidAmount = 0.0;
    } else if (paidAmount != null) {
      finalPaidAmount = paidAmount;
    }

    final orderId = await orderController.createOrder(
      items: items,
      totalAmount: total,
      paidAmount: finalPaidAmount,
      orderType: OrderType.pos_sale,
      sellerCompanyId: companyId,
      customerId: selectedCustomer.value?.id,
      paymentMethod: paymentMethod,
      // discount, tax logic can be added later
    );

    if (orderId != null) {
      cart.clear();
      return true;
    } else {
      Get.showSnackbar(GetSnackBar(title: 'err_error'.tr, message: 'msg_checkout_error'.tr, backgroundColor: Colors.red, duration: const Duration(seconds: 2)));
      return false;
    }
  }
}
