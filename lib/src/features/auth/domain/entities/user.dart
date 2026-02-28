import 'package:solar_hub/src/features/auth/domain/entities/city.dart';
import 'package:solar_hub/src/features/auth/domain/entities/company.dart';

class User {
  final int id;
  final String username;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final City? city;
  final String? image;
  final bool isSuperUser;
  final bool isCompanyMember;
  final String? securityQuestion;
  final String? securityAnswer;
  final Company? company;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.city,
    this.image,
    this.isSuperUser = false,
    this.isCompanyMember = false,
    this.securityQuestion,
    this.securityAnswer,
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
      image: json['image'],
      isSuperUser: json['is_superuser'] ?? false,
      isCompanyMember: json['is_company_member'] ?? false,
      securityQuestion: json['security_question'],
      securityAnswer: json['security_answer'],
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
      'image': image,
      'is_superuser': isSuperUser,
      'is_company_member': isCompanyMember,
      'security_question': securityQuestion,
      'security_answer': securityAnswer,
      'company': company?.toJson(),
    };
  }

  User copyWith({
    int? id,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    City? city,
    String? image,
    bool? isSuperUser,
    bool? isCompanyMember,
    String? securityQuestion,
    String? securityAnswer,
    Company? company,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      image: image ?? this.image,
      isSuperUser: isSuperUser ?? this.isSuperUser,
      isCompanyMember: isCompanyMember ?? this.isCompanyMember,
      securityQuestion: securityQuestion ?? this.securityQuestion,
      securityAnswer: securityAnswer ?? this.securityAnswer,
      company: company ?? this.company,
    );
  }

  String get fullName {
    return '$firstName $lastName';
  }
}
