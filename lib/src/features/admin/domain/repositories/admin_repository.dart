
import 'package:solar_hub/src/features/admin/domain/models/admin_city.dart';
import 'package:solar_hub/src/features/admin/domain/models/admin_company_details.dart';
import 'package:solar_hub/src/features/admin/domain/models/admin_country.dart';
import 'package:solar_hub/src/features/admin/domain/models/admin_currency.dart';
import 'package:solar_hub/src/features/admin/domain/models/admin_global_category.dart';
import 'package:solar_hub/src/features/admin/domain/models/admin_subscription_plan.dart';
import 'package:solar_hub/src/features/admin/domain/models/admin_user.dart';
import 'package:solar_hub/src/features/admin/domain/models/company_service.dart';
import 'package:solar_hub/src/features/admin/domain/models/service_catalog_item.dart';
import 'package:solar_hub/src/features/admin/domain/models/service_request.dart';
import 'package:solar_hub/src/shared/domain/company/company.dart';

abstract class AdminRepository {
  Future<List<Company>> listCompanies({String? status, int page = 1, int pageSize = 12});
  Future<void> updateCompanyStatus(int companyId, String status);
  Future<List<ServiceCatalogItem>> listServiceCatalog();
  Future<ServiceCatalogItem> createServiceCatalogEntry(ServiceCatalogItem item);
  Future<ServiceCatalogItem> updateServiceCatalogEntry(String serviceCode, Map<String, dynamic> data);
  Future<void> deleteServiceCatalogEntry(String serviceCode);
  Future<List<CompanyService>> listCompanyServices(int companyId);
  Future<AdminCompanyDetails> getCompanyDetails(int companyId);
  Future<List<ServiceRequest>> listServiceRequests({int page = 1, int pageSize = 12});
  Future<void> reviewServiceRequest(int companyId, String serviceCode, Map<String, dynamic> data);
  Future<void> toggleCompanyService(int companyId, String serviceCode, Map<String, dynamic> data);

  // Currencies
  Future<List<AdminCurrency>> listCurrencies({int page = 1, int pageSize = 12});
  Future<AdminCurrency> createCurrency(Map<String, dynamic> data);
  Future<AdminCurrency> updateCurrency(int id, Map<String, dynamic> data);
  Future<void> deleteCurrency(int id);

  // Countries
  Future<List<AdminCountry>> listCountries({int page = 1, int pageSize = 12});
  Future<AdminCountry> createCountry(Map<String, dynamic> data);
  Future<AdminCountry> updateCountry(int id, Map<String, dynamic> data);
  Future<void> deleteCountry(int id);

  // Cities
  Future<List<AdminCity>> listCities({int page = 1, int pageSize = 12});
  Future<AdminCity> createCity(Map<String, dynamic> data);
  Future<AdminCity> updateCity(int id, Map<String, dynamic> data);
  Future<void> deleteCity(int id);

  // Global Categories
  Future<List<AdminGlobalCategory>> listGlobalCategories({int page = 1, int pageSize = 12});
  Future<AdminGlobalCategory> createGlobalCategory(Map<String, dynamic> data);
  Future<AdminGlobalCategory> updateGlobalCategory(int id, Map<String, dynamic> data);
  Future<void> deleteGlobalCategory(int id);

  // Users
  Future<List<AdminUser>> listUsers({int page = 1, int pageSize = 12});
  Future<void> promoteUser(String username, bool promote);

  // Subscriptions
  Future<List<AdminSubscriptionPlan>> listSubscriptionPlans({int page = 1, int pageSize = 12});
  Future<AdminSubscriptionPlan> createSubscriptionPlan(Map<String, dynamic> data);
  Future<AdminSubscriptionPlan> updateSubscriptionPlan(int id, Map<String, dynamic> data);
  Future<void> deleteSubscriptionPlan(int id);
}
