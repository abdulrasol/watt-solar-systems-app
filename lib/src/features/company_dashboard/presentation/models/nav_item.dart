import 'package:flutter/widgets.dart';

class NavItem {
  final String label;
  final IconData icon;
  final String? iconUrl;
  final String? route;
  final String? serviceCode;

  const NavItem({
    required this.label,
    required this.icon,
    this.iconUrl,
    this.route,
    this.serviceCode,
  });
}
