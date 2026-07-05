import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/shared/domain/company/company.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/entities/company_activation_reminder_response.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/entities/company_subscription_plan.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/entities/company_subscription_request.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/models/company_subscription_request_form_model.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/repositories/company_management_repository.dart';

class CompanyActivationState {
  const CompanyActivationState({
    this.companyId,
    this.isLoadingPlans = false,
    this.isSubmittingSubscription = false,
    this.isSendingReminder = false,
    this.plans = const [],
    this.plansError,
    this.selectedPlanId,
    this.subscriptionRequest,
    this.reminderResponse,
  });

  final int? companyId;
  final bool isLoadingPlans;
  final bool isSubmittingSubscription;
  final bool isSendingReminder;
  final List<CompanySubscriptionPlan> plans;
  final String? plansError;
  final int? selectedPlanId;
  final CompanySubscriptionRequest? subscriptionRequest;
  final CompanyActivationReminderResponse? reminderResponse;

  CompanySubscriptionPlan? get selectedPlan {
    if (selectedPlanId == null) return null;
    for (final plan in plans) {
      if (plan.id == selectedPlanId) return plan;
    }
    return null;
  }

  CompanyActivationState copyWith({
    int? companyId,
    bool? isLoadingPlans,
    bool? isSubmittingSubscription,
    bool? isSendingReminder,
    List<CompanySubscriptionPlan>? plans,
    Object? plansError = _activationSentinel,
    Object? selectedPlanId = _activationSentinel,
    Object? subscriptionRequest = _activationSentinel,
    Object? reminderResponse = _activationSentinel,
  }) {
    return CompanyActivationState(
      companyId: companyId ?? this.companyId,
      isLoadingPlans: isLoadingPlans ?? this.isLoadingPlans,
      isSubmittingSubscription:
          isSubmittingSubscription ?? this.isSubmittingSubscription,
      isSendingReminder: isSendingReminder ?? this.isSendingReminder,
      plans: plans ?? this.plans,
      plansError: plansError == _activationSentinel
          ? this.plansError
          : plansError as String?,
      selectedPlanId: selectedPlanId == _activationSentinel
          ? this.selectedPlanId
          : selectedPlanId as int?,
      subscriptionRequest: subscriptionRequest == _activationSentinel
          ? this.subscriptionRequest
          : subscriptionRequest as CompanySubscriptionRequest?,
      reminderResponse: reminderResponse == _activationSentinel
          ? this.reminderResponse
          : reminderResponse as CompanyActivationReminderResponse?,
    );
  }
}

const _activationSentinel = Object();

class CompanyActivationController extends Notifier<CompanyActivationState> {
  late final CompanyManagementRepository _repository;

  @override
  CompanyActivationState build() {
    _repository = getIt<CompanyManagementRepository>();
    return const CompanyActivationState();
  }

  Future<void> syncCompany(Company company) async {
    if (state.companyId != company.id) {
      state = CompanyActivationState(companyId: company.id);
    }

    if (!company.requiresSubscriptionRenewal) {
      state = state.copyWith(
        subscriptionRequest: null,
        plansError: null,
      );
      return;
    }

    if (state.subscriptionRequest != null &&
        state.subscriptionRequest!.isPending) {
      return;
    }

    if (state.plans.isNotEmpty || state.isLoadingPlans) return;
    await loadSubscriptionPlans();
  }

  Future<void> loadSubscriptionPlans() async {
    state = state.copyWith(isLoadingPlans: true, plansError: null);
    try {
      final plans = await _repository.listSubscriptionPlans();
      state = state.copyWith(
        isLoadingPlans: false,
        plans: plans,
        selectedPlanId: plans.isNotEmpty ? plans.first.id : null,
      );
    } catch (e) {
      state = state.copyWith(isLoadingPlans: false, plansError: e.toString());
    }
  }

  void selectPlan(int planId) {
    state = state.copyWith(selectedPlanId: planId);
  }

  Future<CompanySubscriptionRequest> createSubscriptionRequest(
    int companyId,
    CompanySubscriptionRequestFormModel payload,
  ) async {
    state = state.copyWith(isSubmittingSubscription: true);
    try {
      final request = await _repository.createSubscriptionRequest(
        companyId,
        payload,
      );
      state = state.copyWith(
        isSubmittingSubscription: false,
        subscriptionRequest: request.isPending ? request : null,
      );
      return request;
    } catch (e) {
      state = state.copyWith(isSubmittingSubscription: false);
      rethrow;
    }
  }

  Future<CompanyActivationReminderResponse> sendActivationReminder(
    int companyId,
  ) async {
    state = state.copyWith(isSendingReminder: true);
    try {
      final response = await _repository.sendActivationReminder(companyId);
      state = state.copyWith(
        isSendingReminder: false,
        reminderResponse: response,
      );
      return response;
    } catch (e) {
      state = state.copyWith(isSendingReminder: false);
      rethrow;
    }
  }
}

final companyActivationProvider =
    NotifierProvider<CompanyActivationController, CompanyActivationState>(
      CompanyActivationController.new,
    );
