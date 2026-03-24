import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/cashe/cashe_interface.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/features/calculations/domain/entities/calculated_system.dart';
import 'package:solar_hub/src/features/calculations/presentation/providers/calculator_controller.dart';
import 'package:solar_hub/src/features/calculations/presentation/screens/system_calculator_wizard.dart';
import 'package:intl/intl.dart';

class CalculatedSystemsPage extends ConsumerStatefulWidget {
  const CalculatedSystemsPage({super.key});

  @override
  ConsumerState<CalculatedSystemsPage> createState() => _CalculatedSystemsPageState();
}

class _CalculatedSystemsPageState extends ConsumerState<CalculatedSystemsPage> {
  List<CalculatedSystem> savedSystems = [];

  @override
  void initState() {
    super.initState();
    _loadSavedSystems();
  }

  void _loadSavedSystems() {
    try {
      final cached = getIt<CasheInterface>().get('saved_calculated_systems');
      if (cached != null) {
        setState(() {
          savedSystems = List<dynamic>.from(cached)
              .map((e) => CalculatedSystem.fromJson(e as Map<String, dynamic>))
              .toList().reversed.toList();
        });
      }
    } catch (e) {
      debugPrint("Error loading saved systems: $e");
    }
  }

  Future<void> _deleteSystem(String id) async {
    try {
      final cache = getIt<CasheInterface>();
      final existingData = cache.get('saved_calculated_systems');
      if (existingData != null) {
        List<CalculatedSystem> systems = List<dynamic>.from(existingData)
            .map((e) => CalculatedSystem.fromJson(e as Map<String, dynamic>))
            .toList();
        systems.removeWhere((s) => s.id == id);
        await cache.save('saved_calculated_systems', systems.map((e) => e.toJson()).toList());
        _loadSavedSystems();
      }
    } catch (e) {
      debugPrint("Error deleting system: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.my_systems),
      ),
      body: savedSystems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.folder_open_outline, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(l10n.no_saved_systems_found, style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: savedSystems.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final system = savedSystems[index];
                return _buildSystemItem(context, system);
              },
            ),
    );
  }

  Widget _buildSystemItem(BuildContext context, CalculatedSystem system) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          ref.read(calculatorProvider).loadCalculation(system);
          await Navigator.push(context, MaterialPageRoute(builder: (context) => const SystemCalculatorWizard()));
          _loadSavedSystems();
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Iconsax.flash_bold, color: Colors.green),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      system.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${system.recommendedPanels} Panels, ${system.recommendedInverterSize.toStringAsFixed(1)} kW",
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat.yMMMd().add_jm().format(system.date),
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Iconsax.trash_outline, color: Colors.red),
                onPressed: () => _showDeleteConfirmation(context, system),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, CalculatedSystem system) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete'),
        content: const Text('Are you sure you want to delete this system?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.cancel)),
          TextButton(
            onPressed: () {
              _deleteSystem(system.id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
