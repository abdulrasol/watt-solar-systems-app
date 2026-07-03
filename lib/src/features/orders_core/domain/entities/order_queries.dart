class OrderListQuery {
  final int page;
  final int pageSize;
  final String? status;
  final String? paymentStatus;
  final String? paymentMethod;
  final String? orderType;
  final String? customerType;
  final String? search;
  final String? dateFrom;
  final String? dateTo;
  final String ordering;

  const OrderListQuery({
    this.page = 1,
    this.pageSize = 12,
    this.status,
    this.paymentStatus,
    this.paymentMethod,
    this.orderType,
    this.customerType,
    this.search,
    this.dateFrom,
    this.dateTo,
    this.ordering = '-created_at',
  });

  Map<String, dynamic> toQueryParameters() {
    return {
      'page': page,
      'page_size': pageSize,
      'status': status,
      'payment_status': paymentStatus,
      'payment_method': paymentMethod,
      'order_type': orderType,
      'customer_type': customerType,
      'search': search,
      'date_from': dateFrom,
      'date_to': dateTo,
      'ordering': ordering,
    }..removeWhere((key, value) => value == null || value == '');
  }

  OrderListQuery copyWith({
    int? page,
    int? pageSize,
    String? status,
    String? paymentStatus,
    String? paymentMethod,
    String? orderType,
    String? customerType,
    String? search,
    String? dateFrom,
    String? dateTo,
    String? ordering,
    bool clearStatus = false,
    bool clearPaymentStatus = false,
    bool clearPaymentMethod = false,
    bool clearOrderType = false,
    bool clearCustomerType = false,
    bool clearSearch = false,
    bool clearDateFrom = false,
    bool clearDateTo = false,
  }) {
    return OrderListQuery(
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      status: clearStatus ? null : (status ?? this.status),
      paymentStatus: clearPaymentStatus
          ? null
          : (paymentStatus ?? this.paymentStatus),
      paymentMethod: clearPaymentMethod
          ? null
          : (paymentMethod ?? this.paymentMethod),
      orderType: clearOrderType ? null : (orderType ?? this.orderType),
      customerType: clearCustomerType
          ? null
          : (customerType ?? this.customerType),
      search: clearSearch ? null : (search ?? this.search),
      dateFrom: clearDateFrom ? null : (dateFrom ?? this.dateFrom),
      dateTo: clearDateTo ? null : (dateTo ?? this.dateTo),
      ordering: ordering ?? this.ordering,
    );
  }
}
