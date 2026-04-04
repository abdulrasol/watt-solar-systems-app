import 'package:solar_hub/src/core/models/response.dart';
import 'package:solar_hub/src/core/services/dio.dart';
import 'package:solar_hub/src/features/storefront/domain/entities/storefront_models.dart';
import 'package:solar_hub/src/utils/app_urls.dart';

abstract class StorefrontRemoteDataSource {
  Future<StorefrontMeta> getMeta();
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
    final response = await _dioService.getRawMap(AppUrls.shopCatalogMeta);
    if ((response['status'] ?? 500) != 200 || response['error'] == true) {
      throw Exception(
        response['message_user'] ??
            response['message'] ??
            'Failed to load storefront metadata',
      );
    }
    return StorefrontMeta.fromJson(
      Map<String, dynamic>.from(response['body'] ?? const <String, dynamic>{}),
    );
  }

  @override
  Future<PaginatedItemsResponse<StorefrontProduct>> getProducts({
    required StorefrontAudience audience,
    required StorefrontQuery query,
    int? companyId,
  }) async {
    final endpoint = _resolveEndpoint(
      audience: audience,
      query: query,
      companyId: companyId,
    );

    final response = await _dioService.getRawMap(
      endpoint,
      queryParameters: query.toQueryParameters(),
    );
    if ((response['status'] ?? 500) != 200 || response['error'] == true) {
      throw Exception(
        response['message_user'] ??
            response['message'] ??
            'Failed to load storefront products',
      );
    }

    return PaginatedItemsResponse<StorefrontProduct>.fromJson(
      response,
      StorefrontProduct.fromJson,
    );
  }

  String _resolveEndpoint({
    required StorefrontAudience audience,
    required StorefrontQuery query,
    int? companyId,
  }) {
    final hasSearch = query.search.trim().isNotEmpty;

    if (audience == StorefrontAudience.b2b) {
      if (companyId != null) return AppUrls.b2bCompanyProducts(companyId);
      return hasSearch ? AppUrls.b2bSearch : AppUrls.b2bProducts;
    }

    if (companyId != null) return AppUrls.b2cCompanyProducts(companyId);
    return hasSearch ? AppUrls.b2cSearch : AppUrls.b2cProducts;
  }
}
