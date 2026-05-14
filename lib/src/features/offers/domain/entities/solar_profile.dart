class SolarProfile {
  final String name;
  final String phone;
  final String email;
  final String? image;

  SolarProfile({
    required this.name,
    required this.phone,
    required this.email,
    this.image,
  });

  factory SolarProfile.fromJson(Map<String, dynamic> json) {
    return SolarProfile(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'image': image,
    };
  }
}
