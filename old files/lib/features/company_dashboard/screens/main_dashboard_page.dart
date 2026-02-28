import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_hub/features/company_dashboard/screens/company_dashboard_layout.dart';
import 'package:solar_hub/features/company_dashboard/controllers/main_dashboard_controller.dart';

class MainDashboardPage extends StatelessWidget {
  const MainDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller is initialized here if not already
    Get.put(MainDashboardController());

    return const CompanyDashboardLayout();
  }
}
