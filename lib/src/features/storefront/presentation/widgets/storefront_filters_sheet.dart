import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/storefront/presentation/providers/storefront_provider.dart';

class StorefrontFiltersSheet extends StatefulWidget {
  final StorefrontState state;
  final bool hideCompanyFilter;
  final Future<void> Function({
    required int? companyId,
    required bool clearCompanyId,
    required bool? isAvailable,
    required bool clearAvailability,
    required double? minPrice,
    required bool clearMinPrice,
    required double? maxPrice,
    required bool clearMaxPrice,
  })
  onApply;
  final Future<void> Function() onClear;

  const StorefrontFiltersSheet({
    super.key,
    required this.state,
    required this.hideCompanyFilter,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<StorefrontFiltersSheet> createState() => _StorefrontFiltersSheetState();
}

class _StorefrontFiltersSheetState extends State<StorefrontFiltersSheet> {
  late final TextEditingController _minController;
  late final TextEditingController _maxController;
  int? _companyId;
  bool? _availability;

  @override
  void initState() {
    super.initState();
    _minController = TextEditingController(
      text: widget.state.query.minPrice?.toString() ?? '',
    );
    _maxController = TextEditingController(
      text: widget.state.query.maxPrice?.toString() ?? '',
    );
    _companyId = widget.state.query.companyId;
    _availability = widget.state.query.isAvailable;
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
                DropdownButtonFormField<int?>(
                  initialValue: _companyId,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: l10n.company_name,
                    prefixIcon: const Icon(Icons.business_rounded),
                  ),
                  items: [
                    DropdownMenuItem<int?>(
                      value: null,
                      child: Text(l10n.all_companies),
                    ),
                    ...widget.state.meta.companies.map(
                      (company) => DropdownMenuItem<int?>(
                        value: company.id,
                        child: Text(
                          company.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                  onChanged: (value) => setState(() => _companyId = value),
                ),
                SizedBox(height: 12.h),
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
                      onPressed: widget.onClear,
                      child: Text(l10n.clear_filters),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onApply(
                          companyId: _companyId,
                          clearCompanyId: _companyId == null,
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
