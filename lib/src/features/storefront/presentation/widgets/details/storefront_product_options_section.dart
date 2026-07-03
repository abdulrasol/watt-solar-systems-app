import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/storefront/domain/entities/storefront_models.dart';

class StorefrontProductOptionsSection extends StatelessWidget {
  final List<StorefrontProductOption> options;
  final Set<int> selectedOptionIds;
  final bool showB2bPricing;
  final StorefrontAudience previewAudience;
  final ValueChanged<int> onToggleOption;

  const StorefrontProductOptionsSection({
    super.key,
    required this.options,
    required this.selectedOptionIds,
    required this.showB2bPricing,
    required this.previewAudience,
    required this.onToggleOption,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final money = NumberFormat.decimalPattern();

    return _CardSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.selected_options_title,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 10.h),
          ...options.map((option) {
            final selected = selectedOptionIds.contains(option.id);
            final required = option.isRequired;
            final optionPrice =
                showB2bPricing && previewAudience == StorefrontAudience.b2b
                ? option.wholesalePrice
                : option.retailPrice;

            return CheckboxListTile(
              value: selected,
              dense: true,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: required ? null : (_) => onToggleOption(option.id),
              title: Text(option.name),
              subtitle: Text(l10n.iqd_price(money.format(optionPrice))),
            );
          }),
        ],
      ),
    );
  }
}

class _CardSection extends StatelessWidget {
  final Widget child;

  const _CardSection({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: child,
    );
  }
}
