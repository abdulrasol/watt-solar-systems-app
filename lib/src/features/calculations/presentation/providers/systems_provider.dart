import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_hub/src/features/calculations/domain/entities/system_model.dart';
import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';

class SystemsState {
  final List<SystemModel> savedSystems;
  final List<SystemModel> installedSystems;
  final bool isLoading;

  SystemsState({this.savedSystems = const [], this.installedSystems = const [], this.isLoading = false});

  SystemsState copyWith({List<SystemModel>? savedSystems, List<SystemModel>? installedSystems, bool? isLoading}) {
    return SystemsState(
      savedSystems: savedSystems ?? this.savedSystems,
      installedSystems: installedSystems ?? this.installedSystems,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SystemsProvider extends Notifier<SystemsState> {
  @override
  SystemsState build() {
    // Initial fetch
    Future.microtask(() => fetchSystems());
    return SystemsState();
  }

  Future<void> fetchSystems() async {
    state = state.copyWith(isLoading: true);
    try {
      final authState = ref.read(authProvider);
      if (authState.user == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      // TODO: Replace with actual API call
      // Mocking fetch for now since Supabase was removed
      final fetched = <SystemModel>[];

      state = state.copyWith(savedSystems: fetched, installedSystems: fetched.where((s) => s.installedByCompanyId != null).toList());
    } catch (e) {
      debugPrint('Error fetching systems: $e');
    } finally {
      state = state.copyWith(isLoading: false);
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
      final authState = ref.read(authProvider);
      if (authState.user == null) return;

      Map<String, dynamic> newSpecs = existingSystem?.specs != null ? Map<String, dynamic>.from(existingSystem!.specs) : {};

      newSpecs[partName] = data;

      if (existingSystem != null) {
        // TODO: Implement API Update Call
        debugPrint('TODO: Update system part "$partName" with new data for system ID ${existingSystem.id}');
      } else {
        // TODO: Implement API Create Call
        debugPrint('TODO: Create new system with part "$partName"');
      }

      await fetchSystems();
    } catch (e) {
      debugPrint('Error saving system part: $e');
    }
  }

  Future<void> deleteSavedSystem(String id) async {
    try {
      // TODO: Implement API Delete Call
      debugPrint('TODO: Delete system $id');
      await fetchSystems();
    } catch (e) {
      debugPrint('Error deleting system: $e');
    }
  }

  Future<void> updateSystemStatus(String id, String status) async {
    try {
      // TODO: Implement API Status Update Call
      debugPrint('TODO: Update system $id status to $status');
      await fetchSystems();
    } catch (e) {
      debugPrint('Error updating system status: $e');
    }
  }

  Future<List<Map<String, dynamic>>> searchCompanies(String query) async {
    try {
      if (query.length < 3) return [];
      // TODO: Implement API Search Call
      debugPrint('TODO: Search companies for query: $query');
      return [];
    } catch (e) {
      debugPrint('Error searching companies: $e');
      return [];
    }
  }

  Future<void> requestOffers(SystemModel system, {String? notes}) async {
    try {
      final authState = ref.read(authProvider);
      if (authState.user == null) return;

      // TODO: Implement API Request Offers Call
      debugPrint('TODO: Request offers for system ${system.id}');
    } catch (e) {
      debugPrint('Error requesting offers: $e');
    }
  }
}

final systemsProvider = NotifierProvider<SystemsProvider, SystemsState>(() {
  return SystemsProvider();
});
