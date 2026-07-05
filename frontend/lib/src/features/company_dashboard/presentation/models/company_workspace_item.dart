import 'package:flutter/material.dart';

class CompanyWorkspaceItem {
  const CompanyWorkspaceItem({
    required this.id,
    required this.label,
    required this.subtitle,
    required this.route,
    required this.icon,
    this.iconUrl,
    this.serviceCode,
    this.externalRoute,
  });

  final String id;
  final String label;
  final String subtitle;
  final String route;
  final IconData icon;
  final String? iconUrl;
  final String? serviceCode;
  final String? externalRoute;

  bool get isExternal => externalRoute != null && externalRoute!.isNotEmpty;
}
