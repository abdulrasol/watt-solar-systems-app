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

abstract class CompanyManagementRepository {
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
