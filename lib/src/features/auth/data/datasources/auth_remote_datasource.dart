import 'package:dio/dio.dart' hide Response;
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/core/services/dio.dart';
import 'package:solar_hub/src/core/models/response.dart';
import 'package:solar_hub/src/features/auth/domain/entities/auth_response.dart';
import 'package:solar_hub/src/features/auth/domain/entities/city.dart';
import 'package:solar_hub/src/shared/domain/company/company.dart';
import 'package:solar_hub/src/features/auth/domain/entities/country.dart';
import 'package:solar_hub/src/features/auth/domain/entities/company_register_model.dart';
import 'package:solar_hub/src/shared/domain/company/company_type.dart';
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
}

class AuthDjangoDataSourceImpl implements AuthRemoteDataSource {
  final DioService _dioService = getIt<DioService>();

  void _throwIfFailed(BaseResponse response) {
    if (response.status != 200 || response.error) {
      dPrint(response.messageUser);
      throw Exception(
        response.messageUser.isNotEmpty
            ? response.messageUser
            : response.message,
      );
    }
  }

  @override
  Future<AuthResponse> login(String username, String password) async {
    try {
      Response response = await _dioService.post(
        AppUrls.login,
        data: {'username': username, 'password': password},
      );
      _throwIfFailed(response);
      return AuthResponse.fromBase(response);
    } catch (e, stackTrace) {
      dPrint(
        'login error: $e',
        stackTrace: stackTrace,
        tag: 'AuthRemoteDataSource',
      );
      rethrow;
    }
  }

  @override
  Future<AuthResponse> register(UserRegisterModel userRegisterModel) async {
    try {
      dPrint(await userRegisterModel.toJson());
      BaseResponse response = await _dioService.post(
        AppUrls.register,
        data: await userRegisterModel.toJson(),
      );
      _throwIfFailed(response);
      dPrint(response);
      return AuthResponse.fromBase(response);
    } catch (e, stackTrace) {
      dPrint(
        'register error: $e',
        stackTrace: stackTrace,
        tag: 'AuthRemoteDataSource',
      );
      rethrow;
    }
  }

  @override
  Future<User> fetchProfile() async {
    try {
      BaseResponse response = await _dioService.get(AppUrls.profile);
      _throwIfFailed(response);
      return User.fromJson(response.body);
    } catch (e, stackTrace) {
      dPrint(
        'fetchProfile error: $e',
        stackTrace: stackTrace,
        tag: 'AuthRemoteDataSource',
      );
      rethrow;
    }
  }

  @override
  Future<User> updateProfile(UserRegisterModel userRegisterModel) async {
    try {
      dPrint(await userRegisterModel.toJson());

      Response response = await _dioService.multipartRequest(
        AppUrls.profile,
        file: FormData.fromMap(await userRegisterModel.toJson()),
        isPut: true,
      );
      _throwIfFailed(response);
      return User.fromJson(response.body);
    } catch (e, stackTrace) {
      dPrint(
        'updateProfile error: $e',
        stackTrace: stackTrace,
        tag: 'AuthRemoteDataSource',
      );
      rethrow;
    }
  }

  @override
  Future<void> logout() {
    return Future.value();
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    try {
      final response = await _dioService.post(
        AppUrls.passwordReset,
        data: {'email': email},
      );
      _throwIfFailed(response);
    } catch (e, stackTrace) {
      dPrint(
        'requestPasswordReset error: $e',
        stackTrace: stackTrace,
        tag: 'AuthRemoteDataSource',
      );
      rethrow;
    }
  }

  @override
  Future<void> validatePasswordResetToken(String token) async {
    try {
      final response = await _dioService.post(
        AppUrls.passwordResetValidateToken,
        data: {'token': token},
      );
      _throwIfFailed(response);
    } catch (e, stackTrace) {
      dPrint(
        'validatePasswordResetToken error: $e',
        stackTrace: stackTrace,
        tag: 'AuthRemoteDataSource',
      );
      rethrow;
    }
  }

