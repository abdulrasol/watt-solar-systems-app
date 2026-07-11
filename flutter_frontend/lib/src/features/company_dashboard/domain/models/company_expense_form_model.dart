class CompanyExpenseFormModel {
  const CompanyExpenseFormModel({
    required this.amount,
    required this.category,
    this.description,
    this.date,
  });

  final double amount;
  final String category;
  final String? description;
  final DateTime? date;

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'category': category,
      'description': description,
      'date': (date ?? DateTime.now()).toIso8601String().split('T')[0],
    };
  }
}
