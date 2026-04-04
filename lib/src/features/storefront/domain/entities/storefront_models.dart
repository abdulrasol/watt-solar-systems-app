enum StorefrontAudience { b2b, b2c }

enum StorefrontCategoryType { global, internal, company }

class StorefrontCompany {
  final int id;
  final String name;
  final bool allowsB2b;
  final bool allowsB2c;
  final List<StorefrontCategory> companyCategories;

  const StorefrontCompany({
    required this.id,
    required this.name,
    required this.allowsB2b,
    required this.allowsB2c,
    this.companyCategories = const [],
  });

  factory StorefrontCompany.fromJson(Map<String, dynamic> json) {
    return StorefrontCompany(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      allowsB2b: json['allows_b2b'] ?? false,
      allowsB2c: json['allows_b2c'] ?? false,
      companyCategories: (json['company_categories'] as List? ?? const [])
          .whereType<Map>()
          .map(
            (item) =>
                StorefrontCategory.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(),
    );
  }
}

class StorefrontCategory {
  final int id;
  final String name;
  final int? companyId;

  const StorefrontCategory({
    required this.id,
    required this.name,
    this.companyId,
  });

  factory StorefrontCategory.fromJson(Map<String, dynamic> json) {
    return StorefrontCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      companyId: json['company_id'],
    );
  }
}

class StorefrontProductOption {
  final int id;
  final String name;
  final double cost;
  final double retailPrice;
  final double wholesalePrice;
  final bool isRequired;

  const StorefrontProductOption({
    required this.id,
    required this.name,
    required this.cost,
    required this.retailPrice,
    required this.wholesalePrice,
    required this.isRequired,
  });

  factory StorefrontProductOption.fromJson(Map<String, dynamic> json) {
    return StorefrontProductOption(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      cost: (json['cost'] as num?)?.toDouble() ?? 0,
      retailPrice: (json['retail_price'] as num?)?.toDouble() ?? 0,
      wholesalePrice: (json['wholesale_price'] as num?)?.toDouble() ?? 0,
      isRequired: json['is_required'] ?? false,
    );
  }
}

class StorefrontPricingTier {
  final int id;
  final int quantity;
  final double unitPrice;

  const StorefrontPricingTier({
    required this.id,
    required this.quantity,
    required this.unitPrice,
  });

  factory StorefrontPricingTier.fromJson(Map<String, dynamic> json) {
    return StorefrontPricingTier(
      id: json['id'] ?? 0,
      quantity: json['quantity'] ?? 0,
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0,
    );
  }
}

