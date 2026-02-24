import 'package:get/get.dart';
import 'package:solar_hub/models/system_model.dart';
import 'package:solar_hub/services/supabase_service.dart';

class SystemsController extends GetxController {
  final _supabase = SupabaseService().client;

  final savedSystems = <SystemModel>[].obs;
  final installedSystems = <SystemModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSystems();
  }

  Future<void> fetchSystems() async {
    try {
      isLoading.value = true;
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await _supabase.from('systems').select().eq('user_id', userId).order('created_at', ascending: false);

      final List<SystemModel> fetched = (response as List).map((json) => SystemModel.fromJson(json)).toList();

      // Separate into saved/draft vs installed?
      // Verification status usually determines if it's "installed" (verified) or just a draft/pending
      savedSystems.assignAll(fetched);
      installedSystems.assignAll(fetched.where((s) => s.installedByCompanyId != null).toList());
    } catch (e) {
      // print('Error fetching user systems: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveSystemPart({
    SystemModel? existingSystem,
    String? newSystemName,
    String? companyId,
    required String partName,
    required Map<String, dynamic> data,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      Map<String, dynamic> newSpecs = existingSystem?.specs != null ? Map<String, dynamic>.from(existingSystem!.specs) : {};

      newSpecs[partName] = data;

      // Map partName to correct column
      // parts: batteries -> battery, panels -> pv, inverter -> inverter
      String targetCol = 'notes'; // fallback
      if (partName == 'batteries') targetCol = 'battery';
      if (partName == 'panels') targetCol = 'pv';
      if (partName == 'inverter') targetCol = 'inverter';

      if (existingSystem != null) {
        // Update existing column
        // Note: this overwrites the existing component data completely with new data
        Map<String, dynamic> updateData = {targetCol: data, 'updated_at': DateTime.now().toIso8601String()};
        if (companyId != null) {
          updateData['installed_by'] = companyId;
          updateData['company_status'] = 'pending';
          updateData['user_status'] = 'accepted'; // User initiated

          // Notify company members
          await _notifyCompanyMembers(companyId, 'System Installation Request', 'A user has linked a solar system to your company for verification.');
        }
        await _supabase.from('systems').update(updateData).eq('id', existingSystem.id);
      } else {
        // Create new
        Map<String, dynamic> insertData = {'user_id': userId, 'notes': newSystemName ?? 'New System', targetCol: data};
        if (companyId != null) {
          insertData['installed_by'] = companyId;
          insertData['company_status'] = 'pending';
          insertData['user_status'] = 'accepted';

          // Notify company members
          await _notifyCompanyMembers(
            companyId,
            'System Installation Request',
            'A user has added a solar system and linked it to your company for verification.',
          );
        } else {
          insertData['user_status'] = 'accepted';
          insertData['company_status'] = 'pending';
        }
        await _supabase.from('systems').insert(insertData);
      }
      await fetchSystems();
    } catch (e) {
      // print('Error saving system part: $e');
    }
  }

  Future<void> _notifyCompanyMembers(String companyId, String title, String body) async {
    try {
      final membersRes = await _supabase.from('company_members').select('user_id').eq('company_id', companyId);
      final List<dynamic> members = membersRes as List<dynamic>;

      if (members.isNotEmpty) {
        final notifications = members
            .map(
              (m) => {
                'user_id': m['user_id'],
                'title': title,
                'body': body,
                'type': 'system_verification',
                'related_entity_id': null,
                'is_read': false,
                'created_at': DateTime.now().toIso8601String(),
              },
            )
            .toList();

        await _supabase.from('notifications').insert(notifications);
      }
    } catch (e) {
      // print('Error notifying company members: $e');
    }
  }

  Future<void> deleteSavedSystem(String id) async {
    try {
      await _supabase.from('systems').delete().eq('id', id);
      await fetchSystems();
    } catch (e) {
      // print('Error deleting system: $e');
    }
  }

  Future<void> updateSystemStatus(String id, String status) async {
    try {
      // Map verified to accepted
      final statusMap = (status == 'verified') ? 'accepted' : 'pending';
      await _supabase.from('systems').update({'company_status': statusMap, 'user_status': statusMap}).eq('id', id);
      await fetchSystems();
    } catch (e) {
      // print('Error updating system status: $e');
    }
  }

  Future<List<Map<String, dynamic>>> searchCompanies(String query) async {
    try {
      if (query.length < 3) return [];
      final response = await _supabase.from('companies').select('id, name, logo_url').ilike('name', '%$query%').limit(10);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      // print('Error searching companies: $e');
      return [];
    }
  }

  Future<void> requestOffers(SystemModel system, {String? notes}) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // // Extract details from system specs
      // final details = {
      //   'system_id': system.id,
      //   'system_name': system.systemName,
      //   'capacity': system.totalCapacityKw,
      //   'specs': system.specs, // Explicitly save the specs
      // };

      await _supabase.from('offer_requests').insert({
        'user_id': userId,
        'title': 'Request for ${system.systemName ?? "System"}',
        'notes': notes ?? 'Please provide an offer for this system configuration.',
        'specs': system.specs, // Correct column per schema
        'pv_total': system.totalCapacityKw ?? 0,
        'status': 'open',
      });

      Get.snackbar('Success', 'Offer request submitted successfully');
    } catch (e) {
      // print('Error requesting offers: $e');
      Get.snackbar('Error', 'Failed to submit offer request');
    }
  }
}
