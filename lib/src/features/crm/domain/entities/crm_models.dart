class CustomerQuery {
  final int page;
  final int pageSize;
  final String? customerType;
  final String? search;
  final String ordering;

  const CustomerQuery({
    this.page = 1,
    this.pageSize = 12,
    this.customerType,
    this.search,
    this.ordering = '-created_at',
  });

  Map<String, dynamic> toQueryParameters() {
    return {
      'page': page,
      'page_size': pageSize,
      'customer_type': customerType,
      'search': search,
      'ordering': ordering,
    }..removeWhere((key, value) => value == null || value == '');
  }

  CustomerQuery copyWith({
    int? page,
    int? pageSize,
    String? customerType,
    String? search,
    String? ordering,
    bool clearCustomerType = false,
    bool clearSearch = false,
  }) {
    return CustomerQuery(
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      customerType: clearCustomerType
          ? null
          : (customerType ?? this.customerType),
      search: clearSearch ? null : (search ?? this.search),
      ordering: ordering ?? this.ordering,
    );
  }
}

class SupplierQuery {
  final int page;
  final int pageSize;
  final String? supplierType;
  final String? search;
  final String ordering;

  const SupplierQuery({
    this.page = 1,
    this.pageSize = 12,
    this.supplierType,
    this.search,
    this.ordering = '-created_at',
  });

  Map<String, dynamic> toQueryParameters() {
    return {
      'page': page,
      'page_size': pageSize,
      'supplier_type': supplierType,
      'search': search,
      'ordering': ordering,
    }..removeWhere((key, value) => value == null || value == '');
  }

  SupplierQuery copyWith({
    int? page,
    int? pageSize,
    String? supplierType,
    String? search,
    String? ordering,
    bool clearSupplierType = false,
    bool clearSearch = false,
  }) {
    return SupplierQuery(
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      supplierType: clearSupplierType
          ? null
          : (supplierType ?? this.supplierType),
      search: clearSearch ? null : (search ?? this.search),
      ordering: ordering ?? this.ordering,
    );
  }
}

class CustomerWriteRequest {
  final String customerType;
  final String fullName;
  final String? phoneNumber;
  final String? email;
  final String? address;

  const CustomerWriteRequest({
    required this.customerType,
    required this.fullName,
    this.phoneNumber,
    this.email,
    this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'customer_type': customerType,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'email': email,
      'address': address,
    }..removeWhere((key, value) => value == null);
  }
}

class SupplierWriteRequest {
  final String supplierType;
  final String fullName;
  final String? phoneNumber;
  final String? email;
  final String? address;

  const SupplierWriteRequest({
    required this.supplierType,
    required this.fullName,
    this.phoneNumber,
    this.email,
    this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'supplier_type': supplierType,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'email': email,
      'address': address,
    }..removeWhere((key, value) => value == null);
  }
}
