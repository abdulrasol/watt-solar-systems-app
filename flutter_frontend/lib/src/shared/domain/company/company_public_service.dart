class CompanyPublicService {
  final int id;
  final String title;
  final num? price;
  final String? description;
  final int? company;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CompanyPublicService({
    required this.id,
    required this.title,
    this.price,
    this.description,
    this.company,
    this.createdAt,
    this.updatedAt,
  });

  factory CompanyPublicService.fromJson(Map<String, dynamic> json) {
    return CompanyPublicService(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: json['title']?.toString() ?? '',
      price: json['price'] as num?,
      description: json['description']?.toString(),
      company: int.tryParse(json['company']?.toString() ?? ''),
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
      'company': company,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  CompanyPublicService copyWith({
    int? id,
    String? title,
    num? price,
    String? description,
    int? company,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CompanyPublicService(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      description: description ?? this.description,
      company: company ?? this.company,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
