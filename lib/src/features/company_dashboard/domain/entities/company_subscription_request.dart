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
    );
  }
}
