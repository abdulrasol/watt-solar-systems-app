class CompanyServiceRequest {
  final int? id;
  final String serviceCode;
  final String status;
  final String? notes;
  final String? imageUrl;
  final String? createdAt;

  CompanyServiceRequest({
    this.id,
    required this.serviceCode,
    required this.status,
    this.notes,
    this.imageUrl,
    this.createdAt,
  });

  factory CompanyServiceRequest.fromJson(Map<String, dynamic> json) {
    return CompanyServiceRequest(
      id: json['id'],
      serviceCode: json['service_code'] ?? '',
      status: json['status'] ?? 'pending',
      notes: json['notes'],
      imageUrl: json['image'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_code': serviceCode,
      'status': status,
      'notes': notes,
      'image': imageUrl,
      'created_at': createdAt,
    };
  }
}
