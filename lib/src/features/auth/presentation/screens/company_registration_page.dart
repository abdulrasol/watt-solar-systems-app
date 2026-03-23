import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/features/auth/domain/entities/city.dart';
import 'package:solar_hub/src/features/auth/domain/entities/company_register_model.dart';
import 'package:solar_hub/src/features/auth/domain/entities/country.dart';
import 'package:solar_hub/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:solar_hub/src/utils/app_theme.dart';
import 'package:solar_hub/src/utils/toast_service.dart';
import 'package:validatorless/validatorless.dart';

class CompanyRegistrationPage extends ConsumerStatefulWidget {
  const CompanyRegistrationPage({super.key});

  @override
  ConsumerState<CompanyRegistrationPage> createState() =>
      _CompanyRegistrationPageState();
}

class _CompanyRegistrationPageState
    extends ConsumerState<CompanyRegistrationPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  City? _selectedCity;
  Country? _selectedCountry;
  List<Country> _countries = [];
  List<City> _cities = [];
  bool _isLoadingCountries = false;
  bool _isLoadingCities = false;

  bool _isB2B = false;
  bool _isB2C = false;

  bool isLoading = false;

  final ValueNotifier<File?> logoFile = ValueNotifier<File?>(null);

  Future<void> pickLogo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        logoFile.value = File(image.path);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchCountries();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.register_company), centerTitle: true),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.0.r),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppLocalizations.of(context)!.start_your_solar_business,
                style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                AppLocalizations.of(context)!.register_company_details,
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.h),

              // Logo Upload
              Center(
                child: GestureDetector(
                  onTap: pickLogo,
                  child: Container(
                    width: 120.r,
                    height: 120.r,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.3),
                      ),
                      image: logoFile.value != null
                          ? DecorationImage(
                              image: FileImage(logoFile.value!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: logoFile.value == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Iconsax.camera_bold,
                                size: 32.r,
                                color: Colors.grey[600],
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                l10n.upload_logo,
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          )
                        : null,
                  ),
                ),
              ),
              SizedBox(height: 32.h),

              // Form Fields
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.company_name,
                  prefixIcon: const Icon(Iconsax.building_bold),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: Validatorless.required(
                  AppLocalizations.of(context)!.company_name_is_required,
                ),
              ),
              SizedBox(height: 16.h),

              TextFormField(
                controller: descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.description,
                  prefixIcon: const Icon(Iconsax.document_text_bold),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) => value!.isEmpty
                    ? AppLocalizations.of(context)!.description_is_required
                    : null,
              ),
              SizedBox(height: 16.h),

              SwitchListTile(
                title: Text(AppLocalizations.of(context)!.b2b),
                value: _isB2B,
                onChanged: (value) {
                  setState(() {
                    _isB2B = value;
                  });
                },
              ),
              SizedBox(height: 16.h),
              SwitchListTile(
                title: Text(AppLocalizations.of(context)!.b2c),
                value: _isB2C,
                onChanged: (value) {
                  setState(() {
                    _isB2C = value;
                  });
                },
              ),

              SizedBox(height: 16.h),

              // City Dropdown
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<Country>(
                      initialValue: _selectedCountry,
                      decoration: InputDecoration(
                        labelText: _isLoadingCountries
                            ? AppLocalizations.of(context)!.loading
                            : AppLocalizations.of(context)!.country,
                        prefixIcon: _selectedCountry != null
                            ? Icon(Iconsax.location_bold, size: 20.r)
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 16.h,
                        ),
                      ),
                      items: _countries
                          .map(
                            (country) => DropdownMenuItem(
                              value: country,
                              child: Text(country.name),
                            ),
                          )
                          .toList(), // Now empty list
                      onChanged: (value) {
                        setState(() {
                          _selectedCountry = value;
                          _selectedCity =
                              null; // Reset city to resolve assertion error
                          _fetchCities();
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: DropdownButtonFormField<City>(
                      initialValue: _selectedCity,
                      decoration: InputDecoration(
                        labelText: _isLoadingCities
                            ? AppLocalizations.of(context)!.loading
                            : AppLocalizations.of(context)!.city,
                        prefixIcon: _selectedCity != null
                            ? Icon(Iconsax.location_bold, size: 20.r)
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 16.h,
                        ),
                      ),
                      items: _cities
                          .map(
                            (city) => DropdownMenuItem(
                              value: city,
                              child: Text(city.name),
                            ),
                          )
                          .toList(), // Now empty list
                      onChanged: (value) {
                        setState(() {
                          _selectedCity = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return AppLocalizations.of(context)!.city_is_required;
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.address,
                  prefixIcon: const Icon(Iconsax.location_bold),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: Validatorless.required(
                  AppLocalizations.of(context)!.address_is_required,
                ),
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: l10n.business_phone,
                  prefixIcon: const Icon(Iconsax.call_bold),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: Validatorless.multiple([
                  Validatorless.required(l10n.phone_required),
                  Validatorless.number(l10n.invalid_phone_number),
                ]),
              ),

              SizedBox(height: 40.h),

              // Submit Button
              ElevatedButton(
                onPressed: sumbit,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.r),
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.r,
                      )
                    : Text(
                        l10n.submit_application,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ), // TODO: translate
              ),
            ],
          ),
        ),
      ),
    );
  }

  void sumbit() async {
    final l10n = AppLocalizations.of(context)!;
    if (isLoading) return;
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      await getIt
          .get<AuthRepository>()
          .registerCompany(
            CompanyRegistrationModel(
              name: nameController.text,
              description: descriptionController.text,
              address: addressController.text,
              city: _selectedCity!.id,
              b2b: _isB2B,
              b2c: _isB2C,
            ),
          )
          .then((value) {
            setState(() {
              isLoading = false;
            });
            if (mounted) {
              ToastService.success(
                context,
                l10n.success,
                l10n.company_registered_success,
              );
            }
            if (mounted) context.pop();
          })
          .catchError((error) {
            setState(() {
              isLoading = false;
            });
            if (mounted) {
              ToastService.error(context, l10n.error, error.toString());
            }
          });
    }
  }

  Future<void> _fetchCountries() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isLoadingCountries = true;
    });
    try {
      final response = await getIt.get<AuthRepository>().getCountries();
      setState(() {
        _countries = response;
      });
    } catch (e) {
      if (mounted) ToastService.error(context, l10n.error, e.toString());
    }
    if (_selectedCity != null) {
      _selectedCountry = _countries.firstWhere(
        (element) => element.id == _selectedCity!.country.id,
      );
    }
    setState(() {
      _isLoadingCountries = false;
    });
  }

  Future<void> _fetchCities({int? countryId}) async {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedCountry == null && countryId == null) return;
    setState(() {
      _isLoadingCities = true;
    });
    try {
      final response = await getIt.get<AuthRepository>().getCities(
        countryId: countryId ?? _selectedCountry!.id,
      );
      setState(() {
        _cities = response;
      });
    } catch (e) {
      if (mounted) ToastService.error(context, l10n.error, e.toString());
    }
    setState(() {
      _isLoadingCities = false;
    });
  }
}
