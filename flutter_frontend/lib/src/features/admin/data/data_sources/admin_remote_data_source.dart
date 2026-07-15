import 'package:dio/dio.dart';
import 'package:watt/src/core/services/dio.dart';
import 'package:watt/src/core/models/response.dart' as api;
import 'package:watt/src/utils/app_urls.dart';

abstract class AdminRemoteDataSource {
  Future<api.PaginationResponse> listCompanies({String? status, int page = 1, int pageSize = 12});
  Future<api.Response> updateCompanyStatus(int companyId, String status);
  Future<api.PaginationResponse> listCompanyServices(int companyId);
  Future<api.Response> getCompanyDetails(int companyId);

  // Currencies
  Future<api.PaginationResponse> listCurrencies({int page = 1, int pageSize = 12});
  Future<api.Response> createCurrency(Map<String, dynamic> data);
  Future<api.Response> updateCurrency(int id, Map<String, dynamic> data);
  Future<api.Response> deleteCurrency(int id);

  // Countries
  Future<api.ListResponse> listCountries();
  Future<api.Response> createCountry(Map<String, dynamic> data);
  Future<api.Response> updateCountry(int id, Map<String, dynamic> data);
  Future<api.Response> deleteCountry(int id);

  // Cities
  Future<api.ListResponse> listCities({int? countryId});
  Future<api.Response> createCity(Map<String, dynamic> data);
  Future<api.Response> updateCity(int id, Map<String, dynamic> data);
  Future<api.Response> deleteCity(int id);

  // Global Categories
  Future<api.PaginationResponse> listGlobalCategories({int page = 1, int pageSize = 12});
  Future<api.Response> createGlobalCategory(Map<String, dynamic> data);
  Future<api.Response> updateGlobalCategory(int id, Map<String, dynamic> data);
  Future<api.Response> deleteGlobalCategory(int id);

  // Users
  Future<api.PaginationResponse> listUsers({int page = 1, int pageSize = 12});
  Future<api.Response> promoteUser(String username, bool promote);

  // Subscriptions
  Future<api.PaginationResponse> listSubscriptionPlans({int page = 1, int pageSize = 12});
  Future<api.Response> createSubscriptionPlan(Map<String, dynamic> data);
  Future<api.Response> updateSubscriptionPlan(int id, Map<String, dynamic> data);
  Future<api.Response> deleteSubscriptionPlan(int id);
  Future<api.PaginationResponse> listSubscriptionRequests({String? status, int page = 1, int pageSize = 12});
  Future<api.Response> reviewSubscriptionRequest(int companyId, int requestId, String status, {String? notes});

  // Feedbacks
  Future<api.PaginationResponse> listFeedbacks({int page = 1, int pageSize = 12});
  Future<api.Response> updateFeedbackStatus(int id, bool isRead);
  Future<api.Response> deleteFeedback(int id);

  // Notifications
  Future<api.PaginationResponse> listNotifications({int page = 1, int pageSize = 12});

  // Products
  Future<api.PaginationResponse> listAdminProducts({int page = 1, int pageSize = 12});

  /// [payload] is the JSON-encoded `AdminProductCreateSchema` body
  /// (includes `company_id`); [imagePaths] are local file paths to upload
  /// as the multipart `images` field, matching `POST /admin/shop/products`.
  Future<api.Response> createAdminProduct(String payload, {List<String> imagePaths = const []});

  /// [payload] is the JSON-encoded `AdminProductUpdateSchema` body
  /// (`company_id` optional — only send it to reassign the product to a
  /// different company).
  Future<api.Response> updateAdminProduct(int productId, String payload, {List<String> imagePaths = const []});

  Future<api.Response> deleteAdminProduct(int productId);

  // Systems
  Future<api.PaginationResponse> listAdminSystems({int page = 1, int pageSize = 12});

  /// Either field may be omitted — the backend only updates whichever of
  /// `user_status`/`company_status` is supplied, leaving the other as-is.
  Future<api.Response> updateAdminSystemStatus(int systemId, {String? userStatus, String? companyStatus});
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final DioService _dioService;

  AdminRemoteDataSourceImpl(this._dioService);

