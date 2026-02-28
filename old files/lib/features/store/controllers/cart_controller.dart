import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:solar_hub/features/store/models/cart_item_model.dart';
import 'package:solar_hub/features/store/models/product_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:solar_hub/utils/toast_service.dart';
import 'package:solar_hub/features/orders/controllers/company_order_controller.dart';
import 'package:solar_hub/models/enums.dart';
import 'package:solar_hub/features/store/models/delivery_option_model.dart';
import 'package:solar_hub/controllers/company_controller.dart';

class CartController extends GetxController {
  final _box = GetStorage();
  final _key = 'cart_items';

  var cartItems = <CartItemModel>[].obs;
  var isLoading = false.obs;

  // Delivery Management
  // available delivery options per company: {companyId: [Option1, Option2]}
  var availableDeliveryOptions = <String, List<DeliveryOptionModel>>{}.obs;

  // Selected delivery option ID per company: {companyId: optionId}
  var selectedDeliveryMap = <String, String>{}.obs;

  // Payment method per company: {companyId: 'cash'}
  var selectedPaymentMap = <String, String>{}.obs;

  // Delivery address per company: {companyId: 'address string'}
  var deliveryAddressMap = <String, String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCart();
    ever(cartItems, (_) => _refreshDeliveryOptions()); // Fetch options when cart changes
    // Initialize default payment methods for companies in cart
    ever(cartItems, (_) => _initDefaults());
  }

  void _loadCart() {
    List? storedItems = _box.read<List>(_key);
    if (storedItems != null) {
      cartItems.assignAll(storedItems.map((e) => CartItemModel.fromJson(e)).toList());
    }
    _refreshDeliveryOptions();
    _initDefaults();
  }

  void _initDefaults() {
    final companyIds = cartItems.map((e) => e.product.companyId).whereType<String>().toSet();
    for (var id in companyIds) {
      if (!selectedPaymentMap.containsKey(id)) {
        selectedPaymentMap[id] = 'cash';
      }
      if (!deliveryAddressMap.containsKey(id)) {
        deliveryAddressMap[id] = '';
      }
    }
  }

  void _saveCart() {
    _box.write(_key, cartItems.map((e) => e.toJson()).toList());
  }

  void addToCart(ProductModel product, {List<Map<String, dynamic>> selectedOptions = const [], double? customUnitPrice, int quantity = 1}) {
    // 1. Stock Validation
    if (product.stockQuantity <= 0) {
      ToastService.error('out_of_stock'.tr, 'product_out_of_stock'.tr);
      return;
    }

    // Find existing item with same product ID AND same options AND same custom price condition
    var existingItem = cartItems.firstWhereOrNull((element) {
      if (element.product.id != product.id) return false;
      // If custom price is provided, it must match. If not, it defaults to product price, effectively meaning 'standard retail'.
      if (customUnitPrice != element.customUnitPrice) return false;
      return _areOptionsEqual(element.selectedOptions, selectedOptions);
    });

    if (existingItem != null) {
      // 2. Stock Validation for existing item
      if (existingItem.quantity + quantity > product.stockQuantity) {
        existingItem.quantity = product.stockQuantity;
        ToastService.warning('limited_stock'.tr, 'only_x_available'.tr.replaceAll('@qty', product.stockQuantity.toString()));
      } else {
        existingItem.quantity += quantity;
      }
      cartItems.refresh();
    } else {
      // 3. Stock Validation for new item
      int finalQty = quantity > product.stockQuantity ? product.stockQuantity : quantity;
      if (finalQty < quantity) {
        ToastService.warning('limited_stock'.tr, 'only_x_available'.tr.replaceAll('@qty', product.stockQuantity.toString()));
      }
      cartItems.add(CartItemModel(product: product, selectedOptions: selectedOptions, quantity: finalQty, customUnitPrice: customUnitPrice));
    }
    _saveCart();
    ToastService.success('added_to_cart'.tr, 'product_added_cart'.tr.replaceAll('@name', product.name));
  }

  bool _areOptionsEqual(List<Map<String, dynamic>> a, List<Map<String, dynamic>> b) {
    if (a.length != b.length) return false;
    String sigA = a.map((e) => '${e['name']}:${e['value']}').join('|');
    String sigB = b.map((e) => '${e['name']}:${e['value']}').join('|');
    return sigA == sigB;
  }

  void removeFromCart(CartItemModel item) {
    cartItems.remove(item);
    _saveCart();
  }

  void increaseQuantity(CartItemModel item) {
    if (item.quantity < item.product.stockQuantity) {
      item.quantity++;
      cartItems.refresh();
      _saveCart();
    } else {
      ToastService.warning('limited_stock'.tr, 'max_stock_reached'.tr);
    }
  }

  void decreaseQuantity(CartItemModel item) {
    if (item.quantity > 1) {
      item.quantity--;
      cartItems.refresh();
      _saveCart();
    } else {
      removeFromCart(item);
    }
  }

  void updatePayment(String companyId, String method) {
    selectedPaymentMap[companyId] = method;
  }

  void updateAddress(String companyId, String address) {
    deliveryAddressMap[companyId] = address;
  }

  void clearCart() {
    cartItems.clear();
    _saveCart();
    selectedDeliveryMap.clear();
    selectedPaymentMap.clear();
    deliveryAddressMap.clear();
  }

  Future<void> _refreshDeliveryOptions() async {
    final companyIds = cartItems.map((e) => e.product.companyId).whereType<String>().toSet().toList();

    for (var id in companyIds) {
      if (!availableDeliveryOptions.containsKey(id)) {
        await _fetchDeliveryOptionsForCompany(id);
      }
    }

    // Set default selections if not set
    for (var id in companyIds) {
      if (!selectedDeliveryMap.containsKey(id) && availableDeliveryOptions.containsKey(id)) {
        var opts = availableDeliveryOptions[id]!;
        if (opts.isNotEmpty) {
          selectedDeliveryMap[id] = opts.first.id!;
        }
      }
    }
  }

  Future<void> _fetchDeliveryOptionsForCompany(String companyId) async {
    try {
      final response = await Supabase.instance.client.from('delivery_options').select().eq('company_id', companyId).eq('is_active', true);

      final opts = (response as List).map((e) => DeliveryOptionModel.fromJson(e)).toList();
      availableDeliveryOptions[companyId] = opts;
    } catch (e) {
      // print('Error fetching delivery options: $e');
    }
  }

  double getShippingCost(String companyId) {
    final optionId = selectedDeliveryMap[companyId];
    if (optionId == null) return 0.0;
    final options = availableDeliveryOptions[companyId];
    final selected = options?.firstWhereOrNull((e) => e.id == optionId);
    return selected?.cost ?? 0.0;
  }

  double get grandTotal {
    double total = cartItems.fold(0, (sum, item) => sum + item.totalPrice);
    final companyIds = cartItems.map((e) => e.product.companyId).whereType<String>().toSet();
    for (var id in companyIds) {
      total += getShippingCost(id);
    }
    return total;
  }

  double get subTotal => cartItems.fold(0, (sum, item) => sum + item.totalPrice);

  Future<void> checkout(String companyId) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      Get.toNamed('/auth');
      return;
    }

    final companyItems = cartItems.where((i) => i.product.companyId == companyId).toList();
    if (companyItems.isEmpty) return;

    final address = deliveryAddressMap[companyId];
    if (address == null || address.trim().isEmpty) {
      ToastService.error("Missing Info", "Please provide a delivery address for this order.");
      return;
    }

    isLoading.value = true;
    try {
      final orderController = Get.put(CompanyOrderController());

      // Calculate totals for this company
      final totalProductPrice = companyItems.fold(0.0, (sum, item) => sum + item.totalPrice);
      final shippingCost = getShippingCost(companyId);
      final shippingOptionId = selectedDeliveryMap[companyId];
      final optionName = availableDeliveryOptions[companyId]?.firstWhereOrNull((e) => e.id == shippingOptionId)?.name ?? 'Default';

      final finalTotal = totalProductPrice + shippingCost;
      final paymentMethod = selectedPaymentMap[companyId] ?? 'cash';

      final orderItemsData = companyItems
          .map(
            (item) => {
              'product_id': item.product.id,
              'quantity': item.quantity,
              'unit_price': item.customUnitPrice ?? item.product.effectivePrice,
              'total_line_price': item.totalPrice,
              'product_name_snapshot': item.product.name,
              'selected_options': item.selectedOptions,
            },
          )
          .toList();

      await orderController.createOrder(
        items: orderItemsData,
        totalAmount: finalTotal,
        orderType: OrderType.online_order,
        sellerCompanyId: companyId,
        buyerUserId: user.id,
        paymentMethod: paymentMethod,
        shippingCost: shippingCost,
        shippingMethod: optionName,
        shippingAddress: {'address': address},
        buyerCompanyId: Get.isRegistered<CompanyController>() ? Get.find<CompanyController>().company.value?.id : null,
        // If items have custom price, it's likely a wholesale order, but for now we default to online_order unless explicit
        // To be safe, we can check if the seller is a wholesaler tier, but 'online_order' is fine for general B2B too.
      );

      // Remove only purchased items
      cartItems.removeWhere((item) => item.product.companyId == companyId);

      // Cleanup maps
      selectedDeliveryMap.remove(companyId);
      selectedPaymentMap.remove(companyId);
      deliveryAddressMap.remove(companyId);

      _saveCart();

      Get.offNamed('/my-orders');
      Future.delayed(const Duration(milliseconds: 300), () {
        ToastService.success("Order Placed", "Order for this seller placed successfully!");
      });
    } catch (e) {
      ToastService.error("Checkout Failed", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  int get itemCount => cartItems.fold(0, (sum, item) => sum + item.quantity);
}
