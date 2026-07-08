import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:solar_hub/l10n/app_localizations.dart';

class ProductInventoryForm extends ConsumerWidget {
  final TextEditingController stockCtrl;
  final TextEditingController minStockCtrl;

  const ProductInventoryForm({
    super.key,
    required this.stockCtrl,
    required this.minStockCtrl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        TextFormField(
          controller: stockCtrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: l10n.stockQuantity, border: const OutlineInputBorder()),
        ),
        SizedBox(height: 16.h),
        TextFormField(
          controller: minStockCtrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: l10n.minStockAlert, border: const OutlineInputBorder()),
        ),
      ],
    );
  }
}
