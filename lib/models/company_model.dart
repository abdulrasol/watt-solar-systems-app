import 'package:solar_hub/models/enums.dart';

class CompanyModel {
  final String id;
  final String name;
  final CompanyTier tier;
  final String? description;
  final String? logoUrl;
  final String? address;
  final String? contactPhone;
  final String? currencyId;
  final double balance;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool allowsB2B;
  final bool allowsB2C;

  CompanyModel({
    required this.id,
    required this.name,
    this.tier = CompanyTier.intermediary,
    this.description,
    this.logoUrl,
    this.address,
    this.contactPhone,
    this.currencyId,
    this.balance = 0.0,
    this.status = 'active', // Default to active for backward compatibility
    this.createdAt,
    this.updatedAt,
    this.allowsB2B = true,
    this.allowsB2C = true,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id'] as String,
      name: json['name'] as String,
      tier: CompanyTier.values.firstWhere(
        (e) => e.toString().split('.').last == (json['tier'] as String? ?? 'intermediary'),
        orElse: () => CompanyTier.intermediary,
      ),
      description: json['description'] as String?,
      logoUrl: json['logo_url'] as String?,
      address: json['address'] as String?,
      contactPhone: json['contact_phone'] as String?,
      currencyId: json['currency_id'] as String?,
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'active',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
      allowsB2B: json['allows_b2b'] as bool? ?? true,
      allowsB2C: json['allows_b2c'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'tier': tier.toString().split('.').last,
      'description': description,
      'logo_url': logoUrl,
      'address': address,
      'contact_phone': contactPhone,
      'currency_id': currencyId,
      'balance': balance,
      'status': status,
      'allows_b2b': allowsB2B,
      'allows_b2c': allowsB2C,
    };
  }

  CompanyModel copyWith({
    String? id,
    String? name,
    CompanyTier? tier,
    String? description,
    String? logoUrl,
    String? address,
    String? contactPhone,
    String? currencyId,
    double? balance,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? allowsB2B,
    bool? allowsB2C,
  }) {
    return CompanyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      tier: tier ?? this.tier,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      address: address ?? this.address,
      contactPhone: contactPhone ?? this.contactPhone,
      currencyId: currencyId ?? this.currencyId,
      balance: balance ?? this.balance,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      allowsB2B: allowsB2B ?? this.allowsB2B,
      allowsB2C: allowsB2C ?? this.allowsB2C,
    );
  }
}