  @override
  Future<void> confirmPasswordReset({
    required String token,
    required String password,
  }) async {
    try {
      final response = await _dioService.post(
        AppUrls.passwordResetConfirm,
        data: {'token': token, 'password': password},
      );
      _throwIfFailed(response);
    } catch (e, stackTrace) {
      dPrint(
        'confirmPasswordReset error: $e',
        stackTrace: stackTrace,
        tag: 'AuthRemoteDataSource',
      );
      rethrow;
    }
  }

  @override
  Future<void> deleteAccount({required String password, String? reason}) async {
    try {
      final response = await _dioService.post(
        AppUrls.deleteAccount,
        data: {
          'password': password,
          'reason': reason?.trim().isEmpty == true ? null : reason?.trim(),
        },
      );
      _throwIfFailed(response);
    } catch (e, stackTrace) {
      dPrint(
        'deleteAccount error: $e',
        stackTrace: stackTrace,
        tag: 'AuthRemoteDataSource',
      );
      rethrow;
    }
  }

  @override
  Future<List<Country>> getCountries() async {
    try {
      ListResponse response =
          await _dioService.get(AppUrls.countries, isList: true)
              as ListResponse;
      _throwIfFailed(response);
      dPrint(response.body);
      return (response.body as List).map((e) => Country.fromJson(e)).toList();
    } catch (e, stackTrace) {
      dPrint(
        'getCountries error: $e',
        stackTrace: stackTrace,
        tag: 'AuthRemoteDataSource',
      );
      rethrow;
    }
  }

  @override
  Future<List<City>> getCities({int? countryId}) async {
    try {
      ListResponse response =
          await _dioService.get(AppUrls.cities, isList: true) as ListResponse;
      _throwIfFailed(response);
      dPrint(response.body);
      return (response.body as List).map((e) => City.fromJson(e)).toList();
    } catch (e, stackTrace) {
      dPrint(
        'getCities error: $e',
        stackTrace: stackTrace,
        tag: 'AuthRemoteDataSource',
      );
      rethrow;
    }
  }

  @override
  Future<List<CompanyType>> getCompanyTypes() async {
    try {
      final response = await _dioService.get(AppUrls.companyTypes);
      _throwIfFailed(response);
      final body = response.body as List? ?? const [];
      return body
          .whereType<Map>()
          .map((e) => CompanyType.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e, stackTrace) {
      dPrint(
        'getCompanyTypes error: $e',
        stackTrace: stackTrace,
        tag: 'AuthRemoteDataSource',
      );
      rethrow;
    }
  }

  @override
  Future<Company> registerCompany(
    CompanyRegistrationModel companyRegistrationModel,
  ) async {
    try {
      BaseResponse response = await _dioService.multipartRequest(
        AppUrls.registerCompany,
        file: FormData.fromMap(await companyRegistrationModel.toJson()),
      );
      _throwIfFailed(response);
      dPrint(response);
      return Company.fromJson(response.body);
    } catch (e, stackTrace) {
      dPrint(
        'registerCompany error: $e',
        stackTrace: stackTrace,
        tag: 'AuthRemoteDataSource',
      );
      rethrow;
    }
  }

  @override
  Future<Company> updateCompany({
    required int companyId,
    required CompanyRegistrationModel companyRegistrationModel,
  }) async {
    try {
      final response = await _dioService.multipartRequest(
        AppUrls.updateCompany(companyId),
        file: FormData.fromMap(await companyRegistrationModel.toJson()),
        isPut: true,
      );
      _throwIfFailed(response);
      return Company.fromJson(response.body);
    } catch (e, stackTrace) {
      dPrint(
        'updateCompany error: $e',
        stackTrace: stackTrace,
        tag: 'AuthRemoteDataSource',
      );
      rethrow;
    }
  }
}
