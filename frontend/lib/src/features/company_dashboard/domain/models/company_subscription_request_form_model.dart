class CompanySubscriptionRequestFormModel {
  const CompanySubscriptionRequestFormModel({
    required this.subscriptionPlan,
    this.notes,
    this.imagePath,
  });

  final int subscriptionPlan;
  final String? notes;
  final String? imagePath;
}
