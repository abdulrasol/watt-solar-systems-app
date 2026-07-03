// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/calculations/domain/entities/system_model.dart';
import 'package:solar_hub/src/features/calculations/presentation/providers/systems_provider.dart';

class SaveToSystemDialog extends ConsumerStatefulWidget {
  const SaveToSystemDialog({super.key});

  @override
  ConsumerState<SaveToSystemDialog> createState() => _SaveToSystemDialogState();
}

class _SaveToSystemDialogState extends ConsumerState<SaveToSystemDialog> {
  SystemModel? _selectedSystem;
  final TextEditingController _nameController = TextEditingController();
  bool _isCreatingNew = false;
  late final SystemsState _systemsState;

  @override
  void initState() {
    super.initState();
    _systemsState = ref.read(systemsProvider);
    if (_systemsState.savedSystems.isNotEmpty) {
      _selectedSystem = _systemsState.savedSystems.first;
      _isCreatingNew = false;
    } else {
      _isCreatingNew = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final systemsState = ref.watch(systemsProvider);
    return AlertDialog(
      title: Text(_isCreatingNew ? l10n.new_system : l10n.select_system),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_isCreatingNew) ...[
              Text(l10n.add_calculation_to_existing_system, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 10),
              if (systemsState.savedSystems.isNotEmpty)
                Column(
                  children: systemsState.savedSystems.map((system) {
                    return RadioListTile<SystemModel>(
                      title: Text(system.systemName ?? 'Msg_Unknown', style: const TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: Text(system.createdAt.toString().split(' ')[0]),
                      value: system,
                      groupValue: _selectedSystem,
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      activeColor: Theme.of(context).primaryColor,
                      onChanged: (val) => setState(() => _selectedSystem = val),
                    );
                  }).toList(),
                )
              else
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(l10n.no_saved_systems_found, style: TextStyle(fontStyle: FontStyle.italic)),
                ),
              const Divider(),
              Center(
                child: TextButton.icon(
                  onPressed: () => setState(() {
                    _isCreatingNew = true;
                    _selectedSystem = null;
                  }),
                  icon: const Icon(Iconsax.add_square),
                  label: Text(l10n.create_new_system),
                ),
              ),
            ] else ...[
              Text(l10n.enter_system_name),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: l10n.system_name,
                  hintText: l10n.system_name_hint,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Iconsax.edit_2),
                ),
              ),
              if (systemsState.savedSystems.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: TextButton.icon(
                    onPressed: () => setState(() {
                      _isCreatingNew = false;
                      _selectedSystem = systemsState.savedSystems.first;
                    }),
                    icon: const Icon(Icons.arrow_back),
                    label: Text(l10n.back_to_list),
                  ),
                ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.cancel)),
        ElevatedButton(
          onPressed: _onSave,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(l10n.save),
        ),
      ],
    );
  }

  void _onSave() {
    if (_isCreatingNew) {
      final name = _nameController.text.trim();
      if (name.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.error_enter_system_name), behavior: SnackBarBehavior.floating));
        return;
      }
      Navigator.of(context).pop({'isNew': true, 'name': name, 'system': null, 'companyId': null});
    } else {
      if (_selectedSystem == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.error_select_system), behavior: SnackBarBehavior.floating));
        return;
      }
      Navigator.of(context).pop({'isNew': false, 'system': _selectedSystem, 'name': null});
    }
  }
}
