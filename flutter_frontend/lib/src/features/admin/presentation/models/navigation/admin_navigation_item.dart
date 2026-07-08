import 'package:flutter/material.dart';

class AdminNavigationItem {
  const AdminNavigationItem({
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
