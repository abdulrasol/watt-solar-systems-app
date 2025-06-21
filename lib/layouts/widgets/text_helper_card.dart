import 'package:flutter/material.dart';
import 'package:solar_hub/utils/app_constants.dart';

/// Custom input field widget with help text
Container textHelperCard(BuildContext context, {String? text, String? title}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      ),
    ),
    child: Column(
      children: [
        if (title != null)
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
            textAlign: TextAlign.center,
          ),
        verSpace(space: 5),
        if (text != null)
          Text(
            text,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
            textAlign: TextAlign.justify,
          ),
      ],
    ),
  );
}
