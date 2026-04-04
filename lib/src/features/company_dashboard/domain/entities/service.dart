class CompanyService {
  final String serviceCode;
  final String serviceName;
  final String? status;
  final bool isAutoEnabled;
  final List<dynamic> autoEnabledBy;
  final int? subscriptionId;
  final DateTime? requestedAt;
  final DateTime? approvedAt;
  final DateTime? activatedAt;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final String? notes;
  final Map<String, dynamic> meta;
  final String? route;
  final String? icon;

  CompanyService({
    required this.serviceCode,
    required this.serviceName,
    this.status,
    required this.isAutoEnabled,
    required this.autoEnabledBy,
    this.subscriptionId,
    this.requestedAt,
    this.approvedAt,
    this.activatedAt,
    this.startsAt,
    this.endsAt,
    this.notes,
    required this.meta,
    this.route,
    this.icon,
  });

  factory CompanyService.fromJson(Map<String, dynamic> json) {
    return CompanyService(
      serviceCode: json['service_code'] ?? '',
      serviceName: json['service_name'] ?? '',
      status: json['status'],
      isAutoEnabled: json['is_auto_enabled'] ?? false,
      autoEnabledBy: json['auto_enabled_by'] ?? [],
      subscriptionId: json['subscription_id'],
      requestedAt: json['requested_at'] != null
          ? DateTime.tryParse(json['requested_at'])
          : null,
      approvedAt: json['approved_at'] != null
          ? DateTime.tryParse(json['approved_at'])
          : null,
      activatedAt: json['activated_at'] != null
          ? DateTime.tryParse(json['activated_at'])
          : null,
      startsAt: json['starts_at'] != null
          ? DateTime.tryParse(json['starts_at'])
          : null,
      endsAt: json['ends_at'] != null
          ? DateTime.tryParse(json['ends_at'])
          : null,
      notes: json['notes'],
      meta: json['meta'] ?? {},
      route: json['route'],
      icon: json['icon'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'service_code': serviceCode,
      'service_name': serviceName,
      'status': status,
      'is_auto_enabled': isAutoEnabled,
      'auto_enabled_by': autoEnabledBy,
      'subscription_id': subscriptionId,
      'requested_at': requestedAt?.toIso8601String(),
      'approved_at': approvedAt?.toIso8601String(),
      'activated_at': activatedAt?.toIso8601String(),
      'starts_at': startsAt?.toIso8601String(),
      'ends_at': endsAt?.toIso8601String(),
      'notes': notes,
      'meta': meta,
      'route': route,
      'icon': icon,
    };
  }
}
