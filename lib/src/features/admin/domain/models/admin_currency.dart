class AdminCurrency {
  final int id;
  final String name;
  final String code;
  final String symbol;
  final bool isDefault;
  final DateTime createdAt;

  const AdminCurrency({
    required this.id,
    required this.name,
    required this.code,
    required this.symbol,
    required this.isDefault,
    required this.createdAt,
  });

  factory AdminCurrency.fromJson(Map<String, dynamic> json) {
    return AdminCurrency(
      id: json['id'] as int? ?? 0,
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      symbol: json['symbol']?.toString() ?? '',
      isDefault: json['is_default'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'symbol': symbol,
      'is_default': isDefault,
      'created_at': createdAt.toIso8601String(),
    };
  }

  AdminCurrency copyWith({
    int? id,
    String? name,
    String? code,
    String? symbol,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return AdminCurrency(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      symbol: symbol ?? this.symbol,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
