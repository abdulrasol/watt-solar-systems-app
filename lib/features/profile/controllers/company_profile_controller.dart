import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_hub/models/company_model.dart';
import 'package:solar_hub/controllers/auth_controller.dart';
import 'package:solar_hub/services/supabase_service.dart';

class CompanyProfileController extends GetxController {
  final _db = SupabaseService().client;
  final _auth = Get.find<AuthController>();

  final Rx<CompanyModel?> currentCompany = Rx<CompanyModel?>(null);
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final userRole = Rxn<String>();
  final memberCount = 0.obs;
  final systemsCount = 0.obs;
  final productsCount = 0.obs;
  final ordersCount = 0.obs;
  final customersCount = 0.obs;

  Future<CompanyModel?> fetchCompanyProfile(String companyId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _db.from('companies').select().eq('id', companyId).single();

      currentCompany.value = CompanyModel.fromJson(response);

      // Fetch additional stats
      await _fetchCompanyStats(companyId);

      // Check user role
      final userId = _auth.user.value?.id;
      if (userId != null) {
        await getUserRole(companyId, userId);
      }

      return currentCompany.value;
    } catch (e) {
      errorMessage.value = 'Failed to load company profile: $e';
      debugPrint('Error fetching company profile: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchCompanyStats(String companyId) async {
    try {
      // Get member count
      final membersResponse = await _db.from('company_members').select('id').eq('company_id', companyId).count();
      memberCount.value = membersResponse.count;

      // Get systems count
      final systemsResponse = await _db.from('systems').select('id').eq('installed_by', companyId).count();
      systemsCount.value = systemsResponse.count;

      // Get products count
      final productsResponse = await _db.from('products').select('id').eq('company_id', companyId).count();
      productsCount.value = productsResponse.count;

      // Get orders count
      final ordersResponse = await _db.from('orders').select('id').eq('seller_company_id', companyId).count();
      ordersCount.value = ordersResponse.count;

      // Get customers count
      final customersResponse = await _db.from('customers').select('id').eq('company_id', companyId).count();
      customersCount.value = customersResponse.count;
    } catch (e) {
      debugPrint('Error fetching company stats: $e');
    }
  }

  Future<String?> getUserRole(String companyId, String userId) async {
    try {
      final response = await _db.from('company_members').select('role').eq('company_id', companyId).eq('user_id', userId).maybeSingle();

      if (response != null) {
        userRole.value = response['role'] as String?;
        return userRole.value;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user role: $e');
      return null;
    }
  }

  bool canEdit() {
    // Only owner and manager can edit company profile
    return userRole.value == 'owner' || userRole.value == 'manager';
  }

  Future<bool> updateCompany({
    String? name,
    String? description,
    String? logoUrl,
    String? address,
    String? contactPhone,
    bool? allowsB2B,
    bool? allowsB2C,
  }) async {
    try {
      if (!canEdit()) {
        errorMessage.value = 'You do not have permission to edit this company';
        return false;
      }

      isLoading.value = true;
      errorMessage.value = '';

      final companyId = currentCompany.value?.id;
      if (companyId == null) {
        errorMessage.value = 'Company not found';
        return false;
      }

      final Map<String, dynamic> updates = {'updated_at': DateTime.now().toIso8601String()};

      if (name != null) updates['name'] = name;
      if (description != null) updates['description'] = description;
      if (logoUrl != null) updates['logo_url'] = logoUrl;
      if (address != null) updates['address'] = address;
      if (contactPhone != null) updates['contact_phone'] = contactPhone;
      if (allowsB2B != null) updates['allows_b2b'] = allowsB2B;
      if (allowsB2C != null) updates['allows_b2c'] = allowsB2C;

      debugPrint('Updating company: $companyId');
      debugPrint('Updates: $updates');

      final response = await _db.from('companies').update(updates).eq('id', companyId).select();

      debugPrint('Update response: $response');

      // Check if update was successful (RLS might block it returning empty list)
      if (response.isEmpty) {
        errorMessage.value = 'Update failed: You do not have permission to update this company.';
        debugPrint('RLS Error: Update returned 0 rows. Check RLS policies.');
        return false;
      }

      // Refresh company profile
      await fetchCompanyProfile(companyId);

      return true;
    } catch (e) {
      errorMessage.value = 'Failed to update company: $e';
      debugPrint('Error updating company: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> uploadLogo(File imageFile) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final companyId = currentCompany.value?.id;
      if (companyId == null) {
        errorMessage.value = 'Company not found';
        return null;
      }

      final fileName = 'logo_$companyId${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = 'company_logos/$fileName';

      // Upload to Supabase Storage
      await _db.storage.from('company_logos').upload(filePath, imageFile);

      // Get public URL
      final logoUrl = _db.storage.from('company_logos').getPublicUrl(filePath);

      return logoUrl;
    } catch (e) {
      errorMessage.value = 'Failed to upload logo: $e';
      debugPrint('Error uploading logo: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<Map<String, dynamic>>> getCompanyMembers(String companyId) async {
    try {
      final response = await _db
          .from('company_members')
          .select('*, profiles(full_name, avatar_url)')
          .eq('company_id', companyId)
          .order('joined_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching company members: $e');
      return [];
    }
  }
}
