import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/features/company_dashboard/screens/company_dashboard_page.dart';
import 'package:solar_hub/layouts/company/analytics_page.dart';
import 'package:solar_hub/layouts/company/inventory_page.dart';
import 'package:solar_hub/features/accounting/screens/accounting_page.dart';
import 'package:solar_hub/features/orders/screens/order_list_company.dart';
import 'package:solar_hub/features/invoices/screens/invoices_page.dart';
import 'package:solar_hub/layouts/company/requests/offer_requests_page.dart';
import 'package:solar_hub/layouts/company/members/members_page.dart';
import 'package:solar_hub/layouts/company/systems/systems_page.dart';
import 'package:solar_hub/layouts/company/customer_list_page.dart';
import 'package:solar_hub/features/suppliers/screens/suppliers_page.dart';
import 'package:solar_hub/features/orders/screens/purchases_company.dart';
import 'package:solar_hub/layouts/company/subscription/subscription_page.dart';
import 'package:solar_hub/features/pos/screens/pos_page.dart';
import 'package:solar_hub/features/profile/screens/company_profile_page.dart';
import 'package:solar_hub/features/profile/controllers/company_profile_controller.dart';
import 'package:solar_hub/controllers/company_controller.dart';
import 'package:solar_hub/features/store/screens/merchant/delivery_options_page.dart';
import 'package:solar_hub/controllers/subscription_controller.dart';

class MainDashboardController extends GetxController {
  final _currentIndex = 0.obs;
  int get currentIndex => _currentIndex.value;

  final actions = <Widget>[].obs;

  final List<String> _history = ['dashboard'];

  // Restricted pages for inactive subscriptions
  final List<int> _restrictedIndices = [3, 5, 6, 7, 9, 11, 12, 13, 14, 15];

  void changePage(int index, String routeName) {
    if (_currentIndex.value == index) return;

    // Check subscription status
    final subController = Get.put(SubscriptionController());
    if (!subController.isSubscriptionActive.value && _restrictedIndices.contains(index)) {
      _showSubscriptionDialog();
      return;
    }

    actions.clear(); // Reset actions on page change
    _currentIndex.value = index;
    if (_history.isEmpty || _history.last != routeName) {
      _history.add(routeName);
    }

    // Dynamically add actions
    if (routeName == 'profile') {
      _addProfileActions();
    }

    update();
  }

  void _addProfileActions() {
    actions.add(
      Obx(() {
        // Find the profile controller which should be put by the page or we find it here
        // Ideally the page puts it, but we need to ensure it's available.
        if (Get.isRegistered<CompanyProfileController>()) {
          final controller = Get.find<CompanyProfileController>();
          if (controller.canEdit()) {
            return IconButton(
              icon: const Icon(Iconsax.edit_2_bold),
              onPressed: () async {
                final companyId = Get.find<CompanyController>().company.value?.id;
                if (companyId != null) {
                  final result = await Get.toNamed('/company/\$companyId/edit');
                  if (result == true) {
                    Get.snackbar(
                      'success'.tr,
                      'profile_updated_success'.tr,
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                    );
                    controller.fetchCompanyProfile(companyId);
                  }
                }
              },
              tooltip: 'edit_company'.tr,
            );
          }
        }
        return const SizedBox.shrink();
      }),
    );
  }

  void _showSubscriptionDialog() {
    Get.defaultDialog(
      title: 'subscription_required'.tr,
      middleText: 'subscription_required_msg'.tr,
      textConfirm: 'view_plans'.tr,
      textCancel: 'cancel'.tr,
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back(); // Close dialog
        changePage(2, 'subscription'); // Navigate to subscription page
      },
    );
  }

  void goBack() {
    if (_history.length > 1) {
      _history.removeLast();
      final previousRoute = _history.last;
      final newIndex = _getPageIndex(previousRoute);

      // Ensure we don't go back to a restricted page if subscription expired in meantime
      final subController = Get.put(SubscriptionController());
      if (!subController.isSubscriptionActive.value && _restrictedIndices.contains(newIndex)) {
        // Skip restricted page in history or go to dashboard
        changePage(0, 'dashboard');
        return;
      }

      _currentIndex.value = newIndex;
      update();
    }
  }

  bool get canGoBack => _history.length > 1;

  int _getPageIndex(String route) {
    switch (route) {
      case 'dashboard':
        return 0;
      case 'profile':
        return 1;
      case 'subscription':
        return 2;
      case 'offers':
        return 3;
      case 'inventory':
        return 4;
      case 'pos':
        return 5;
      case 'orders':
        return 6;
      case 'invoices':
        return 7;
      case 'accounting':
        return 8;
      case 'analytics':
        return 9;
      case 'members':
        return 10;
      case 'systems':
        return 11;
      case 'customers':
        return 12;
      case 'suppliers':
        return 13;
      case 'my_purchases':
        return 14;
      case 'delivery':
        return 15;
      default:
        return 0;
    }
  }

  Widget get currentBody {
    final companyController = Get.find<CompanyController>();
    final companyId = companyController.company.value?.id;

    switch (_currentIndex.value) {
      case 0:
        return const CompanyDashboardPage();
      case 1:
        return companyId != null ? CompanyProfilePage(companyId: companyId) : Center(child: Text("no_company".tr));
      case 2:
        return const SubscriptionPage();
      case 3:
        return const OfferRequestsPage();
      case 4:
        return const InventoryPage();
      case 5:
        return const PosPage();
      case 6:
        return const CompanyOrderListPage();
      case 7:
        return const InvoicesPage();
      case 8:
        return const AccountingPage();
      case 9:
        return const AnalyticsPage();
      case 10:
        return const MembersPage();
      case 11:
        return const SystemsPage();
      case 12:
        return const CustomerListPage();
      case 13:
        return const SuppliersPage();
      case 14:
        return const CompanyPurchasesPage();
      case 15:
        return companyId != null ? DeliveryOptionsPage(companyId: companyId) : Center(child: Text("no_company".tr));
      default:
        return const CompanyDashboardPage();
    }
  }

  String get currentTitle {
    switch (_currentIndex.value) {
      case 0:
        return 'dashboard'.tr;
      case 1:
        return 'company_profile'.tr;
      case 2:
        return 'subscription'.tr;
      case 3:
        return 'offers'.tr;
      case 4:
        return 'inventory'.tr;
      case 5:
        return 'pos'.tr;
      case 6:
        return 'orders'.tr;
      case 7:
        return 'invoices'.tr;
      case 8:
        return 'accounting'.tr;
      case 9:
        return 'analytics'.tr;
      case 10:
        return 'members'.tr;
      case 11:
        return 'systems'.tr;
      case 12:
        return 'customers'.tr;
      case 13:
        return 'suppliers'.tr;
      case 14:
        return 'my_purchases'.tr;
      case 15:
        return 'delivery'.tr;
      default:
        return 'dashboard'.tr;
    }
  }
}
