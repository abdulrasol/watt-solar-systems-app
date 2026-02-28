import 'package:get/get.dart';
import 'package:solar_hub/models/company_model.dart';
import 'package:solar_hub/services/supabase_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

class AdminCompaniesController extends GetxController {
  final _db = SupabaseService().client;

  final isLoading = false.obs;
  final companies = <CompanyModel>[].obs;
  final filterStatus = 'pending'.obs; // Default to pending as that's the main workload

  @override
  void onInit() {
    super.onInit();
    fetchCompanies();
  }

  void setFilter(String status) {
    if (filterStatus.value == status) return;
    filterStatus.value = status;
    fetchCompanies();
  }

  Future<void> fetchCompanies() async {
    try {
      isLoading.value = true;
      var query = _db.from('companies').select();

      if (filterStatus.value != 'all') {
        query = query.eq('status', filterStatus.value);
      }

      final response = await query.order('created_at', ascending: false);
      final data = List<Map<String, dynamic>>.from(response);
      companies.assignAll(data.map((e) => CompanyModel.fromJson(e)).toList());
    } catch (e) {
      _showError('Failed to fetch companies: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateStatus(String companyId, String newStatus) async {
    try {
      isLoading.value = true;
      await _db.from('companies').update({'status': newStatus}).eq('id', companyId);

      // Update local list
      final index = companies.indexWhere((c) => c.id == companyId);
      if (index != -1) {
        // If we are filtering by a specific status, remove it from list
        if (filterStatus.value != 'all' && filterStatus.value != newStatus) {
          companies.removeAt(index);
        } else {
          // Otherwise verify update (re-fetch or manual update if model supports copyWith)
          // Simplified: just refetch to be safe and lazy
          fetchCompanies();
        }
      }

      _showSuccess('Company status updated to $newStatus');
    } catch (e) {
      _showError('Failed to update status: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> rejectCompany(String companyId) => updateStatus(companyId, 'rejected');
  Future<void> approveCompany(String companyId) => updateStatus(companyId, 'active');

  Future<void> contactOwner(String companyId) async {
    try {
      // Find owner
      final memberRes = await _db
          .from('company_members')
          .select('user_id, profiles(phone_number, full_name, email)')
          .eq('company_id', companyId)
          .eq('role', 'owner') // Assuming single owner for now or pick first
          .limit(1)
          .maybeSingle();

      if (memberRes == null) {
        _showInfo('No owner found for this company.');
        return;
      }

      final profile = memberRes['profiles'] as Map<String, dynamic>?;
      if (profile == null) {
        _showInfo('Owner profile not found.');
        return;
      }

      final phone = profile['phone_number'] as String?;
      // final email = profile['email'] as String?; // Assuming email might be in profile eventually

      if (phone != null && phone.isNotEmpty) {
        final url = Uri.parse('tel:$phone');
        if (await canLaunchUrl(url)) {
          await launchUrl(url);
        } else {
          _showError('Could not launch dialer for $phone');
        }
      } else {
        _showInfo('Owner has no phone number connected.');
      }
    } catch (e) {
      _showError('Failed to contact owner: $e');
    }
  }

  void _showSuccess(String message) {
    Get.showSnackbar(
      GetSnackBar(
        message: message,
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.TOP,
        borderRadius: 8,
        margin: const EdgeInsets.all(10),
        icon: const Icon(Icons.check_circle, color: Colors.white),
      ),
    );
  }

  void _showError(String message) {
    Get.showSnackbar(
      GetSnackBar(
        message: message,
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.TOP,
        borderRadius: 8,
        margin: const EdgeInsets.all(10),
        icon: const Icon(Icons.error, color: Colors.white),
      ),
    );
  }

  void _showInfo(String message) {
    Get.showSnackbar(
      GetSnackBar(
        message: message,
        backgroundColor: Colors.blueGrey,
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.TOP,
        borderRadius: 8,
        margin: const EdgeInsets.all(10),
        icon: const Icon(Icons.info, color: Colors.white),
      ),
    );
  }

  Future<Map<String, int>> getCompanyStats(String companyId) async {
    try {
      final results = await Future.wait([
        _db.from('company_members').count(CountOption.exact).eq('company_id', companyId),
        _db.from('products').count(CountOption.exact).eq('company_id', companyId),
        _db.from('orders').count(CountOption.exact).eq('seller_company_id', companyId),
        _db.from('systems').count(CountOption.exact).eq('installed_by', companyId),
      ]);

      return {'members': results[0], 'products': results[1], 'orders': results[2], 'systems': results[3]};
    } catch (e) {
      debugPrint('Error fetching stats: $e');
      return {'members': 0, 'products': 0, 'orders': 0, 'systems': 0};
    }
  }
}
