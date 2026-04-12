import 'package:solar_hub/src/core/models/response.dart';
import 'package:solar_hub/src/features/storefront/data/datasources/storefront_remote_data_source.dart';
import 'package:solar_hub/src/features/storefront/domain/entities/storefront_models.dart';
import 'package:solar_hub/src/features/storefront/domain/repositories/storefront_repository.dart';

class StorefrontRepositoryImpl implements StorefrontRepository {
  final StorefrontRemoteDataSource _remoteDataSource;

  StorefrontRepositoryImpl(this._remoteDataSource);

  StorefrontMeta? _metaCache;
  DateTime? _lastCacheTime;

  @override
  Future<StorefrontMeta> getMeta() async {
    final now = DateTime.now();
    if (_metaCache != null &&
        _lastCacheTime != null &&
        now.difference(_lastCacheTime!) < const Duration(minutes: 30)) {
      return _metaCache!;
    }

    _metaCache = await _remoteDataSource.getMeta();
    _lastCacheTime = now;
    return _metaCache!;
  }

  @override
  Future<PaginatedItemsResponse<StorefrontCompanyListItem>> getCompanies({
    required StorefrontAudience audience,
    required StorefrontCompanyQuery query,
  }) {
    return _remoteDataSource.getCompanies(audience: audience, query: query);
  }

  @override
  Future<List<StorefrontCompanyCategory>> getCompanyCategories(int companyId) {
    return _remoteDataSource.getCompanyCategories(companyId);
  }

  @override
  Future<PaginatedItemsResponse<StorefrontProduct>> getProducts({
    required StorefrontAudience audience,
    required StorefrontQuery query,
    int? companyId,
  }) {
    return _remoteDataSource.getProducts(
      audience: audience,
      query: query,
      companyId: companyId,
    );
  }
}
