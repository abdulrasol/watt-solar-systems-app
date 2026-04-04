class ServiceRequest {
  final int id;
  final int? companyId;
  final String? companyName;
  final String serviceCode;
  final String serviceName;
  final String status;
  final String? requestedBy;
  final String? reviewedBy;
  final String? requestedAt;
  final String? reviewedAt;
  final String? notes;

  ServiceRequest({
    required this.id,
    this.companyId,
    this.companyName,
    required this.serviceCode,
    required this.serviceName,
    required this.status,
    this.requestedBy,
    this.reviewedBy,
    this.requestedAt,
    this.reviewedAt,
    this.notes,
  });

  bool get isActive => status.toLowerCase() == 'active';
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isRejected => status.toLowerCase() == 'rejected';

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    return ServiceRequest(
      id: json['id'],
      companyId: json['company_id'],
      companyName: json['company_name'],
      serviceCode: json['service_code'] ?? '',
      serviceName: json['service_name'] ?? '',
      status: json['status'] ?? 'pending',
      requestedBy: json['requested_by'],
      reviewedBy: json['reviewed_by'],
      requestedAt: json['requested_at'],
      reviewedAt: json['reviewed_at'],
      notes: json['notes'],
    );
  }
}
