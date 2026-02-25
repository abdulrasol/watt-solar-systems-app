import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:solar_hub/features/auth/controllers/auth_controller.dart';
import 'package:solar_hub/controllers/company_controller.dart';
import 'package:solar_hub/features/company_dashboard/screens/main_dashboard_page.dart';

class CompanyRegistrationController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();

  final Rx<File?> logoFile = Rx<File?>(null);
  final RxBool isLoading = false.obs;

  final SupabaseClient _supabase = Supabase.instance.client;
  final AuthController _authController = Get.find<AuthController>();
  final ImagePicker _picker = ImagePicker();

  Future<void> pickLogo() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      logoFile.value = File(image.path);
    }
  }

  Future<void> submitApplication() async {
    if (!formKey.currentState!.validate()) return;
    if (logoFile.value == null) {
      Get.snackbar('Error', 'Please upload a company logo');
      return;
    }

    try {
      isLoading.value = true;
      final userId = _authController.user.value?.id;
      if (userId == null) throw 'User not authenticated';

      // 1. Upload Logo
      String? logoUrl;
      final fileExt = logoFile.value!.path.split('.').last;
      final fileName = '${DateTime.now().toIso8601String()}_$userId.$fileExt';
      await _supabase.storage.from('company_logos').upload(fileName, logoFile.value!);
      logoUrl = _supabase.storage.from('company_logos').getPublicUrl(fileName);

      // 2. Create Company (Status: pending)
      final companyResponse = await _supabase
          .from('companies')
          .insert({
            'name': nameController.text.trim(),
            'description': descriptionController.text.trim(),
            'address': addressController.text.trim(),
            'contact_phone': phoneController.text.trim(),
            'logo_url': logoUrl,
            'status': 'pending', // Pending by default
            'tier': 'intermediary', // Default tier
          })
          .select()
          .single();

      final companyId = companyResponse['id'];

      // 3. Add User as Owner
      await _supabase.from('company_members').insert({
        'company_id': companyId,
        'user_id': userId,
        'role': 'owner',
        'roles': ['owner'],
        'permissions': ['all'],
      });

      // 4. Update CompanyController
      if (Get.isRegistered<CompanyController>()) {
        await Get.find<CompanyController>().fetchMyCompany();
      }

      // Navigate directly to Dashboard which will show Pending screen
      Get.off(() => const MainDashboardPage());
    } catch (e) {
      Get.snackbar('Error', 'Failed to submit application: $e', backgroundColor: Colors.red, colorText: Colors.white);
      debugPrint('Registration Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    addressController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.onClose();
  }
}
