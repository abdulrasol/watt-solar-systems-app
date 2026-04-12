import 'package:solar_hub/src/core/services/dio.dart';
import 'package:solar_hub/src/shared/domain/company/company.dart';
import 'package:solar_hub/src/shared/domain/company/company_type.dart';
import 'package:solar_hub/src/features/services/domain/entities/public_companies_query.dart';
import 'package:solar_hub/src/features/services/domain/entities/public_companies_result.dart';
import 'package:solar_hub/src/utils/app_urls.dart';
import 'package:solar_hub/src/utils/helper_methods.dart';

abstract class PublicServicesRemoteDataSource {
  Future<List<CompanyType>> getTypes();
  Future<PublicCompaniesResult> getCompanies(PublicCompaniesQuery query);
  Future<Company> getCompanyDetails(int companyId);
}

class PublicServicesRemoteDataSourceImpl
    implements PublicServicesRemoteDataSource {
  final DioService _dioService;

  PublicServicesRemoteDataSourceImpl(this._dioService);

  @override
  Future<List<CompanyType>> getTypes() async {
    try {
      final response = await _dioService.getRawMap(AppUrls.companyTypes);
      if ((response['status'] ?? 500) != 200 || response['error'] == true) {
        throw Exception(
          response['message_user'] ??
              response['message'] ??
              'Failed to load company types',
        );
      }

      return (response['body'] as List? ?? const [])
          .whereType<Map>()
          .map((item) => CompanyType.fromJson(Map<String, dynamic>.from(item)))
          .where((type) => !type.isPlaceholder)
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
            if (map['services'] is List && map['public_services'] == null) {
              map['public_services'] = map['services'];
            }
            map['services'] = const [];
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
      if (body['services'] is List && body['public_services'] == null) {
        body['public_services'] = body['services'];
      }
      body['services'] = const [];

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
