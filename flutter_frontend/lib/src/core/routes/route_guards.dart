import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watt/src/core/flags/feature_flags.dart';
import 'package:watt/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:watt/src/core/routes/app_routes.dart';
import 'package:watt/src/utils/helper_methods.dart';

class RouteGuards {
  static String? appRedirectForRoute(String path, AuthState authState, [dynamic ref]) {
    if (ref != null && _isFeatureDisabledForRoute(path, ref)) {
      return AppRoutes.featureUnavailable;
    }

    if (routeRequiresAdmin(path) && !authState.isSuperUser) {
      return authState.isSigned ? AppRoutes.home : '${AppRoutes.auth}?redirect_to=$path';
    }

    if (routeRequiresCompanyMember(path) && !authState.isCompanyMember) {
      return authState.isSigned ? AppRoutes.home : '${AppRoutes.auth}?redirect_to=$path';
    }

    if (path == AppRoutes.companyWork || path.startsWith('${AppRoutes.companyWork}/')) {
      final projectsValue = authState.company?.permissions?.projects;
      if (projectsValue == 'none' || projectsValue == null) {
        return AppRoutes.home;
      }

      if ((path == '${AppRoutes.companyWork}/${AppRoutes.companyWorkAdd}' || path.startsWith('${AppRoutes.companyWork}/edit/')) && projectsValue != 'write') {
        return AppRoutes.companyWork;
      }
    }

    if (path.startsWith('${AppRoutes.companyContentWorks}/')) {
      final projectsValue = authState.company?.permissions?.projects;
      if (projectsValue == 'none' || projectsValue == null) {
        return AppRoutes.home;
      }

      if ((path == '${AppRoutes.companyContentWorks}/add' || path.startsWith('${AppRoutes.companyContentWorks}/edit/')) && projectsValue != 'write') {
        return AppRoutes.companyContentWorks;
      }
    }

    if (routeRequiresAuthenticatedUser(path) && !authState.isSigned) {
      return '${AppRoutes.auth}?redirect_to=$path';
    }

    return null;
  }

  static bool _isFeatureDisabledForRoute(String path, Ref ref) {
    // Global
    if ((path == AppRoutes.auth || path.startsWith('${AppRoutes.auth}/')) && !isFeatureEnabled(ref, AppFeature.auth)) return true;
    if (path == AppRoutes.notifications && !isFeatureEnabled(ref, AppFeature.notifications)) return true;
    if (path == AppRoutes.feedback && !isFeatureEnabled(ref, AppFeature.feedback)) return true;

    // Dashboard & Calculators
    if ((path == AppRoutes.userRequests || path.startsWith('${AppRoutes.userRequests}/')) && !isFeatureEnabled(ref, AppFeature.userRequests)) return true;
    if (path == AppRoutes.calcStructureDesign && !isFeatureEnabled(ref, AppFeature.calculatorStructure)) return true;
    if (path == AppRoutes.calcRoofSimulator && !isFeatureEnabled(ref, AppFeature.calculatorRoof)) return true;
    if (path == AppRoutes.calcPvSystem && !isFeatureEnabled(ref, AppFeature.calculatorPv)) return true;
    if (path == AppRoutes.calcFast && !isFeatureEnabled(ref, AppFeature.calculatorFast)) return true;
    if ((path == AppRoutes.storefront || path.startsWith('${AppRoutes.storefront}/')) && !isFeatureEnabled(ref, AppFeature.store, defaultValue: false)) return true;
    if ((path == AppRoutes.services || path.startsWith('${AppRoutes.services}/')) && !isFeatureEnabled(ref, AppFeature.services)) return true;

    // Company Dashboard
    if (path.startsWith('/companies/dashboard/sales') && !isFeatureEnabled(ref, AppFeature.companySales)) return true;
    if (path.startsWith('/companies/dashboard/inventory') && !isFeatureEnabled(ref, AppFeature.companyInventory)) return true;
    if (path.startsWith('/companies/dashboard/orders') && !isFeatureEnabled(ref, AppFeature.companyOrders)) return true;
    if (path.startsWith('/companies/dashboard/content') && !isFeatureEnabled(ref, AppFeature.companyContent)) return true;
    if (path.startsWith('/companies/dashboard/finance') && !isFeatureEnabled(ref, AppFeature.companyFinance)) return true;

    return false;
  }

  static bool routeRequiresAdmin(String path) => path == AppRoutes.admin || path.startsWith('${AppRoutes.admin}/') || path == AppRoutes.adminMarketplace;

  static bool routeRequiresCompanyMember(String path) {
    return path.startsWith(AppRoutes.companyDashboard) ||
        path == AppRoutes.companyWork ||
        path.startsWith('${AppRoutes.companyWork}/') ||
        path == AppRoutes.members ||
        path == AppRoutes.offers ||
        path.startsWith('${AppRoutes.offers}/');
  }

  static bool routeRequiresAuthenticatedUser(String path) {
    return path == '${AppRoutes.auth}/${AppRoutes.authProfile}' ||
        path == '${AppRoutes.auth}/${AppRoutes.authEditProfile}' ||
        path == AppRoutes.notifications ||
        path == AppRoutes.userRequests ||
        path.startsWith('${AppRoutes.userRequests}/') ||
        path == AppRoutes.calcOfferWizard ||
        (path.startsWith('${AppRoutes.storefront}/') && path.contains('/orders'));
  }
}
