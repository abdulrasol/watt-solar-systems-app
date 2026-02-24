import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_hub/features/store/controllers/delivery_options_controller.dart';
import 'package:solar_hub/features/store/models/delivery_option_model.dart';
import 'package:solar_hub/utils/app_theme.dart';
import 'package:solar_hub/controllers/company_controller.dart';

class DeliveryOptionsPage extends StatefulWidget {
  final String companyId;

  const DeliveryOptionsPage({super.key, required this.companyId});

  @override
  State<DeliveryOptionsPage> createState() => _DeliveryOptionsPageState();
}

class _DeliveryOptionsPageState extends State<DeliveryOptionsPage> {
  final DeliveryOptionsController controller = Get.put(DeliveryOptionsController());
  final CompanyController companyController = Get.find<CompanyController>(); // Assumes CompanyController is alive

  bool get canEdit => companyController.hasAnyRole(['owner', 'manager', 'inventory_manager']);

  @override
  void initState() {
    super.initState();
    controller.fetchOptions(widget.companyId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Delivery Options')),
      body: Obx(() {
        if (controller.isLoading.value && controller.options.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.options.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.local_shipping_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text('No delivery options yet', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey)),
                const SizedBox(height: 8),
                const Text('Add options for your customers to choose from.'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.options.length,
          itemBuilder: (context, index) {
            final option = controller.options[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.local_shipping, color: AppTheme.primaryColor),
                ),
                title: Text(option.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text('${companyController.effectiveCurrency.symbol}${option.cost.toStringAsFixed(2)}'),
                    if (option.estimatedDaysMin != null && option.estimatedDaysMax != null)
                      Text('${option.estimatedDaysMin} - ${option.estimatedDaysMax} Days', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
                trailing: canEdit
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showOptionDialog(context, option: option),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmDelete(context, option),
                          ),
                        ],
                      )
                    : null,
              ),
            );
          },
        );
      }),
      floatingActionButton: canEdit
          ? FloatingActionButton.extended(
              onPressed: () => _showOptionDialog(context),
              label: const Text('Add Option'),
              icon: const Icon(Icons.add),
              backgroundColor: AppTheme.primaryColor,
            )
          : null,
    );
  }

  void _showOptionDialog(BuildContext context, {DeliveryOptionModel? option}) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: option?.name ?? '');
    final costController = TextEditingController(text: option?.cost.toString() ?? '0');
    final minDaysController = TextEditingController(text: option?.estimatedDaysMin?.toString() ?? '');
    final maxDaysController = TextEditingController(text: option?.estimatedDaysMax?.toString() ?? '');
    final descController = TextEditingController(text: option?.description ?? '');

    Get.dialog(
      AlertDialog(
        title: Text(option == null ? 'Add Delivery Option' : 'Edit Delivery Option'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name (e.g., Standard Shipping)'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: costController,
                  decoration: InputDecoration(labelText: 'Cost (${companyController.effectiveCurrency.symbol})'),
                  keyboardType: TextInputType.number,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: minDaysController,
                        decoration: const InputDecoration(labelText: 'Min Days'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: maxDaysController,
                        decoration: const InputDecoration(labelText: 'Max Days'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description (Optional)'),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final newOption = DeliveryOptionModel(
                  id: option?.id, // Null for new
                  companyId: widget.companyId,
                  name: nameController.text.trim(),
                  cost: double.tryParse(costController.text) ?? 0,
                  estimatedDaysMin: int.tryParse(minDaysController.text),
                  estimatedDaysMax: int.tryParse(maxDaysController.text),
                  description: descController.text.trim(),
                  isActive: true, // Default active
                );

                bool success;
                if (option == null) {
                  success = await controller.createOption(newOption);
                } else {
                  success = await controller.updateOption(newOption);
                }

                if (success && context.mounted) {
                  Navigator.of(context).pop();
                }
              }
            },
            child: Text(option == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, DeliveryOptionModel option) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Option'),
        content: Text('Are you sure you want to delete "${option.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await controller.deleteOption(option.id!);
              if (context.mounted) Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
