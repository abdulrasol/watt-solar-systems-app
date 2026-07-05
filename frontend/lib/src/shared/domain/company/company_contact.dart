class CompanyContact {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String? notes;
  final int? company;
  final DateTime? createdAt;

  const CompanyContact({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.notes,
    this.company,
    this.createdAt,
  });

  factory CompanyContact.fromJson(Map<String, dynamic> json) {
    return CompanyContact(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      notes: json['notes']?.toString(),
      company: int.tryParse(json['company']?.toString() ?? ''),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'notes': notes,
      'company': company,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  CompanyContact copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? notes,
    int? company,
    DateTime? createdAt,
  }) {
    return CompanyContact(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      notes: notes ?? this.notes,
      company: company ?? this.company,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
