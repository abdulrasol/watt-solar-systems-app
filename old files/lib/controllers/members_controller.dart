import 'package:get/get.dart';
import 'package:solar_hub/services/supabase_service.dart';
import 'package:solar_hub/controllers/company_controller.dart';

class MembersController extends GetxController {
  final isLoading = false.obs;
  final members = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchMembers();
  }

  Future<void> fetchMembers() async {
    final companyId = Get.find<CompanyController>().company.value?.id;
    if (companyId == null) return;

    isLoading.value = true;
    try {
      // Fetch members with profile details
      final response = await SupabaseService().client.from('company_members').select('*, profiles(*)').eq('company_id', companyId);

      members.assignAll(List<Map<String, dynamic>>.from(response));
    } catch (e) {
       // print('Error fetching members: $e');
      // We can't show snackbar here reliably without context
    } finally {
      isLoading.value = false;
    }
  }

  Future<Map<String, dynamic>> addMember(String emailOrPhone, List<String> roles) async {
    try {
      final companyId = Get.find<CompanyController>().company.value?.id;
      if (companyId == null) {
        return {'success': false, 'message': 'No company found'};
      }

      // Search for user by phone_number in profiles table
      var result = await SupabaseService().client.from('profiles').select('id, full_name, phone_number').eq('phone_number', emailOrPhone).maybeSingle();

      if (result == null) {
        return {'success': false, 'message': 'user_not_found'};
      }

      final userId = result['id'];

      // Check if user is already a member
      final existingMember = await SupabaseService().client
          .from('company_members')
          .select('id')
          .eq('company_id', companyId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existingMember != null) {
        return {'success': false, 'message': 'user_already_member'};
      }

      // Insert new member
      await SupabaseService().client.from('company_members').insert({
        'company_id': companyId,
        'user_id': userId,
        'roles': roles,
        'role': roles.isNotEmpty ? roles.first : 'staff', // Backward compat
      });

      // Refresh the members list
      await fetchMembers();

      return {'success': true, 'message': 'member_added_success'};
    } catch (e) {
       // print('Error adding member: $e');
      return {'success': false, 'message': 'Failed to add member: $e'};
    }
  }

  Future<bool> updateMemberRoles(String memberId, List<String> newRoles) async {
    try {
      await SupabaseService().client.from('company_members').update({'roles': newRoles}).eq('id', memberId);

      final index = members.indexWhere((m) => m['id'] == memberId);
      if (index != -1) {
        members[index]['roles'] = newRoles;
        members.refresh();
      }
      return true;
    } catch (e) {
       // print('Error updating member: $e');
      return false;
    }
  }

  Future<bool> removeMember(String memberId) async {
    try {
      await SupabaseService().client.from('company_members').delete().eq('id', memberId);

      members.removeWhere((m) => m['id'] == memberId);
      return true;
    } catch (e) {
       // print('Error removing member: $e');
      return false;
    }
  }
}
