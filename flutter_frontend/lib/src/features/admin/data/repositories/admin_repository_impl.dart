import 'package:watt/src/features/company_dashboard/domain/entities/company_subscription_request.dart';

import 'package:watt/src/features/admin/data/data_sources/admin_remote_data_source.dart';

import 'package:watt/src/features/admin/domain/models/admin_city.dart';
import 'package:watt/src/features/admin/domain/models/admin_company_details.dart';
import 'package:watt/src/features/admin/domain/models/admin_country.dart';
import 'package:watt/src/features/admin/domain/models/admin_currency.dart';
import 'package:watt/src/features/admin/domain/models/admin_global_category.dart';
import 'package:watt/src/features/admin/domain/models/admin_subscription_plan.dart';
import 'package:watt/src/features/admin/domain/models/admin_user.dart';
import 'package:watt/src/features/admin/domain/models/company_service.dart';
import 'package:watt/src/features/admin/domain/models/service_catalog_item.dart';
import 'package:watt/src/features/admin/domain/repositories/admin_repository.dart';
import 'package:watt/src/shared/domain/company/company.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource _remoteDataSource;

  AdminRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Company>> listCompanies({String? status, int page = 1, int pageSize = 12}) async {
    final response = await _remoteDataSource.listCompanies(status: status, page: page, pageSize: pageSize);
    final body = response.body;
    if (body is! List) throw Exception('Expected List but got ${body.runtimeType}');

    final companies = body.map((e) => Company.fromJson(e as Map<String, dynamic>)).toList();

    if (status != null && status.isNotEmpty) {
      return companies.where((c) => c.status.trim().toLowerCase() == status.trim().toLowerCase()).toList();
    }
    return companies;
  }

  @override
  Future<void> updateCompanyStatus(int companyId, String status) async {
    await _remoteDataSource.updateCompanyStatus(companyId, status);
  }

  @override
  Future<List<ServiceCatalogItem>> listServiceCatalog() async {
    final response = await _remoteDataSource.listServiceCatalog();
    final body = response.body;
    if (body is! List) throw Exception('Expected List but got ${body.runtimeType}');
    return body.map((e) => ServiceCatalogItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<ServiceCatalogItem> createServiceCatalogEntry(ServiceCatalogItem item) async {
    final response = await _remoteDataSource.createServiceCatalogEntry(item);
    return ServiceCatalogItem.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<ServiceCatalogItem> updateServiceCatalogEntry(String serviceCode, Map<String, dynamic> data) async {
    final response = await _remoteDataSource.updateServiceCatalogEntry(serviceCode, data);
    return ServiceCatalogItem.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<void> deleteServiceCatalogEntry(String serviceCode) async {
    await _remoteDataSource.deleteServiceCatalogEntry(serviceCode);
  }

  @override
  Future<List<CompanyService>> listCompanyServices(int companyId) async {
    final response = await _remoteDataSource.listCompanyServices(companyId);
    final body = response.body;
    if (body is! List) throw Exception('Expected List but got ${body.runtimeType}');
    return body.map((e) => CompanyService.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<AdminCompanyDetails> getCompanyDetails(int companyId) async {
    final response = await _remoteDataSource.getCompanyDetails(companyId);
    return AdminCompanyDetails.fromJson(response.body as Map<String, dynamic>);
  }


  // Currencies
  @override
  Future<List<AdminCurrency>> listCurrencies({int page = 1, int pageSize = 12}) async {
    final response = await _remoteDataSource.listCurrencies(page: page, pageSize: pageSize);
    final body = response.body;
    if (body is! List) throw Exception('Expected List but got ${body.runtimeType}');
    return body.map((e) => AdminCurrency.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<AdminCurrency> createCurrency(Map<String, dynamic> data) async {
    final response = await _remoteDataSource.createCurrency(data);
    return AdminCurrency.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<AdminCurrency> updateCurrency(int id, Map<String, dynamic> data) async {
    final response = await _remoteDataSource.updateCurrency(id, data);
    return AdminCurrency.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<void> deleteCurrency(int id) async {
    await _remoteDataSource.deleteCurrency(id);
  }

  // Countries
  @override
  Future<List<AdminCountry>> listCountries() async {
    final response = await _remoteDataSource.listCountries();
    final body = response.body;
    if (body is! List) throw Exception('Expected List but got ${body.runtimeType}');
    return body.map((e) => AdminCountry.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<AdminCountry> createCountry(Map<String, dynamic> data) async {
    final response = await _remoteDataSource.createCountry(data);
    return AdminCountry.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<AdminCountry> updateCountry(int id, Map<String, dynamic> data) async {
    final response = await _remoteDataSource.updateCountry(id, data);
    return AdminCountry.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<void> deleteCountry(int id) async {
    await _remoteDataSource.deleteCountry(id);
  }

  // Cities
  @override
  Future<List<AdminCity>> listCities({int? countryId}) async {
    final response = await _remoteDataSource.listCities(countryId: countryId);
    final body = response.body;
    if (body is! List) throw Exception('Expected List but got ${body.runtimeType}');
    return body.map((e) => AdminCity.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<AdminCity> createCity(Map<String, dynamic> data) async {
    final response = await _remoteDataSource.createCity(data);
    return AdminCity.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<AdminCity> updateCity(int id, Map<String, dynamic> data) async {
    final response = await _remoteDataSource.updateCity(id, data);
    return AdminCity.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<void> deleteCity(int id) async {
    await _remoteDataSource.deleteCity(id);
  }

  // Global Categories
  @override
  Future<List<AdminGlobalCategory>> listGlobalCategories({int page = 1, int pageSize = 12}) async {
    final response = await _remoteDataSource.listGlobalCategories(page: page, pageSize: pageSize);
    final body = response.body;
    if (body is! List) throw Exception('Expected List but got ${body.runtimeType}');
    return body.map((e) => AdminGlobalCategory.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<AdminGlobalCategory> createGlobalCategory(Map<String, dynamic> data) async {
    final response = await _remoteDataSource.createGlobalCategory(data);
    return AdminGlobalCategory.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<AdminGlobalCategory> updateGlobalCategory(int id, Map<String, dynamic> data) async {
    final response = await _remoteDataSource.updateGlobalCategory(id, data);
    return AdminGlobalCategory.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<void> deleteGlobalCategory(int id) async {
    await _remoteDataSource.deleteGlobalCategory(id);
  }

  // Users
  @override
  Future<List<AdminUser>> listUsers({int page = 1, int pageSize = 12}) async {
    final response = await _remoteDataSource.listUsers(page: page, pageSize: pageSize);
    final body = response.body;
    if (body is! List) throw Exception('Expected List but got ${body.runtimeType}');
    return body.map((e) => AdminUser.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> promoteUser(String username, bool promote) async {
    await _remoteDataSource.promoteUser(username, promote);
  }

  // Subscriptions
  @override
  Future<List<AdminSubscriptionPlan>> listSubscriptionPlans({int page = 1, int pageSize = 12}) async {
    final response = await _remoteDataSource.listSubscriptionPlans(page: page, pageSize: pageSize);
    final body = response.body;
    if (body is! List) throw Exception('Expected List but got ${body.runtimeType}');
    return body.map((e) => AdminSubscriptionPlan.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<AdminSubscriptionPlan> createSubscriptionPlan(Map<String, dynamic> data) async {
    final response = await _remoteDataSource.createSubscriptionPlan(data);
    return AdminSubscriptionPlan.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<AdminSubscriptionPlan> updateSubscriptionPlan(int id, Map<String, dynamic> data) async {
    final response = await _remoteDataSource.updateSubscriptionPlan(id, data);
    return AdminSubscriptionPlan.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<void> deleteSubscriptionPlan(int id) async {
    await _remoteDataSource.deleteSubscriptionPlan(id);
  }

  @override
  Future<List<CompanySubscriptionRequest>> listSubscriptionRequests({String? status, int page = 1, int pageSize = 12}) async {
    final response = await _remoteDataSource.listSubscriptionRequests(status: status, page: page, pageSize: pageSize);
    final body = response.body;
    if (body is! List) throw Exception('Expected List but got ${body.runtimeType}');
    return body.map((e) => CompanySubscriptionRequest.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> reviewSubscriptionRequest(int companyId, int requestId, String status, {String? notes}) async {
    await _remoteDataSource.reviewSubscriptionRequest(companyId, requestId, status, notes: notes);
  }
}
