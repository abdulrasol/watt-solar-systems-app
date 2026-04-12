import 'package:solar_hub/src/shared/domain/company/company_category.dart';
import 'package:solar_hub/src/shared/domain/company/company_contact.dart';
import 'package:solar_hub/src/shared/domain/company/company_public_service.dart';
import 'package:solar_hub/src/features/company_dashboard/data/data_sources/company_management_remote_data_source.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/entities/company_activation_reminder_response.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/entities/company_subscription_plan.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/entities/company_subscription_request.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/models/company_category_form_model.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/models/company_contact_form_model.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/models/company_public_service_form_model.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/models/company_subscription_request_form_model.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/repositories/company_management_repository.dart';

class CompanyManagementRepositoryImpl implements CompanyManagementRepository {
  CompanyManagementRepositoryImpl(this._remoteDataSource);

  final CompanyManagementRemoteDataSource _remoteDataSource;

  @override
  Future<List<CompanyCategory>> listCategories(int companyId) {
    return _remoteDataSource.listCategories(companyId);
  }

  @override
  Future<List<CompanyContact>> listContacts(
    int companyId, {
    int page = 1,
    int? pageSize,
  }) {
    return _remoteDataSource.listContacts(
      companyId,
      page: page,
      pageSize: pageSize,
    );
  }

  @override
  Future<List<CompanyPublicService>> listPublicServices(int companyId) {
    return _remoteDataSource.listPublicServices(companyId);
  }

  @override
  Future<CompanyCategory> createCategory(
    int companyId,
    CompanyCategoryFormModel payload,
  ) {
    return _remoteDataSource.createCategory(companyId, payload);
  }

  @override
  Future<CompanyContact> createContact(
    int companyId,
    CompanyContactFormModel payload,
  ) {
    return _remoteDataSource.createContact(companyId, payload);
  }

  @override
  Future<CompanyPublicService> createPublicService(
    int companyId,
    CompanyPublicServiceFormModel payload,
  ) {
    return _remoteDataSource.createPublicService(companyId, payload);
  }

  @override
  Future<void> deleteCategory(int companyId, int categoryId) {
    return _remoteDataSource.deleteCategory(companyId, categoryId);
  }

  @override
  Future<void> deleteContact(int companyId, int contactId) {
    return _remoteDataSource.deleteContact(companyId, contactId);
  }

  @override
  Future<void> deletePublicService(int companyId, int serviceId) {
    return _remoteDataSource.deletePublicService(companyId, serviceId);
  }

  @override
  Future<List<CompanySubscriptionPlan>> listSubscriptionPlans() {
    return _remoteDataSource.listSubscriptionPlans();
  }

  @override
  Future<CompanySubscriptionRequest> createSubscriptionRequest(
    int companyId,
    CompanySubscriptionRequestFormModel payload,
  ) {
    return _remoteDataSource.createSubscriptionRequest(companyId, payload);
  }

  @override
  Future<CompanyActivationReminderResponse> sendActivationReminder(
    int companyId,
  ) {
    return _remoteDataSource.sendActivationReminder(companyId);
  }

  @override
  Future<CompanyPublicService> updatePublicService(
    int companyId,
    int serviceId,
    CompanyPublicServiceFormModel payload,
  ) {
    return _remoteDataSource.updatePublicService(companyId, serviceId, payload);
  }
}
