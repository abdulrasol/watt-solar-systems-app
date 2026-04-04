import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/src/features/offers/domain/entities/involve.dart';
import 'package:solar_hub/src/features/offers/presentation/screens/form/models/selected_involve.dart';
import 'package:solar_hub/src/utils/app_theme.dart';
import 'package:flutter/services.dart';

class InvolveItemCard extends StatelessWidget {
  final int index;
  final SelectedTemplateInvolve selected;
  final List<Involve> options;
  final List<Involve> catalogItems;
  final VoidCallback onRemove;
  final VoidCallback onChanged;
  final String Function(String en, String ar) tr;

  const InvolveItemCard({
    super.key,
    required this.index,
    required this.selected,
    required this.options,
    required this.catalogItems,
    required this.onRemove,
    required this.onChanged,
    required this.tr,
  });

  @override
  Widget build(BuildContext context) {
    Involve? selectedTemplate;
    for (final item in catalogItems) {
      if (item.id == selected.templateId) {
        selectedTemplate = item;
        break;
      }
    }
    final rowCost = selectedTemplate == null ? 0.0 : selectedTemplate.cost.toDouble() * selected.quantity;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                tr('Service details', 'تفاصيل الخدمة'),
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // Item Selection (Full Row)
          DropdownButtonFormField<int>(
            isExpanded: true,
            initialValue: selected.templateId,
            onChanged: (value) {
              selected.templateId = value;
              onChanged();
            },
            decoration: InputDecoration(
              labelText: tr('Item', 'العنصر'),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r)),
              filled: true,
              fillColor: Colors.grey.withValues(alpha: 0.02),
            ),
            items: options
                .map((item) => DropdownMenuItem<int>(
                      value: item.id,
                      child: Text(
                        '${item.name} (\$${item.cost})',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ))
                .toList(),
          ),
          SizedBox(height: 12.h),
          // Qty and Delete Action in Row
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: selected.quantityController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) => onChanged(),
                  decoration: InputDecoration(
                    labelText: tr('Quantity', 'الكمية'),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r)),
                    prefixIcon: const Icon(Iconsax.box_bold, size: 20),
                    filled: true,
                    fillColor: Colors.grey.withValues(alpha: 0.02),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Material(
                color: Colors.redAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16.r),
                child: InkWell(
                  onTap: onRemove,
                  borderRadius: BorderRadius.circular(16.r),
                  child: Container(
                    padding: EdgeInsets.all(12.r),
                    child: const Icon(Iconsax.trash_bold, color: Colors.redAccent),
                  ),
                ),
              ),
            ],
          ),
          if (selectedTemplate != null) ...[
            SizedBox(height: 12.h),
            const Divider(),
            SizedBox(height: 4.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  tr('Line total', 'إجمالي البند'),
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
                Text(
                  '\$${rowCost.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
