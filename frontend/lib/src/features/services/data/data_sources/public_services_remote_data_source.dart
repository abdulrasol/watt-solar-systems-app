import 'package:solar_hub/src/core/services/dio.dart';
import 'package:solar_hub/src/shared/domain/company/company.dart';
import 'package:solar_hub/src/shared/domain/service_type.dart';
import 'package:solar_hub/src/features/services/domain/entities/public_companies_query.dart';
import 'package:solar_hub/src/features/services/domain/entities/public_companies_result.dart';
import 'package:solar_hub/src/utils/app_urls.dart';
import 'package:solar_hub/src/utils/helper_methods.dart';

abstract class PublicServicesRemoteDataSource {
  Future<List<ServiceType>> getTypes();
  Future<PublicCompaniesResult> getCompanies(PublicCompaniesQuery query);
  Future<Company> getCompanyDetails(int companyId);
}

class PublicServicesRemoteDataSourceImpl
    implements PublicServicesRemoteDataSource {
  final DioService _dioService;

  PublicServicesRemoteDataSourceImpl(this._dioService);

  @override
  Future<List<ServiceType>> getTypes() async {
    try {
      final response = await _dioService.get(
        AppUrls.serviceTypesPublic,
        isList: true,
      );
      return ((response as dynamic).body as List? ?? const [])
          .whereType<Map>()
          .map((item) => ServiceType.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e, stackTrace) {
      dPrint(
        'getTypes error: $e',
        stackTrace: stackTrace,
        tag: 'PublicServicesRemoteDataSourceImpl',
      );
      rethrow;
    }
  }

  @override
  Future<PublicCompaniesResult> getCompanies(PublicCompaniesQuery query) async {
    try {
      final response = await _dioService.getRawMap(
        AppUrls.publicCompanies,
        queryParameters: query.toQueryParameters(),
      );
      if ((response['status'] ?? 500) != 200 || response['error'] == true) {
        throw Exception(
          response['message_user'] ??
              response['message'] ??
              'Failed to load companies',
        );
      }

      final body = Map<String, dynamic>.from(
        response['body'] ?? const <String, dynamic>{},
      );
      final normalizedItems = (body['items'] as List? ?? const [])
          .whereType<Map>()
          .map((item) {
            final map = Map<String, dynamic>.from(item);
            // Only fall back to 'services' as 'public_services' if 'public_services' is missing
            // and the data looks like public services (not system features)
            if (map['public_services'] == null && map['services'] is List) {
              final servicesList = map['services'] as List;
              if (servicesList.isNotEmpty &&
                  (servicesList.first as Map).containsKey('title')) {
                map['public_services'] = map['services'];
                map['services'] =
                    const []; // Clear it only in this specific fallback case
              }
            }
            return map;
          })
          .toList();

      return PublicCompaniesResult(
        items: normalizedItems.map(Company.fromJson).toList(),
        count: int.tryParse(body['count']?.toString() ?? '') ?? 0,
        channel: body['channel']?.toString() ?? query.channel,
      );
    } catch (e, stackTrace) {
      dPrint(
        'getCompanies error: $e',
        stackTrace: stackTrace,
        tag: 'PublicServicesRemoteDataSourceImpl',
      );
      rethrow;
    }
  }

  @override
  Future<Company> getCompanyDetails(int companyId) async {
    try {
      final response = await _dioService.getRawMap(
        AppUrls.publicCompany(companyId),
      );
      if ((response['status'] ?? 500) != 200 || response['error'] == true) {
        throw Exception(
          response['message_user'] ??
              response['message'] ??
              'Failed to load company details',
        );
      }

      final body = Map<String, dynamic>.from(
        response['body'] ?? const <String, dynamic>{},
      );

      // Only fall back to 'services' as 'public_services' if 'public_services' is missing
      if (body['public_services'] == null && body['services'] is List) {
        final servicesList = body['services'] as List;
        if (servicesList.isNotEmpty &&
            (servicesList.first as Map).containsKey('title')) {
          body['public_services'] = body['services'];
          body['services'] = const [];
        }
      }

      return Company.fromJson(body);
    } catch (e, stackTrace) {
      dPrint(
        'getCompanyDetails error: $e',
        stackTrace: stackTrace,
        tag: 'PublicServicesRemoteDataSourceImpl',
      );
      rethrow;
    }
  }
}
