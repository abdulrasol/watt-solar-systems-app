import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/storefront/presentation/providers/storefront_provider.dart';
import 'package:solar_hub/src/features/storefront/presentation/widgets/filters/storefront_company_categories_picker.dart';
import 'package:solar_hub/src/features/storefront/presentation/widgets/filters/storefront_company_picker.dart';
import 'package:solar_hub/src/features/storefront/presentation/widgets/filters/storefront_filter_section.dart';
import 'package:solar_hub/src/features/storefront/presentation/widgets/filters/storefront_global_categories_picker.dart';
import 'package:solar_hub/src/features/storefront/presentation/widgets/filters/storefront_sort_picker.dart';

class StorefrontFiltersSheet extends ConsumerStatefulWidget {
  final StorefrontScope scope;
  final bool hideCompanyFilter;

  const StorefrontFiltersSheet({
    super.key,
    required this.scope,
    required this.hideCompanyFilter,
  });

  @override
  ConsumerState<StorefrontFiltersSheet> createState() =>
      _StorefrontFiltersSheetState();
}

class _StorefrontFiltersSheetState
    extends ConsumerState<StorefrontFiltersSheet> {
  late final TextEditingController _companySearchController;
  late final TextEditingController _minController;
  late final TextEditingController _maxController;
  late final ScrollController _companiesScrollController;
  bool _didSubmit = false;

  int? _selectedCompanyId;
  int? _selectedGlobalCategoryId;
  int? _selectedCompanyCategoryId;
  bool? _availability;
  late String _ordering;

  @override
  void initState() {
    super.initState();
    final state = ref.read(storefrontNotifierProvider(widget.scope));
    final effectiveCompanyId = widget.scope.companyId ?? state.query.companyId;

    _selectedCompanyId = effectiveCompanyId;
    _selectedGlobalCategoryId = state.query.globalCategoryId;
    _selectedCompanyCategoryId = state.query.companyCategoryId;
    _availability = state.query.isAvailable;
    _ordering = state.query.ordering;
    _companySearchController = TextEditingController(
      text: state.filterSheet.companySearch,
    );
    _minController = TextEditingController(
      text: state.query.minPrice?.toString() ?? '',
    );
    _maxController = TextEditingController(
      text: state.query.maxPrice?.toString() ?? '',
    );
    _companiesScrollController = ScrollController()
      ..addListener(_onCompaniesScroll);

    Future.microtask(() async {
      if (!mounted) return;
      final notifier = ref.read(
        storefrontNotifierProvider(widget.scope).notifier,
      );
      if (!widget.hideCompanyFilter) {
        await notifier.ensureCompaniesLoaded();
      }
      if (!mounted) return;
      if (_selectedCompanyId != null) {
        await notifier.ensureCompanyCategoriesLoaded(_selectedCompanyId!);
      }
    });
  }

  @override
  void dispose() {
    if (!_didSubmit) {
      final scope = widget.scope;
      Future.microtask(() {
        final notifier = ref.read(storefrontNotifierProvider(scope).notifier);
        final appliedState = ref.read(storefrontNotifierProvider(scope));
        final appliedCompanyId =
            scope.companyId ?? appliedState.query.companyId;

        if (appliedCompanyId != null) {
          notifier.ensureCompanyCategoriesLoaded(
            appliedCompanyId,
            forceRefresh: true,
          );
        } else {
          notifier.clearDraftCompanyCategories();
        }
      });
    }

    _companiesScrollController.removeListener(_onCompaniesScroll);
    _companiesScrollController.dispose();
    _companySearchController.dispose();
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  void _onCompaniesScroll() {
    if (_companiesScrollController.position.pixels >=
        _companiesScrollController.position.maxScrollExtent - 120) {
      ref
          .read(storefrontNotifierProvider(widget.scope).notifier)
          .loadMoreCompanies();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(storefrontNotifierProvider(widget.scope));
    final notifier = ref.read(
      storefrontNotifierProvider(widget.scope).notifier,
    );

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20.w,
          20.h,
          20.w,
          20.h + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.store_filters,
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900),
              ),
              SizedBox(height: 8.h),
              Text(
                l10n.store_filters_subtitle,
                style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
              ),
              SizedBox(height: 16.h),
              StorefrontFilterSection(
                title: l10n.sort_by,
                child: StorefrontSortPicker(
                  ordering: _ordering,
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _ordering = value);
                  },
                ),
              ),
              SizedBox(height: 12.h),
              StorefrontFilterSection(
                title: l10n.categories,
                child: StorefrontGlobalCategoriesPicker(
                  categories: state.meta.globalCategories,
                  selectedCategoryId: _selectedGlobalCategoryId,
                  onChanged: (value) {
                    setState(() => _selectedGlobalCategoryId = value);
                  },
                ),
              ),
              if (!widget.hideCompanyFilter) ...[
                SizedBox(height: 12.h),
                StorefrontFilterSection(
                  title: l10n.company_name,
                  child: Column(
                    children: [
                      TextField(
                        controller: _companySearchController,
                        onChanged: (value) {
                          setState(() {});
                          notifier.updateCompanySearch(value);
                        },
                        decoration: InputDecoration(
                          labelText: l10n.company_name,
                          hintText: l10n.search_company_hint,
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: _companySearchController.text.isEmpty
                              ? null
                              : IconButton(
                                  onPressed: () {
                                    _companySearchController.clear();
                                    notifier.updateCompanySearch('');
                                    setState(() {});
                                  },
                                  icon: const Icon(Icons.close_rounded),
                                ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      StorefrontCompanyPicker(
                        filterSheet: state.filterSheet,
                        scrollController: _companiesScrollController,
                        selectedCompanyId: _selectedCompanyId,
                        onCompanyTap: (company) async {
                          final isSameCompany =
                              _selectedCompanyId == company.id;
                          setState(() {
                            _selectedCompanyId = isSameCompany
                                ? null
                                : company.id;
                            _selectedCompanyCategoryId = null;
                          });

                          if (isSameCompany) {
                            notifier.clearDraftCompanyCategories();
                            return;
                          }

                          await notifier.ensureCompanyCategoriesLoaded(
                            company.id,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
              if (_selectedCompanyId != null || widget.hideCompanyFilter) ...[
                SizedBox(height: 12.h),
                StorefrontFilterSection(
                  title: l10n.company_category,
                  child: StorefrontCompanyCategoriesPicker(
                    categories: state.companyCategories,
                    isLoading: state.isLoadingCompanyCategories,
                    error: state.companyCategoriesError,
                    selectedCompanyCategoryId: _selectedCompanyCategoryId,
                    onChanged: (value) {
                      setState(() => _selectedCompanyCategoryId = value);
                    },
                  ),
                ),
              ],
              SizedBox(height: 12.h),
              StorefrontFilterSection(
                title: l10n.availability,
                child: DropdownButtonFormField<bool?>(
                  initialValue: _availability,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: l10n.availability,
                    prefixIcon: const Icon(Icons.inventory_2_outlined),
                  ),
                  items: [
                    DropdownMenuItem<bool?>(value: null, child: Text(l10n.all)),
                    DropdownMenuItem<bool?>(
                      value: true,
                      child: Text(l10n.available),
                    ),
                    DropdownMenuItem<bool?>(
                      value: false,
                      child: Text(l10n.unavailable),
                    ),
                  ],
                  onChanged: (value) => setState(() => _availability = value),
                ),
              ),
              SizedBox(height: 12.h),
              StorefrontFilterSection(
                title: l10n.price_range,
                child: Column(
                  children: [
                    TextField(
                      controller: _minController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: l10n.min_price,
                        prefixIcon: const Icon(Icons.attach_money_rounded),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    TextField(
                      controller: _maxController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: l10n.max_price,
                        prefixIcon: const Icon(Icons.attach_money_rounded),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 18.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        _didSubmit = true;
                        Navigator.of(context).pop();
                        await notifier.clearFilters();
                      },
                      child: Text(l10n.clear_filters),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        _didSubmit = true;
                        Navigator.of(context).pop();
                        await notifier.applyFilters(
                          companyId: _selectedCompanyId,
                          clearCompanyId: _selectedCompanyId == null,
                          globalCategoryId: _selectedGlobalCategoryId,
                          clearGlobalCategoryId:
                              _selectedGlobalCategoryId == null,
                          companyCategoryId: _selectedCompanyCategoryId,
                          clearCompanyCategoryId:
                              _selectedCompanyCategoryId == null,
                          isAvailable: _availability,
                          clearAvailability: _availability == null,
                          minPrice: double.tryParse(_minController.text.trim()),
                          clearMinPrice: _minController.text.trim().isEmpty,
                          maxPrice: double.tryParse(_maxController.text.trim()),
                          clearMaxPrice: _maxController.text.trim().isEmpty,
                          ordering: _ordering,
                        );
                      },
                      child: Text(l10n.apply_filters),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