  @override
  Future<api.PaginationResponse> listCompanies({String? status, int page = 1, int pageSize = 12}) async {
    try {
      final queryParameters = <String, dynamic>{'page': page, 'page_size': pageSize};
      if (status != null) queryParameters['status'] = status;

      final response = await _dioService.get(AppUrls.companies, queryParameters: queryParameters, isPagination: true);
      return response as api.PaginationResponse;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<api.Response> updateCompanyStatus(int companyId, String status) async {
    try {
      return await _dioService.post(AppUrls.updateCompanyStatus(companyId), data: {'status': status});
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<api.PaginationResponse> listCompanyServices(int companyId) async {
    try {
      final response = await _dioService.get(AppUrls.companyAdminServices(companyId), isPagination: true);
      return response as api.PaginationResponse;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<api.Response> getCompanyDetails(int companyId) async {
    try {
      return await _dioService.get(AppUrls.companyAdminDetails(companyId)) as api.Response;
    } catch (e) {
      rethrow;
    }
  }

  // Currencies
  @override
  Future<api.PaginationResponse> listCurrencies({int page = 1, int pageSize = 12}) async {
    try {
      final queryParameters = <String, dynamic>{'page': page, 'page_size': pageSize};
      final response = await _dioService.get(AppUrls.currencies, queryParameters: queryParameters, isPagination: true);
      return response as api.PaginationResponse;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<api.Response> createCurrency(Map<String, dynamic> data) async {
    try {
      return await _dioService.post(AppUrls.currencies, data: data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<api.Response> updateCurrency(int id, Map<String, dynamic> data) async {
    try {
      return await _dioService.put(AppUrls.currency(id), data: data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<api.Response> deleteCurrency(int id) async {
    try {
      return await _dioService.delete(AppUrls.currency(id));
    } catch (e) {
      rethrow;
    }
  }

  // Countries
  @override
  Future<api.ListResponse> listCountries() async {
    try {
      final response = await _dioService.get(AppUrls.countries, isList: true);
      return response as api.ListResponse;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<api.Response> createCountry(Map<String, dynamic> data) async {
    try {
      return await _dioService.post(AppUrls.countries, data: data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<api.Response> updateCountry(int id, Map<String, dynamic> data) async {
    try {
      return await _dioService.put(AppUrls.country(id), data: data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<api.Response> deleteCountry(int id) async {
    try {
      return await _dioService.delete(AppUrls.country(id));
    } catch (e) {
      rethrow;
    }
  }

  // Cities
  @override
  Future<api.ListResponse> listCities({int? countryId}) async {
    try {
      final queryParameters = <String, dynamic>{};
      if (countryId != null) queryParameters['country_id'] = countryId;
      final response = await _dioService.get(AppUrls.cities, queryParameters: queryParameters, isList: true);
      return response as api.ListResponse;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<api.Response> createCity(Map<String, dynamic> data) async {
    try {
      return await _dioService.post(AppUrls.cities, data: data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<api.Response> updateCity(int id, Map<String, dynamic> data) async {
    try {
      return await _dioService.put(AppUrls.city(id), data: data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<api.Response> deleteCity(int id) async {
    try {
      return await _dioService.delete(AppUrls.city(id));
    } catch (e) {
      rethrow;
    }
  }

  // Global Categories
  @override
  Future<api.PaginationResponse> listGlobalCategories({int page = 1, int pageSize = 12}) async {
    try {
      final queryParameters = <String, dynamic>{'page': page, 'page_size': pageSize};
      final response = await _dioService.get(AppUrls.globalCategories, queryParameters: queryParameters, isPagination: true);
      return response as api.PaginationResponse;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<api.Response> createGlobalCategory(Map<String, dynamic> data) async {
    try {
      return await _dioService.post(AppUrls.globalCategories, data: data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<api.Response> updateGlobalCategory(int id, Map<String, dynamic> data) async {
    try {
      return await _dioService.put(AppUrls.globalCategory(id), data: data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<api.Response> deleteGlobalCategory(int id) async {
    try {
      return await _dioService.delete(AppUrls.globalCategory(id));
    } catch (e) {
      rethrow;
    }
  }

  // Users
  @override
  Future<api.PaginationResponse> listUsers({int page = 1, int pageSize = 12}) async {
    try {
      final queryParameters = <String, dynamic>{'page': page, 'page_size': pageSize};
      final response = await _dioService.get(AppUrls.allUsers, queryParameters: queryParameters, isPagination: true);
      return response as api.PaginationResponse;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<api.Response> promoteUser(String username, bool promote) async {
    try {
      return await _dioService.post(AppUrls.promoteUser(username), data: {'promote': promote});
    } catch (e) {
      rethrow;
    }
  }

  // Subscriptions
  @override
  Future<api.PaginationResponse> listSubscriptionPlans({int page = 1, int pageSize = 12}) async {
    try {
      final queryParameters = <String, dynamic>{'page': page, 'page_size': pageSize};
      final response = await _dioService.get(AppUrls.adminSubscriptions, queryParameters: queryParameters, isPagination: true);
      return response as api.PaginationResponse;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<api.Response> createSubscriptionPlan(Map<String, dynamic> data) async {
    try {
      return await _dioService.post(AppUrls.adminSubscriptions, data: data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<api.Response> updateSubscriptionPlan(int id, Map<String, dynamic> data) async {
    try {
      return await _dioService.put('${AppUrls.adminSubscriptions}/$id', data: data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<api.Response> deleteSubscriptionPlan(int id) async {
    try {
      return await _dioService.delete('${AppUrls.adminSubscriptions}/$id');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<api.PaginationResponse> listSubscriptionRequests({String? status, int page = 1, int pageSize = 12}) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
        'status': ?status,
      };
      final response = await _dioService.get(AppUrls.adminSubscriptionRequests, queryParameters: queryParameters, isPagination: true);
      return response as api.PaginationResponse;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<api.Response> reviewSubscriptionRequest(int companyId, int requestId, String status, {String? notes}) async {
    try {
      final data = <String, dynamic>{'status': status};
      if (notes != null) {
        data['notes'] = notes;
      }
      return await _dioService.post(AppUrls.adminReviewSubscriptionRequest(companyId, requestId), data: data);
    } catch (e) {
      rethrow;
    }
  }

  // Feedbacks
  @override
  Future<api.PaginationResponse> listFeedbacks({int page = 1, int pageSize = 12}) async {
    try {
      final queryParameters = <String, dynamic>{'page': page, 'page_size': pageSize};
      final response = await _dioService.get(AppUrls.feedbacks, queryParameters: queryParameters, isPagination: true);
      return response as api.PaginationResponse;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<api.Response> updateFeedbackStatus(int id, bool isRead) async {
    try {
      return await _dioService.put(AppUrls.feedbackStatus(id), data: {'is_read': isRead});
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<api.Response> deleteFeedback(int id) async {
    try {
      return await _dioService.delete(AppUrls.feedback(id));
    } catch (e) {
      rethrow;
    }
  }

  // Notifications
  @override
  Future<api.PaginationResponse> listNotifications({int page = 1, int pageSize = 12}) async {
    try {
      final queryParameters = <String, dynamic>{'page': page, 'page_size': pageSize};
      final response = await _dioService.get('${AppUrls.baseUrl}/notifications', queryParameters: queryParameters, isPagination: true);
      return response as api.PaginationResponse;
    } catch (e) {
      rethrow;
    }
  }

  // Products
  @override
  Future<api.PaginationResponse> listAdminProducts({int page = 1, int pageSize = 12}) async {
    try {
      final queryParameters = <String, dynamic>{'page': page, 'page_size': pageSize};
      final response = await _dioService.get(AppUrls.adminProducts, queryParameters: queryParameters, isPagination: true);
      return response as api.PaginationResponse;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<api.Response> createAdminProduct(String payload, {List<String> imagePaths = const []}) async {
    try {
      final formData = FormData();
      formData.fields.add(MapEntry('payload', payload));
      for (final path in imagePaths) {
        formData.files.add(MapEntry('images', await MultipartFile.fromFile(path, filename: path.split('/').last)));
      }
      return await _dioService.multipartRequest(AppUrls.adminProducts, file: formData);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<api.Response> updateAdminProduct(int productId, String payload, {List<String> imagePaths = const []}) async {
    try {
      final formData = FormData();
      formData.fields.add(MapEntry('payload', payload));
      for (final path in imagePaths) {
        formData.files.add(MapEntry('images', await MultipartFile.fromFile(path, filename: path.split('/').last)));
      }
      return await _dioService.multipartRequest(AppUrls.adminProduct(productId), file: formData, isPut: true);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<api.Response> deleteAdminProduct(int productId) async {
    try {
      return await _dioService.delete(AppUrls.adminProduct(productId));
    } catch (e) {
      rethrow;
    }
  }

  // Systems
  @override
  Future<api.PaginationResponse> listAdminSystems({int page = 1, int pageSize = 12}) async {
    try {
      final queryParameters = <String, dynamic>{'page': page, 'page_size': pageSize};
      final response = await _dioService.get(AppUrls.adminSystems, queryParameters: queryParameters, isPagination: true);
      return response as api.PaginationResponse;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<api.Response> updateAdminSystemStatus(int systemId, {String? userStatus, String? companyStatus}) async {
    try {
      final data = <String, dynamic>{};
      if (userStatus != null) data['user_status'] = userStatus;
      if (companyStatus != null) data['company_status'] = companyStatus;
      return await _dioService.put(AppUrls.adminSystemStatus(systemId), data: data);
    } catch (e) {
      rethrow;
    }
  }
}
