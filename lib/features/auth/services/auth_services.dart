import 'package:flutter/foundation.dart';
import 'package:solar_hub/core/cashe/cashe_interface.dart';
import 'package:solar_hub/core/di/get_it.dart';
import 'package:solar_hub/core/models/response.dart';
import 'package:solar_hub/core/services/dio.dart';
import 'package:solar_hub/features/auth/models/company.dart';
import 'package:solar_hub/features/auth/models/response.dart';
import 'package:solar_hub/features/auth/models/user.dart';
import 'package:solar_hub/utils/app_urls.dart';

class AuthServices {
  final DioService _dioService = getIt<DioService>();

  bool isLoading = false;

  Future login(String username, String password) async {
    isLoading = true;

    try {
      Response response = await _dioService.post(AppUrls.login, data: {'username': username, 'password': password});
      AuthResponse authResponse = AuthResponse.fromResponse(response);
      if (authResponse.status == 200) {
        getIt<CasheInterface>().saveToken(authResponse.token);
        getIt<CasheInterface>().saveUser(authResponse.user);
        getIt<CasheInterface>().save('company', authResponse.company?.toJson());
        getIt<CasheInterface>().save('permissions', authResponse.permissions?.toJson());
      } else {
        throw Exception(response.messageUser);
      }
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrintStack(stackTrace: s);
      throw Exception(e.toString());
    } finally {
      isLoading = false;
    }
  }

  Future register(String username, String password, Map<String, dynamic> data) async {
    isLoading = true;

    try {
      Response response = await _dioService.post(AppUrls.register, data: {'username': username, 'password': password, ...data});
      AuthResponse authResponse = AuthResponse.fromResponse(response);
      if (authResponse.status == 200) {
        getIt<CasheInterface>().saveToken(authResponse.token);
        getIt<CasheInterface>().saveUser(authResponse.user);
        getIt<CasheInterface>().save('company', authResponse.company?.toJson());
        getIt<CasheInterface>().save('permissions', authResponse.permissions?.toJson());
      } else {
        throw Exception(response.messageUser);
      }
    } catch (e) {
      throw Exception(e.toString());
    } finally {
      isLoading = false;
    }
  }

  Future logout() async {
    isLoading = true;

    try {
      await getIt<CasheInterface>().delete('token');
      await getIt<CasheInterface>().delete('user');
      await getIt<CasheInterface>().delete('company');
      await getIt<CasheInterface>().delete('permissions');
    } catch (e) {
      throw Exception(e.toString());
    } finally {
      isLoading = false;
    }
  }

  // TODO: implement updateProfile
  Future<User?> updateProfile({required String fullName, required String phoneNumber, String? avatarUrl}) async {
    isLoading = true;
    try {
      // Response response = await _dioService.put(AppUrls.updateProfile, data: {'fullName': fullName, 'phoneNumber': phoneNumber, 'avatarUrl': avatarUrl});
      // if (response.status == 200) {
      //   return true;
      // } else {
      //   throw Exception(response.message);
      // }
      return null;
    } catch (e) {
      throw Exception(e.toString());
    } finally {
      isLoading = false;
    }
  }

  Future<Company?> updateCompany(Company company) async {
    isLoading = true;
    try {
      // Response response = await _dioService.put(AppUrls.updateCompany, data: company.toJson());
      // if (response.status == 200) {
      //   return Company.fromJson(response.body);
      // } else {
      //   throw Exception(response.message);
      // }
      return null;
    } catch (e) {
      throw Exception(e.toString());
    } finally {
      isLoading = false;
    }
  }
}
