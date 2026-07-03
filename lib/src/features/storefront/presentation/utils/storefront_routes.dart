import 'package:solar_hub/src/features/storefront/domain/entities/storefront_models.dart';

String storefrontLandingLocation({
  required StorefrontAudience audience,
  int? companyId,
}) {
  final uri = Uri(
    path: '/storefront',
    queryParameters: {
      'audience': audience.name,
      if (companyId != null) 'company_id': '$companyId',
    },
  );
  return uri.toString();
}

String storefrontProductsLocation({
  required StorefrontAudience audience,
  int? companyId,
  int? globalCategoryId,
  String? title,
}) {
  final uri = Uri(
    path: '/storefront/products',
    queryParameters: {
      'audience': audience.name,
      if (companyId != null) 'company_id': '$companyId',
      if (globalCategoryId != null) 'global_category_id': '$globalCategoryId',
      if (title != null && title.trim().isNotEmpty) 'title': title.trim(),
    },
  );
  return uri.toString();
}

String storefrontCompaniesLocation({required StorefrontAudience audience}) {
  final uri = Uri(
    path: '/storefront/companies',
    queryParameters: {'audience': audience.name},
  );
  return uri.toString();
}

StorefrontAudience storefrontAudienceFromQuery(String? value) {
  return value == 'b2b' ? StorefrontAudience.b2b : StorefrontAudience.b2c;
}
