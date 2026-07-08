import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:watt/src/core/theme/app_colors.dart';
import 'package:watt/src/utils/app_theme.dart';

/// A reusable base screen wrapper used across the application.
///
/// Provides a consistent app bar, back navigation, actions, padding,
/// floating action button placement, and safe area handling.
class BaseScreen extends ConsumerWidget {
  final String? title;
  final Widget child;
  final List<Widget>? actions;
  final Widget? leading;
  final Widget? floatingActionButton;
  final EdgeInsetsGeometry padding;
  final bool topSafeArea;
  final bool bottomSafeArea;
  final bool hideAppBar;
  final bool withBack;
  final bool centerTitle;
  final Color? backgroundColor;
  final PreferredSizeWidget? bottom;

  const BaseScreen({
    super.key,
    this.title,
    required this.child,
    this.actions,
    this.leading,
    this.floatingActionButton,
    this.padding = const EdgeInsets.all(16),
    this.topSafeArea = true,
    this.bottomSafeArea = true,
    this.hideAppBar = false,
    this.withBack = true,
    this.centerTitle = true,
    this.backgroundColor,
    this.bottom,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(appColorsProvider);
    final canPop = context.canPop();

    return Scaffold(
      backgroundColor: backgroundColor ?? colors.background,
      appBar: hideAppBar
          ? null
          : AppBar(
              title: title != null
                  ? Text(
                      title!,
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    )
                  : null,
              centerTitle: centerTitle,
              backgroundColor: colors.surface,
              foregroundColor: colors.textPrimary,
              elevation: 0,
              leading: leading ?? (withBack && canPop ? const _BackButton() : null),
              actions: actions,
              bottom: bottom,
            ),
      body: SafeArea(
        top: topSafeArea,
        bottom: bottomSafeArea,
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}

class _BackButton extends ConsumerWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(appColorsProvider);
    return IconButton(
      onPressed: () => context.pop(),
      icon: Icon(
        Directionality.of(context) == TextDirection.rtl
            ? Iconsax.arrow_right_3
            : Iconsax.arrow_left_2,
        color: colors.textPrimary,
      ),
    );
  }
}
