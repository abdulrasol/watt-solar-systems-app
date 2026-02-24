import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_hub/controllers/company_controller.dart';
import 'package:solar_hub/features/orders/models/order_model.dart';
import 'package:solar_hub/models/enums.dart';
import 'package:solar_hub/services/supabase_service.dart';
import 'package:solar_hub/controllers/inventory_controller.dart';

class CompanyOrderController extends GetxController {
  final _dbService = SupabaseService();
  // Pagination & Filtering State
  final int _pageSize = 15;
  int _currentPage = 0;
  final hasMore = true.obs;
  final isMoreLoading = false.obs;
  final isLoading = false.obs;
  final companyOrders = <OrderModel>[].obs;

  final RxString currentSearch = ''.obs;
  final RxString currentStatusFilter = 'All'.obs;
  final RxString currentTypeFilter = 'All'.obs;
  final Rx<DateTimeRange?> dateRangeFilter = Rx<DateTimeRange?>(null);

  // Fetch orders for the logged-in company (Seller)
  Future<void> fetchCompanyOrders({bool refresh = false}) async {
    try {
      final companyId = Get.find<CompanyController>().company.value?.id;
      if (companyId == null) return;

      if (refresh) {
        isLoading.value = true;
        _currentPage = 0;
        hasMore.value = true;
        companyOrders.clear();
      } else {
        if (!hasMore.value || isMoreLoading.value) return;
        isMoreLoading.value = true;
      }

      var query = _dbService.client.from('orders').select('*, order_items(*), customers(*), buyer_user_id:profiles(*)').eq('seller_company_id', companyId);

      // 1. Search (ID or Name)
      if (currentSearch.value.isNotEmpty) {
        final search = currentSearch.value.trim();
        if (search.isNotEmpty) {
          List<String> orConditions = [];

          // A. Search by Order Number (Partial match via computed column)
          // Requires 'order_number_str' function in DB
          orConditions.add('order_number_str.ilike.%$search%');

          // B. Search by ID (Exact match)
          // Still keep exact ID match for copy-pasted UUIDs
          final isUuid = RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$').hasMatch(search);
          if (isUuid) {
            orConditions.add('id.eq.$search');
          }

          // C. Search Guest Name
          orConditions.add('guest_customer_name.ilike.%$search%');

          // C. Multi-table search for Linked Customers/Users if NO UUID match (to save time)
          // or ALWAYS do it? User said "just customer name or id".
          if (!isUuid) {
            try {
              // 1. Search in Customers
              final cRes = await _dbService.client.from('customers').select('id').eq('company_id', companyId).ilike('full_name', '%$search%');
              final customerIds = (cRes as List).map((e) => e['id'] as String).toList();
              if (customerIds.isNotEmpty) {
                orConditions.add('customer_id.in.(${customerIds.join(',')})');
              }

              // 2. Search in Profiles (Registered Users)
              final pRes = await _dbService.client.from('profiles').select('id').ilike('full_name', '%$search%');
              final profileIds = (pRes as List).map((e) => e['id'] as String).toList();
              if (profileIds.isNotEmpty) {
                orConditions.add('buyer_user_id.in.(${profileIds.join(',')})');
              }
            } catch (e) {
              debugPrint('Error searching related tables: $e');
            }
          }

          if (orConditions.isNotEmpty) {
            query = query.or(orConditions.join(','));
          }
        }
      }

      // 2. Status Filter
      if (currentStatusFilter.value != 'All') {
        if (currentStatusFilter.value == 'Pending') {
          query = query.inFilter('status', ['pending', 'waiting']);
        } else if (currentStatusFilter.value == 'In Progress') {
          query = query.inFilter('status', ['in_progress', 'processing']);
        } else if (currentStatusFilter.value == 'Completed') {
          query = query.inFilter('status', ['completed', 'done']);
        } else if (currentStatusFilter.value == 'Cancelled') {
          query = query.eq('status', 'cancelled');
        } else {
          query = query.eq('status', currentStatusFilter.value.toLowerCase());
        }
      }

      // 3. Type Filter
      if (currentTypeFilter.value != 'All') {
        String typeDb = 'pos_sale';
        if (currentTypeFilter.value == 'Online') typeDb = 'online_order';
        if (currentTypeFilter.value == 'Online B2B') typeDb = 'b2b_supply'; // Using migrated value? Or user reverted?
        // User reverted code manually? Wait, Step 651 user changed it back to 'b2b_supply'.
        // "Step Id: 651 ... typeDb = 'b2b_supply'; // Updated to match request"
        // And Step 655 user CLEARED the migration file content?
        // AND Step 650 user REMOVED online_b2b_supply from Enum?
        // IT SEEMS THE USER REJECTED MY "online_b2b_supply" solution and wants to stick to 'b2b_supply'.
        // I MUST RESPECT THAT. I will assume 'b2b_supply' is the intended value for "Online B2B".

        if (currentTypeFilter.value == 'Online B2B') typeDb = 'b2b_supply'; // Sticking to user's preference
        if (currentTypeFilter.value == 'POS') typeDb = 'pos_sale';
        query = query.eq('order_type', typeDb);
      }

      // 4. Date Filter
      if (dateRangeFilter.value != null) {
        final start = dateRangeFilter.value!.start.toIso8601String();
        final end = dateRangeFilter.value!.end.add(const Duration(days: 1)).toIso8601String(); // End of day roughly
        query = query.gte('created_at', start).lt('created_at', end);
      }

      // 5. Sorting & Pagination
      final start = _currentPage * _pageSize;
      final end = start + _pageSize - 1;

      final response = await query.order('created_at', ascending: false).range(start, end);

      final data = List<Map<String, dynamic>>.from(response);
      final newOrders = data.map((e) => OrderModel.fromJson(e)).toList();

      if (refresh) {
        companyOrders.assignAll(newOrders);
      } else {
        companyOrders.addAll(newOrders);
      }

      if (newOrders.length < _pageSize) {
        hasMore.value = false;
      } else {
        _currentPage++;
      }
    } catch (e, stack) {
      debugPrint('Error loading company orders: $e');
      debugPrintStack(stackTrace: stack);
    } finally {
      isLoading.value = false;
      isMoreLoading.value = false;
    }
  }

