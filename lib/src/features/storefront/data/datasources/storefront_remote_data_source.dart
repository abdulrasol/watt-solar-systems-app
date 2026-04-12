import 'package:solar_hub/src/core/models/response.dart';
import 'package:solar_hub/src/core/services/dio.dart';
import 'package:solar_hub/src/features/storefront/domain/entities/storefront_models.dart';
import 'package:solar_hub/src/utils/app_urls.dart';
import 'package:solar_hub/src/utils/helper_methods.dart';

abstract class StorefrontRemoteDataSource {
  Future<StorefrontMeta> getMeta();
  Future<PaginatedItemsResponse<StorefrontCompanyListItem>> getCompanies({
    required StorefrontAudience audience,
    required StorefrontCompanyQuery query,
  });
  Future<List<StorefrontCompanyCategory>> getCompanyCategories(int companyId);
  Future<PaginatedItemsResponse<StorefrontProduct>> getProducts({
    required StorefrontAudience audience,
    required StorefrontQuery query,
    int? companyId,
  });
}

class StorefrontRemoteDataSourceImpl implements StorefrontRemoteDataSource {
  final DioService _dioService;

  StorefrontRemoteDataSourceImpl(this._dioService);

  @override
  Future<StorefrontMeta> getMeta() async {
    try {
      final response = await _dioService.getRawMap(AppUrls.shopCatalogMeta);
      _ensureSuccess(
        response,
        fallbackMessage: 'Failed to load storefront metadata',
      );
      return StorefrontMeta.fromJson(
        Map<String, dynamic>.from(
          response['body'] ?? const <String, dynamic>{},
        ),
      );
    } catch (e, stackTrace) {
      dPrint(
        'getMeta error: $e',
        stackTrace: stackTrace,
        tag: 'StorefrontRemoteDataSourceImpl',
      );
      rethrow;
    }
  }

  @override
  Future<PaginatedItemsResponse<StorefrontCompanyListItem>> getCompanies({
    required StorefrontAudience audience,
    required StorefrontCompanyQuery query,
  }) async {
    try {
      final response = await _dioService.getRawMap(
        AppUrls.storefrontCompanies,
        queryParameters: query.toQueryParameters(),
      );
      _ensureSuccess(
        response,
        fallbackMessage: 'Failed to load storefront companies',
      );
      return PaginatedItemsResponse<StorefrontCompanyListItem>.fromJson(
        response,
        StorefrontCompanyListItem.fromJson,
      );
    } catch (e, stackTrace) {
      dPrint(
        'getCompanies error: $e for ${audience.name}',
        stackTrace: stackTrace,
        tag: 'StorefrontRemoteDataSourceImpl',
      );
      rethrow;
    }
  }

  @override
  Future<List<StorefrontCompanyCategory>> getCompanyCategories(
    int companyId,
  ) async {
    try {
      final response = await _dioService.getRawMap(
        AppUrls.storefrontCompanyCategories(companyId),
      );
      _ensureSuccess(
        response,
        fallbackMessage: 'Failed to load storefront company categories',
      );
      final body = response['body'] as List? ?? const [];
      return body.whereType<Map>().map((item) {
        return StorefrontCompanyCategory.fromJson(
          Map<String, dynamic>.from(item),
        );
      }).toList();
    } catch (e, stackTrace) {
      dPrint(
        'getCompanyCategories error: $e for company $companyId',
        stackTrace: stackTrace,
        tag: 'StorefrontRemoteDataSourceImpl',
      );
      rethrow;
    }
  }

  @override
  Future<PaginatedItemsResponse<StorefrontProduct>> getProducts({
    required StorefrontAudience audience,
    required StorefrontQuery query,
    int? companyId,
  }) async {
    try {
      final response = await _dioService.getRawMap(
        _resolveProductEndpoint(audience: audience, companyId: companyId),
        queryParameters: query.toQueryParameters(),
      );
      _ensureSuccess(
        response,
        fallbackMessage: 'Failed to load storefront products',
      );

      return PaginatedItemsResponse<StorefrontProduct>.fromJson(
        response,
        StorefrontProduct.fromJson,
      );
    } catch (e, stackTrace) {
      dPrint(
        'getProducts error: $e',
        stackTrace: stackTrace,
        tag: 'StorefrontRemoteDataSourceImpl',
      );
      rethrow;
    }
  }

  String _resolveProductEndpoint({
    required StorefrontAudience audience,
    int? companyId,
  }) {
    if (audience == StorefrontAudience.b2b) {
      if (companyId != null) return AppUrls.b2bCompanyProducts(companyId);
      return AppUrls.b2bProducts;
    }

    if (companyId != null) return AppUrls.b2cCompanyProducts(companyId);
    return AppUrls.b2cProducts;
  }

  void _ensureSuccess(
    Map<String, dynamic> response, {
    required String fallbackMessage,
  }) {
    if ((response['status'] ?? 500) != 200 || response['error'] == true) {
      throw Exception(
        response['message_user'] ?? response['message'] ?? fallbackMessage,
      );
    }
  }
}
