import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_hub/features/admin/controllers/app_config_controller.dart';
import 'package:solar_hub/features/admin/models/flag.dart';

class AdminConfigPage extends GetView<AppConfigController> {
  const AdminConfigPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(onPressed: () => _showEditDialog(context), child: const Icon(Icons.add)),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.flags.isEmpty) {
          return const Center(child: Text("No configurations found."));
        }

        final flags = controller.flags.toList();
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: flags.length,
          //  separatorBuilder: (c, i) => const Divider(),
          itemBuilder: (context, index) {
            return _flagRow(context, flags[index]);
          },
        );
      }),
    );
  }

  Widget _flagRow(BuildContext context, Flag flag) {
    return Card(
      key: ValueKey(flag.key),
      child: ListTile(
        title: Text(flag.key, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(flag.description.toString()),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: flag.value,
              onChanged: (val) => updateConfig(context, flag, enable: val, isDialog: false),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(context, flag.key),
            ),
          ],
        ),
        onTap: () => _showEditDialog(context, flag: flag),
      ),
    );
  }

  void _showEditDialog(BuildContext context, {Flag? flag}) {
    final keyController = TextEditingController(text: flag?.key ?? '');
    final descriptionController = TextEditingController(text: flag?.description ?? '');
    final valueNotifier = ValueNotifier<bool>(flag?.value ?? false);
    final isEditing = flag != null;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isEditing ? "Edit Config" : "Add Config"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isEditing)
              TextField(
                controller: keyController,
                decoration: const InputDecoration(labelText: "Feature Key", hintText: "e.g. show_promo_banner"),
              ),
            if (isEditing) Text("Key: ${flag.key}", style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: "Description", hintText: "e.g. show_promo_banner"),
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<bool>(
              valueListenable: valueNotifier,
              builder: (context, val, child) {
                return SwitchListTile(title: const Text("Enabled"), value: val, onChanged: (newValue) => valueNotifier.value = newValue);
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () => updateConfig(
              dialogContext,
              isEditing ? flag : null,
              enable: valueNotifier.value,
              key: keyController.text.trim(),
              description: descriptionController.text.trim(),
            ),
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void updateConfig(BuildContext? context, Flag? flag, {bool? enable, String? key, String? description, bool isDialog = true}) {
    late Flag newFlag;
    if (flag == null) {
      newFlag = Flag(key: key!, value: enable!, description: description);
    } else {
      newFlag = flag.copyWith(key: key, value: enable, description: description);
    }
    controller.updateConfig(newFlag);
    if (isDialog) {
      if (context != null) {
        Navigator.pop(context);
      } else {
        Get.back(); // Fallback
      }
    }
  }

  void _confirmDelete(BuildContext context, String key) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Delete Config"),
        content: Text("Are you sure you want to delete '$key'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              controller.deleteConfig(key);
              Navigator.pop(dialogContext);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}