  void searchOrders(String query) {
    currentSearch.value = query;
    fetchCompanyOrders(refresh: true);
  }

  void filterOrders({String? status, String? type, DateTimeRange? dateRange}) {
    if (status != null) currentStatusFilter.value = status;
    if (type != null) currentTypeFilter.value = type;
    if (dateRange != null) dateRangeFilter.value = dateRange;
    fetchCompanyOrders(refresh: true);
  }

  void clearDateFilter() {
    dateRangeFilter.value = null;
    fetchCompanyOrders(refresh: true);
  }

  Future<void> loadMore() async {
    await fetchCompanyOrders();
  }

  // Fetch orders for the logged-in user (Buyer)
  final userOrders = <OrderModel>[].obs;

  Future<void> fetchUserOrders() async {
    try {
      final userId = _dbService.client.auth.currentUser?.id;
      if (userId == null) return;

      isLoading.value = true;
      final response = await _dbService.client
          .from('orders')
          .select('*, order_items(*), seller_company:companies!orders_seller_company_id_fkey(*)')
          .eq('buyer_user_id', userId)
          .order('created_at', ascending: false);

      final data = List<Map<String, dynamic>>.from(response);
      userOrders.assignAll(data.map((e) => OrderModel.fromJson(e)).toList());
    } catch (e, stack) {
      debugPrint('Error loading user orders: $e');
      debugPrintStack(stackTrace: stack);
    } finally {
      isLoading.value = false;
    }
  }

  // NEW: Fetch orders where my company is the BUYER
  final companyPurchases = <OrderModel>[].obs;

  Future<void> fetchCompanyPurchases() async {
    try {
      final companyId = Get.find<CompanyController>().company.value?.id;
      if (companyId == null) return;

      isLoading.value = true;
      final response = await _dbService.client
          .from('orders')
          .select('*, order_items(*), seller_company:companies!orders_seller_company_id_fkey(*)')
          .eq('buyer_company_id', companyId)
          .order('created_at', ascending: false);

      final data = List<Map<String, dynamic>>.from(response);
      companyPurchases.assignAll(data.map((e) => OrderModel.fromJson(e)).toList());
    } catch (e, stack) {
      debugPrint('Error loading company purchases: $e');
      debugPrintStack(stackTrace: stack);
    } finally {
      isLoading.value = false;
    }
  }

