import 'package:dio/dio.dart';
import 'package:solar_hub/src/core/models/response.dart' as api;
import 'package:solar_hub/src/core/services/dio.dart';
import 'package:solar_hub/src/shared/domain/company/company_category.dart';
import 'package:solar_hub/src/shared/domain/company/company_contact.dart';
import 'package:solar_hub/src/shared/domain/company/company_public_service.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/entities/company_activation_reminder_response.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/entities/company_subscription_plan.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/entities/company_subscription_request.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/models/company_category_form_model.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/models/company_contact_form_model.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/models/company_public_service_form_model.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/models/company_subscription_request_form_model.dart';
import 'package:solar_hub/src/utils/app_urls.dart';
import 'package:solar_hub/src/utils/helper_methods.dart';

abstract class CompanyManagementRemoteDataSource {
  Future<List<CompanyContact>> listContacts(
    int companyId, {
    int page = 1,
    int? pageSize,
  });

  Future<CompanyContact> createContact(
    int companyId,
    CompanyContactFormModel payload,
  );

  Future<void> deleteContact(int companyId, int contactId);

  Future<List<CompanyPublicService>> listPublicServices(int companyId);

  Future<CompanyPublicService> createPublicService(
    int companyId,
    CompanyPublicServiceFormModel payload,
  );

  Future<CompanyPublicService> updatePublicService(
    int companyId,
    int serviceId,
    CompanyPublicServiceFormModel payload,
  );

  Future<void> deletePublicService(int companyId, int serviceId);

  Future<List<CompanyCategory>> listCategories(int companyId);

  Future<CompanyCategory> createCategory(
    int companyId,
    CompanyCategoryFormModel payload,
  );

  Future<void> deleteCategory(int companyId, int categoryId);

  Future<List<CompanySubscriptionPlan>> listSubscriptionPlans();

  Future<CompanySubscriptionRequest> createSubscriptionRequest(
    int companyId,
    CompanySubscriptionRequestFormModel payload,
  );

  Future<CompanyActivationReminderResponse> sendActivationReminder(
    int companyId,
  );
}

