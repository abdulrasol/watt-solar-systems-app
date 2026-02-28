import 'package:solar_hub/src/features/auth/domain/entities/auth_response.dart';
import 'package:solar_hub/src/features/auth/domain/entities/city.dart';
import 'package:solar_hub/src/features/auth/domain/entities/company.dart';
import 'package:solar_hub/src/features/auth/domain/entities/country.dart';
import 'package:solar_hub/src/features/auth/domain/entities/company_register_model.dart';
import 'package:solar_hub/src/features/auth/domain/entities/user.dart';
import '../datasources/auth_remote_datasource.dart';
import '../../domain/entities/user_register_model.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _authRemoteDataSource;

  AuthRepositoryImpl(this._authRemoteDataSource);

  @override
  Future<AuthResponse> login(String username, String password) async {
    final authResponse = _authRemoteDataSource.login(username, password);
    return authResponse;
  }

  @override
  Future<AuthResponse> register(UserRegisterModel userRegisterModel) {
    return _authRemoteDataSource.register(userRegisterModel);
  }

  @override
  Future<User> updateProfile(UserRegisterModel userRegisterModel) {
    return _authRemoteDataSource.updateProfile(userRegisterModel);
  }

  @override
  Future<User> fetchProfile() {
    return _authRemoteDataSource.fetchProfile();
  }

  @override
  Future<void> logout() {
    return _authRemoteDataSource.logout();
  }

  @override
  Future<List<Country>> getCountries() {
    return _authRemoteDataSource.getCountries();
  }

  @override
  Future<List<City>> getCities({int? countryId}) {
    return _authRemoteDataSource.getCities(countryId: countryId);
  }

  @override
  Future<Company> registerCompany(CompanyRegistrationModel companyRegistrationModel) {
    return _authRemoteDataSource.registerCompany(companyRegistrationModel);
  }
}
