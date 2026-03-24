class AppUrls {
  //static const String baseUrl = 'https://abdulrasol.pythonanywhere.com/api/v1';
  static const String baseUrl = 'http://127.0.0.1:8000/api/v1';

  // Auth
  static const String authBaseUrl = '$baseUrl/users';
  static const String login = '$authBaseUrl/login';
  static const String register = '$authBaseUrl/register';
  static const String profile = '$authBaseUrl/profile';

  // admin
  static const String adminBaseUrl = '$baseUrl/admin';
  static const String appConfigs = '$adminBaseUrl/config';
  static const String currency = '$adminBaseUrl/currency';

  // cities & countries
  static const String countries = '$adminBaseUrl/countries';
  static const String cities = '$adminBaseUrl/cities';

  // companies
  static const String companiesBaseUrl = '$baseUrl/company';
  static const String registerCompany = '$companiesBaseUrl/register';
  static String company(int id) => '$companiesBaseUrl/$id';

  // dashboard
  /// products
  static String products(int companyId) => '$companiesBaseUrl/$companyId/products';
}
