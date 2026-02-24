import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/features/company_registration/controllers/company_registration_controller.dart';
import 'package:solar_hub/utils/app_theme.dart';

class CompanyRegistrationPage extends StatelessWidget {
  const CompanyRegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CompanyRegistrationController());

    return Scaffold(
      appBar: AppBar(title: const Text("Register Company"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Start Your Solar Business",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Fill in the details below to register your company. Your application will be reviewed by our admin team.",
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Logo Upload
              Center(
                child: GestureDetector(
                  onTap: controller.pickLogo,
                  child: Obx(() {
                    return Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                        image: controller.logoFile.value != null ? DecorationImage(image: FileImage(controller.logoFile.value!), fit: BoxFit.cover) : null,
                      ),
                      child: controller.logoFile.value == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Iconsax.camera_bold, size: 32, color: Colors.grey[600]),
                                const SizedBox(height: 4),
                                Text("Upload Logo", style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                              ],
                            )
                          : null,
                    );
                  }),
                ),
              ),
              const SizedBox(height: 32),

              // Form Fields
              TextFormField(
                controller: controller.nameController,
                decoration: InputDecoration(
                  labelText: "Company Name",
                  prefixIcon: const Icon(Iconsax.building_bold),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) => value!.isEmpty ? "Company Name is required" : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: controller.descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "Description",
                  prefixIcon: const Icon(Iconsax.document_text_bold),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) => value!.isEmpty ? "Description is required" : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: controller.addressController,
                decoration: InputDecoration(
                  labelText: "Address",
                  prefixIcon: const Icon(Iconsax.location_bold),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) => value!.isEmpty ? "Address is required" : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: controller.phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Business Phone",
                  prefixIcon: const Icon(Iconsax.call_bold),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) => value!.isEmpty ? "Phone number is required" : null,
              ),

              const SizedBox(height: 40),

              // Submit Button
              Obx(
                () => ElevatedButton(
                  onPressed: controller.isLoading.value ? null : controller.submitApplication,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("Submit Application", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
