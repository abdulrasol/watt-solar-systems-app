class CurrencyModel {
  final String id;
  final String name;
  final String code;
  final String symbol;
  final bool isDefault;
  final DateTime? createdAt;

  CurrencyModel({required this.id, required this.name, required this.code, required this.symbol, this.isDefault = false, this.createdAt});

  factory CurrencyModel.fromJson(Map<String, dynamic> json) {
    return CurrencyModel(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      symbol: json['symbol'] as String,
      isDefault: json['is_default'] as bool? ?? false,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'code': code, 'symbol': symbol, 'is_default': isDefault};
  }

  CurrencyModel copyWith({String? id, String? name, String? code, String? symbol, bool? isDefault, DateTime? createdAt}) {
    return CurrencyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      symbol: symbol ?? this.symbol,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
