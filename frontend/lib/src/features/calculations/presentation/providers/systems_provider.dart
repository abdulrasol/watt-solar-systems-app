import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_hub/src/core/cashe/cashe_interface.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/core/enums/system_status.dart';
import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solar_hub/src/features/calculations/domain/entities/system_model.dart';

class SystemsState {
  final List<SystemModel> savedSystems;
  final List<SystemModel> installedSystems;
  final bool isLoading;

  const SystemsState({
    this.savedSystems = const [],
    this.installedSystems = const [],
    this.isLoading = false,
  });

  SystemsState copyWith({
    List<SystemModel>? savedSystems,
    List<SystemModel>? installedSystems,
    bool? isLoading,
  }) {
    return SystemsState(
      savedSystems: savedSystems ?? this.savedSystems,
      installedSystems: installedSystems ?? this.installedSystems,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SystemsProvider extends Notifier<SystemsState> {
  static const String _savedSystemsKey = 'saved_system_models';

  @override
  SystemsState build() {
    final authState = ref.read(authProvider);
    final persistedSystems = _loadPersistedSystems();
    final visibleSystems = _filterSystemsForUser(
      persistedSystems,
      authState.user?.id,
    );

    return SystemsState(
      savedSystems: visibleSystems,
      installedSystems: visibleSystems
          .where((system) => system.installedByCompanyId != null)
          .toList(),
    );
  }

  Future<void> fetchSystems() async {
    state = state.copyWith(isLoading: true);
    try {
      final authState = ref.read(authProvider);
      if (authState.user == null) {
        state = const SystemsState();
        return;
      }

      final visibleSystems = _filterSystemsForUser(
        _loadPersistedSystems(),
        authState.user?.id,
      );

      state = state.copyWith(
        savedSystems: visibleSystems,
        installedSystems: visibleSystems
            .where((system) => system.installedByCompanyId != null)
            .toList(),
      );
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
      final user = authState.user;
      if (user == null) return;

      final systems = _loadPersistedSystems();
      final newSpecs = existingSystem?.specs != null
          ? Map<String, dynamic>.from(existingSystem!.specs)
          : <String, dynamic>{};
      newSpecs[partName] = data;

      if (existingSystem != null) {
        final index = systems.indexWhere((system) => system.id == existingSystem.id);
        if (index == -1) {
          return;
        }
        systems[index] = _mergeSystem(
          systems[index],
          specs: newSpecs,
          installedByCompanyId: companyId ?? systems[index].installedByCompanyId,
        );
      } else {
        final displayName = user.fullName.trim().isNotEmpty
            ? user.fullName.trim()
            : user.username;
        systems.add(
          SystemModel(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            ownerId: user.id.toString(),
            installedByCompanyId: companyId,
            verificationStatus: SystemStatus.pendingVerification,
            systemName: newSystemName?.trim().isNotEmpty == true
                ? newSystemName!.trim()
                : 'Saved System',
            specs: newSpecs,
            createdAt: DateTime.now(),
            userName: displayName,
            installer: '',
          ),
        );
      }

      await _persistSystems(systems);
      await fetchSystems();
    } catch (e) {
      debugPrint('Error saving system part: $e');
    }
  }

  Future<void> deleteSavedSystem(String id) async {
    try {
      final systems = _loadPersistedSystems();
      systems.removeWhere((system) => system.id == id);
      await _persistSystems(systems);
      await fetchSystems();
    } catch (e) {
      debugPrint('Error deleting system: $e');
    }
  }

  Future<void> updateSystemStatus(String id, String status) async {
    try {
      final systems = _loadPersistedSystems();
      final index = systems.indexWhere((system) => system.id == id);
      if (index == -1) {
        return;
      }

      systems[index] = _mergeSystem(
        systems[index],
        verificationStatus: _statusFromString(status),
      );
      await _persistSystems(systems);
      await fetchSystems();
    } catch (e) {
      debugPrint('Error updating system status: $e');
    }
  }

  Future<List<Map<String, dynamic>>> searchCompanies(String query) async {
    return const <Map<String, dynamic>>[];
  }

  Future<void> requestOffers(SystemModel system, {String? notes}) async {
    try {
      final authState = ref.read(authProvider);
      if (authState.user == null) return;

      final systems = _loadPersistedSystems();
      final index = systems.indexWhere((savedSystem) => savedSystem.id == system.id);
      if (index == -1) {
        return;
      }

      final specs = Map<String, dynamic>.from(systems[index].specs);
      specs['offer_request'] = <String, dynamic>{
        'requested_at': DateTime.now().toIso8601String(),
        'notes': notes,
        'status': 'pending_submission',
      };

      systems[index] = _mergeSystem(systems[index], specs: specs);
      await _persistSystems(systems);
      await fetchSystems();
    } catch (e) {
      debugPrint('Error requesting offers: $e');
    }
  }

  List<SystemModel> _loadPersistedSystems() {
    final raw = getIt<CasheInterface>().get(_savedSystemsKey);
    if (raw is! List) {
      return <SystemModel>[];
    }

    return raw
        .whereType<Map>()
        .map((item) => SystemModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  List<SystemModel> _filterSystemsForUser(List<SystemModel> systems, int? userId) {
    if (userId == null) {
      return <SystemModel>[];
    }

    final ownerId = userId.toString();
    final filtered = systems.where((system) => system.ownerId == ownerId).toList();
    filtered.sort(
      (a, b) => (b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0)).compareTo(
        a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0),
      ),
    );
    return filtered;
  }

  Future<void> _persistSystems(List<SystemModel> systems) {
    return getIt<CasheInterface>().save(
      _savedSystemsKey,
      systems.map((system) => system.toJson()).toList(),
    );
  }

  SystemModel _mergeSystem(
    SystemModel original, {
    Map<String, dynamic>? specs,
    String? installedByCompanyId,
    SystemStatus? verificationStatus,
  }) {
    return SystemModel(
      id: original.id,
      ownerId: original.ownerId,
      installedByCompanyId: installedByCompanyId ?? original.installedByCompanyId,
      verificationStatus: verificationStatus ?? original.verificationStatus,
      systemName: original.systemName,
      locationCoordinates: original.locationCoordinates,
      totalCapacityKw: original.totalCapacityKw,
      imageUrl: original.imageUrl,
      specs: specs ?? original.specs,
      notes: original.notes,
      installDate: original.installDate,
      createdAt: original.createdAt,
      userName: original.userName,
      installer: original.installer,
    );
  }

  SystemStatus _statusFromString(String status) {
    for (final value in SystemStatus.values) {
      if (value.name == status) {
        return value;
      }
    }
    return SystemStatus.pendingVerification;
  }
}

final systemsProvider = NotifierProvider<SystemsProvider, SystemsState>(() {
  return SystemsProvider();
});
