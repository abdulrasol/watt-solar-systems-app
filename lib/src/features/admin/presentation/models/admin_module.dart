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
  currencies,
  categories,
  address,
  users,
  subscriptions,
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

  static const currencies = AdminModule(
    id: AdminModuleId.currencies,
    label: 'Currencies',
    subtitle: 'Manage system-wide accepted currencies.',
    route: '/admin/currencies',
    icon: Iconsax.money_bold,
  );

  static const categories = AdminModule(
    id: AdminModuleId.categories,
    label: 'Categories',
    subtitle: 'Global product and service category tags.',
    route: '/admin/categories',
    icon: Iconsax.category_bold,
  );

  static const address = AdminModule(
    id: AdminModuleId.address,
    label: 'Address & Global',
    subtitle: 'Manage system-wide countries and cities.',
    route: '/admin/address',
    icon: Iconsax.global_bold,
  );

  static const users = AdminModule(
    id: AdminModuleId.users,
    label: 'Users',
    subtitle: 'Promote users and manage admin accounts.',
    route: '/admin/users',
    icon: Iconsax.user_bold,
  );

  static const subscriptions = AdminModule(
    id: AdminModuleId.subscriptions,
    label: 'Subscriptions',
    subtitle: 'Manage pricing tiers and subscription plans.',
    route: '/admin/subscriptions',
    icon: Iconsax.card_bold,
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
    currencies,
    categories,
    address,
    users,
    subscriptions,
  ];

  static const dashboardCards = <AdminModule>[
    companies,
    serviceRequests,
    serviceCatalog,
    serviceTypes,
    subscriptions,
    users,
    address,
    categories,
    currencies,
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
    if (location.startsWith('/admin/currencies')) return currencies;
    if (location.startsWith('/admin/categories')) return categories;
    if (location.startsWith('/admin/address')) return address;
    if (location.startsWith('/admin/users')) return users;
    if (location.startsWith('/admin/subscriptions')) return subscriptions;
    return dashboard;
  }
}
