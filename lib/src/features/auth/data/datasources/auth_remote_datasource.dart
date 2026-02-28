import 'package:dio/dio.dart' hide Response;
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/core/services/dio.dart';
import 'package:solar_hub/src/core/models/response.dart';
import 'package:solar_hub/src/features/auth/domain/entities/auth_response.dart';
import 'package:solar_hub/src/features/auth/domain/entities/city.dart';
import 'package:solar_hub/src/features/auth/domain/entities/company.dart';
import 'package:solar_hub/src/features/auth/domain/entities/country.dart';
import 'package:solar_hub/src/features/auth/domain/entities/company_register_model.dart';
import 'package:solar_hub/src/features/auth/domain/entities/user.dart';
import 'package:solar_hub/src/utils/app_urls.dart';
import 'package:solar_hub/src/utils/helper_methods.dart';
import '../../domain/entities/user_register_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponse> login(String username, String password);

  Future<AuthResponse> register(UserRegisterModel userRegisterModel);

  Future<User> updateProfile(UserRegisterModel userRegisterModel);

  Future<User> fetchProfile();

  Future<void> logout();

  Future<List<Country>> getCountries();

  Future<List<City>> getCities({int? countryId});

  Future<Company> registerCompany(CompanyRegistrationModel companyRegistrationModel);
}

class AuthDjangoDataSourceImpl implements AuthRemoteDataSource {
  final DioService _dioService = getIt<DioService>();
  @override
  Future<AuthResponse> login(String username, String password) async {
    Response response = await _dioService.post(AppUrls.login, data: {'username': username, 'password': password});
    if (response.status != 200 || response.error) {
      throw Exception(response.messageUser);
    }
    return AuthResponse.fromBase(response);
  }

  @override
  Future<AuthResponse> register(UserRegisterModel userRegisterModel) async {
    dPrint(await userRegisterModel.toJson());
    BaseResponse response = await _dioService.post(AppUrls.register, data: await userRegisterModel.toJson());
    if (response.status != 200 || response.error) {
      dPrint(response.messageUser);
      throw Exception(response.messageUser);
    }
    dPrint(response);
    return AuthResponse.fromBase(response);
  }

  @override
  Future<User> fetchProfile() async {
    BaseResponse response = await _dioService.get(AppUrls.profile);
    if (response.status != 200 || response.error) {
      throw Exception(response.messageUser);
    }
    return User.fromJson(response.body);
  }

  @override
  Future<User> updateProfile(UserRegisterModel userRegisterModel) async {
    dPrint(await userRegisterModel.toJson());

    Response response = await _dioService.multipartRequest(AppUrls.profile, file: FormData.fromMap(await userRegisterModel.toJson()), isPut: true);
    if (response.status != 200 || response.error) {
      throw Exception(response.messageUser);
    }
    return User.fromJson(response.body);
  }

  @override
  Future<void> logout() {
    return Future.value();
  }

  @override
  Future<List<Country>> getCountries() async {
    ListResponse response = await _dioService.get(AppUrls.countries, isList: true) as ListResponse;
    if (response.status != 200 || response.error) {
      dPrint(response.messageUser);
      throw Exception(response.messageUser);
    }
    dPrint(response.body);
    return (response.body as List).map((e) => Country.fromJson(e)).toList();
  }

  @override
  Future<List<City>> getCities({int? countryId}) async {
    ListResponse response = await _dioService.get(AppUrls.cities, isList: true) as ListResponse;
    if (response.status != 200 || response.error) {
      dPrint(response.messageUser);
      throw Exception(response.messageUser);
    }
    dPrint(response.body);
    return (response.body as List).map((e) => City.fromJson(e)).toList();
  }

  @override
  Future<Company> registerCompany(CompanyRegistrationModel companyRegistrationModel) async {
    BaseResponse response = await _dioService.multipartRequest(AppUrls.registerCompany, file: FormData.fromMap(await companyRegistrationModel.toJson()));
    if (response.status != 200 || response.error) {
      dPrint(response.messageUser);
      throw Exception(response.messageUser);
    }
    dPrint(response);
    return Company.fromJson(response.body);
  }
}
