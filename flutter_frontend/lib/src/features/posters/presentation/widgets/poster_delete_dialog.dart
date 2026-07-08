import 'package:flutter/material.dart';
import 'package:solar_hub/l10n/app_localizations.dart';

Future<bool> showPosterDeleteDialog(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.localeName == 'ar' ? 'حذف الملصق' : 'Delete Poster'),
      content: Text(l10n.localeName == 'ar' ? 'هل أنت متأكد من حذف هذا الملصق؟' : 'Are you sure you want to delete this poster?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
  return result ?? false;
}
