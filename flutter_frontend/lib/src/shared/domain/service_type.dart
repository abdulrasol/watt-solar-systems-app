class ServiceType {
  final int id;
  final String name;
  final String? description;
  final String? image;
  final int companiesCount;
  final bool isServed;

  const ServiceType({
    required this.id,
    required this.name,
    this.description,
    this.image,
    this.companiesCount = 0,
    this.isServed = false,
  });

  factory ServiceType.fromJson(Map<String, dynamic> json) {
    return ServiceType(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      image: json['image']?.toString(),
      companiesCount:
          int.tryParse(json['companies_count']?.toString() ?? '') ?? 0,
      isServed: json['is_served'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'companies_count': companiesCount,
      'is_served': isServed,
    };
  }

  ServiceType copyWith({
    int? id,
    String? name,
    String? description,
    String? image,
    int? companiesCount,
    bool? isServed,
  }) {
    return ServiceType(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      image: image ?? this.image,
      companiesCount: companiesCount ?? this.companiesCount,
      isServed: isServed ?? this.isServed,
    );
  }
}
