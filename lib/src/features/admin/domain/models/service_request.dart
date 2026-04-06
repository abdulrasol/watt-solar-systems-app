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
  bool get isSuspended => status.toLowerCase() == 'suspended';
  bool get isCancelled => status.toLowerCase() == 'cancelled';

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'company_name': companyName,
      'service_code': serviceCode,
      'service_name': serviceName,
      'status': status,
      'requested_by': requestedBy,
      'reviewed_by': reviewedBy,
      'requested_at': requestedAt,
      'reviewed_at': reviewedAt,
      'notes': notes,
    };
  }

  ServiceRequest copyWith({
    int? id,
    int? companyId,
    String? companyName,
    String? serviceCode,
    String? serviceName,
    String? status,
    String? requestedBy,
    String? reviewedBy,
    String? requestedAt,
    String? reviewedAt,
    String? notes,
  }) {
    return ServiceRequest(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      companyName: companyName ?? this.companyName,
      serviceCode: serviceCode ?? this.serviceCode,
      serviceName: serviceName ?? this.serviceName,
      status: status ?? this.status,
      requestedBy: requestedBy ?? this.requestedBy,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      requestedAt: requestedAt ?? this.requestedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      notes: notes ?? this.notes,
    );
  }
}
