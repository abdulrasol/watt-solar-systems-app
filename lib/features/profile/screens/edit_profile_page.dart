import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:solar_hub/core/cashe/cashe_interface.dart';
import 'package:solar_hub/core/di/get_it.dart';
import 'package:solar_hub/features/auth/controllers/auth_controller.dart';
import 'package:solar_hub/features/auth/services/auth_services.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final authController = Get.put(AuthController());
  final _authServices = getIt<AuthServices>();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  File? _selectedImage;
  String? _uploadedAvatarUrl;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: authController.user.value?.firstName ?? '');
    _lastNameController = TextEditingController(text: authController.user.value?.lastName ?? '');
    _phoneController = TextEditingController(text: authController.user.value?.phone ?? '');
    _uploadedAvatarUrl = authController.user.value?.image;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
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

    String? avatarUrl = _uploadedAvatarUrl;

    // Upload new image if selected

    final newUser = await _authServices.updateProfile(
      fullName: _firstNameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      avatarUrl: avatarUrl,
    );

    if (newUser != null) {
      getIt<CasheInterface>().saveUser(newUser);
      if (mounted) Navigator.of(context).pop(true);
    } else {
      // Show error snackbar using ScaffoldMessenger to avoid GetX overlay issues
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('error save masege '.tr), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          Obx(
            () => TextButton(
              onPressed: _authServices.isLoading ? null : _saveProfile,
              child: _authServices.isLoading ? SizedBox(width: 20.w, height: 20.h, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Save'),
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
                          backgroundImage: _selectedImage != null
                              ? FileImage(_selectedImage!)
                              : (_uploadedAvatarUrl != null && _uploadedAvatarUrl!.isNotEmpty)
                              ? CachedNetworkImageProvider(_uploadedAvatarUrl!)
                              : null,
                          child: (_selectedImage == null && (_uploadedAvatarUrl == null || _uploadedAvatarUrl!.isEmpty))
                              ? const Icon(Iconsax.user_bold, size: 50)
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

              // Full Name Field
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: const Icon(Iconsax.user_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Phone Number Field
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  hintText: '+1234567890',
                  prefixIcon: const Icon(Iconsax.call_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your phone number';
                  }
                  if (!GetUtils.isPhoneNumber(value.trim())) {
                    return 'Please enter a valid phone number with country code (e.g., +1234567890)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Save Button (alternative to AppBar action)
              SizedBox(
                width: double.infinity,
                child: Obx(
                  () => ElevatedButton.icon(
                    onPressed: _authServices.isLoading ? null : _saveProfile,
                    icon: const Icon(Iconsax.tick_circle_bold),
                    label: _authServices.isLoading ? const Text('Saving...') : const Text('Save Changes'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.r),
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
