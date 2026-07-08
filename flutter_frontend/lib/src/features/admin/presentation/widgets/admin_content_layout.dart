import 'package:flutter/material.dart';
import 'package:watt/src/utils/app_theme.dart';

enum DeviceType { mobile, tablet, desktop }

class AdminContentLayout extends StatelessWidget {
  const AdminContentLayout({
    super.key,
    required this.child,
    this.title,
    this.actions = const [],
  });

  final Widget child;
  final String? title;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final device = width < 700 ? DeviceType.mobile : width < 1100 ? DeviceType.tablet : DeviceType.desktop;
        final data = AdminLayoutData._(device: device);

        return AdminLayoutScope(
          data: data,
          child: Column(
            children: [
              if (title != null || actions.isNotEmpty)
                _AdminHeader(title: title, actions: actions, data: data),
              Expanded(
                child: _buildContent(context, data),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, AdminLayoutData data) {
    if (data.isDesktop) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: child,
        ),
      );
    }
    if (data.isTablet) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: child,
        ),
      );
    }
    return child;
  }
}

class _AdminHeader extends StatelessWidget {
  const _AdminHeader({required this.title, required this.actions, required this.data});

  final String? title;
  final List<Widget> actions;
  final AdminLayoutData data;

  @override
  Widget build(BuildContext context) {
    final horizontal = data.isMobile ? 12.0 : data.isTablet ? 24.0 : 32.0;
    final vertical = data.isMobile ? 8.0 : 12.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(data.isMobile ? 4 : horizontal, vertical, horizontal, 0),
      child: Row(
        children: [
          if (data.isMobile && Scaffold.maybeOf(context)?.hasDrawer == true)
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
          if (title != null) ...[
            Flexible(
              child: Text(
                title!,
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: data.isMobile ? 18 : 22,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 16),
          ],
          if (actions.isNotEmpty) ...[
            if (title != null) const Spacer(),
            ...actions,
          ],
        ],
      ),
    );
  }
}

class AdminLayoutData {
  final DeviceType device;

  AdminLayoutData._({required this.device});

  bool get isMobile => device == DeviceType.mobile;
  bool get isTablet => device == DeviceType.tablet;
  bool get isDesktop => device == DeviceType.desktop;

  double get padding => isMobile ? 16 : isTablet ? 24 : 32;

  int getCrossAxisCount(double childWidth) {
    final available = isDesktop ? 1000.0 : isTablet ? 800.0 : 600.0;
    final count = (available / (childWidth + 16)).floor();
    return count.clamp(1, 4);
  }
}

class AdminLayoutScope extends InheritedWidget {
  const AdminLayoutScope({
    super.key,
    required this.data,
    required super.child,
  });

  final AdminLayoutData data;

  static AdminLayoutData of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AdminLayoutScope>();
    assert(scope != null, 'No AdminLayoutScope found in context');
    return scope!.data;
  }

  @override
  bool updateShouldNotify(AdminLayoutScope oldWidget) => oldWidget.data.device != data.device;
}
