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

  Map<String, dynamic> toJson() {
    return {
      'service_code': serviceCode,
      'service_name': serviceName,
      'status': status,
      'is_auto_enabled': isAutoEnabled,
      'auto_enabled_by': autoEnabledBy,
      'subscription_id': subscriptionId,
      'requested_at': requestedAt,
      'approved_at': approvedAt,
      'activated_at': activatedAt,
      'starts_at': startsAt,
      'ends_at': endsAt,
      'notes': notes,
      'meta': meta,
      'route': route,
      'icon': icon,
    };
  }

  CompanyService copyWith({
    String? serviceCode,
    String? serviceName,
    String? status,
    bool? isAutoEnabled,
    List<dynamic>? autoEnabledBy,
    int? subscriptionId,
    String? requestedAt,
    String? approvedAt,
    String? activatedAt,
    String? startsAt,
    String? endsAt,
    String? notes,
    Map<String, dynamic>? meta,
    String? route,
    String? icon,
  }) {
    return CompanyService(
      serviceCode: serviceCode ?? this.serviceCode,
      serviceName: serviceName ?? this.serviceName,
      status: status ?? this.status,
      isAutoEnabled: isAutoEnabled ?? this.isAutoEnabled,
      autoEnabledBy: autoEnabledBy ?? this.autoEnabledBy,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      requestedAt: requestedAt ?? this.requestedAt,
      approvedAt: approvedAt ?? this.approvedAt,
      activatedAt: activatedAt ?? this.activatedAt,
      startsAt: startsAt ?? this.startsAt,
      endsAt: endsAt ?? this.endsAt,
      notes: notes ?? this.notes,
      meta: meta ?? this.meta,
      route: route ?? this.route,
      icon: icon ?? this.icon,
    );
  }
}
