import 'package:flutter/material.dart';
import 'package:solar_hub/l10n/app_localizations.dart';

class StorefrontSortPicker extends StatelessWidget {
  final String ordering;
  final ValueChanged<String?> onChanged;

  const StorefrontSortPicker({
    super.key,
    required this.ordering,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DropdownButtonFormField<String>(
      initialValue: ordering,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: l10n.sort_by,
        prefixIcon: const Icon(Icons.swap_vert_rounded),
      ),
      items: [
        DropdownMenuItem(value: '-created_at', child: Text(l10n.sort_newest)),
        DropdownMenuItem(value: 'created_at', child: Text(l10n.sort_oldest)),
        DropdownMenuItem(value: 'name', child: Text(l10n.sort_name_asc)),
        DropdownMenuItem(value: '-name', child: Text(l10n.sort_name_desc)),
        DropdownMenuItem(
          value: 'retail_price',
          child: Text(l10n.sort_retail_price_asc),
        ),
        DropdownMenuItem(
          value: '-retail_price',
          child: Text(l10n.sort_retail_price_desc),
        ),
        DropdownMenuItem(
          value: 'wholesale_price',
          child: Text(l10n.sort_wholesale_price_asc),
        ),
        DropdownMenuItem(
          value: '-wholesale_price',
          child: Text(l10n.sort_wholesale_price_desc),
        ),
      ],
      onChanged: onChanged,
    );
  }
}
