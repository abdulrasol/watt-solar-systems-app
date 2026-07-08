class CompanyExpense {
  final int id;
  final double amount;
  final String category;
  final String? description;
  final DateTime? date;
  final DateTime? createdAt;

  const CompanyExpense({
    required this.id,
    required this.amount,
    required this.category,
    this.description,
    this.date,
    this.createdAt,
  });

  factory CompanyExpense.fromJson(Map<String, dynamic> json) {
    return CompanyExpense(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      category: json['category']?.toString() ?? '',
      description: json['description']?.toString(),
      date: json['date'] != null ? DateTime.tryParse(json['date'].toString()) : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'category': category,
      'description': description,
      'date': date?.toIso8601String(),
    };
  }
}
