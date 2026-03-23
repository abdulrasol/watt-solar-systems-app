import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/auth/domain/entities/country.dart';
import 'package:solar_hub/src/utils/helper_methods.dart';
import 'package:solar_hub/src/utils/toast_service.dart';
import 'package:validatorless/validatorless.dart';

import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/features/auth/domain/entities/city.dart';
import 'package:solar_hub/src/features/auth/domain/entities/user_register_model.dart';
import 'package:solar_hub/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _usernameController;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _securityQuestionController;
  late TextEditingController _securityAnswerController;

  City? _selectedCity;
  Country? _selectedCountry;
  List<Country> _countries = [];
  List<City> _cities = [];
  bool _isLoadingCountries = false;
  bool _isLoadingCities = false;

  File? _selectedImage;
  String? _uploadedAvatarUrl;
  bool _isLoading = false;
  late AuthState authController;

  @override
  void initState() {
    super.initState();
    authController = ref.read(authProvider);
    final user = authController.user;
    _usernameController = TextEditingController(text: user?.username ?? '');
    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _securityQuestionController = TextEditingController(text: user?.securityQuestion ?? '');
    _securityAnswerController = TextEditingController(text: user?.securityAnswer ?? '');
    _selectedCity = user?.city;
    _uploadedAvatarUrl = user?.image;
    if (user?.city != null) {
      _cities = [user!.city!];
      //  _selectedCountry = user.city!.country;
      // _countries = [user.city!.country];
      _fetchCities(countryId: user.city!.country.id);
    }
    _fetchCountries();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _securityQuestionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      // Desktop platforms often lack default camera implementation for image_picker
      // fallback to gallery directly to avoid "cameraDelegate" crash
      _imgFromSource(ImageSource.gallery);
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _imgFromSource(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _imgFromSource(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _imgFromSource(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source, maxWidth: 512, maxHeight: 512, imageQuality: 85);

      if (image != null) {
        setState(() => _selectedImage = File(image.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to pick image: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    dPrint(_selectedImage?.path);
    try {
      final userModel = UserRegisterModel(
        username: _usernameController.text.trim(),
        password: '', // Ignored by API during profile update or not required
        email: _emailController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: _phoneController.text.trim(),
        city: _selectedCity?.id,
        image: _selectedImage?.path, // Assuming backend accepts string image path or we leave as null
        securityQuestion: _securityQuestionController.text.trim(),
        securityAnswer: _securityAnswerController.text.trim(),
      );

      final response = await getIt.get<AuthRepository>().updateProfile(userModel);

      if (mounted) {
        ref.read(authProvider.notifier).updateProfile(response);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully'), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
      if (mounted) context.pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get colors respecting the dark mode
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading ? SizedBox(width: 20.w, height: 20.h, child: const CircularProgressIndicator(strokeWidth: 2)) : const Text('Save'),
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
              // Avatar Picker
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
                          backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                          backgroundImage: _selectedImage != null
                              ? FileImage(_selectedImage!)
                              : (_uploadedAvatarUrl != null && _uploadedAvatarUrl!.isNotEmpty)
                              ? CachedNetworkImageProvider(_uploadedAvatarUrl!)
                              : null,
                          child: (_selectedImage == null && (_uploadedAvatarUrl == null || _uploadedAvatarUrl!.isEmpty))
                              ? Icon(Iconsax.user_bold, size: 50, color: isDark ? Colors.white54 : Colors.grey)
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
              Text('Tap to change avatar', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              const SizedBox(height: 32),

              // Username Field
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  prefixIcon: const Icon(Iconsax.user_cirlce_add_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: Validatorless.required('Username is required'),
              ),
              const SizedBox(height: 16),

              // Email Field
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Iconsax.sms_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: Validatorless.multiple([Validatorless.required('Email is required'), Validatorless.email('Invalid email')]),
              ),
              const SizedBox(height: 16),

              // First Name Field
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: 'First Name',
                  prefixIcon: const Icon(Iconsax.user_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),

              // Last Name Field
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: 'Last Name',
                  prefixIcon: const Icon(Iconsax.user_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),

              // Phone Number Field
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: const Icon(Iconsax.call_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                // validator: Validatorless.multiple([Validatorless.required('Phone is required'), Validatorless.number('Enter valid phone number')]),
              ),
              const SizedBox(height: 16),

              // Security Question Field
              TextFormField(
                controller: _securityQuestionController,
                decoration: InputDecoration(
                  labelText: 'Security Question',
                  prefixIcon: const Icon(Iconsax.security_safe_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),

              // Security Answer Field
              TextFormField(
                controller: _securityAnswerController,
                decoration: InputDecoration(
                  labelText: 'Security Answer',
                  prefixIcon: const Icon(Iconsax.security_safe_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),

              // City Dropdown
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<Country>(
                      initialValue: _selectedCountry,
                      decoration: InputDecoration(
                        labelText: _isLoadingCountries ? AppLocalizations.of(context)!.loading : AppLocalizations.of(context)!.country,
                        prefixIcon: _selectedCountry != null ? Icon(Iconsax.location_bold, size: 20.r) : null,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
                        filled: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                      ),
                      items: _countries.map((country) => DropdownMenuItem(value: country, child: Text(country.name))).toList(), // Now empty list
                      onChanged: (value) {
                        setState(() {
                          _selectedCountry = value;
                          _selectedCity = null; // Reset city to resolve assertion error
                          _fetchCities();
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<City>(
                      initialValue: _selectedCity,
                      decoration: InputDecoration(
                        labelText: _isLoadingCities ? AppLocalizations.of(context)!.loading : AppLocalizations.of(context)!.city,
                        prefixIcon: _selectedCity != null ? Icon(Iconsax.location_bold, size: 20.r) : null,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
                        filled: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                      ),
                      items: _cities.map((city) => DropdownMenuItem(value: city, child: Text(city.name))).toList(), // Now empty list
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

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveProfile,
                  icon: _isLoading
                      ? SizedBox(width: 20.w, height: 20.h, child: const CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Iconsax.tick_circle_bold),
                  label: _isLoading ? const Text('Saving...') : const Text('Save Changes'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.r),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _fetchCountries() async {
    setState(() {
      _isLoadingCountries = true;
    });
    try {
      final response = await getIt.get<AuthRepository>().getCountries();
      setState(() {
        _countries = response;
      });
    } catch (e) {
      if (mounted) ToastService.error(context, 'Error', e.toString());
    }
    if (_selectedCity != null) {
      _selectedCountry = _countries.firstWhere((element) => element.id == _selectedCity!.country.id);
    }
    setState(() {
      _isLoadingCountries = false;
    });
  }

  Future<void> _fetchCities({int? countryId}) async {
    if (_selectedCountry == null && countryId == null) return;
    setState(() {
      _isLoadingCities = true;
    });
    try {
      final response = await getIt.get<AuthRepository>().getCities(countryId: countryId ?? _selectedCountry!.id);
      setState(() {
        _cities = response;
      });
    } catch (e) {
      if (mounted) ToastService.error(context, 'Error', e.toString());
    }
    setState(() {
      _isLoadingCities = false;
    });
  }
}
