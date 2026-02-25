import 'package:solar_hub/features/auth/models/company.dart';
import 'package:solar_hub/models/city.dart';
import 'package:solar_hub/models/country.dart';

class User {
  final int id;
  final String username;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final City? city;
  final Country? country;
  final String? image;
  final bool isSuperUser;
  final Company? company;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.city,
    required this.country,
    required this.image,
    this.isSuperUser = false,
    this.company,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      phone: json['phone'],
      city: json['city'] != null ? City.fromJson(json['city']) : null,
      country: json['country'] != null ? Country.fromJson(json['country']) : null,
      image: json['image'],
      isSuperUser: json['is_super_user'] ?? false,
      company: json['company'] != null ? Company.fromJson(json['company']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'city': city?.toJson(),
      'country': country?.toJson(),
      'image': image,
      'is_super_user': isSuperUser,
      'company': company?.toJson(),
    };
  }

  String get fullName {
    return '$firstName $lastName';
  }
}
