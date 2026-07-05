class CompanyActivationReminderResponse {
  const CompanyActivationReminderResponse({
    required this.companyId,
    this.lastActivationReminderAt,
    this.activationReminderAvailableAt,
  });

  final int companyId;
  final DateTime? lastActivationReminderAt;
  final DateTime? activationReminderAvailableAt;

  factory CompanyActivationReminderResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return CompanyActivationReminderResponse(
      companyId: int.tryParse(json['company_id']?.toString() ?? '') ?? 0,
      lastActivationReminderAt: json['last_activation_reminder_at'] != null
          ? DateTime.tryParse(json['last_activation_reminder_at'].toString())
          : null,
      activationReminderAvailableAt:
          json['activation_reminder_available_at'] != null
          ? DateTime.tryParse(
              json['activation_reminder_available_at'].toString(),
            )
          : null,
    );
  }
}