  // ==============================================================================
  // Centralized Order Creation Logic
  // Handles POS, Online Store, and Offer Acceptances
  // ==============================================================================
  Future<String?> createOrder({
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    required OrderType orderType,
    String? sellerCompanyId,
    String? buyerUserId,
    String? customerId,
    String? offerId,
    String? guestCustomerName,
    String paymentMethod = 'cash',
    double paidAmount = 0.0,
    double discountAmount = 0.0,

    double taxAmount = 0.0,
    bool isOffline = false,
    double shippingCost = 0.0,
    String? shippingMethod,
    Map<String, dynamic>? shippingAddress,
    String? buyerCompanyId,
  }) async {
    isLoading.value = true;
    try {
      // 1. Determine Payment Status
      PaymentStatus paymentStatus = PaymentStatus.unpaid;
      if (paidAmount >= totalAmount) {
        paymentStatus = PaymentStatus.paid;
      } else if (paidAmount > 0) {
        paymentStatus = PaymentStatus.partial;
      }

      // 1.5. B2B Customer Handling
      // If this is a B2B order (buyerCompanyId exists) and no customerId is provided,
      // check if this buyer is already a customer or create them.
      if (buyerCompanyId != null && customerId == null && sellerCompanyId != null) {
        debugPrint('[B2B_FLOW] Attempting to ensure B2B customer for seller $sellerCompanyId and buyer $buyerCompanyId');
        try {
          final res = await _dbService.client.rpc(
            'ensure_b2b_customer',
            params: {'p_seller_company_id': sellerCompanyId, 'p_buyer_company_id': buyerCompanyId},
          );
          customerId = res as String?;
          debugPrint('[B2B_FLOW] B2B customer linking result: $customerId');
        } catch (e) {
          debugPrint('[B2B_FLOW] Error linking B2B customer via RPC: $e');
        }
      }

      // 1.8 Fetch Seller Currency
      String currencySymbol = '\$';
      String currencyCode = 'USD';

      if (sellerCompanyId != null) {
        try {
          final currencyRes = await _dbService.client.from('companies').select('currencies(symbol, code)').eq('id', sellerCompanyId).single();
          if (currencyRes['currencies'] != null) {
            currencySymbol = currencyRes['currencies']['symbol'];
            currencyCode = currencyRes['currencies']['code'];
          }
        } catch (e) {
          debugPrint('Error fetching currency for order: $e');
        }
      }

      // 2. Prepare Order Data
      final orderData = {
        'seller_company_id': sellerCompanyId,
        'buyer_user_id': buyerUserId,
        'buyer_company_id': buyerCompanyId,
        'customer_id': customerId,
        'offer_id': offerId,
        'guest_customer_name': guestCustomerName,
        'order_type': orderType.name,
        'status': orderType == OrderType.pos_sale ? 'completed' : 'pending',
        'payment_status': paymentStatus.name,
        'total_amount': totalAmount,
        'discount_amount': discountAmount,
        'tax_amount': taxAmount,
        'paid_amount': paidAmount,
        'payment_method': paymentMethod,
        'created_offline': isOffline,
        'shipping_cost': shippingCost,
        'shipping_method': shippingMethod,
        'shipping_address': shippingAddress,
        'currency_symbol': currencySymbol,
        'currency_code': currencyCode,
        'created_at': DateTime.now().toIso8601String(),
      };

      // 3. Insert Order
      debugPrint('[ORDER] Inserting new order for seller $sellerCompanyId, type: ${orderType.name}');
      final orderResp = await _dbService.client.from('orders').insert(orderData).select().single();
      final orderId = orderResp['id'] as String;
      debugPrint('[ORDER] Success: Order created with ID $orderId');

      // 4. Insert Items & Manage Inventory
      final itemsData = <Map<String, dynamic>>[];

      for (var item in items) {
        itemsData.add({
          'order_id': orderId,
          'product_id': item['product_id'],
          'quantity': item['quantity'],
          'unit_price': item['unit_price'],
          'total_line_price': item['total_line_price'],
          'product_name_snapshot': item['product_name_snapshot'],
          'selected_options': item['selected_options'] ?? [],
        });

        // Reduce Stock
        if (item['product_id'] != null && (orderType == OrderType.pos_sale || orderType == OrderType.online_order || orderType == OrderType.b2b_supply)) {
          try {
            final int quantity = (item['quantity'] as num).toInt();
            await _dbService.rpcReduceStock(productId: item['product_id'], quantitySold: quantity);

            // If InventoryController is active, update local state
            if (Get.isRegistered<InventoryController>()) {
              final invCtrl = Get.find<InventoryController>();
              final pIndex = invCtrl.products.indexWhere((p) => p.id == item['product_id']);
              if (pIndex != -1) {
                final currentQty = invCtrl.products[pIndex].stockQuantity;
                invCtrl.products[pIndex] = invCtrl.products[pIndex].copyWith(stockQuantity: currentQty - quantity);
              }
            }
          } catch (e) {
            debugPrint('[ORDER] Error reducing stock for ${item['product_name_snapshot']}: $e');
            // We log but don't fail the order creation for now, as it might be a sync issue.
            // Ideally, we might want to flag this.
          }
        }
      }

      if (itemsData.isNotEmpty) {
        await _dbService.client.from('order_items').insert(itemsData);
      }

      // 5. Update Customer Stats (if Customer exists)
      if (customerId != null) {
        await updateCustomerStats(customerId, totalAmount, paidAmount);
      }

      await fetchCompanyOrders();
      return orderId;
    } catch (e) {
      debugPrint("Create Order Error: $e");
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateCustomerStats(String customerId, double saleAmount, double paidAmount) async {
    debugPrint('[STATS_UPDATE] [START] Customer ID: $customerId');
    debugPrint('[STATS_UPDATE] [DETAIL] Sale: \$$saleAmount, Paid: \$$paidAmount, Debt Change: \$${saleAmount - paidAmount}');
    try {
      await _dbService.client.rpc(
        'update_customer_stats_secure',
        params: {'p_customer_id': customerId, 'p_sale_amount': saleAmount, 'p_paid_amount': paidAmount},
      );
      debugPrint('[STATS_UPDATE] [SUCCESS] Customer $customerId stats updated via RPC.');
    } catch (e, s) {
      debugPrint('[STATS_UPDATE] [ERROR] Failed to update customer stats for $customerId: $e');
      debugPrintStack(stackTrace: s);
    }
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status, {String? cancellationReason, OrderModel? order}) async {
    try {
      final updates = {'status': status.name};

      if (status == OrderStatus.cancelled && cancellationReason != null) {
        updates['cancellation_reason'] = cancellationReason;
      }

      final targetOrder =
          order ?? (await _dbService.client.from('orders').select('*, order_items(*)').eq('id', orderId).single().then((json) => OrderModel.fromJson(json)));

      if (targetOrder == null) return;

      if (status == OrderStatus.cancelled) {
        debugPrint('[ORDER_UPDATE] Order $orderId cancelled. Restoring stock if applicable.');

        // Restore stock for ALL types now (since B2B Supply also reduces at creation)
        for (var item in targetOrder.items) {
          if (item.productId != null) {
            try {
              // Negative quantity to add stock back
              final int restoreQty = -(item.quantity);
              await _dbService.rpcReduceStock(productId: item.productId!, quantitySold: restoreQty);

              // Update local inventory state
              if (Get.isRegistered<InventoryController>()) {
                final invCtrl = Get.find<InventoryController>();
                final pIndex = invCtrl.products.indexWhere((p) => p.id == item.productId);
                if (pIndex != -1) {
                  final currentQty = invCtrl.products[pIndex].stockQuantity;
                  // Subtracting a negative adds it back
                  invCtrl.products[pIndex] = invCtrl.products[pIndex].copyWith(stockQuantity: currentQty - restoreQty);
                }
              }
              debugPrint('[STOCK_RESTORE] Restored ${item.quantity} for product ${item.productId}');
            } catch (e) {
              debugPrint('[STOCK_RESTORE] Error restoring stock for ${item.productId}: $e');
            }
          }
        }
      }

      await _dbService.client.from('orders').update(updates).eq('id', orderId);

      if (status == OrderStatus.completed) {
        debugPrint('[ORDER_UPDATE] Order $orderId completed. Starting post-completion B2B tasks.');
        final targetOrder =
            order ?? (await _dbService.client.from('orders').select('*, order_items(*)').eq('id', orderId).single().then((json) => OrderModel.fromJson(json)));

        if (targetOrder == null) {
          debugPrint('[ORDER_UPDATE] Error: Order $orderId not found for post-completion tasks.');
          return;
        }

        // 1. Reduce Seller Stock - REMOVED for B2B Supply
        // B2B Supply, Online Order, and POS all now reduce stock at CREATION.
        // We no longer need deferred reduction here.
        // If there are other edge cases (like Offer-based orders without product IDs initially), they might need handling,
        // but for standard "Supplies", it's done.

        await _createSystemForOrder(orderId, targetOrder);

        // 2. B2B Stock Transfer: If Buyer is a company, add items to their inventory
        if (targetOrder.buyerCompanyId != null) {
          debugPrint('[B2B_STOCK] Order ${targetOrder.id} has Buyer Company ${targetOrder.buyerCompanyId}. Starting stock transfer to buyer...');
          final InventoryController inventoryController = Get.isRegistered<InventoryController>()
              ? Get.find<InventoryController>()
              : Get.put(InventoryController());

          for (var item in targetOrder.items) {
            // We use 'unit_price' as the 'cost_price' for the buyer.
            try {
              await inventoryController.addStockFromPurchase(
                companyId: targetOrder.buyerCompanyId!,
                productNameSnapshot: item.productNameSnapshot ?? 'Unknown Product',
                quantityAdded: item.quantity,
                unitCostPrice: item.unitPrice,
              );
            } catch (e) {
              debugPrint('Error adding buyer stock for item ${item.productNameSnapshot}: $e');
            }
          }
        }

        // 3. Update Company Balance (Revenue)
        if (targetOrder.sellerCompanyId != null) {
          await _updateCompanyBalance(targetOrder.sellerCompanyId!, targetOrder.totalAmount);
        }

        // Force refresh inventory to ensure RPC changes are reflected locally
        if (Get.isRegistered<InventoryController>()) {
          Get.find<InventoryController>().fetchMyProducts(isRefresh: true);
        }
      }

      await fetchCompanyOrders();
      await fetchUserOrders();
    } catch (e, s) {
      debugPrint('Error updating order status: $e');
      debugPrintStack(stackTrace: s);
      rethrow;
    }
  }

  Future<void> _createSystemForOrder(String orderId, OrderModel? order) async {
    try {
      var currentOrder = order;
      if (currentOrder == null || currentOrder.offerId == null) {
        final res = await _dbService.client.from('orders').select().eq('id', orderId).single();
        currentOrder = OrderModel.fromJson(res);
      }

      if (currentOrder.offerId == null) return;

      final offerRes = await _dbService.client.from('offers').select('*, request:offer_requests(*)').eq('id', currentOrder.offerId!).single();
      final offer = offerRes;
      final request = offer['request'] as Map<String, dynamic>;

      // Map specs to separate JSONB columns as per 'systems' table
      // Offer/Request usually has structure { pv_specs, battery_specs, inverter_specs }
      // We need to map them to the format expected by 'systems' table columns: pv, battery, inverter

      final pvData = offer['pv_specs'] ?? request['specs']['panels'] ?? {};
      final battData = offer['battery_specs'] ?? request['specs']['battery'] ?? {};
      final invData = offer['inverter_specs'] ?? request['specs']['inverter'] ?? {};

      // Ensure we convert to Map<String, dynamic> if they are not already (Supabase might return them as such)

      final validPv = pvData is Map ? pvData : <String, dynamic>{};
      final validBatt = battData is Map ? battData : <String, dynamic>{};
      final validInv = invData is Map ? invData : <String, dynamic>{};

      final systemData = {
        'user_id': currentOrder.buyerUserId,
        'installed_by': currentOrder.sellerCompanyId,
        // 'user': '', // Optional: could look up phone number if needed for legacy column
        'company_status': 'accepted',
        'user_status': 'pending', // Waiting for user confirmation
        'pv': validPv,
        'battery': validBatt,
        'inverter': validInv,
        'notes': "${offer['notes'] ?? ''}\nCreated from Order #${currentOrder.id.substring(0, 8)} - ${request['title'] ?? ''}",
        'installed_at': DateTime.now().toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
        'order_id': currentOrder.id,
      };

      await _dbService.client.from('systems').insert(systemData);
      debugPrint("System Auto-Created for Order $orderId in 'systems' table");
    } catch (e, s) {
      debugPrint("Error creating system for order: $e");
      debugPrintStack(stackTrace: s);
    }
  }

  Future<void> _updateCompanyBalance(String companyId, double amount) async {
    try {
      // 1. Fetch current balance
      final res = await _dbService.client.from('companies').select('balance').eq('id', companyId).single();
      final currentBalance = (res['balance'] as num?)?.toDouble() ?? 0.0;
      final newBalance = currentBalance + amount;

      // 2. Update balance
      await _dbService.client.from('companies').update({'balance': newBalance}).eq('id', companyId);
      debugPrint('[BALANCE] Updated company $companyId balance to $newBalance');

      // 3. Update local state if it's my company
      if (Get.isRegistered<CompanyController>()) {
        final companyCtrl = Get.find<CompanyController>();
        if (companyCtrl.company.value?.id == companyId) {
          companyCtrl.company.value = companyCtrl.company.value?.copyWith(balance: newBalance);
        }
      }
    } catch (e) {
      debugPrint('[BALANCE] Error updating balance: $e');
    }
  }
}
