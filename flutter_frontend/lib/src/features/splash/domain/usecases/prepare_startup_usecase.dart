import 'package:solar_hub/src/core/cashe/cashe_interface.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/features/auth/domain/entities/user.dart';
import 'package:solar_hub/src/features/settings/domain/entiteis/settings.dart';
import 'package:solar_hub/src/features/splash/domain/entities/startup_bootstrap_result.dart';

class PrepareStartupUseCase {
  final CasheInterface _cache;

  PrepareStartupUseCase({CasheInterface? cache})
    : _cache = cache ?? getIt<CasheInterface>();

  StartupBootstrapResult call() {
    final user = _cache.user();
    final hasValidSession = _cache.token() != null && user != null;
    final settings = _cache.settings();

    return StartupBootstrapResult(
      route: _resolveRoute(
        hasValidSession: hasValidSession,
        user: user,
        settings: settings,
      ),
      shouldRefreshConfigs: true,
      shouldRefreshProfile: hasValidSession,
    );
  }

  String _resolveRoute({
    required bool hasValidSession,
    required User? user,
    required Settings settings,
  }) {
    if (!hasValidSession) {
      return '/home';
    }

    final canUseRoleSelection =
        user?.isCompanyMember == true || user?.isSuperUser == true;
    if (!canUseRoleSelection) {
      return '/home';
    }

    if (settings.saveRolePageSelection) {
      final savedRoute = settings.saveRolePageSelectionRoute;
      if (savedRoute == null || savedRoute.isEmpty) {
        return '/home';
      }
      return savedRoute;
    }

    return '/role_selection';
  }
}
