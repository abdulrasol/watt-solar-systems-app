class CompanyPublicServiceFormModel {
  const CompanyPublicServiceFormModel({
    required this.title,
    this.price,
    this.description,
  });

  final String title;
  final num? price;
  final String? description;

  Map<String, dynamic> toJson() {
    return {'title': title, 'price': price, 'description': description};
  }
}
