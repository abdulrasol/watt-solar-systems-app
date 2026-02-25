import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:solar_hub/controllers/currency_controller.dart';
import 'package:solar_hub/core/cashe/cashe_interface.dart';
import 'package:solar_hub/core/di/get_it.dart';
import 'package:solar_hub/features/auth/controllers/auth_controller.dart';
import 'package:solar_hub/features/auth/models/company.dart';
import 'package:solar_hub/features/auth/services/auth_services.dart';
import 'package:solar_hub/models/currency_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class EditCompanyProfilePage extends StatefulWidget {
  final String companyId;

  const EditCompanyProfilePage({super.key, required this.companyId});

  @override
  State<EditCompanyProfilePage> createState() => _EditCompanyProfilePageState();
}

class _EditCompanyProfilePageState extends State<EditCompanyProfilePage> {
  final authServices = getIt<AuthServices>();
  final AuthController authController = Get.find();
  final currencyController = Get.put(CurrencyController()); // Ensure it's available
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;

  bool _allowsB2B = true;
  bool _allowsB2C = true;

  File? _selectedImage;
  String? _uploadedLogoUrl;
  String? _selectedCurrencyId;
  late final Company company;

  @override
  void initState() {
    super.initState();
    if (authController.company.value == null) {
      Get.back();
      Get.snackbar('Error', 'Company not found', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    company = authController.company.value!;
    _nameController = TextEditingController(text: company.name);
    _descriptionController = TextEditingController(text: company.description);
    _addressController = TextEditingController(text: company.address);

    _allowsB2B = company.allowsB2B;
    _allowsB2C = company.allowsB2C;

    _uploadedLogoUrl = company.logo;
    //    _selectedCurrencyId = authController.company.currencyId;

    // Check permissions
    if (!authController.canEdit) {
      Future.delayed(Duration.zero, () {
        Get.back();
        Get.snackbar('Permission Denied', 'Only owners and managers can edit company profile', snackPosition: SnackPosition.BOTTOM);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery, maxWidth: 512, maxHeight: 512, imageQuality: 85);

      if (image != null) {
        setState(() => _selectedImage = File(image.path));
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> _saveCompany() async {
    if (!_formKey.currentState!.validate()) return;

    String? logoUrl = _uploadedLogoUrl;

    // // Upload new logo if selected
    // if (_selectedImage != null) {
    //   logoUrl = await authServices.uploadLogo(_selectedImage!);
    //   if (logoUrl == null) {
    //     Get.snackbar('Error', authServices.errorMessage.value, snackPosition: SnackPosition.BOTTOM);
    //     return;
    //   }
    // }

    final newCompany = Company(
      id: company.id,
      name: _nameController.text.trim(),
      companyType: company.companyType,
      description: _descriptionController.text.trim(),
      address: _addressController.text.trim(),
      allowsB2B: _allowsB2B,
      allowsB2C: _allowsB2C,
      status: company.status,
      tier: company.tier,
      logo: logoUrl,
      city: company.city,
      expireDate: company.expireDate,
      createdAt: company.createdAt,
      updatedAt: company.updatedAt,
    );

    Company? updatedCompany = await authServices.updateCompany(newCompany);

    if (updatedCompany != null) {
      getIt<CasheInterface>().save('company', updatedCompany.toJson());

      // Navigate back using Navigator instead of Get to avoid snackbar conflicts
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully'), backgroundColor: Colors.green));
        // Delay slightly to let the user see the message or ensuring the overlay isn't destroyed instantly
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) Navigator.of(context).pop(true);
      }
    } else {
      // Show error snackbar using ScaffoldMessenger to avoid GetX overlay issues
      if (mounted) {
        // TODO: translate error message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('get error'.tr), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Company Profile'),
        actions: [
          Obx(
            () => TextButton(
              onPressed: authServices.isLoading ? null : _saveCompany,
              child: authServices.isLoading ? SizedBox(width: 20.w, height: 20.h, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Save'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Logo Picker
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Theme.of(context).primaryColor, width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage: _selectedImage != null
                              ? FileImage(_selectedImage!)
                              : (_uploadedLogoUrl != null && _uploadedLogoUrl!.isNotEmpty)
                              ? CachedNetworkImageProvider(_uploadedLogoUrl!)
                              : null,
                          child: (_selectedImage == null && (_uploadedLogoUrl == null || _uploadedLogoUrl!.isEmpty))
                              ? const Icon(Iconsax.building_bold, size: 50)
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Theme.of(context).primaryColor, shape: BoxShape.circle),
                          child: const Icon(Iconsax.camera_bold, size: 20, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text('Tap to change logo', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              const SizedBox(height: 32),

              // Company Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Company Name',
                  prefixIcon: const Icon(Iconsax.building_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter company name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description Field
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Description',
                  alignLabelWithHint: true,
                  prefixIcon: const Padding(padding: EdgeInsets.only(bottom: 60), child: Icon(Iconsax.document_text_outline)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),

              // Address Field
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Address',
                  prefixIcon: const Icon(Iconsax.location_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),

              // Phone Field
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Contact Phone',
                  prefixIcon: const Icon(Iconsax.call_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),

              // Currency Dropdown
              Obx(() {
                if (currencyController.isLoading.value && currencyController.currencies.isEmpty) {
                  return const Center(child: LinearProgressIndicator());
                }

                return DropdownButtonFormField<String>(
                  initialValue: _selectedCurrencyId ?? currencyController.defaultCurrency?.id,
                  decoration: InputDecoration(
                    labelText: 'Store Currency',
                    prefixIcon: const Icon(Icons.monetization_on_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    helperText: "This currency will be used for all your products",
                  ),
                  items: currencyController.currencies.map((CurrencyModel currency) {
                    return DropdownMenuItem<String>(value: currency.id, child: Text("${currency.name} (${currency.symbol})"));
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCurrencyId = newValue;
                    });
                  },
                );
              }),

              const SizedBox(height: 24),

              // Toggles
              SwitchListTile(
                title: const Text("Sell to Companies (B2B)", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text("Enable this if you want to sell products wholesale to other companies."),
                value: _allowsB2B,
                onChanged: (val) => setState(() => _allowsB2B = val),
                activeThumbColor: Theme.of(context).primaryColor,
              ),
              const Divider(),
              SwitchListTile(
                title: const Text("Sell to Customers (B2C)", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text("Enable this if you want to sell products directly to end customers in the store."),
                value: _allowsB2C,
                onChanged: (val) => setState(() => _allowsB2C = val),
                activeThumbColor: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: Obx(
                  () => ElevatedButton.icon(
                    onPressed: authServices.isLoading ? null : _saveCompany,
                    icon: const Icon(Iconsax.tick_circle_bold),
                    label: authServices.isLoading ? const Text('Saving...') : const Text('Save Changes'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
