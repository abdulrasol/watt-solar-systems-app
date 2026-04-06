import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/inventory/domain/entities/product.dart';
import 'package:solar_hub/src/features/inventory/presentation/providers/product_form_provider.dart';

class ProductPricingTiersForm extends ConsumerWidget {
  const ProductPricingTiersForm({super.key});

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
            Text(l10n.pricing_tiers, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
            TextButton.icon(
              icon: const Icon(Icons.add_circle_outline),
              label: Text(l10n.add),
              onPressed: () => _showAddTierDialog(context, notifier, l10n),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        if (state.pricingTiers.isEmpty)
          Text(l10n.noTiers, style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
        ...state.pricingTiers.asMap().entries.map((req) {
          final idx = req.key;
          final tier = req.value;
          return Card(
            margin: EdgeInsets.only(bottom: 8.h),
            color: Colors.grey.withValues(alpha: 0.05),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
              side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
            ),
            child: ListTile(
              title: Text('${tier.quantity}+ units', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
              subtitle: Text(l10n.iqd_price(tier.unitPrice)),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => notifier.removePricingTier(idx),
              ),
            ),
          );
        }),
      ],
    );
  }

  void _showAddTierDialog(BuildContext context, ProductFormNotifier notifier, AppLocalizations l10n) {
    int qty = 10;
    double price = 0;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.add),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(labelText: l10n.minStockAlert), // Using similar key for "min quantity" if needed, but the labels should be specific.
              keyboardType: TextInputType.number,
              onChanged: (v) => qty = int.tryParse(v) ?? 10,
            ),
            TextField(
              decoration: InputDecoration(labelText: l10n.retail_price),
              keyboardType: TextInputType.number,
              onChanged: (v) => price = double.tryParse(v) ?? 0,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () {
              if (price > 0) {
                notifier.addPricingTier(ProductPricingTier(quantity: qty, unitPrice: price));
              }
              Navigator.pop(ctx);
            },
            child: Text(l10n.add),
          ),
        ],
      ),
    );
  }
}
