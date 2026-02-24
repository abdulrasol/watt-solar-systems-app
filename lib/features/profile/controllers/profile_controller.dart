import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_hub/features/profile/models/profile_model.dart';
import 'package:solar_hub/controllers/auth_controller.dart';
import 'package:solar_hub/services/supabase_service.dart';

class ProfileController extends GetxController {
  final _db = SupabaseService().client;
  final _auth = Get.find<AuthController>();

  final Rx<ProfileModel?> currentProfile = Rx<ProfileModel?>(null);
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final userId = _auth.user.value?.id;
    if (userId != null) {
      fetchProfile(userId);
    }
  }

  Future<ProfileModel?> fetchProfile(String userId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _db.from('profiles').select().eq('id', userId).single();

      currentProfile.value = ProfileModel.fromJson(response);
      return currentProfile.value;
    } catch (e) {
      errorMessage.value = 'Failed to load profile: $e';
      debugPrint('Error fetching profile: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateProfile({String? fullName, String? phoneNumber, String? avatarUrl}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final userId = _auth.user.value?.id;
      if (userId == null) {
        errorMessage.value = 'User not authenticated';
        return false;
      }

      final Map<String, dynamic> updates = {'updated_at': DateTime.now().toIso8601String()};

      if (fullName != null) updates['full_name'] = fullName;
      if (phoneNumber != null) updates['phone_number'] = phoneNumber;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

      debugPrint('Updating profile for user: $userId');
      debugPrint('Updates: $updates');

      final response = await _db.from('profiles').update(updates).eq('id', userId).select();

      debugPrint('Update response: $response');

      // Check if update was successful (RLS might block it returning empty list)
      if (response.isEmpty) {
        errorMessage.value = 'Update failed: You might not have permission to update this profile.';
        debugPrint('RLS Error: Update returned 0 rows. Check RLS policies.');
        return false;
      }

      // Refresh profile
      await fetchProfile(userId);

      return true;
    } catch (e) {
      errorMessage.value = 'Failed to update profile: $e';
      debugPrint('Error updating profile: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> uploadAvatar(File imageFile) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final userId = _auth.user.value?.id;
      if (userId == null) {
        errorMessage.value = 'User not authenticated';
        return null;
      }

      final fileName = 'avatar_$userId${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = 'avatars/$fileName';

      // Upload to Supabase Storage
      await _db.storage.from('profiles').upload(filePath, imageFile);

      // Get public URL
      final avatarUrl = _db.storage.from('profiles').getPublicUrl(filePath);

      return avatarUrl;
    } catch (e) {
      errorMessage.value = 'Failed to upload avatar: $e';
      debugPrint('Error uploading avatar: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  bool validatePhoneNumber(String phone) {
    // Basic validation: should start with + and have at least 7 digits
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    // return (cleanPhone.startsWith('+') || cleanPhone.startsWith('00')) && cleanPhone.length >= 8;
    return cleanPhone.length >= 7;
  }
}