class StorefrontProduct {
  final int id;
  final StorefrontCompany company;
  final String name;
  final String? sku;
  final String? description;
  final StorefrontCategory? globalCategory;
  final List<StorefrontCategory> internalCategories;
  final double retailPrice;
  final double wholesalePrice;
  final double displayPrice;
  final double discount;
  final int stockQuantity;
  final int minStockAlert;
  final bool isAvailable;
  final String status;
  final Map<String, dynamic> specs;
  final List<StorefrontProductOption> options;
  final List<StorefrontPricingTier> pricingTiers;
  final List<String> images;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const StorefrontProduct({
    required this.id,
    required this.company,
    required this.name,
    this.sku,
    this.description,
    this.globalCategory,
    this.internalCategories = const [],
    required this.retailPrice,
    required this.wholesalePrice,
    required this.displayPrice,
    required this.discount,
    required this.stockQuantity,
    required this.minStockAlert,
    required this.isAvailable,
    required this.status,
    this.specs = const {},
    this.options = const [],
    this.pricingTiers = const [],
    this.images = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory StorefrontProduct.fromJson(Map<String, dynamic> json) {
    return StorefrontProduct(
      id: json['id'] ?? 0,
      company: StorefrontCompany.fromJson(
        Map<String, dynamic>.from(json['company'] ?? const <String, dynamic>{}),
      ),
      name: json['name'] ?? '',
      sku: json['sku'],
      description: json['description'],
      globalCategory: json['global_category'] == null
          ? null
          : StorefrontCategory.fromJson(
              Map<String, dynamic>.from(json['global_category']),
            ),
      internalCategories: (json['internal_categories'] as List? ?? const [])
          .whereType<Map>()
          .map(
            (item) =>
                StorefrontCategory.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(),
      retailPrice: (json['retail_price'] as num?)?.toDouble() ?? 0,
      wholesalePrice: (json['wholesale_price'] as num?)?.toDouble() ?? 0,
      displayPrice: (json['display_price'] as num?)?.toDouble() ?? 0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
      stockQuantity: json['stock_quantity'] ?? 0,
      minStockAlert: json['min_stock_alert'] ?? 0,
      isAvailable: json['is_available'] ?? false,
      status: json['status'] ?? 'inactive',
      specs: json['specs'] == null
          ? const {}
          : Map<String, dynamic>.from(json['specs']),
      options: (json['options'] as List? ?? const [])
          .whereType<Map>()
          .map(
            (item) => StorefrontProductOption.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
      pricingTiers: (json['pricing_tiers'] as List? ?? const [])
          .whereType<Map>()
          .map(
            (item) =>
                StorefrontPricingTier.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(),
      images: List<String>.from(json['images'] as List? ?? const []),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  String? get primaryImage => images.isEmpty ? null : images.first;

  String get categoryLabel {
    if (globalCategory != null) return globalCategory!.name;
    if (internalCategories.isNotEmpty) return internalCategories.first.name;
    if (company.companyCategories.isNotEmpty) {
      return company.companyCategories.first.name;
    }
    return '';
  }
}

class StorefrontMeta {
  final List<StorefrontCompany> companies;
  final List<StorefrontCategory> globalCategories;
  final List<StorefrontCategory> internalCategories;
  final List<StorefrontCategory> companyCategories;

  const StorefrontMeta({
    this.companies = const [],
    this.globalCategories = const [],
    this.internalCategories = const [],
    this.companyCategories = const [],
  });

  factory StorefrontMeta.fromJson(Map<String, dynamic> json) {
    return StorefrontMeta(
      companies: (json['companies'] as List? ?? const [])
          .whereType<Map>()
          .map(
            (item) =>
                StorefrontCompany.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(),
      globalCategories: (json['global_categories'] as List? ?? const [])
          .whereType<Map>()
          .map(
            (item) =>
                StorefrontCategory.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(),
      internalCategories: (json['internal_categories'] as List? ?? const [])
          .whereType<Map>()
          .map(
            (item) =>
                StorefrontCategory.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(),
      companyCategories: (json['company_categories'] as List? ?? const [])
          .whereType<Map>()
          .map(
            (item) =>
                StorefrontCategory.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(),
    );
  }

  static const empty = StorefrontMeta();

  List<StorefrontCategory> categoriesForType(StorefrontCategoryType? type) {
    switch (type) {
      case StorefrontCategoryType.global:
        return globalCategories;
      case StorefrontCategoryType.internal:
        return internalCategories;
      case StorefrontCategoryType.company:
        return companyCategories;
      case null:
        return const [];
    }
  }
}

class StorefrontQuery {
  final int page;
  final int pageSize;
  final String search;
  final int? companyId;
  final int? categoryId;
  final int? globalCategoryId;
  final int? internalCategoryId;
  final int? companyCategoryId;
  final double? minPrice;
  final double? maxPrice;
  final bool? isAvailable;
  final String? status;
  final String ordering;

  const StorefrontQuery({
    this.page = 1,
    this.pageSize = 12,
    this.search = '',
    this.companyId,
    this.categoryId,
    this.globalCategoryId,
    this.internalCategoryId,
    this.companyCategoryId,
    this.minPrice,
    this.maxPrice,
    this.isAvailable,
    this.status,
    this.ordering = '-created_at',
  });

  StorefrontQuery copyWith({
    int? page,
    int? pageSize,
    String? search,
    int? companyId,
    bool clearCompanyId = false,
    int? categoryId,
    bool clearCategoryId = false,
    int? globalCategoryId,
    bool clearGlobalCategoryId = false,
    int? internalCategoryId,
    bool clearInternalCategoryId = false,
    int? companyCategoryId,
    bool clearCompanyCategoryId = false,
    double? minPrice,
    bool clearMinPrice = false,
    double? maxPrice,
    bool clearMaxPrice = false,
    bool? isAvailable,
    bool clearAvailability = false,
    String? status,
    bool clearStatus = false,
    String? ordering,
  }) {
    return StorefrontQuery(
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      search: search ?? this.search,
      companyId: clearCompanyId ? null : (companyId ?? this.companyId),
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      globalCategoryId: clearGlobalCategoryId
          ? null
          : (globalCategoryId ?? this.globalCategoryId),
      internalCategoryId: clearInternalCategoryId
          ? null
          : (internalCategoryId ?? this.internalCategoryId),
      companyCategoryId: clearCompanyCategoryId
          ? null
          : (companyCategoryId ?? this.companyCategoryId),
      minPrice: clearMinPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
      isAvailable: clearAvailability ? null : (isAvailable ?? this.isAvailable),
      status: clearStatus ? null : (status ?? this.status),
      ordering: ordering ?? this.ordering,
    );
  }

  Map<String, dynamic> toQueryParameters() {
    return {
      'page': page,
      'page_size': pageSize,
      if (search.trim().isNotEmpty) 'search': search.trim(),
      if (companyId != null) 'company_id': companyId,
      if (categoryId != null) 'category_id': categoryId,
      if (globalCategoryId != null) 'global_category_id': globalCategoryId,
      if (internalCategoryId != null)
        'internal_category_id': internalCategoryId,
      if (companyCategoryId != null) 'company_category_id': companyCategoryId,
      if (minPrice != null) 'min_price': minPrice,
      if (maxPrice != null) 'max_price': maxPrice,
      if (isAvailable != null) 'is_available': isAvailable,
      if (status != null && status!.isNotEmpty) 'status': status,
      'ordering': ordering,
    };
  }

  StorefrontQuery resetPage() => copyWith(page: 1);
}
