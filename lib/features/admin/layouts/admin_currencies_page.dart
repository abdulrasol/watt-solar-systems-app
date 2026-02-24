import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/controllers/currency_controller.dart';
import 'package:solar_hub/models/currency_model.dart';
import 'package:solar_hub/utils/app_theme.dart';

class AdminCurrenciesPage extends StatefulWidget {
  const AdminCurrenciesPage({super.key});

  @override
  State<AdminCurrenciesPage> createState() => _AdminCurrenciesPageState();
}

class _AdminCurrenciesPageState extends State<AdminCurrenciesPage> {
  final CurrencyController _controller = Get.find<CurrencyController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(context),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Currency Management",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
            const SizedBox(height: 8),
            const Text("Manage available currencies for companies.", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),

            Expanded(
              child: Obx(() {
                if (_controller.isLoading.value && _controller.currencies.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (_controller.currencies.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.monetization_on_outlined, size: 48, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        const Text("No currencies added yet", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: _controller.currencies.length,
                  separatorBuilder: (c, i) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final currency = _controller.currencies[index];
                    return _buildCurrencyCard(context, currency);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyCard(BuildContext context, CurrencyModel currency) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
        border: currency.isDefault ? Border.all(color: AppTheme.primaryColor, width: 2) : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Center(
            child: Text(
              currency.symbol,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                currency.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (currency.isDefault) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: AppTheme.primaryColor, borderRadius: BorderRadius.circular(4)),
                child: const Text(
                  "DEFAULT",
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text("${currency.code} • Created: ${currency.createdAt?.toString().split(' ')[0] ?? 'N/A'}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Iconsax.edit_bold, size: 20, color: Colors.grey),
              onPressed: () => _showAddEditDialog(context, currency: currency),
            ),
            IconButton(
              icon: const Icon(Iconsax.trash_bold, size: 20, color: Colors.red),
              onPressed: () => _confirmDelete(context, currency),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddEditDialog(BuildContext context, {CurrencyModel? currency}) {
    final nameController = TextEditingController(text: currency?.name);
    final codeController = TextEditingController(text: currency?.code);
    final symbolController = TextEditingController(text: currency?.symbol);
    bool isDefault = currency?.isDefault ?? false;

    Get.dialog(
      AlertDialog(
        title: Text(currency == null ? "Add Currency" : "Edit Currency"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name (e.g. US Dollar)", icon: Icon(Icons.abc)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: codeController,
              decoration: const InputDecoration(labelText: "Code (e.g. USD)", icon: Icon(Icons.code)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: symbolController,
              decoration: const InputDecoration(labelText: "Symbol (e.g. \$)", icon: Icon(Icons.attach_money)),
            ),
            const SizedBox(height: 16),
            StatefulBuilder(
              builder: (context, setState) {
                return CheckboxListTile(title: const Text("Set as Default"), value: isDefault, onChanged: (val) => setState(() => isDefault = val ?? false));
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
            onPressed: () async {
              if (nameController.text.isEmpty || codeController.text.isEmpty || symbolController.text.isEmpty) return;

              final newCurrency = CurrencyModel(
                id: currency?.id ?? '', // ID handled by DB for new
                name: nameController.text,
                code: codeController.text,
                symbol: symbolController.text,
                isDefault: isDefault,
              );

              if (currency == null) {
                await _controller.createCurrency(newCurrency);
              } else {
                await _controller.updateCurrency(newCurrency);
              }
              Get.back();
            },
            child: Text(currency == null ? "Add" : "Save", style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, CurrencyModel currency) {
    Get.dialog(
      AlertDialog(
        title: const Text("Delete Currency"),
        content: Text("Are you sure you want to delete ${currency.name}?"),
        actions: [
          TextButton(onPressed: () => {if (context.mounted) Navigator.pop(context)}, child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              await _controller.deleteCurrency(currency.id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
