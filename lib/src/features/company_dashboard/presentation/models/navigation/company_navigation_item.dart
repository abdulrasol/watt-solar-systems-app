import 'package:flutter/material.dart';

/// A single navigable item within a company dashboard section.
class CompanyNavigationItem {
  const CompanyNavigationItem({
    required this.id,
    required this.label,
    required this.route,
    required this.icon,
  });

  final String id;
  final String label;
  final String route;
  final IconData icon;
}
