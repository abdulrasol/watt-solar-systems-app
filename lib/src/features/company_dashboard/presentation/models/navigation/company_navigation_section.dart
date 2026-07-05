import 'package:flutter/material.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/models/navigation/company_navigation_item.dart';

/// A top-level navigation section for the company dashboard.
///
/// Each section maps to an expandable group in the desktop sidebar.
class CompanyNavigationSection {
  const CompanyNavigationSection({
    required this.id,
    required this.label,
    required this.icon,
    required this.defaultRoute,
    required this.items,
  });

  final String id;
  final String label;
  final IconData icon;
  final String defaultRoute;
  final List<CompanyNavigationItem> items;

  /// Returns true when [location] belongs to this section.
  bool isActiveFor(String location) {
    if (location == defaultRoute) return true;
    for (final item in items) {
      if (location.startsWith(item.route)) return true;
    }
    return false;
  }
}
