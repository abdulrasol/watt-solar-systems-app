import 'package:solar_hub/src/features/admin/data/data_sources/admin_remote_data_source.dart';
import 'package:solar_hub/src/features/admin/domain/models/admin_company_details.dart';
import 'package:solar_hub/src/features/admin/domain/models/admin_country.dart';
import 'package:solar_hub/src/features/admin/domain/models/admin_currency.dart';
import 'package:solar_hub/src/features/admin/domain/models/admin_global_category.dart';
import 'package:solar_hub/src/features/admin/domain/models/admin_user.dart';
import 'package:solar_hub/src/features/admin/domain/models/company_service.dart';
import 'package:solar_hub/src/features/admin/domain/models/service_catalog_item.dart';
import 'package:solar_hub/src/features/admin/domain/models/service_request.dart';
import 'package:solar_hub/src/features/admin/domain/models/admin_city.dart';
import 'package:solar_hub/src/features/admin/domain/models/admin_subscription_plan.dart';
import 'package:solar_hub/src/features/admin/domain/repositories/admin_repository.dart';
import 'package:solar_hub/src/shared/domain/company/company.dart';
import 'package:solar_hub/src/utils/helper_methods.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource _remoteDataSource;

  AdminRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Company>> listCompanies({String? status, int page = 1, int pageSize = 20}) async {
    final response = await _remoteDataSource.listCompanies(status: status, page: page, pageSize: pageSize);
    // response.body is already a List (extracted by PaginationResponse)
    final body = response.body;
    if (body is! List) {
      throw Exception('Expected List but got ${body.runtimeType}');
    }

    // Parse all companies
    final companies = body.map((e) => Company.fromJson(e as Map<String, dynamic>)).toList();

    // Client-side filtering (workaround for backend not filtering by status)
    if (status != null && status.isNotEmpty) {
      final filtered = companies.where((c) => c.status.trim().toLowerCase() == status.trim().toLowerCase()).toList();
      dPrint('Filtered companies: ${filtered.length} / ${companies.length} for status: $status', tag: 'AdminRepository');
      return filtered;
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
    if (body is! List) {
      throw Exception('Expected List but got ${body.runtimeType}');
    }
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
    if (body is! List) {
      throw Exception('Expected List but got ${body.runtimeType}');
    }
    return body.map((e) => CompanyService.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<AdminCompanyDetails> getCompanyDetails(int companyId) async {
    final response = await _remoteDataSource.getCompanyDetails(companyId);
    return AdminCompanyDetails.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<List<ServiceRequest>> listServiceRequests({int page = 1, int pageSize = 20}) async {
    final response = await _remoteDataSource.listServiceRequests(page: page, pageSize: pageSize);
    final body = response.body;
    if (body is! List) {
      throw Exception('Expected List but got ${body.runtimeType}');
    }
    return body.map((e) => ServiceRequest.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> reviewServiceRequest(int companyId, String serviceCode, Map<String, dynamic> data) async {
    await _remoteDataSource.reviewServiceRequest(companyId, serviceCode, data);
  }

  @override
  Future<void> toggleCompanyService(int companyId, String serviceCode, Map<String, dynamic> data) async {
    await _remoteDataSource.reviewServiceRequest(companyId, serviceCode, data);
  }

  @override
  Future<List<AdminCurrency>> listCurrencies({int page = 1, int pageSize = 12}) => throw UnimplementedError();
  @override
  Future<AdminCurrency> createCurrency(Map<String, dynamic> data) => throw UnimplementedError();
  @override
  Future<AdminCurrency> updateCurrency(int id, Map<String, dynamic> data) => throw UnimplementedError();
  @override
  Future<void> deleteCurrency(int id) => throw UnimplementedError();
  @override
  Future<List<AdminCountry>> listCountries({int page = 1, int pageSize = 12}) => throw UnimplementedError();
  @override
  Future<AdminCountry> createCountry(Map<String, dynamic> data) => throw UnimplementedError();
  @override
  Future<AdminCountry> updateCountry(int id, Map<String, dynamic> data) => throw UnimplementedError();
  @override
  Future<void> deleteCountry(int id) => throw UnimplementedError();
  @override
  Future<List<AdminCity>> listCities({int page = 1, int pageSize = 12}) => throw UnimplementedError();
  @override
  Future<AdminCity> createCity(Map<String, dynamic> data) => throw UnimplementedError();
  @override
  Future<AdminCity> updateCity(int id, Map<String, dynamic> data) => throw UnimplementedError();
  @override
  Future<void> deleteCity(int id) => throw UnimplementedError();
  @override
  Future<List<AdminGlobalCategory>> listGlobalCategories({int page = 1, int pageSize = 12}) => throw UnimplementedError();
  @override
  Future<AdminGlobalCategory> createGlobalCategory(Map<String, dynamic> data) => throw UnimplementedError();
  @override
  Future<AdminGlobalCategory> updateGlobalCategory(int id, Map<String, dynamic> data) => throw UnimplementedError();
  @override
  Future<void> deleteGlobalCategory(int id) => throw UnimplementedError();
  @override
  Future<List<AdminUser>> listUsers({int page = 1, int pageSize = 12}) => throw UnimplementedError();
  @override
  Future<void> promoteUser(String username, bool promote) => throw UnimplementedError();
  @override
  Future<List<AdminSubscriptionPlan>> listSubscriptionPlans({int page = 1, int pageSize = 12}) => throw UnimplementedError();
  @override
  Future<AdminSubscriptionPlan> createSubscriptionPlan(Map<String, dynamic> data) => throw UnimplementedError();
  @override
  Future<AdminSubscriptionPlan> updateSubscriptionPlan(int id, Map<String, dynamic> data) => throw UnimplementedError();
  @override
  Future<void> deleteSubscriptionPlan(int id) => throw UnimplementedError();
}

