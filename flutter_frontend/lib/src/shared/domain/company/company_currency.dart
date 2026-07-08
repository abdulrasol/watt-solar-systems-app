class CompanyCurrency {
  final int id;
  final String name;
  final String code;
  final String? symbol;
  final bool isDefault;
  final DateTime? createdAt;

  const CompanyCurrency({
    required this.id,
    required this.name,
    required this.code,
    this.symbol,
    required this.isDefault,
    this.createdAt,
  });

  factory CompanyCurrency.fromJson(Map<String, dynamic> json) {
    return CompanyCurrency(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      symbol: json['symbol']?.toString(),
      isDefault: json['is_default'] == true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'symbol': symbol,
      'is_default': isDefault,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  CompanyCurrency copyWith({
    int? id,
    String? name,
    String? code,
    String? symbol,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return CompanyCurrency(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      symbol: symbol ?? this.symbol,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
