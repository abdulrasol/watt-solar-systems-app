import 'package:solar_hub/core/models/response.dart';
import 'package:solar_hub/features/auth/models/company.dart';
import 'package:solar_hub/features/auth/models/user.dart';
import 'package:solar_hub/features/auth/models/user_permissions.dart';

class AuthResponse {
  final String token;
  final User user;
  final Company? company;
  final UserPermissions? permissions;
  final int status;
  final String message;
  final String error;
  final String messageUser;

  AuthResponse({
    required this.token,
    required this.user,
    required this.company,
    required this.permissions,
    required this.status,
    required this.message,
    required this.error,
    required this.messageUser,
  });

  factory AuthResponse.fromResponse(Response response) {
    return AuthResponse(
      token: response.body['token'],
      user: User.fromJson(response.body['user']),
      company: response.body['company'] != null ? Company.fromJson(response.body['company']) : null,
      permissions: response.body['permissions'] != null ? UserPermissions.fromJson(response.body['permissions']) : null,
      status: response.status,
      message: response.message,
      error: response.error,
      messageUser: response.messageUser,
    );
  }

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token']['body'],
      user: User.fromJson(json['user']['body']),
      company: json['company'] != null ? Company.fromJson(json['company']['body']) : null,
      permissions: json['permissions'] != null ? UserPermissions.fromJson(json['permissions']['body']) : null,
      status: json['status'],
      message: json['message'],
      error: json['error'],
      messageUser: json['messageUser'],
    );
  }
}
