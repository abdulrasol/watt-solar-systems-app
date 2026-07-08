class CompanyContactFormModel {
  const CompanyContactFormModel({
    required this.name,
    required this.email,
    required this.phone,
    this.notes,
  });

  final String name;
  final String email;
  final String phone;
  final String? notes;

  Map<String, dynamic> toJson() {
    return {'name': name, 'email': email, 'phone': phone, 'notes': notes};
  }
}
