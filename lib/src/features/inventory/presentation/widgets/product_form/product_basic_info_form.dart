import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/inventory/presentation/providers/product_form_provider.dart';

class ProductBasicInfoForm extends ConsumerWidget {
  final TextEditingController nameCtrl;
  final TextEditingController descCtrl;
  final TextEditingController skuCtrl;

  const ProductBasicInfoForm({
    super.key,
    required this.nameCtrl,
    required this.descCtrl,
    required this.skuCtrl,
  });

  Future<void> _scanBarcode(BuildContext context) async {
    try {
      final result = await BarcodeScanner.scan();
      if (result.type == ResultType.Barcode && result.rawContent.isNotEmpty) {
        skuCtrl.text = result.rawContent;
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to scan barcode')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(productFormNotifierProvider);
    final notifier = ref.read(productFormNotifierProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: nameCtrl,
          decoration: InputDecoration(labelText: l10n.productName, border: const OutlineInputBorder()),
          validator: (val) => val == null || val.isEmpty ? l10n.required_field : null,
        ),
        SizedBox(height: 16.h),
        TextFormField(
          controller: descCtrl,
          decoration: InputDecoration(labelText: l10n.description, border: const OutlineInputBorder()),
          maxLines: 3,
        ),
        SizedBox(height: 16.h),
        TextFormField(
          controller: skuCtrl,
          decoration: InputDecoration(
            labelText: l10n.sku,
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: const Icon(Icons.qr_code_scanner),
              onPressed: () => _scanBarcode(context),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: state.status,
                decoration: InputDecoration(labelText: l10n.status, border: const OutlineInputBorder()),
                items: [
                  DropdownMenuItem(value: 'active', child: Text(l10n.active)),
                  DropdownMenuItem(value: 'inactive', child: Text(l10n.inactive)),
                ],
                onChanged: (val) => notifier.setStatus(val ?? 'active'),
              ),
            ),
            SizedBox(width: 16.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.availability, style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
                Switch(
                  value: state.isAvailable,
                  onChanged: (val) => notifier.setAvailability(val),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
