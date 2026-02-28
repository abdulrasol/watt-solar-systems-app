class AppUrls {
  static const String baseUrl = 'https://abdulrasol.pythonanywhere.com/api/v1';

  // Auth
  static const String authBaseUrl = '$baseUrl/users';
  static const String login = '$authBaseUrl/login';
  static const String register = '$authBaseUrl/register';
  static const String profile = '$authBaseUrl/profile';

  //
  static const String adminBaseUrl = '$baseUrl/admin';
  static const String configs = '$adminBaseUrl/config';
  static const String currency = '$adminBaseUrl/currency';
}
