import 'package:solar_hub/src/core/models/response.dart';
import 'package:solar_hub/src/features/storefront/data/datasources/storefront_remote_data_source.dart';
import 'package:solar_hub/src/features/storefront/domain/entities/storefront_models.dart';
import 'package:solar_hub/src/features/storefront/domain/repositories/storefront_repository.dart';

class StorefrontRepositoryImpl implements StorefrontRepository {
  final StorefrontRemoteDataSource _remoteDataSource;

  StorefrontRepositoryImpl(this._remoteDataSource);

  @override
  Future<StorefrontMeta> getMeta() {
    return _remoteDataSource.getMeta();
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
