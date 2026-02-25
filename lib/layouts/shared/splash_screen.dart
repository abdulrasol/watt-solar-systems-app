import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_hub/features/auth/controllers/auth_controller.dart';
import 'package:solar_hub/controllers/company_controller.dart';

import 'package:solar_hub/controllers/notifications_controller.dart';
import 'package:solar_hub/core/cashe/cashe_interface.dart';
import 'package:solar_hub/core/di/get_it.dart';
import 'package:solar_hub/layouts/shared/role_selection_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Artificial delay for better UX (so logo doesn't flash)
    await Future.delayed(const Duration(seconds: 2));

    final authController = Get.find<AuthController>();

    // Check if user is logged in
    if (authController.user.value == null) {
      // User not logged in -> Go to Auth/Home (Guest)
      // Actually usually Force Login or Guest Home.
      // If Home supports Guest, go to Home.
      Get.offAllNamed('/home');
      return;
    }

    // User is logged in -> Load Data
    try {
      // Initialize controllers that might need data
      final companyController = Get.find<CompanyController>();
      final notifController = Get.find<NotificationsController>();

      // Wait for critical data
      await Future.wait([
        companyController.fetchMyCompany(),
        notifController.forceRefresh(),
        authController.fetchUserRole(),
        // Add other critical fetches here
      ]);

      // Routing Logic
      if (companyController.company.value != null || authController.role.value == 'admin') {
        // Is Company Member -> Check for saved choices or go to Role Selection
        final handled = loadSaveMyChoies();
        if (!handled) {
          Get.offAll(() => const RoleSelectionPage());
        }
      } else {
        // Normal User -> Go to Home
        Get.offAllNamed('/home');
      }
    } catch (e) {
      // Logic error or offline? Go home or retry
      debugPrint("Splash Error: $e");
      Get.offAllNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo (Replace with your actual asset if available, or icon for now)
            Icon(Icons.solar_power, size: 80, color: Colors.orange.shade700),
            const SizedBox(height: 24),
            const Text("Solar Hub", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 8),
            const Text("Use The Power Of The Sun", style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 48),
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text("Loading...", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  bool loadSaveMyChoies() {
    final CasheInterface casheService = getIt<CasheInterface>();

    bool saveMyChoies = casheService.get('save-role-page-selection') ?? false;
    if (saveMyChoies) {
      final String myChoies = casheService.get('save-role-page-selection-route') ?? '';
      debugPrint('myChoies: $myChoies');
      if (myChoies == 'admin') {
        Get.offAllNamed('/admin_dashboard');
        return true;
      } else if (myChoies == 'company') {
        Get.offAllNamed('/company_dashboard');
        return true;
      } else if (myChoies == 'user') {
        Get.offAllNamed('/home');
        return true;
      }
    }
    return false;
  }
}
