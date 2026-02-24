import 'package:get/get.dart';
import 'package:solar_hub/models/subscription_model.dart';
import 'package:solar_hub/services/supabase_service.dart';
import 'package:solar_hub/controllers/company_controller.dart';
import 'package:solar_hub/utils/toast_service.dart';

class SubscriptionController extends GetxController {
  final _supabase = SupabaseService().client;
  final CompanyController _companyController = Get.find<CompanyController>();

  final isLoading = false.obs;
  final plans = <SubscriptionPlanModel>[].obs;
  final currentSubscription = Rxn<CompanySubscriptionModel>();
  final isSubscriptionActive = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPlans();
    if (_companyController.company.value != null) {
      checkSubscriptionStatus();
    }

    // Listen to company changes (e.g., switch company)
    ever(_companyController.company, (company) {
      if (company != null) {
        checkSubscriptionStatus();
      } else {
        currentSubscription.value = null;
        isSubscriptionActive.value = false;
      }
    });
  }

  Future<void> fetchPlans() async {
    try {
      isLoading.value = true;
      final response = await _supabase.from('subscription_plans').select().eq('is_active', true).order('price', ascending: true);

      plans.assignAll((response as List).map((e) => SubscriptionPlanModel.fromJson(e)).toList());
    } catch (e) {
      // debugPrint('Error fetching plans: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> checkSubscriptionStatus() async {
    final companyId = _companyController.company.value?.id;
    if (companyId == null) return;

    try {
      final response = await _supabase
          .from('company_subscriptions')
          .select()
          .eq('company_id', companyId)
          .eq('status', 'active')
          .gt('end_date', DateTime.now().toIso8601String())
          .order('end_date', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response != null) {
        currentSubscription.value = CompanySubscriptionModel.fromJson(response);
        isSubscriptionActive.value = true;
        // Ensure company status is 'active' locally if needed, though DB trigger handles sync ideally.
        // For now, let's trust the DB or update it if we find a valid sub.
      } else {
        currentSubscription.value = null;
        isSubscriptionActive.value = false;
        // Check if company status needs to be downgraded?
        // We might just restrict access based on `isSubscriptionActive` without changing company `status` strictly,
        // or we rely on backend jobs to expire statuses.
      }
    } catch (e) {
      // debugPrint('Error checking subscription: $e');
    }
  }

  Future<void> subscribe(SubscriptionPlanModel plan) async {
    final companyId = _companyController.company.value?.id;
    if (companyId == null) return;

    isLoading.value = true;
    try {
      // 1. Create Subscription Record
      // Determine End Date
      final startDate = DateTime.now();
      final endDate = startDate.add(Duration(days: plan.durationDays));

      await _supabase.from('company_subscriptions').insert({
        'company_id': companyId,
        'plan_id': plan.id,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'status': 'active',
        'payment_ref': 'manual_mock_${DateTime.now().millisecondsSinceEpoch}',
      });

      // 2. Activate Company Status
      await _supabase.from('companies').update({'status': 'active'}).eq('id', companyId);

      // 3. Refresh Local State
      await checkSubscriptionStatus();
      await _companyController.fetchMyCompany(); // update company model status

      ToastService.success('Success', 'Subscription activated successfully!');
      Get.close(1); // Close subscription page or dialog safely
    } catch (e) {
      ToastService.error('Error', 'Failed to subscribe: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
