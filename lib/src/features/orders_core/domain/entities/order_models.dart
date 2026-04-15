import 'package:solar_hub/src/features/storefront/domain/entities/storefront_cart.dart';

enum OrderAudience { b2c, b2b }

enum OrderStatus {
  pending,
  processing,
  shipped,
  delivered,
  cancelled,
  completed,
}

class OrderCity {
  final int id;
  final String name;
  final String? code;

  const OrderCity({required this.id, required this.name, this.code});

  factory OrderCity.fromJson(Map<String, dynamic> json) {
    return OrderCity(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString(),
    );
  }
}

class OrderParty {
  final String type;
  final int id;
  final String name;
  final String? phone;
  final String? email;
  final OrderCity? city;
  final String? address;

  const OrderParty({
    required this.type,
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.city,
    this.address,
  });

  factory OrderParty.fromJson(Map<String, dynamic> json) {
    return OrderParty(
      type: json['type']?.toString() ?? '',
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      city: json['city'] is Map<String, dynamic>
          ? OrderCity.fromJson(json['city'] as Map<String, dynamic>)
          : null,
      address: json['address']?.toString(),
    );
  }
}

class OrderCounterparty {
  final int id;
  final String type;
  final String name;

  const OrderCounterparty({
    required this.id,
    required this.type,
    required this.name,
  });

  factory OrderCounterparty.fromJson(Map<String, dynamic> json) {
    return OrderCounterparty(
      id: json['id'] ?? 0,
      type: json['type']?.toString() ?? '',
      name: json['name']?.toString() ?? json['full_name']?.toString() ?? '',
    );
  }
}

class CustomerRecord {
  final int id;
  final String customerType;
  final String fullName;
  final String? phoneNumber;
  final String? email;
  final String? address;
  final OrderCounterparty? buyerCompany;
  final OrderParty? buyerProfile;
  final double totalSales;
  final double totalPaid;
  final double balance;
  final DateTime? lastPaymentDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CustomerRecord({
    required this.id,
    required this.customerType,
    required this.fullName,
    this.phoneNumber,
    this.email,
    this.address,
    this.buyerCompany,
    this.buyerProfile,
    required this.totalSales,
    required this.totalPaid,
    required this.balance,
    this.lastPaymentDate,
    this.createdAt,
    this.updatedAt,
  });

  factory CustomerRecord.fromJson(Map<String, dynamic> json) {
    return CustomerRecord(
      id: json['id'] ?? 0,
      customerType: json['customer_type']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString(),
      email: json['email']?.toString(),
      address: json['address']?.toString(),
      buyerCompany: json['buyer_company'] is Map<String, dynamic>
          ? OrderCounterparty.fromJson(
              json['buyer_company'] as Map<String, dynamic>,
            )
          : null,
      buyerProfile: json['buyer_profile'] is Map<String, dynamic>
          ? OrderParty.fromJson(json['buyer_profile'] as Map<String, dynamic>)
          : null,
      totalSales: (json['total_sales'] as num?)?.toDouble() ?? 0,
      totalPaid: (json['total_paid'] as num?)?.toDouble() ?? 0,
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
      lastPaymentDate: DateTime.tryParse(
        json['last_payment_date']?.toString() ?? '',
      ),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
    );
  }
}

class SupplierRecord {
  final int id;
  final String supplierType;
  final String fullName;
  final String? phoneNumber;
  final String? email;
  final String? address;
  final OrderCounterparty? sellerCompany;
  final double totalPurchases;
  final double totalPaid;
  final double balance;
  final DateTime? lastPaymentDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SupplierRecord({
    required this.id,
    required this.supplierType,
    required this.fullName,
    this.phoneNumber,
    this.email,
    this.address,
    this.sellerCompany,
    required this.totalPurchases,
    required this.totalPaid,
    required this.balance,
    this.lastPaymentDate,
    this.createdAt,
    this.updatedAt,
  });

  factory SupplierRecord.fromJson(Map<String, dynamic> json) {
    return SupplierRecord(
      id: json['id'] ?? 0,
      supplierType: json['supplier_type']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString(),
      email: json['email']?.toString(),
      address: json['address']?.toString(),
      sellerCompany: json['seller_company'] is Map<String, dynamic>
          ? OrderCounterparty.fromJson(
              json['seller_company'] as Map<String, dynamic>,
            )
          : null,
      totalPurchases: (json['total_purchases'] as num?)?.toDouble() ?? 0,
      totalPaid: (json['total_paid'] as num?)?.toDouble() ?? 0,
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
      lastPaymentDate: DateTime.tryParse(
        json['last_payment_date']?.toString() ?? '',
      ),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
    );
  }
}

