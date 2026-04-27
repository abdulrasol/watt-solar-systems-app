import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

enum AdminModuleId {
  dashboard,
  feedbacks,
  configs,
  notifications,
  companies,
  serviceTypes,
  serviceCatalog,
  serviceRequests,
}

class AdminModule {
  const AdminModule({
    required this.id,
    required this.label,
    required this.subtitle,
    required this.route,
    required this.icon,
  });

  final AdminModuleId id;
  final String label;
  final String subtitle;
  final String route;
  final IconData icon;
}

class AdminModules {
  static const dashboard = AdminModule(
    id: AdminModuleId.dashboard,
    label: 'Dashboard',
    subtitle: 'Open a section to load its data.',
    route: '/admin',
    icon: Iconsax.grid_1_bold,
  );

  static const feedbacks = AdminModule(
    id: AdminModuleId.feedbacks,
    label: 'Feedbacks',
    subtitle: 'Review user reports and mark items as read.',
    route: '/admin/feedbacks',
    icon: Iconsax.message_bold,
  );

  static const configs = AdminModule(
    id: AdminModuleId.configs,
    label: 'App Configs',
    subtitle: 'Manage runtime configuration flags.',
    route: '/admin/configs',
    icon: Iconsax.setting_2_bold,
  );

  static const notifications = AdminModule(
    id: AdminModuleId.notifications,
    label: 'Notifications',
    subtitle: 'Send pushes and inspect delivery statistics.',
    route: '/admin/send-notification',
    icon: Iconsax.notification_bing_bold,
  );

  static const companies = AdminModule(
    id: AdminModuleId.companies,
    label: 'Companies',
    subtitle: 'Inspect, approve, and manage company accounts.',
    route: '/admin/companies',
    icon: Iconsax.buildings_2_bold,
  );

  static const serviceTypes = AdminModule(
    id: AdminModuleId.serviceTypes,
    label: 'Service Types',
    subtitle: 'Manage public service type tags for companies.',
    route: '/admin/service-types',
    icon: Iconsax.gallery_edit_bold,
  );

  static const serviceCatalog = AdminModule(
    id: AdminModuleId.serviceCatalog,
    label: 'Service Catalog',
    subtitle: 'Control available services and ordering.',
    route: '/admin/service-catalog',
    icon: Iconsax.category_2_bold,
  );

  static const serviceRequests = AdminModule(
    id: AdminModuleId.serviceRequests,
    label: 'Service Requests',
    subtitle: 'Review activation requests from companies.',
    route: '/admin/service-requests',
    icon: Iconsax.briefcase_bold,
  );

  static const navItems = <AdminModule>[
    dashboard,
    feedbacks,
    configs,
    notifications,
    companies,
    serviceTypes,
    serviceCatalog,
    serviceRequests,
  ];

  static const dashboardCards = <AdminModule>[
    companies,
    serviceTypes,
    serviceRequests,
    serviceCatalog,
    feedbacks,
    configs,
    notifications,
  ];

  static AdminModule fromLocation(String location) {
    if (location == '/admin') return dashboard;
    if (location.startsWith('/admin/feedbacks')) return feedbacks;
    if (location.startsWith('/admin/configs')) return configs;
    if (location.startsWith('/admin/send-notification')) return notifications;
    if (location.startsWith('/admin/companies')) return companies;
    if (location.startsWith('/admin/service-types')) return serviceTypes;
    if (location.startsWith('/admin/service-catalog')) return serviceCatalog;
    if (location.startsWith('/admin/service-requests')) return serviceRequests;
    return dashboard;
  }
}
