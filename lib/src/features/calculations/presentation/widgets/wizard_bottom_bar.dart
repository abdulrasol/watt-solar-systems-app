import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/utils/app_theme.dart';
import 'package:solar_hub/src/utils/helper_methods.dart' show isEnabled;

class WizardBottomBar extends ConsumerWidget {
  const WizardBottomBar({
    super.key,
    required this.tabIndex,
    required this.isDark,
    required this.onBack,
    required this.onNext,
    required this.onRequest,
    required this.l10n,
    required this.theme,
  });

  final int tabIndex;
  final bool isDark;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onRequest;
  final AppLocalizations l10n;
  final ThemeData theme;

  static const _btnShape = RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12)));
  static const _btnStyle = TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w600, fontSize: 15);
  static const _btnPadding = EdgeInsets.symmetric(vertical: 14);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 12.h + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back / Close
          OutlinedButton(
            onPressed: onBack,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: _btnShape,
              side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.4)),
            ),
            child: Text(tabIndex == 0 ? l10n.close : l10n.back),
          ),
          const SizedBox(width: 12),

          // Next / Calculate / Request — animated swap
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero).animate(anim),
                  child: child,
                ),
              ),
              child: tabIndex < 2
                  ? SizedBox(
                      key: ValueKey('nav_$tabIndex'),
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: onNext,
                        icon: Icon(tabIndex == 1 ? Iconsax.calculator_bold : Icons.arrow_forward_rounded, size: 18),
                        label: Text(tabIndex == 1 ? l10n.calculate : l10n.next),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: _btnPadding,
                          shape: _btnShape,
                          textStyle: _btnStyle,
                        ),
                      ),
                    )
                  : isEnabled(ref, 'offers')
                  ? SizedBox(
                      key: const ValueKey('nav_request'),
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: onRequest,
                        icon: const Icon(Iconsax.send_2_bold, size: 18),
                        label: Text(l10n.request_this_system),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: _btnPadding,
                          shape: _btnShape,
                          textStyle: _btnStyle,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}
