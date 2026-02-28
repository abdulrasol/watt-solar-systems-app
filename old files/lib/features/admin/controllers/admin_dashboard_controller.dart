import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_hub/features/admin/layouts/admin_analytics_page.dart';
import 'package:solar_hub/features/admin/layouts/admin_companies_page.dart';
import 'package:solar_hub/features/admin/layouts/admin_currencies_page.dart';
import 'package:solar_hub/features/admin/layouts/admin_config_page.dart';
import 'package:solar_hub/features/admin/layouts/admin_settings_page.dart';
import 'package:solar_hub/controllers/currency_controller.dart';
import 'package:icons_plus/icons_plus.dart';

class AdminDashboardController extends GetxController {
  final _currentIndex = 0.obs;
  int get currentIndex => _currentIndex.value;

  final List<String> _titles = ['Dashboard', 'Companies', 'Currencies', 'Configuration', 'Settings'];

  String get currentTitle => _titles[_currentIndex.value];

  void changePage(int index) {
    _currentIndex.value = index;
    update(); // Notify GetBuilder if used
  }

  Widget get currentBody {
    switch (_currentIndex.value) {
      case 0:
        return const AdminAnalyticsPage();
      case 1:
        return const AdminCompaniesPage();
      case 2:
        return const AdminCurrenciesPage();
      case 3:
        return AdminConfigPage();
      case 4:
        return const AdminSettingsPage();
      default:
        return const AdminAnalyticsPage();
    }
  }

  final List<Map<String, dynamic>> menuItems = [
    {'title': 'Dashboard', 'icon': Iconsax.category_bold, 'index': 0},
    {'title': 'Companies', 'icon': Iconsax.buildings_bold, 'index': 1},
    {'title': 'Currencies', 'icon': Icons.monetization_on, 'index': 2},
    {'title': 'Configuration', 'icon': Iconsax.setting_2_bold, 'index': 3},
    {'title': 'Settings', 'icon': Icons.settings, 'index': 4},
  ];

  @override
  void onInit() {
    super.onInit();
    Get.put(CurrencyController());
  }
}
