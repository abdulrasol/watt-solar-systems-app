import 'package:dio/dio.dart';

class UserRegisterModel {
  final String username;
  final String password;
  final String email;
  final String firstName;
  final String lastName;
  final String phone;
  final int? city;
  final String? image;
  final String? securityQuestion;
  final String? securityAnswer;

  UserRegisterModel({
    required this.username,
    required this.password,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.city,
    this.image,
    this.securityQuestion,
    this.securityAnswer,
  });

  Future<Map<String, dynamic>> toJson() async {
    final data = <String, dynamic>{};
    data['username'] = username;
    data['password'] = password;
    data['email'] = email;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['phone'] = phone;
    if (city != null) data['city_id'] = city;
    if (image != null && image!.isNotEmpty) data['image'] = await MultipartFile.fromFile(image!);
    if (securityQuestion != null) data['security_question'] = securityQuestion;
    if (securityAnswer != null) data['security_answer'] = securityAnswer;
    return data;
  }
}
