import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/storefront/domain/entities/storefront_models.dart';
import 'package:solar_hub/src/features/storefront/presentation/providers/storefront_provider.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

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
  int? _selectedCompanyCategoryId;
  bool? _availability;

  @override
  void initState() {
    super.initState();
    final state = ref.read(storefrontNotifierProvider(widget.scope));
    final effectiveCompanyId = widget.scope.companyId ?? state.query.companyId;

    _selectedCompanyId = effectiveCompanyId;
    _selectedCompanyCategoryId = state.query.companyCategoryId;
    _availability = state.query.isAvailable;
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
      final notifier = ref.read(
        storefrontNotifierProvider(widget.scope).notifier,
      );
      if (!widget.hideCompanyFilter) {
        await notifier.ensureCompaniesLoaded();
      }
      if (_selectedCompanyId != null) {
        await notifier.ensureCompanyCategoriesLoaded(_selectedCompanyId!);
      }
    });
  }

  @override
  void dispose() {
    if (!_didSubmit) {
      final notifier = ref.read(
        storefrontNotifierProvider(widget.scope).notifier,
      );
      final appliedState = ref.read(storefrontNotifierProvider(widget.scope));
      final appliedCompanyId =
          widget.scope.companyId ?? appliedState.query.companyId;
      if (appliedCompanyId != null) {
        notifier.ensureCompanyCategoriesLoaded(
          appliedCompanyId,
          forceRefresh: true,
        );
      } else {
        notifier.clearDraftCompanyCategories();
      }
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
              SizedBox(height: 16.h),
              if (!widget.hideCompanyFilter) ...[
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
                _CompaniesPicker(
                  state: state,
                  scrollController: _companiesScrollController,
                  selectedCompanyId: _selectedCompanyId,
                  onCompanyTap: (company) async {
                    final isSameCompany = _selectedCompanyId == company.id;
                    setState(() {
                      _selectedCompanyId = isSameCompany ? null : company.id;
                      _selectedCompanyCategoryId = null;
                    });

                    if (isSameCompany) {
                      notifier.clearDraftCompanyCategories();
                      return;
                    }

                    await notifier.ensureCompanyCategoriesLoaded(company.id);
                  },
                ),
                SizedBox(height: 16.h),
              ],
              if (_selectedCompanyId != null || widget.hideCompanyFilter) ...[
                Text(
                  l10n.company_category,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 10.h),
                _CompanyCategoriesPicker(
                  state: state,
                  selectedCompanyCategoryId: _selectedCompanyCategoryId,
                  onChanged: (value) {
                    setState(() => _selectedCompanyCategoryId = value);
                  },
                ),
                SizedBox(height: 16.h),
              ],
              DropdownButtonFormField<bool?>(
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
              SizedBox(height: 12.h),
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
                          companyCategoryId: _selectedCompanyCategoryId,
                          clearCompanyCategoryId:
                              _selectedCompanyCategoryId == null,
                          isAvailable: _availability,
                          clearAvailability: _availability == null,
                          minPrice: double.tryParse(_minController.text.trim()),
                          clearMinPrice: _minController.text.trim().isEmpty,
                          maxPrice: double.tryParse(_maxController.text.trim()),
                          clearMaxPrice: _maxController.text.trim().isEmpty,
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

class _CompaniesPicker extends StatelessWidget {
  final StorefrontState state;
  final ScrollController scrollController;
  final int? selectedCompanyId;
  final ValueChanged<StorefrontCompanyListItem> onCompanyTap;

  const _CompaniesPicker({
    required this.state,
    required this.scrollController,
    required this.selectedCompanyId,
    required this.onCompanyTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final filterSheet = state.filterSheet;

    if (filterSheet.isLoadingCompanies && filterSheet.companies.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (filterSheet.companiesError != null && filterSheet.companies.isEmpty) {
      return _InlineMessage(message: filterSheet.companiesError!);
    }

    if (filterSheet.companies.isEmpty) {
      return _InlineMessage(message: l10n.no_company_found);
    }

    return Container(
      constraints: BoxConstraints(maxHeight: 260.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: ListView.separated(
        controller: scrollController,
        shrinkWrap: true,
        itemCount:
            filterSheet.companies.length +
            (filterSheet.isLoadingMoreCompanies ? 1 : 0),
        separatorBuilder: (_, _) => Divider(height: 1.h),
        itemBuilder: (context, index) {
          if (index >= filterSheet.companies.length) {
            return Padding(
              padding: EdgeInsets.all(12.r),
              child: const Center(child: CircularProgressIndicator()),
            );
          }

          final company = filterSheet.companies[index];
          final selected = selectedCompanyId == company.id;

          return ListTile(
            onTap: () => onCompanyTap(company),
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.12),
              child: Text(
                company.name.isEmpty ? '?' : company.name.substring(0, 1),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            title: Text(
              company.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: company.cityName == null
                ? null
                : Text(
                    company.cityName!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
            trailing: selected
                ? Icon(Icons.check_circle_rounded, color: AppTheme.primaryColor)
                : null,
          );
        },
      ),
    );
  }
}

class _CompanyCategoriesPicker extends StatelessWidget {
  final StorefrontState state;
  final int? selectedCompanyCategoryId;
  final ValueChanged<int?> onChanged;

  const _CompanyCategoriesPicker({
    required this.state,
    required this.selectedCompanyCategoryId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (state.isLoadingCompanyCategories) {
      return _InlineMessage(message: l10n.company_categories_loading);
    }

    if (state.companyCategoriesError != null) {
      return _InlineMessage(message: state.companyCategoriesError!);
    }

    if (state.companyCategories.isEmpty) {
      return _InlineMessage(message: l10n.company_categories_empty_title);
    }

    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: [
        ChoiceChip(
          label: Text(l10n.all_categories),
          selected: selectedCompanyCategoryId == null,
          onSelected: (_) => onChanged(null),
        ),
        ...state.companyCategories.map(
          (category) => ChoiceChip(
            label: Text(category.name),
            selected: selectedCompanyCategoryId == category.id,
            onSelected: (_) => onChanged(category.id),
          ),
        ),
      ],
    );
  }
}

class _InlineMessage extends StatelessWidget {
  final String message;

  const _InlineMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 13.sp),
      ),
    );
  }
}
