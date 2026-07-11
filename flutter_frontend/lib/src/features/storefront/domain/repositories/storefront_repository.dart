import 'package:watt/src/core/models/response.dart';
import 'package:watt/src/features/storefront/domain/entities/storefront_models.dart';

abstract class StorefrontRepository {
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
  Future<StorefrontProduct> getProduct(int id, StorefrontAudience audience);
  Future<StorefrontCartValidateResponse> validateCart(
    StorefrontCartValidateRequest request,
  );
}
