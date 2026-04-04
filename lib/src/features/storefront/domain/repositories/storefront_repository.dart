import 'package:solar_hub/src/core/models/response.dart';
import 'package:solar_hub/src/features/storefront/domain/entities/storefront_models.dart';

abstract class StorefrontRepository {
  Future<StorefrontMeta> getMeta();
  Future<PaginatedItemsResponse<StorefrontProduct>> getProducts({
    required StorefrontAudience audience,
    required StorefrontQuery query,
    int? companyId,
  });
}
