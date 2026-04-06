import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:solar_hub/l10n/app_localizations.dart';

class ProductPricingForm extends ConsumerWidget {
  final TextEditingController retailPriceCtrl;
  final TextEditingController costPriceCtrl;
  final TextEditingController wholesalePriceCtrl;

  const ProductPricingForm({
    super.key,
    required this.retailPriceCtrl,
    required this.costPriceCtrl,
    required this.wholesalePriceCtrl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        TextFormField(
          controller: retailPriceCtrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: l10n.retail_price, border: const OutlineInputBorder()),
          validator: (val) => val == null || val.isEmpty ? l10n.required_field : null,
        ),
        SizedBox(height: 16.h),
        TextFormField(
          controller: costPriceCtrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: l10n.costPrice, border: const OutlineInputBorder()),
        ),
        SizedBox(height: 16.h),
        TextFormField(
          controller: wholesalePriceCtrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: l10n.wholesale_price, border: const OutlineInputBorder()),
        ),
      ],
    );
  }
}
