import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_hub/controllers/company_controller.dart';
import 'package:solar_hub/core/di/get_it.dart';
import 'package:solar_hub/features/compnay/controllers/company_controller.dart';
import '../../../../../lib/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solar_hub/features/systems/models/system_model.dart';
import 'package:solar_hub/features/compnay/controllers/auth_controller.dart';
import 'package:solar_hub/services/supabase_service.dart';
import 'package:solar_hub/models/company_model.dart';
import 'package:solar_hub/utils/toast_service.dart';

enum SystemFilterType { company, user, hub, storeProfile }

class SystemsController extends GetxController {
  final _db = SupabaseService().client;
  final AuthController _auth = getIt<AuthController>();
  final CompanyController _companyController = getIt<CompanyController>();

  // State
  final RxList<SystemModel> mySystems = <SystemModel>[].obs; // For User
  final RxList<SystemModel> companySystems = <SystemModel>[].obs; // For Company
  final RxList<SystemModel> publicSystems = <SystemModel>[].obs; // For Hub/Public
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserSystems();
    fetchPublicSystems();

    // Check if user has company and fetch
    String? companyId = _companyController.company.value?.id.toString();
    if (companyId != null && companyId.isNotEmpty) {
      fetchCompanySystems(companyId);
    }
  }

  // --- Fetching ---

  // --- Fetching ---

  Future<List<SystemModel>> fetchSystemsUnified({required SystemFilterType type, String? id, int page = 1, int limit = 20}) async {
    try {
      var query = _db.from('systems').select('*, companies(name, logo_url), profiles:profiles!systems_user_id_fkey(full_name, avatar_url)');

      switch (type) {
        case SystemFilterType.company:
          if (id != null) query = query.eq('installed_by', id);
          break;
        case SystemFilterType.user:
          // Query by 'user_id' OR 'user' (phone) for backward compatibility
          if (id != null) {
            final user = _auth.user.value;
            final userId = user?.id;
            final phone = user?.phone;

            if (userId != null && phone != null) {
              query = query.or('user_id.eq.$userId,user.eq.$phone');
            } else if (userId != null) {
              query = query.eq('user_id', userId);
            } else if (phone != null) {
              query = query.eq('user', phone);
            }
          }
          break;
        case SystemFilterType.hub:
          // Hub: Show fully accepted systems (Public Feed)
          query = query.eq('user_status', 'accepted').eq('company_status', 'accepted');
          break;
        case SystemFilterType.storeProfile:
          // Store Profile: Only systems installed by this company (and likely accepted)
          if (id != null) query = query.eq('installed_by', id);
          query = query.eq('company_status', 'accepted'); // portfolio only shows verified
          break;
      }

      // Pagination
      final from = (page - 1) * limit;
      final to = from + limit - 1;
      final response = await query.order('created_at', ascending: false).range(from, to);

      final data = response as List<dynamic>;
      return data.map((e) => SystemModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint("Error fetching systems: $e");
      return [];
    }
  }

  Future<void> fetchUserSystems() async {
    try {
      isLoading.value = true;
      final user = _auth.user.value;
      if (user == null) return;
      // print(user.phone);
      final phone = user.phone;
      if (phone == null || phone.isEmpty) {
        debugPrint("User phone is null, cannot fetch systems");
        return;
      }

      final systems = await fetchSystemsUnified(type: SystemFilterType.user, id: phone);
      mySystems.assignAll(systems);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCompanySystems(String companyId) async {
    try {
      isLoading.value = true;
      final systems = await fetchSystemsUnified(type: SystemFilterType.company, id: companyId);
      companySystems.assignAll(systems);
    } finally {
      isLoading.value = false;
    }
  }

  // Pagination State for Public Systems
  int _publicSystemsPage = 1;
  final int _publicSystemsPageSize = 10;
  final RxBool isMorePublicSystemsAvailable = true.obs;

  Future<void> fetchPublicSystems({bool refresh = false}) async {
    if (refresh) {
      _publicSystemsPage = 1;
      isMorePublicSystemsAvailable.value = true;
    }

    if (!isMorePublicSystemsAvailable.value && !refresh) return;

    try {
      if (refresh) isLoading.value = true;

      // Use fetchSystemsUnified with pagination
      final newSystems = await fetchSystemsUnified(type: SystemFilterType.hub, page: _publicSystemsPage, limit: _publicSystemsPageSize);

      if (newSystems.length < _publicSystemsPageSize) {
        isMorePublicSystemsAvailable.value = false;
      }

      if (refresh) {
        publicSystems.assignAll(newSystems);
      } else {
        publicSystems.addAll(newSystems);
      }

      _publicSystemsPage++;
    } catch (e) {
      debugPrint("Error fetching public systems: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // --- Actions ---

  Future<bool> createSystem(SystemModel system) async {
    try {
      isLoading.value = true;

      // Ensure userPhone is set from current user ONLY if this is a self-installed system (user creating their own system)
      // If installedBy is set, it means a company is creating it for a client, so we shouldn't default to the company's phone.
      if ((system.userPhone == null || system.userPhone!.isEmpty) && system.installedBy == null) {
        final currentUser = _auth.user.value;
        if (currentUser?.phone != null) {
          system = system.copyWith(userPhone: currentUser!.phone);
        }
      }

      // Convert to JSON and remove ID/dates to let DB handle defaults
      final json = system.toJson();
      json.remove('id');
      json.remove('created_at');
      json.remove('updated_at');

      // Diagnostics
      final currentUser = _auth.user.value;
      debugPrint("Current User ID: ${currentUser?.id}");
      debugPrint("Current User Phone: ${currentUser?.phone}");

      // Fix legacy FK issue: If we have user_id, we should prefer it and avoid the strict phone number FK (systems_user_fkey)
      // which often fails due to formatting mismatches between auth and profile.
      if (json['user_id'] != null && json['user_id'].toString().isNotEmpty) {
        debugPrint("Removing legacy 'user' (phone) field because 'user_id' is present to avoid FK violation");
        json.remove('user');
      }

      debugPrint("Attempting to create system with JSON: $json");

      await _db.from('systems').insert(json);

      // Refresh lists
      if (system.userId == _auth.user.value?.id) fetchUserSystems();
      if (system.installedBy != null) fetchCompanySystems(system.installedBy!);

      return true;
    } catch (e) {
      debugPrint("Error creating system: $e");
      if (e.toString().contains('systems_user_fkey') || e.toString().contains('systems_user_id_fkey')) {
        ToastService.error("Profile Missing", "Your profile is not fully initialized. Please update your profile first.");
      } else {
        ToastService.error("Error", "Failed to create system: ${e.toString()}");
      }
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateSystem(SystemModel system) async {
    if (system.id == null) return false;
    try {
      isLoading.value = true;
      final json = system.toJson();
      json['updated_at'] = DateTime.now().toIso8601String();

      await _db.from('systems').update(json).eq('id', system.id!);

      // Refresh local state without full refetch if possible, but refetch is safer
      int index = mySystems.indexWhere((s) => s.id == system.id);
      if (index != -1) mySystems[index] = system;

      int cIndex = companySystems.indexWhere((s) => s.id == system.id);
      if (cIndex != -1) companySystems[cIndex] = system;

      return true;
    } catch (e) {
      // print("Error updating system: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteSystem(String id) async {
    try {
      isLoading.value = true;
      await _db.from('systems').delete().eq('id', id);
      mySystems.removeWhere((s) => s.id == id);
      companySystems.removeWhere((s) => s.id == id);
      return true;
    } catch (e) {
      debugPrint("Error deleting system: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // --- Status Management ---

  Future<void> updateStatus(String id, {String? userStatus, String? companyStatus}) async {
    try {
      isLoading.value = true;
      final Map<String, dynamic> updates = {};
      if (userStatus != null) updates['user_status'] = userStatus;
      if (companyStatus != null) updates['company_status'] = companyStatus;

      await _db.from('systems').update(updates).eq('id', id);

      // Update local state
      int index = mySystems.indexWhere((s) => s.id == id);
      if (index != -1) {
        mySystems[index] = mySystems[index].copyWith(userStatus: userStatus, companyStatus: companyStatus);
        mySystems.refresh(); // Force update
      }

      int cIndex = companySystems.indexWhere((s) => s.id == id);
      if (cIndex != -1) {
        companySystems[cIndex] = companySystems[cIndex].copyWith(userStatus: userStatus, companyStatus: companyStatus);
        companySystems.refresh();
      }
    } catch (e) {
      debugPrint("Error updating status: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<Map<String, dynamic>>> searchCompanies(String query) async {
    try {
      final response = await _db.from('companies').select('id, name, logo_url').ilike('name', '%$query%').limit(10);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint("Error searching companies: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      // Search profiles by email (exact match)
      final response = await _db.from('profiles').select('id, full_name, avatar_url,phone_number').eq('phone_number', query).limit(1);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint("Error searching users: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>?> getUser(String id) async {
    try {
      final response = await _db.from('profiles').select('id, full_name, avatar_url, phone_number').eq('id', id).maybeSingle();
      return response;
    } catch (e) {
      debugPrint("Error fetching user: $e");
      return null;
    }
  }

  Future<CompanyModel?> fetchCompanyById(String id) async {
    try {
      final response = await _db.from('companies').select().eq('id', id).maybeSingle();
      if (response != null) {
        return CompanyModel.fromJson(response);
      }
      return null;
    } catch (e) {
      debugPrint("Error fetching company by ID: $e");
      return null;
    }
  }
}
