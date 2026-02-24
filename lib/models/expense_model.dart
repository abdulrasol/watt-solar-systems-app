class ExpenseModel {
  final String id;
  final String companyId;
  final double amount;
  final String category;
  final String? description;
  final DateTime date;
  final DateTime createdAt;

  ExpenseModel({
    required this.id,
    required this.companyId,
    required this.amount,
    required this.category,
    this.description,
    required this.date,
    required this.createdAt,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'],
      companyId: json['company_id'],
      amount: (json['amount'] as num).toDouble(),
      category: json['category'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'amount': amount,
      'category': category,
      'description': description,
      'date': date.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