class CompanyManagementRemoteDataSourceImpl
    implements CompanyManagementRemoteDataSource {
  CompanyManagementRemoteDataSourceImpl(this._dioService);

  final DioService _dioService;

  @override
  Future<List<CompanyContact>> listContacts(
    int companyId, {
    int page = 1,
    int? pageSize,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      }..removeWhere((key, value) => value == null);
      final response = await _dioService.getRawMap(
        AppUrls.contacts(companyId),
        queryParameters: queryParameters,
      );
      final pagination = api.PaginationResponse.fromJson(response);
      final items = List<Map<String, dynamic>>.from(
        (pagination.body as List? ?? const []).whereType<Map>().map(
          (item) => Map<String, dynamic>.from(item),
        ),
      );
      return items
          .map<CompanyContact>(CompanyContact.fromJson)
          .toList(growable: false);
    } catch (e, stackTrace) {
      dPrint(
        'listContacts error: $e',
        stackTrace: stackTrace,
        tag: 'CompanyManagementRemoteDataSource',
      );
      rethrow;
    }
  }

  @override
  Future<CompanyContact> createContact(
    int companyId,
    CompanyContactFormModel payload,
  ) async {
    try {
      final response = await _dioService.post(
        AppUrls.contacts(companyId),
        data: payload.toJson(),
      );
      return CompanyContact.fromJson(
        Map<String, dynamic>.from(response.body as Map),
      );
    } catch (e, stackTrace) {
      dPrint(
        'createContact error: $e',
        stackTrace: stackTrace,
        tag: 'CompanyManagementRemoteDataSource',
      );
      rethrow;
    }
  }

  @override
  Future<void> deleteContact(int companyId, int contactId) async {
    try {
      await _dioService.delete(AppUrls.deleteContact(companyId, contactId));
    } catch (e, stackTrace) {
      dPrint(
        'deleteContact error: $e',
        stackTrace: stackTrace,
        tag: 'CompanyManagementRemoteDataSource',
      );
      rethrow;
    }
  }

  @override
  Future<List<CompanyPublicService>> listPublicServices(int companyId) async {
    try {
      final response = await _dioService.get(AppUrls.publicServices(companyId));
      final pagination = api.PaginationResponse.fromJson({
        'status': response.status,
        'message': response.message,
        'body': response.body,
        'error': response.error,
        'message_user': response.messageUser,
      });
      final items = List<Map<String, dynamic>>.from(
        (pagination.body as List? ?? const []).whereType<Map>().map(
          (item) => Map<String, dynamic>.from(item),
        ),
      );
      return items
          .map<CompanyPublicService>(CompanyPublicService.fromJson)
          .toList(growable: false);
    } catch (e, stackTrace) {
      dPrint(
        'listPublicServices error: $e',
        stackTrace: stackTrace,
        tag: 'CompanyManagementRemoteDataSource',
      );
      rethrow;
    }
  }

  @override
  Future<CompanyPublicService> createPublicService(
    int companyId,
    CompanyPublicServiceFormModel payload,
  ) async {
    try {
      final response = await _dioService.post(
        AppUrls.publicServices(companyId),
        data: payload.toJson(),
      );
      return CompanyPublicService.fromJson(
        Map<String, dynamic>.from(response.body as Map),
      );
    } catch (e, stackTrace) {
      dPrint(
        'createPublicService error: $e',
        stackTrace: stackTrace,
        tag: 'CompanyManagementRemoteDataSource',
      );
      rethrow;
    }
  }

  @override
  Future<CompanyPublicService> updatePublicService(
    int companyId,
    int serviceId,
    CompanyPublicServiceFormModel payload,
  ) async {
    try {
      final response = await _dioService.put(
        AppUrls.publicService(companyId, serviceId),
        data: payload.toJson(),
      );
      return CompanyPublicService.fromJson(
        Map<String, dynamic>.from(response.body as Map),
      );
    } catch (e, stackTrace) {
      dPrint(
        'updatePublicService error: $e',
        stackTrace: stackTrace,
        tag: 'CompanyManagementRemoteDataSource',
      );
      rethrow;
    }
  }

  @override
  Future<void> deletePublicService(int companyId, int serviceId) async {
    try {
      await _dioService.delete(AppUrls.publicService(companyId, serviceId));
    } catch (e, stackTrace) {
      dPrint(
        'deletePublicService error: $e',
        stackTrace: stackTrace,
        tag: 'CompanyManagementRemoteDataSource',
      );
      rethrow;
    }
  }

  @override
  Future<List<CompanyCategory>> listCategories(int companyId) async {
    try {
      final response = await _dioService.get(AppUrls.categories(companyId));
      final rawBody = response.body;
      final body = rawBody is List ? rawBody : <dynamic>[];
      final items = List<Map<String, dynamic>>.from(
        body.whereType<Map>().map((item) => Map<String, dynamic>.from(item)),
      );
      return items
          .map<CompanyCategory>(CompanyCategory.fromJson)
          .toList(growable: false);
    } catch (e, stackTrace) {
      dPrint(
        'listCategories error: $e',
        stackTrace: stackTrace,
        tag: 'CompanyManagementRemoteDataSource',
      );
      rethrow;
    }
  }

  @override
  Future<CompanyCategory> createCategory(
    int companyId,
    CompanyCategoryFormModel payload,
  ) async {
    try {
      final response = await _dioService.post(
        AppUrls.categories(companyId),
        data: payload.toJson(),
      );
      return CompanyCategory.fromJson(
        Map<String, dynamic>.from(response.body as Map),
      );
    } catch (e, stackTrace) {
      dPrint(
        'createCategory error: $e',
        stackTrace: stackTrace,
        tag: 'CompanyManagementRemoteDataSource',
      );
      rethrow;
    }
  }

  @override
  Future<void> deleteCategory(int companyId, int categoryId) async {
    try {
      await _dioService.delete(AppUrls.deleteCategory(companyId, categoryId));
    } catch (e, stackTrace) {
      dPrint(
        'deleteCategory error: $e',
        stackTrace: stackTrace,
        tag: 'CompanyManagementRemoteDataSource',
      );
      rethrow;
    }
  }

  @override
  Future<List<CompanySubscriptionPlan>> listSubscriptionPlans() async {
    try {
      final response = await _dioService.get(AppUrls.companySubscriptions);
      final pagination = api.PaginationResponse.fromJson({
        'status': response.status,
        'message': response.message,
        'body': response.body,
        'error': response.error,
        'message_user': response.messageUser,
      });
      final items = List<Map<String, dynamic>>.from(
        (pagination.body as List? ?? const []).whereType<Map>().map(
          (item) => Map<String, dynamic>.from(item),
        ),
      );
      return items
          .map<CompanySubscriptionPlan>(CompanySubscriptionPlan.fromJson)
          .where((plan) => plan.isActive)
          .toList(growable: false);
    } catch (e, stackTrace) {
      dPrint(
        'listSubscriptionPlans error: $e',
        stackTrace: stackTrace,
        tag: 'CompanyManagementRemoteDataSource',
      );
      rethrow;
    }
  }

  @override
  Future<CompanySubscriptionRequest> createSubscriptionRequest(
    int companyId,
    CompanySubscriptionRequestFormModel payload,
  ) async {
    try {
      final formData = FormData();
      formData.fields.add(
        MapEntry('subscription_plan', payload.subscriptionPlan.toString()),
      );
      if (payload.notes != null && payload.notes!.trim().isNotEmpty) {
        formData.fields.add(MapEntry('notes', payload.notes!.trim()));
      }
      if (payload.imagePath != null && payload.imagePath!.isNotEmpty) {
        formData.files.add(
          MapEntry(
            'image',
            await MultipartFile.fromFile(
              payload.imagePath!,
              filename: payload.imagePath!.split('/').last,
            ),
          ),
        );
      }

      final response = await _dioService.multipartRequest(
        AppUrls.companySubscriptionRequest(companyId),
        file: formData,
      );
      return CompanySubscriptionRequest.fromJson(
        Map<String, dynamic>.from(response.body as Map),
      );
    } catch (e, stackTrace) {
      dPrint(
        'createSubscriptionRequest error: $e',
        stackTrace: stackTrace,
        tag: 'CompanyManagementRemoteDataSource',
      );
      rethrow;
    }
  }

  @override
  Future<CompanyActivationReminderResponse> sendActivationReminder(
    int companyId,
  ) async {
    try {
      final response = await _dioService.post(
        AppUrls.companyActivationReminder(companyId),
        data: const <String, dynamic>{},
      );
      return CompanyActivationReminderResponse.fromJson(
        Map<String, dynamic>.from(response.body as Map),
      );
    } catch (e, stackTrace) {
      dPrint(
        'sendActivationReminder error: $e',
        stackTrace: stackTrace,
        tag: 'CompanyManagementRemoteDataSource',
      );
      rethrow;
    }
  }
}
