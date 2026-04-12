import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solar_hub/src/features/admin/presentation/models/admin_module.dart';
import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class AdminShell extends ConsumerWidget {
  const AdminShell({super.key, required this.child, required this.location});

  final Widget child;
  final String location;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeModule = AdminModules.fromLocation(location);
    final authState = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final workspaceColor = isDark
        ? const Color(0xFF152321)
        : const Color(0xFFF3F7F6);
    final workspaceAccent = isDark
        ? AppTheme.primaryColor.withValues(alpha: 0.12)
        : AppTheme.primaryColor.withValues(alpha: 0.08);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isMobile = width < 700;
        final isTablet = width >= 700 && width < 1100;

        return Scaffold(
          backgroundColor: workspaceColor,
          drawer: isMobile
              ? Drawer(
                  child: _AdminNavigation(
                    activeModule: activeModule,
                    compact: false,
                    authState: authState,
                  ),
                )
              : null,
          appBar: AppBar(
            title: Text(
              activeModule.label,
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontWeight: FontWeight.w700,
              ),
            ),
            centerTitle: isMobile,
          ),
          body: SafeArea(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    workspaceColor,
                    workspaceAccent,
                    workspaceColor,
                  ],
                ),
              ),
              child: Row(
                children: [
                  if (!isMobile)
                    _AdminNavigation(
                      activeModule: activeModule,
                      compact: isTablet,
                      authState: authState,
                    ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        isMobile ? 16 : 24,
                        20,
                        isMobile ? 16 : 24,
                        20,
                      ),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: width >= 1440 ? 1320 : 1180,
                          ),
                          child: child,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AdminNavigation extends StatelessWidget {
  const _AdminNavigation({
    required this.activeModule,
    required this.compact,
    required this.authState,
  });

  final AdminModule activeModule;
  final bool compact;
  final AuthState authState;

  @override
  Widget build(BuildContext context) {
    final width = compact ? 96.0 : 260.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Theme.of(context).cardColor,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.06),
            ),
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: compact
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  compact ? 12 : 20,
                  16,
                  compact ? 12 : 20,
                  20,
                ),
                child: compact
                    ? const CircleAvatar(
                        radius: 22,
                        backgroundColor: AppTheme.primaryColor,
                        child: Icon(
                          Icons.admin_panel_settings_rounded,
                          color: Colors.white,
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Solar Hub',
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 14,
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Admin Workspace',
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).textTheme.titleLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Open a module to fetch and manage its content.',
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 12,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        ],
                      ),
              ),
              if (!compact)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: _ModeSwitcher(authState: authState),
                ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 12),
                  children: [
                    for (final module in AdminModules.navItems)
                      _AdminNavTile(
                        module: module,
                        active: module.id == activeModule.id,
                        compact: compact,
                      ),
                    if (compact) ...[
                      const SizedBox(height: 12),
                      _CompactModeAction(
                        icon: Icons.home_rounded,
                        tooltip: 'User Mode',
                        onTap: () => context.go('/home'),
                      ),
                      if (authState.isCompanyMember)
                        _CompactModeAction(
                          icon: Icons.business_rounded,
                          tooltip: 'Company Mode',
                          onTap: () => context.go('/companies/dashboard'),
                        ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeSwitcher extends StatelessWidget {
  const _ModeSwitcher({required this.authState});

  final AuthState authState;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Switch Mode',
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => context.go('/home'),
                icon: const Icon(Icons.home_rounded),
                label: const Text('User'),
              ),
              if (authState.isCompanyMember)
                FilledButton.icon(
                  onPressed: () => context.go('/companies/dashboard'),
                  icon: const Icon(Icons.business_rounded),
                  label: Text(authState.company?.name ?? 'Company'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdminNavTile extends StatelessWidget {
  const _AdminNavTile({
    required this.module,
    required this.active,
    required this.compact,
  });

  final AdminModule module;
  final bool active;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final tile = InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.of(context).maybePop();
        context.go(module.route);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 10 : 14,
          vertical: compact ? 12 : 14,
        ),
        decoration: BoxDecoration(
          color: active
              ? AppTheme.primaryColor.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: compact
            ? Icon(
                module.icon,
                color: active ? AppTheme.primaryColor : Theme.of(context).hintColor,
              )
            : Row(
                children: [
                  Icon(
                    module.icon,
                    color: active ? AppTheme.primaryColor : Theme.of(context).hintColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      module.label,
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 14,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                        color: active
                            ? AppTheme.primaryColor
                            : Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );

    if (!compact) return tile;

    return Tooltip(message: module.label, child: tile);
  }
}

class _CompactModeAction extends StatelessWidget {
  const _CompactModeAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(icon, color: AppTheme.primaryColor),
        ),
      ),
    );
  }
}
