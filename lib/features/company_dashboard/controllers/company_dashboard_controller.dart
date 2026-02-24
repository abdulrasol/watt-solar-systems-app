import 'package:get/get.dart';
import 'package:solar_hub/controllers/company_controller.dart';
import 'package:solar_hub/controllers/notifications_controller.dart';
import 'package:solar_hub/models/currency_model.dart';

class CompanyDashboardController extends GetxController {
  // Dependencies
  final CompanyController companyController = Get.find<CompanyController>();
  final NotificationsController notificationsController = Get.put(NotificationsController());

  // State
  final selectedIndex = 0.obs;

  // Computed
  bool get isLoading => companyController.isLoading.value;

  // Helper for role checking
  bool hasAnyRole(List<String> roles) => companyController.hasAnyRole(roles);

  // Currency helper
  CurrencyModel get effectiveCurrency => companyController.effectiveCurrency;

  @override
  void onInit() {
    super.onInit();
    // Ensure company data is fresh
    if (companyController.company.value == null) {
      companyController.fetchMyCompany();
    }
  }

  void changePage(int index) {
    selectedIndex.value = index;
    // complex logic for page switching if needed, or routing
  }
}
