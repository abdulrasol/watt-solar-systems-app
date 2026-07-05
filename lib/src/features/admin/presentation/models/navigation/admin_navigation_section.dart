import 'package:flutter/material.dart';
import 'package:solar_hub/src/features/admin/presentation/models/navigation/admin_navigation_item.dart';

class AdminNavigationSection {
  const AdminNavigationSection({
    required this.id,
    required this.label,
    required this.icon,
    required this.items,
  });

  final String id;
  final String label;
  final IconData icon;
  final List<AdminNavigationItem> items;

  bool isActiveFor(String location) {
    for (final item in items) {
      if (location == item.route || location.startsWith('${item.route}/')) {
        return true;
      }
    }
    return false;
  }
}
