class CompanySubscriptionRequest {
  const CompanySubscriptionRequest({
    required this.id,
    required this.companyId,
    required this.companyName,
    required this.subscriptionPlanId,
    required this.subscriptionPlanName,
    required this.status,
    this.requestedBy,
    this.notes,
    this.image,
    this.createdAt,
    this.autoApproved = false,
    this.effectiveStart,
    this.resultingExpiry,
    this.companySubscriptionPlanId,
  });

  final int id;
  final int companyId;
  final String companyName;
  final int subscriptionPlanId;
  final String subscriptionPlanName;
  final String status;
  final String? requestedBy;
  final String? notes;
  final String? image;
  final DateTime? createdAt;
  final bool autoApproved;
  final DateTime? effectiveStart;
  final DateTime? resultingExpiry;
  final int? companySubscriptionPlanId;

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isActive => status.toLowerCase() == 'active';
  bool get isAutoActivated => autoApproved || isActive;

  factory CompanySubscriptionRequest.fromJson(Map<String, dynamic> json) {
    return CompanySubscriptionRequest(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      companyId: int.tryParse(json['company_id']?.toString() ?? '') ?? 0,
      companyName: json['company_name']?.toString() ?? '',
      subscriptionPlanId:
          int.tryParse(json['subscription_plan_id']?.toString() ?? '') ?? 0,
      subscriptionPlanName: json['subscription_plan_name']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      requestedBy: json['requested_by']?.toString(),
      notes: json['notes']?.toString(),
      image: json['image']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      autoApproved: json['auto_approved'] == true,
      effectiveStart: json['effective_start'] != null
          ? DateTime.tryParse(json['effective_start'].toString())
          : null,
      resultingExpiry: json['resulting_expiry'] != null
          ? DateTime.tryParse(json['resulting_expiry'].toString())
          : null,
      companySubscriptionPlanId:
          int.tryParse(json['company_subscription_plan_id']?.toString() ?? ''),
    );
  }
}
