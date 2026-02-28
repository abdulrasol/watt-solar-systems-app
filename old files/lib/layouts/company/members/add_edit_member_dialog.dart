import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_hub/controllers/members_controller.dart';
import 'package:solar_hub/utils/app_theme.dart';

class AddEditMemberDialog extends StatefulWidget {
  final Map<String, dynamic>? member; // If null, it's Add mode

  const AddEditMemberDialog({super.key, this.member});

  @override
  State<AddEditMemberDialog> createState() => _AddEditMemberDialogState();
}

class _AddEditMemberDialogState extends State<AddEditMemberDialog> {
  final _emailController = TextEditingController();

  // Available roles mapped to their display keys
  final Map<String, String> _availableRoles = {
    'owner': 'role_owner',
    'manager': 'role_manager',
    'accountant': 'role_accountant',
    'sales': 'role_sales',
    'inventory_manager': 'role_inventory_manager',
    'installer': 'role_installer',
    'staff': 'role_staff',
    'driver': 'role_driver',
    'technician': 'role_technician',
  };

  List<String> _selectedRoles = ['staff']; // Default role

  @override
  void initState() {
    super.initState();
    if (widget.member != null) {
      // Edit Mode
      final profile = widget.member!['profiles'];
      _emailController.text = profile != null ? (profile['email'] ?? profile['phone_number'] ?? '') : '';

      // Load existing roles from 'roles' array, or fallback to single 'role' if upgrading
      if (widget.member!['roles'] != null) {
        _selectedRoles = List<String>.from(widget.member!['roles']);
      } else if (widget.member!['role'] != null) {
        _selectedRoles = [widget.member!['role'].toString()];
      }
    }
  }

  void _toggleRole(String roleKey) {
    setState(() {
      if (_selectedRoles.contains(roleKey)) {
        if (_selectedRoles.length > 1) {
          _selectedRoles.remove(roleKey);
        } else {
          // Prevent removing last role, or allow? Let's keep at least one.
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Member must have at least one role")));
        }
      } else {
        _selectedRoles.add(roleKey);
      }
    });
  }

  Future<void> _submit() async {
    final controller = Get.find<MembersController>();

    Map<String, dynamic> result;
    if (widget.member == null) {
      if (_emailController.text.isEmpty) return;
      result = await controller.addMember(_emailController.text, _selectedRoles);
    } else {
      final success = await controller.updateMemberRoles(widget.member!['id'], _selectedRoles);
      result = {'success': success, 'message': success ? 'member_updated_success' : 'Failed to update member'};
    }

    if (!mounted) return;

    if (result['success'] == true) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'].toString().tr), backgroundColor: Colors.green));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'].toString().tr), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.member != null;

    return AlertDialog(
      title: Text(isEdit ? 'edit_member'.tr : 'add_member'.tr),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Email/Phone Input (Read-only in Edit mode usually)
            if (!isEdit)
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'Enter phone number',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.phone),
                ),
              )
            else
              Text("User: ${widget.member!['profiles']?['full_name'] ?? 'Unknown'}", style: const TextStyle(fontWeight: FontWeight.bold)),

            const SizedBox(height: 20),
            Text('select_roles'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: _availableRoles.entries.map((entry) {
                final roleKey = entry.key;
                final roleLabel = entry.value.tr;
                final isSelected = _selectedRoles.contains(roleKey);

                return FilterChip(
                  label: Text(roleLabel),
                  selected: isSelected,
                  selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                  checkmarkColor: AppTheme.primaryColor,
                  labelStyle: TextStyle(
                    color: isSelected ? AppTheme.primaryColor : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (_) => _toggleRole(roleKey),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('close'.tr, style: const TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white),
          child: Text(isEdit ? 'save_product'.tr : 'add_btn'.tr), // Reuse generic save/add keys
        ),
      ],
    );
  }
}