class OrderItemRecord {
  final int id;
  final int productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double totalLinePrice;
  final List<dynamic> selectedOptions;

  const OrderItemRecord({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalLinePrice,
    this.selectedOptions = const [],
  });

  factory OrderItemRecord.fromJson(Map<String, dynamic> json) {
    return OrderItemRecord(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? 0,
      productName: json['product_name']?.toString() ?? '',
      quantity: json['quantity'] ?? 0,
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0,
      totalLinePrice: (json['total_line_price'] as num?)?.toDouble() ?? 0,
      selectedOptions: (json['selected_options'] as List?) ?? const [],
    );
  }
}

class OrderRecord {
  final int id;
  final int orderNumber;
  final String orderType;
  final String status;
  final String paymentStatus;
  final String paymentMethod;
  final OrderParty sellerParty;
  final OrderParty buyerParty;
  final CustomerRecord? customer;
  final SupplierRecord? supplier;
  final double totalAmount;
  final double discountAmount;
  final double taxAmount;
  final double paidAmount;
  final double shippingCost;
  final String? shippingMethod;
  final Map<String, dynamic>? shippingAddress;
  final String? cancellationReason;
  final String? currencyCode;
  final String? currencySymbol;
  final bool buyerReceiptConfirmed;
  final DateTime? buyerReceiptConfirmedAt;
  final DateTime? fulfilledAt;
  final DateTime? stockTransferredAt;
  final List<OrderItemRecord> items;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const OrderRecord({
    required this.id,
    required this.orderNumber,
    required this.orderType,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.sellerParty,
    required this.buyerParty,
    this.customer,
    this.supplier,
    required this.totalAmount,
    required this.discountAmount,
    required this.taxAmount,
    required this.paidAmount,
    required this.shippingCost,
    this.shippingMethod,
    this.shippingAddress,
    this.cancellationReason,
    this.currencyCode,
    this.currencySymbol,
    required this.buyerReceiptConfirmed,
    this.buyerReceiptConfirmedAt,
    this.fulfilledAt,
    this.stockTransferredAt,
    this.items = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory OrderRecord.fromJson(Map<String, dynamic> json) {
    return OrderRecord(
      id: json['id'] ?? 0,
      orderNumber: json['order_number'] ?? 0,
      orderType: json['order_type']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      paymentStatus: json['payment_status']?.toString() ?? '',
      paymentMethod: json['payment_method']?.toString() ?? '',
      sellerParty: OrderParty.fromJson(
        Map<String, dynamic>.from(
          json['seller_party'] ?? const <String, dynamic>{},
        ),
      ),
      buyerParty: OrderParty.fromJson(
        Map<String, dynamic>.from(
          json['buyer_party'] ?? const <String, dynamic>{},
        ),
      ),
      customer: json['customer'] is Map<String, dynamic>
          ? CustomerRecord.fromJson(json['customer'] as Map<String, dynamic>)
          : null,
      supplier: json['supplier'] is Map<String, dynamic>
          ? SupplierRecord.fromJson(json['supplier'] as Map<String, dynamic>)
          : null,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0,
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0,
      taxAmount: (json['tax_amount'] as num?)?.toDouble() ?? 0,
      paidAmount: (json['paid_amount'] as num?)?.toDouble() ?? 0,
      shippingCost: (json['shipping_cost'] as num?)?.toDouble() ?? 0,
      shippingMethod: json['shipping_method']?.toString(),
      shippingAddress: json['shipping_address'] is Map
          ? Map<String, dynamic>.from(json['shipping_address'] as Map)
          : null,
      cancellationReason: json['cancellation_reason']?.toString(),
      currencyCode: json['currency_code']?.toString(),
      currencySymbol: json['currency_symbol']?.toString(),
      buyerReceiptConfirmed: json['buyer_receipt_confirmed'] == true,
      buyerReceiptConfirmedAt: DateTime.tryParse(
        json['buyer_receipt_confirmed_at']?.toString() ?? '',
      ),
      fulfilledAt: DateTime.tryParse(json['fulfilled_at']?.toString() ?? ''),
      stockTransferredAt: DateTime.tryParse(
        json['stock_transferred_at']?.toString() ?? '',
      ),
      items: (json['items'] as List? ?? const [])
          .whereType<Map>()
          .map(
            (item) => OrderItemRecord.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
    );
  }

  bool get isB2b => orderType == 'b2b';
  bool get canConfirmReceipt =>
      isB2b && status == 'delivered' && !buyerReceiptConfirmed;
  bool get canCancel => !const {'cancelled', 'completed'}.contains(status);
}

class OrderItemCreateRequest {
  final int productId;
  final int quantity;

  const OrderItemCreateRequest({
    required this.productId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {'product_id': productId, 'quantity': quantity};
  }

  factory OrderItemCreateRequest.fromCartItem(StorefrontCartItem item) {
    return OrderItemCreateRequest(
      productId: item.productId,
      quantity: item.quantity,
    );
  }
}

abstract class BaseOrderCreateRequest {
  final int sellerCompanyId;
  final List<OrderItemCreateRequest> items;
  final String paymentMethod;
  final double shippingCost;
  final String? shippingMethod;
  final Map<String, dynamic>? shippingAddress;
  final double discountAmount;
  final double taxAmount;
  final String? currencyCode;
  final String? currencySymbol;

  const BaseOrderCreateRequest({
    required this.sellerCompanyId,
    required this.items,
    required this.paymentMethod,
    this.shippingCost = 0,
    this.shippingMethod,
    this.shippingAddress,
    this.discountAmount = 0,
    this.taxAmount = 0,
    this.currencyCode,
    this.currencySymbol,
  });

  Map<String, dynamic> toJson() {
    return {
      'seller_company_id': sellerCompanyId,
      'items': items.map((e) => e.toJson()).toList(),
      'payment_method': paymentMethod,
      'shipping_cost': shippingCost,
      'shipping_method': shippingMethod,
      'shipping_address': shippingAddress,
      'discount_amount': discountAmount,
      'tax_amount': taxAmount,
      'currency_code': currencyCode,
      'currency_symbol': currencySymbol,
    }..removeWhere((key, value) => value == null);
  }
}

class B2cOrderCreateRequest extends BaseOrderCreateRequest {
  const B2cOrderCreateRequest({
    required super.sellerCompanyId,
    required super.items,
    super.paymentMethod = 'cash',
    super.shippingCost,
    super.shippingMethod,
    super.shippingAddress,
    super.discountAmount,
    super.taxAmount,
    super.currencyCode,
    super.currencySymbol,
  });

  factory B2cOrderCreateRequest.fromCompanyCart(StorefrontCompanyCart cart) {
    return B2cOrderCreateRequest(
      sellerCompanyId: cart.companyId,
      items: cart.items.map(OrderItemCreateRequest.fromCartItem).toList(),
    );
  }
}

class B2bOrderCreateRequest extends BaseOrderCreateRequest {
  final String? dueDate;

  const B2bOrderCreateRequest({
    required super.sellerCompanyId,
    required super.items,
    super.paymentMethod = 'credit',
    super.shippingCost,
    super.shippingMethod,
    super.shippingAddress,
    super.discountAmount,
    super.taxAmount,
    super.currencyCode,
    super.currencySymbol,
    this.dueDate,
  });

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    if (dueDate != null) data['due_date'] = dueDate;
    return data;
  }

  factory B2bOrderCreateRequest.fromCompanyCart(StorefrontCompanyCart cart) {
    return B2bOrderCreateRequest(
      sellerCompanyId: cart.companyId,
      items: cart.items.map(OrderItemCreateRequest.fromCartItem).toList(),
    );
  }
}

class SellerOrderUpdateRequest {
  final String? status;
  final double? shippingCost;
  final String? shippingMethod;
  final Map<String, dynamic>? shippingAddress;
  final String? cancellationReason;
  final double? paidAmount;

  const SellerOrderUpdateRequest({
    this.status,
    this.shippingCost,
    this.shippingMethod,
    this.shippingAddress,
    this.cancellationReason,
    this.paidAmount,
  });

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'shipping_cost': shippingCost,
      'shipping_method': shippingMethod,
      'shipping_address': shippingAddress,
      'cancellation_reason': cancellationReason,
      'paid_amount': paidAmount,
    }..removeWhere((key, value) => value == null);
  }
}
