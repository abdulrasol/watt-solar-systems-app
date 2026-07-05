class CompanyService {
  final int id;
  final String title;
  final double price;
  final String? description;
  final int? companyId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CompanyService({
    required this.id,
    required this.title,
    required this.price,
    this.description,
    this.companyId,
    this.createdAt,
    this.updatedAt,
  });

  factory CompanyService.fromJson(Map<String, dynamic> json) {
    return CompanyService(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: json['title']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      description: json['description']?.toString(),
      companyId: int.tryParse(json['company']?.toString() ?? ''),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'description': description,
      'company': companyId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
