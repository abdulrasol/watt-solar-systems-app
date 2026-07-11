import 'package:watt/src/core/models/response.dart';
import 'package:watt/src/core/services/dio.dart';
import 'package:watt/src/features/storefront/domain/entities/storefront_models.dart';
import 'package:watt/src/utils/app_urls.dart';
import 'package:watt/src/utils/helper_methods.dart';

abstract class StorefrontRemoteDataSource {
  Future<StorefrontMeta> getMeta();
  Future<PaginatedItemsResponse<StorefrontCompanyListItem>> getCompanies({required StorefrontAudience audience, required StorefrontCompanyQuery query});
  Future<List<StorefrontCompanyCategory>> getCompanyCategories(int companyId);
  Future<PaginatedItemsResponse<StorefrontProduct>> getProducts({required StorefrontAudience audience, required StorefrontQuery query, int? companyId});
  Future<StorefrontProduct> getProduct(int id, StorefrontAudience audience);
  Future<StorefrontCartValidateResponse> validateCart(StorefrontCartValidateRequest request);
}

class StorefrontRemoteDataSourceImpl implements StorefrontRemoteDataSource {
  final DioService _dioService;

  StorefrontRemoteDataSourceImpl(this._dioService);

  @override
  Future<StorefrontMeta> getMeta() async {
    try {
      final response = await _dioService.getRawMap(AppUrls.shopCatalogMeta);
      _ensureSuccess(response, fallbackMessage: 'Failed to load storefront metadata');
      return StorefrontMeta.fromJson(Map<String, dynamic>.from(response['body'] ?? const <String, dynamic>{}));
    } catch (e, stackTrace) {
      dPrint('getMeta error: $e', stackTrace: stackTrace, tag: 'StorefrontRemoteDataSourceImpl');
      rethrow;
    }
  }

  @override
  Future<PaginatedItemsResponse<StorefrontCompanyListItem>> getCompanies({required StorefrontAudience audience, required StorefrontCompanyQuery query}) async {
    try {
      final response = await _dioService.getRawMap(AppUrls.storefrontCompanies, queryParameters: query.toQueryParameters());
      _ensureSuccess(response, fallbackMessage: 'Failed to load storefront companies');
      return PaginatedItemsResponse<StorefrontCompanyListItem>.fromJson(response, StorefrontCompanyListItem.fromJson);
    } catch (e, stackTrace) {
      dPrint('getCompanies error: $e for ${audience.name}', stackTrace: stackTrace, tag: 'StorefrontRemoteDataSourceImpl');
      rethrow;
    }
  }

  @override
  Future<List<StorefrontCompanyCategory>> getCompanyCategories(int companyId) async {
    try {
      final response = await _dioService.getRawMap(AppUrls.storefrontCompanyCategories(companyId));
      _ensureSuccess(response, fallbackMessage: 'Failed to load storefront company categories');
      final body = response['body'];
      if (body is! List) {
        return const [];
      }
      return body.whereType<Map>().map((item) {
        return StorefrontCompanyCategory.fromJson(Map<String, dynamic>.from(item));
      }).toList();
    } catch (e, stackTrace) {
      dPrint('getCompanyCategories error: $e for company $companyId', stackTrace: stackTrace, tag: 'StorefrontRemoteDataSourceImpl');
      rethrow;
    }
  }

  @override
  Future<PaginatedItemsResponse<StorefrontProduct>> getProducts({required StorefrontAudience audience, required StorefrontQuery query, int? companyId}) async {
    try {
      final url = audience == StorefrontAudience.b2b
          ? (companyId != null ? AppUrls.b2bCompanyProducts(companyId) : AppUrls.b2bProducts)
          : (companyId != null ? AppUrls.b2cCompanyProducts(companyId) : AppUrls.b2cProducts);
      final response = await _dioService.getRawMap(url, queryParameters: query.toQueryParameters());
      _ensureSuccess(response, fallbackMessage: 'Failed to load storefront products');
      return PaginatedItemsResponse<StorefrontProduct>.fromJson(response, StorefrontProduct.fromJson);
    } catch (e, stackTrace) {
      dPrint('getProducts error: $e for ${audience.name}', stackTrace: stackTrace, tag: 'StorefrontRemoteDataSourceImpl');
      rethrow;
    }
  }

  @override
  Future<StorefrontProduct> getProduct(int id, StorefrontAudience audience) async {
    try {
      final url = audience == StorefrontAudience.b2b ? AppUrls.b2bProduct(id) : AppUrls.b2cProduct(id);
      final response = await _dioService.getRawMap(url);
      _ensureSuccess(response, fallbackMessage: 'Failed to load storefront product');
      return StorefrontProduct.fromJson(Map<String, dynamic>.from(response['body'] ?? const <String, dynamic>{}));
    } catch (e, stackTrace) {
      dPrint('getProduct error: $e for product $id', stackTrace: stackTrace, tag: 'StorefrontRemoteDataSourceImpl');
      rethrow;
    }
  }

  @override
  Future<StorefrontCartValidateResponse> validateCart(StorefrontCartValidateRequest request) async {
    try {
      final response = await _dioService.post(AppUrls.shopCartValidate, data: request.toJson());
      if (response.status != 200 || response.error) {
        throw Exception(response.messageUser.isNotEmpty ? response.messageUser : (response.message.isNotEmpty ? response.message : 'Failed to validate cart'));
      }

      final body = Map<String, dynamic>.from(response.body ?? const <String, dynamic>{});
      return StorefrontCartValidateResponse.fromJson(body);
    } catch (e, stackTrace) {
      dPrint('validateCart error: $e', stackTrace: stackTrace, tag: 'StorefrontRemoteDataSourceImpl');
      rethrow;
    }
  }

  void _ensureSuccess(Map<String, dynamic> response, {required String fallbackMessage}) {
    if ((response['status'] ?? 500) != 200 || response['error'] == true) {
      throw Exception(response['message_user'] ?? response['message'] ?? fallbackMessage);
    }
  }
}
