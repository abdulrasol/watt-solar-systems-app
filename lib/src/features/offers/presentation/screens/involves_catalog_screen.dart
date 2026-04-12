import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;

    return PreScaffold(
      title: l10n.offers_catalog,
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
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;
    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF14231F), const Color(0xFF10171A)]
              : [const Color(0xFFEAF7F1), const Color(0xFFFFFFFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: isDark
              ? onSurface.withValues(alpha: 0.08)
              : const Color(0xFFC7E6D7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.manage_extra_fees,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w900,
              color: onSurface,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            l10n.manage_extra_fees_desc,
            style: TextStyle(
              fontSize: 12.sp,
              color: onSurface.withValues(alpha: 0.72),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Container(
      padding: EdgeInsets.all(28.r),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          Icon(
            Iconsax.box_search_bold,
            size: 42.sp,
            color: onSurface.withValues(alpha: 0.45),
          ),
          SizedBox(height: 12.h),
          Text(
            l10n.no_involves_yet,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 6.h),
          Text(
            l10n.no_involves_yet_desc,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              color: onSurface.withValues(alpha: 0.72),
            ),
          ),
          SizedBox(height: 14.h),
          ElevatedButton.icon(
            onPressed: () => _openInvolveEditor(),
            icon: const Icon(Iconsax.add_circle_bold),
            label: Text(l10n.create_item),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, Involve item) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: onSurface.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
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
                  item.isActive ? l10n.active_in_offers : l10n.inactive,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: onSurface.withValues(alpha: 0.65),
                  ),
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
    final l10n = AppLocalizations.of(context)!;
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
        final theme = Theme.of(context);
        final onSurface = theme.colorScheme.onSurface;
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
                      item == null ? l10n.create_involve : l10n.edit_involve,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w900,
                        color: onSurface,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      l10n.involve_examples,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: onSurface.withValues(alpha: 0.72),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: l10n.name,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                          ? l10n.required_field
                          : null,
                    ),
                    SizedBox(height: 12.h),
                    TextFormField(
                      controller: costController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: l10n.costPrice,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      validator: (value) {
                        final parsed = int.tryParse(value?.trim() ?? '');
                        if (parsed == null || parsed < 0) {
                          return l10n.required_field;
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
                        child: Text(l10n.save),
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
    final l10n = AppLocalizations.of(context)!;
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.delete_item),
          content: Text(l10n.delete_item_desc),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.delete_item),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;
    await ref.read(involvesProvider.notifier).deleteInvolve(item.id);
  }
}
