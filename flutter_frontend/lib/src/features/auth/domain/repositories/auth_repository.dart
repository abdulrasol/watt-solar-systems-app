import 'package:solar_hub/src/features/auth/domain/entities/auth_response.dart';
import 'package:solar_hub/src/features/auth/domain/entities/city.dart';
import 'package:solar_hub/src/shared/domain/company/company.dart';
import 'package:solar_hub/src/features/auth/domain/entities/country.dart';
import 'package:solar_hub/src/features/auth/domain/entities/company_register_model.dart';
import 'package:solar_hub/src/shared/domain/company/company_type.dart';
import 'package:solar_hub/src/features/auth/domain/entities/user.dart';
import 'package:solar_hub/src/features/auth/domain/entities/user_register_model.dart';

abstract class AuthRepository {
  Future<AuthResponse> login(String username, String password);

  Future<AuthResponse> register(UserRegisterModel userRegisterModel);

  Future<User> updateProfile(UserRegisterModel userRegisterModel);

  Future<User> fetchProfile();

  Future<void> logout();

  Future<void> requestPasswordReset(String email);

  Future<void> validatePasswordResetToken(String token);

  Future<void> confirmPasswordReset({
    required String token,
    required String password,
  });

  Future<void> deleteAccount({required String password, String? reason});

  Future<List<Country>> getCountries();

  Future<List<City>> getCities({int? countryId});

  Future<List<CompanyType>> getCompanyTypes();

  Future<Company> registerCompany(
    CompanyRegistrationModel companyRegistrationModel,
  );

  Future<Company> updateCompany({
    required int companyId,
    required CompanyRegistrationModel companyRegistrationModel,
  });

  /// Silently syncs the user's preferred language to the server.
  Future<void> updateLanguage(String language);
}
