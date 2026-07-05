import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/admin/presentation/models/navigation/admin_navigation_registry.dart';
import 'package:solar_hub/src/features/admin/presentation/models/navigation/admin_navigation_section.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/admin_content_layout.dart';

class AdminPageScaffold extends StatelessWidget {
  const AdminPageScaffold({super.key, required this.child, this.actions = const []});

  final List<Widget> actions;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final l10n = AppLocalizations.of(context)!;
    final sections = AdminNavigationRegistry.build(l10n);
    final title = _findTitle(sections, location);

    return Material(
      color: Colors.transparent,
      child: AdminContentLayout(title: title, actions: actions, child: child),
    );
  }

  String _findTitle(List<AdminNavigationSection> sections, String location) {
    for (final section in sections) {
      for (final item in section.items) {
        if (location == item.route || location.startsWith('${item.route}/')) {
          return item.label;
        }
      }
    }
    for (final section in sections) {
      if (section.isActiveFor(location)) return section.label;
    }
    return '';
  }
}
