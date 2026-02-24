import 'package:get/get.dart';
import 'package:solar_hub/models/enums.dart';

class OrderModel {
  final String id;
  final String? offerId; // New field
  final String? sellerCompanyId;
  final String? buyerUserId;
  final String? buyerCompanyId;
  final String? guestCustomerName;
  final OrderType orderType;
  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final double totalAmount;
  final double discountAmount;
  final double taxAmount;
  final int? orderNumber; // New field
  final bool createdOffline;
  final DateTime? syncedAt;
  final DateTime? createdAt;
  final List<OrderItemModel> items;
  final String? customerId;
  final String? paymentMethod;
  final double paidAmount;
  final String? cancellationReason;
  final Map<String, dynamic>? customer;
  final Map<String, dynamic>? buyerProfile;

  // Shipping Info
  final double shippingCost;
  final String? shippingMethod;
  final Map<String, dynamic>? shippingAddress;

  // Currency Info
  final String? currencySymbol;
  final String? currencyCode;

  String get effectiveCustomerName {
    if (customer != null && customer!['full_name'] != null) {
      return customer!['full_name'];
    }
    if (buyerProfile != null && buyerProfile!['full_name'] != null) {
      return buyerProfile!['full_name'];
    }
    if (guestCustomerName != null && guestCustomerName!.isNotEmpty) {
      return guestCustomerName!;
    }
    return 'guest'.tr;
  }

  OrderModel({
    required this.id,
    this.offerId,
    this.sellerCompanyId,
    this.buyerUserId,
    this.buyerCompanyId,
    this.guestCustomerName,
    required this.orderType,
    this.status = OrderStatus.completed,
    this.paymentStatus = PaymentStatus.paid,
    required this.totalAmount,
    this.discountAmount = 0.0,
    this.taxAmount = 0.0,
    this.orderNumber,
    this.createdOffline = false,
    this.syncedAt,
    this.createdAt,
    this.items = const [],
    this.customerId,
    this.paymentMethod,
    this.paidAmount = 0.0,
    this.cancellationReason,
    this.customer,
    this.buyerProfile,
    this.shippingCost = 0.0,
    this.shippingMethod,
    this.shippingAddress,
    this.currencySymbol,
    this.currencyCode,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // Helper to safely get ID whether it's a String or a nested Map object
    String? extractId(dynamic value) {
      if (value is String) return value;
      if (value is Map) return value['id'] as String?;
      return null;
    }

    return OrderModel(
      id: json['id'] as String,
      offerId: json['offer_id'] as String?,
      sellerCompanyId: extractId(json['seller_company_id']),
      buyerUserId: extractId(json['buyer_user_id']),
      buyerCompanyId: extractId(json['buyer_company_id']),
      guestCustomerName: json['guest_customer_name'] as String?,
      orderType: OrderType.values.firstWhere(
        (e) => e.toString().split('.').last == (json['order_type'] as String? ?? 'pos_sale'),
        orElse: () => OrderType.pos_sale,
      ),
      status: _parseOrderStatus(json['status'] as String?),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.toString().split('.').last == (json['payment_status'] as String? ?? 'paid'),
        orElse: () => PaymentStatus.paid,
      ),
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (json['tax_amount'] as num?)?.toDouble() ?? 0.0,
      orderNumber: json['order_number'] as int?,
      createdOffline: json['created_offline'] as bool? ?? false,
      syncedAt: json['synced_at'] != null ? DateTime.tryParse(json['synced_at']) : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      // Handle both 'items' (if fetched that way) and 'order_items' (standard relation name)
      items:
          (json['order_items'] as List<dynamic>?)?.map((e) => OrderItemModel.fromJson(e)).toList() ??
          (json['items'] as List<dynamic>?)?.map((e) => OrderItemModel.fromJson(e)).toList() ??
          [],
      customerId: extractId(json['customer_id']),
      paymentMethod: json['payment_method'] as String?,
      paidAmount: (json['paid_amount'] as num?)?.toDouble() ?? 0.0,
      cancellationReason: json['cancellation_reason'] as String?,
      customer: json['customers'] as Map<String, dynamic>?,
      buyerProfile: json['buyer_user_id'] is Map ? json['buyer_user_id'] as Map<String, dynamic>? : null,
      shippingCost: (json['shipping_cost'] as num?)?.toDouble() ?? 0.0,
      shippingMethod: json['shipping_method'] as String?,
      shippingAddress: json['shipping_address'] as Map<String, dynamic>?,
      currencySymbol: json['currency_symbol'] as String?,
      currencyCode: json['currency_code'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'seller_company_id': sellerCompanyId,
      'buyer_user_id': buyerUserId,
      'buyer_company_id': buyerCompanyId,
      'guest_customer_name': guestCustomerName,
      'order_type': orderType.toString().split('.').last,
      'status': status.toString().split('.').last,
      'payment_status': paymentStatus.toString().split('.').last,
      'total_amount': totalAmount,
      'discount_amount': discountAmount,
      'tax_amount': taxAmount,
      'order_number': orderNumber,
      'created_offline': createdOffline,
      'synced_at': syncedAt?.toIso8601String(),
      'customer_id': customerId,
      'payment_method': paymentMethod,
      'paid_amount': paidAmount,
      'offer_id': offerId,
      'shipping_cost': shippingCost,
      'shipping_method': shippingMethod,
      'shipping_address': shippingAddress,
      'currency_symbol': currencySymbol,
      'currency_code': currencyCode,
    };
  }

  static OrderStatus _parseOrderStatus(String? status) {
    if (status == null) return OrderStatus.waiting;
    switch (status.toLowerCase()) {
      case 'waiting':
        return OrderStatus.waiting;
      case 'in_progress':
        return OrderStatus.in_progress;
      case 'done':
        return OrderStatus.done;
      case 'completed':
        return OrderStatus.completed; // or map to done if preferred
      case 'cancelled':
      case 'canceled':
        return OrderStatus.cancelled;
      case 'pending':
        return OrderStatus.pending;
      case 'processing':
        return OrderStatus.processing;
      case 'returned':
        return OrderStatus.returned;
      default:
        return OrderStatus.waiting;
    }
  }
}

class OrderItemModel {
  final String id;
  final String? orderId;
  final String? productId;
  final int quantity;
  final double unitPrice;
  final double totalLinePrice;
  final String? productNameSnapshot;
  final List<Map<String, dynamic>> selectedOptions;

  OrderItemModel({
    required this.id,
    this.orderId,
    this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.totalLinePrice,
    this.productNameSnapshot,
    this.selectedOptions = const [],
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as String,
      orderId: json['order_id'] as String?,
      productId: json['product_id'] as String?,
      quantity: json['quantity'] as int? ?? 0,
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
      totalLinePrice: (json['total_line_price'] as num?)?.toDouble() ?? 0.0,
      productNameSnapshot: json['product_name_snapshot'] as String?,
      selectedOptions: (json['selected_options'] as List<dynamic>?)?.map((e) => e as Map<String, dynamic>).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_line_price': totalLinePrice,
      'product_name_snapshot': productNameSnapshot,
      'selected_options': selectedOptions,
    };
  }
}
