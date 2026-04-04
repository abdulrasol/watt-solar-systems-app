class CompanyService {
  final String serviceCode;
  final String serviceName;
  final String? status;
  final bool isAutoEnabled;
  final List<dynamic> autoEnabledBy;
  final int? subscriptionId;
  final String? requestedAt;
  final String? approvedAt;
  final String? activatedAt;
  final String? startsAt;
  final String? endsAt;
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
    this.meta = const {},
    this.route,
    this.icon,
  });

  bool get isActive => status?.toLowerCase() == 'active';
  bool get isPending => status?.toLowerCase() == 'pending';
  bool get isRejected => status?.toLowerCase() == 'rejected';
  bool get isSuspended => status?.toLowerCase() == 'suspended';
  bool get isCancelled => status?.toLowerCase() == 'cancelled';

  factory CompanyService.fromJson(Map<String, dynamic> json) {
    return CompanyService(
      serviceCode: json['service_code'] ?? '',
      serviceName: json['service_name'] ?? '',
      status: json['status'],
      isAutoEnabled: json['is_auto_enabled'] ?? false,
      autoEnabledBy: json['auto_enabled_by'] ?? [],
      subscriptionId: json['subscription_id'],
      requestedAt: json['requested_at'],
      approvedAt: json['approved_at'],
      activatedAt: json['activated_at'],
      startsAt: json['starts_at'],
      endsAt: json['ends_at'],
      notes: json['notes'],
      meta: json['meta'] ?? {},
      route: json['route'],
      icon: json['icon'],
    );
  }
}
