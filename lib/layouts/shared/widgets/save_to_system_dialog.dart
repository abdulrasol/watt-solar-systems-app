// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/controllers/systems_controller.dart';
import 'package:solar_hub/models/system_model.dart';
import 'package:solar_hub/utils/app_theme.dart';

class SaveToSystemDialog extends StatefulWidget {
  const SaveToSystemDialog({super.key});

  @override
  State<SaveToSystemDialog> createState() => _SaveToSystemDialogState();
}

class _SaveToSystemDialogState extends State<SaveToSystemDialog> {
  final SystemsController controller = Get.find();
  SystemModel? _selectedSystem;
  final TextEditingController _nameController = TextEditingController();
  bool _isCreatingNew = false;
  String? _selectedCompanyId;
  String? _selectedCompanyName;
  List<Map<String, dynamic>> _companyResults = [];
  bool _isSearchingCompany = false;

  @override
  void initState() {
    super.initState();
    if (controller.savedSystems.isNotEmpty) {
      _selectedSystem = controller.savedSystems.first;
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
    return AlertDialog(
      title: Text(_isCreatingNew ? 'New System' : 'Select System'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_isCreatingNew) ...[
              const Text('Add calculation to existing system:', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 10),
              if (controller.savedSystems.isNotEmpty)
                Column(
                  children: controller.savedSystems.map((system) {
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
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("No saved systems found.", style: TextStyle(fontStyle: FontStyle.italic)),
                ),
              const Divider(),
              Center(
                child: TextButton.icon(
                  onPressed: () => setState(() {
                    _isCreatingNew = true;
                    _selectedSystem = null;
                  }),
                  icon: const Icon(Iconsax.add_square_bold),
                  label: const Text("Create New System"),
                ),
              ),
            ] else ...[
              const Text('Enter a name for your new system:'),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'System Name',
                  hintText: 'e.g., My Dream Home',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Iconsax.edit_2_bold),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Select Installer (Optional):', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (_selectedCompanyName != null)
                ListTile(
                  leading: const Icon(Iconsax.house_2_bold, color: AppTheme.primaryColor),
                  title: Text(_selectedCompanyName!),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() {
                      _selectedCompanyId = null;
                      _selectedCompanyName = null;
                    }),
                  ),
                )
              else
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search Company...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _isSearchingCompany
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2)),
                          )
                        : null,
                  ),
                  onChanged: (v) async {
                    if (v.length >= 3) {
                      setState(() => _isSearchingCompany = true);
                      final results = await controller.searchCompanies(v);
                      setState(() {
                        _companyResults = results;
                        _isSearchingCompany = false;
                      });
                    } else {
                      setState(() => _companyResults = []);
                    }
                  },
                ),
              if (_companyResults.isNotEmpty)
                Container(
                  constraints: const BoxConstraints(maxHeight: 150),
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _companyResults.length,
                    itemBuilder: (context, index) {
                      final company = _companyResults[index];
                      return ListTile(
                        title: Text(company['name']),
                        onTap: () => setState(() {
                          _selectedCompanyId = company['id'];
                          _selectedCompanyName = company['name'];
                          _companyResults = [];
                        }),
                      );
                    },
                  ),
                ),
              if (controller.savedSystems.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: TextButton.icon(
                    onPressed: () => setState(() {
                      _isCreatingNew = false;
                      _selectedSystem = controller.savedSystems.first;
                    }),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text("Back to List"),
                  ),
                ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _onSave,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _onSave() {
    if (_isCreatingNew) {
      final name = _nameController.text.trim();
      if (name.isEmpty) {
        Get.snackbar('Required', 'Please enter a system name', snackPosition: SnackPosition.BOTTOM);
        return;
      }
      Navigator.of(context).pop({'isNew': true, 'name': name, 'system': null, 'companyId': _selectedCompanyId});
    } else {
      if (_selectedSystem == null) {
        Get.snackbar('Required', 'Please select a system', snackPosition: SnackPosition.BOTTOM);
        return;
      }
      Navigator.of(context).pop({'isNew': false, 'system': _selectedSystem, 'name': null});
    }
  }
}
