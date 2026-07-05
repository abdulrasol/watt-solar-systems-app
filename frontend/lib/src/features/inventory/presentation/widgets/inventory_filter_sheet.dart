import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/inventory/presentation/providers/inventory_provider.dart';
import 'package:solar_hub/src/features/inventory/domain/entities/filter.dart';

class InventoryFilterSheet extends ConsumerStatefulWidget {
  const InventoryFilterSheet({super.key});

  @override
  ConsumerState<InventoryFilterSheet> createState() => _InventoryFilterSheetState();
}

class _InventoryFilterSheetState extends ConsumerState<InventoryFilterSheet> {
  late ProductsFilter _filter;

  @override
  void initState() {
    super.initState();
    _filter = ref.read(inventoryNotifierProvider).filter;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final options = ref.watch(inventoryNotifierProvider).filterOptions;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.filters, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
          SizedBox(height: 16.h),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(l10n.availability),
                  _buildAvailabilityFilters(l10n),
                  SizedBox(height: 16.h),
                  if (options != null) ...[
                    if (options.globalCategories.isNotEmpty) ...[
                      _buildSectionTitle(l10n.global_category),
                      _buildGlobalCategoryFilters(options.globalCategories),
                      SizedBox(height: 16.h),
                    ],
                    if (options.internalCategories.isNotEmpty) ...[
                      _buildSectionTitle(l10n.internal_category),
                      _buildInternalCategoryFilters(options.internalCategories),
                      SizedBox(height: 16.h),
                    ],
                    if (options.companyCategories.isNotEmpty) ...[
                      _buildSectionTitle(l10n.company_category),
                      _buildCompanyCategoryFilters(options.companyCategories),
                      SizedBox(height: 16.h),
                    ],
                  ],
                  _buildSectionTitle(l10n.sort_by),
                  _buildSortFilters(l10n),
                ],
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _filter = ProductsFilter();
                    });
                  },
                  child: Text(l10n.clear_filters),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(inventoryNotifierProvider.notifier).updateFilters(_filter);
                    Navigator.pop(context);
                  },
                  child: Text(l10n.apply_filters),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildAvailabilityFilters(AppLocalizations l10n) {
    return Wrap(
      spacing: 8.w,
      children: [
        ChoiceChip(
          label: Text(l10n.all),
          selected: _filter.isAvailable == null,
          onSelected: (val) => setState(() => _filter = _filter.copyWith(isAvailable: null)),
        ),
        ChoiceChip(
          label: Text(l10n.available),
          selected: _filter.isAvailable == true,
          onSelected: (val) => setState(() => _filter = _filter.copyWith(isAvailable: true)),
        ),
        ChoiceChip(
          label: Text(l10n.unavailable),
          selected: _filter.isAvailable == false,
          onSelected: (val) => setState(() => _filter = _filter.copyWith(isAvailable: false)),
        ),
      ],
    );
  }

  Widget _buildGlobalCategoryFilters(List<dynamic> categories) {
    return Wrap(
      spacing: 8.w,
      children: [
        ChoiceChip(
          label: const Text('All'),
          selected: _filter.globalCategoryId == null,
          onSelected: (val) => setState(() => _filter = _filter.copyWith(globalCategoryId: null, clearGlobalCategoryId: true)),
        ),
        ...categories.map((cat) => ChoiceChip(
              label: Text(cat.name),
              selected: _filter.globalCategoryId == cat.id,
              onSelected: (val) => setState(() => _filter = _filter.copyWith(globalCategoryId: val ? cat.id : null, clearGlobalCategoryId: !val)),
            )),
      ],
    );
  }

  Widget _buildInternalCategoryFilters(List<dynamic> categories) {
    return Wrap(
      spacing: 8.w,
      children: [
        ChoiceChip(
          label: const Text('All'),
          selected: _filter.internalCategoryId == null,
          onSelected: (val) => setState(() => _filter = _filter.copyWith(internalCategoryId: null, clearInternalCategoryId: true)),
        ),
        ...categories.map((cat) => ChoiceChip(
              label: Text(cat.name),
              selected: _filter.internalCategoryId == cat.id,
              onSelected: (val) => setState(() => _filter = _filter.copyWith(internalCategoryId: val ? cat.id : null, clearInternalCategoryId: !val)),
            )),
      ],
    );
  }

  Widget _buildCompanyCategoryFilters(List<dynamic> categories) {
    return Wrap(
      spacing: 8.w,
      children: [
        ChoiceChip(
          label: const Text('All'),
          selected: _filter.companyCategoryId == null,
          onSelected: (val) => setState(() => _filter = _filter.copyWith(companyCategoryId: null, clearCompanyCategoryId: true)),
        ),
        ...categories.map((cat) => ChoiceChip(
              label: Text(cat.name),
              selected: _filter.companyCategoryId == cat.id,
              onSelected: (val) => setState(() => _filter = _filter.copyWith(companyCategoryId: val ? cat.id : null, clearCompanyCategoryId: !val)),
            )),
      ],
    );
  }

  Widget _buildSortFilters(AppLocalizations l10n) {
    final sortOptions = {
      '-created_at': l10n.sort_newest,
      'created_at': l10n.sort_oldest,
      'name': l10n.sort_name_asc,
      '-name': l10n.sort_name_desc,
      'retail_price': l10n.sort_price_asc,
      '-retail_price': l10n.sort_price_desc,
    };

    return Wrap(
      spacing: 8.w,
      children: sortOptions.entries
          .map((e) => ChoiceChip(
                label: Text(e.value),
                selected: _filter.ordering == e.key,
                onSelected: (val) => setState(() => _filter = _filter.copyWith(ordering: e.key)),
              ))
          .toList(),
    );
  }
}
