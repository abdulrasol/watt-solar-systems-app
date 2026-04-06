import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/inventory/domain/entities/product.dart';
import 'package:solar_hub/src/features/inventory/presentation/providers/product_form_provider.dart';

class ProductOptionsForm extends ConsumerWidget {
  const ProductOptionsForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(productFormNotifierProvider);
    final notifier = ref.read(productFormNotifierProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.productOptions, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
            TextButton.icon(
              icon: const Icon(Icons.add_circle_outline),
              label: Text(l10n.addOption),
              onPressed: () => _showAddOptionDialog(context, notifier, l10n),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        if (state.options.isEmpty)
          Text(l10n.noOptions, style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
        ...state.options.asMap().entries.map((req) {
          final idx = req.key;
          final opt = req.value;
          return Card(
            margin: EdgeInsets.only(bottom: 8.h),
            color: Colors.grey.withValues(alpha: 0.05),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
              side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
            ),
            child: ListTile(
              title: Text(opt.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
              subtitle: Text('+${l10n.iqd_price(opt.retailPrice)}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => notifier.removeOption(idx),
              ),
            ),
          );
        }),
      ],
    );
  }

  void _showAddOptionDialog(BuildContext context, ProductFormNotifier notifier, AppLocalizations l10n) {
    String name = '';
    double ret = 0;
    bool isRequired = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.addOption),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: l10n.optionName),
                onChanged: (v) => name = v,
              ),
              TextField(
                decoration: InputDecoration(labelText: l10n.retail_price),
                keyboardType: TextInputType.number,
                onChanged: (v) => ret = double.tryParse(v) ?? 0,
              ),
              CheckboxListTile(
                title: Text(l10n.isRequired),
                value: isRequired,
                onChanged: (val) => setState(() => isRequired = val ?? false),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
            ElevatedButton(
              onPressed: () {
                if (name.isNotEmpty) {
                  notifier.addOption(ProductOption(name: name, retailPrice: ret, isRequired: isRequired));
                }
                Navigator.pop(ctx);
              },
              child: Text(l10n.add),
            ),
          ],
        ),
      ),
    );
  }
}
