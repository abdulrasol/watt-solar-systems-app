import 'package:watt/src/core/models/response.dart';
import 'package:watt/src/features/storefront/data/data_sources/storefront_remote_data_source.dart';
import 'package:watt/src/features/storefront/domain/entities/storefront_models.dart';
import 'package:watt/src/features/storefront/domain/repositories/storefront_repository.dart';

class StorefrontRepositoryImpl implements StorefrontRepository {
  final StorefrontRemoteDataSource _remoteDataSource;

  StorefrontRepositoryImpl(this._remoteDataSource);

  @override
  Future<StorefrontMeta> getMeta() => _remoteDataSource.getMeta();

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
