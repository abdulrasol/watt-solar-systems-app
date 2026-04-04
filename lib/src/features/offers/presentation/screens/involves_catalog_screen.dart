import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/src/core/widgets/pre_scaffold.dart';
import 'package:solar_hub/src/features/offers/domain/entities/involve.dart';
import 'package:solar_hub/src/features/offers/presentation/providers/involves_provider.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class InvolvesCatalogScreen extends ConsumerStatefulWidget {
  const InvolvesCatalogScreen({super.key});

  @override
  ConsumerState<InvolvesCatalogScreen> createState() =>
      _InvolvesCatalogScreenState();
}

class _InvolvesCatalogScreenState extends ConsumerState<InvolvesCatalogScreen> {
  bool _isArabic(BuildContext context) =>
      Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';

  String _tr(BuildContext context, String en, String ar) {
    return _isArabic(context) ? ar : en;
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(involvesProvider.notifier).getInvolves(force: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(involvesProvider);

    return PreScaffold(
      title: _tr(context, 'Offers Catalog', 'كتالوج التكاليف الإضافية'),
      clickBack: () => Navigator.of(context).maybePop(),
      actions: [
        IconButton(
          onPressed: () => _openInvolveEditor(),
          icon: const Icon(Iconsax.add_circle_bold),
        ),
      ],
      child: RefreshIndicator(
        onRefresh: () =>
            ref.read(involvesProvider.notifier).getInvolves(force: true),
        child: ListView(
          padding: EdgeInsets.all(20.r),
          children: [
            _buildIntroCard(context),
            SizedBox(height: 20.h),
            if (state.isLoading && state.items.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 60),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.items.isEmpty)
              _buildEmptyState(context)
            else
              ...state.items.map((item) => _buildItemCard(context, item)),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEAF7F1), Color(0xFFFFFFFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: const Color(0xFFC7E6D7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _tr(context, 'Manage Extra Fees', 'إدارة الرسوم والخدمات الإضافية'),
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 8.h),
          Text(
            _tr(
              context,
              'Use this list for installation fees, delivery, mounting, wiring, or other extra services you add to offers.',
              'استخدم هذه القائمة لرسوم التركيب أو التوصيل أو الهياكل أو التمديدات أو أي خدمات إضافية تدخل ضمن العرض.',
            ),
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(28.r),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          Icon(Iconsax.box_search_bold, size: 42.sp, color: Colors.grey),
          SizedBox(height: 12.h),
          Text(
            _tr(context, 'No involves yet', 'لا توجد عناصر إضافية بعد'),
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 6.h),
          Text(
            _tr(
              context,
              'Create your first extra cost item to reuse it in offer replies.',
              'أنشئ أول عنصر تكلفة إضافية لإعادة استخدامه في ردود العروض.',
            ),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
          ),
          SizedBox(height: 14.h),
          ElevatedButton.icon(
            onPressed: () => _openInvolveEditor(),
            icon: const Icon(Iconsax.add_circle_bold),
            label: Text(_tr(context, 'Create item', 'إنشاء عنصر')),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, Involve item) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: const Icon(
              Iconsax.receipt_item_bold,
              color: AppTheme.primaryColor,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '\$${item.cost}',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  item.isActive
                      ? _tr(context, 'Active in offers', 'نشط في العروض')
                      : _tr(context, 'Inactive', 'غير نشط'),
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _openInvolveEditor(item: item),
            icon: const Icon(Iconsax.edit_2_bold),
          ),
          IconButton(
            onPressed: () => _confirmDelete(item),
            icon: const Icon(Iconsax.trash_bold, color: Colors.redAccent),
          ),
        ],
      ),
    );
  }

  Future<void> _openInvolveEditor({Involve? item}) async {
    final nameController = TextEditingController(text: item?.name ?? '');
    final costController = TextEditingController(
      text: item?.cost.toStringAsFixed(0) ?? '',
    );
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16.w,
            right: 16.w,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16.h,
          ),
          child: Material(
            borderRadius: BorderRadius.circular(24.r),
            child: Padding(
              padding: EdgeInsets.all(20.r),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _tr(
                        context,
                        item == null ? 'Create involve' : 'Edit involve',
                        item == null
                            ? 'إنشاء عنصر إضافي'
                            : 'تعديل العنصر الإضافي',
                      ),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      _tr(
                        context,
                        'Examples: installation fee, delivery, mounting structure.',
                        'أمثلة: أجور التركيب، التوصيل، هيكل التثبيت.',
                      ),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: _tr(context, 'Name', 'الاسم'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                          ? _tr(context, 'Required', 'مطلوب')
                          : null,
                    ),
                    SizedBox(height: 12.h),
                    TextFormField(
                      controller: costController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: _tr(context, 'Cost', 'السعر'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      validator: (value) {
                        final parsed = int.tryParse(value?.trim() ?? '');
                        if (parsed == null || parsed < 0) {
                          return _tr(context, 'Required', 'مطلوب');
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 18.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;
                          final notifier = ref.read(involvesProvider.notifier);
                          final saved = item == null
                              ? await notifier.createInvolve(
                                  name: nameController.text.trim(),
                                  cost: int.parse(costController.text.trim()),
                                )
                              : await notifier.updateInvolve(
                                  id: item.id,
                                  name: nameController.text.trim(),
                                  cost: int.parse(costController.text.trim()),
                                );
                          if (!context.mounted) return;
                          if (saved != null) Navigator.of(context).pop();
                        },
                        child: Text(_tr(context, 'Save', 'حفظ')),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(Involve item) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(_tr(context, 'Delete item?', 'حذف العنصر؟')),
          content: Text(
            _tr(
              context,
              'This item will be removed from your involves catalog.',
              'سيتم حذف هذا العنصر من كتالوج التكاليف الإضافية.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(_tr(context, 'Cancel', 'إلغاء')),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(_tr(context, 'Delete', 'حذف')),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;
    await ref.read(involvesProvider.notifier).deleteInvolve(item.id);
  }
}
