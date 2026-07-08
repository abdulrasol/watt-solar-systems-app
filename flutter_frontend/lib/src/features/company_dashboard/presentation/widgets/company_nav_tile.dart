import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:watt/src/core/widgets/wd_image_preview.dart';
import 'package:watt/src/features/company_dashboard/presentation/models/company_workspace_item.dart';
import 'package:watt/src/utils/app_theme.dart';

class CompanyNavTile extends StatelessWidget {
  const CompanyNavTile({super.key, required this.item, required this.active, required this.compact, required this.isMobile, required this.isTablet});

  final CompanyWorkspaceItem item;
  final bool active;
  final bool compact;
  final bool isMobile;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    final hasCustomIcon = item.iconUrl != null && item.iconUrl!.isNotEmpty && item.iconUrl != 'null';
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          if (item.isExternal) {
            context.push(item.externalRoute!);
            return;
          }
          context.go(item.route);
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 14, vertical: compact ? 12 : 14),
          decoration: BoxDecoration(color: active ? AppTheme.primaryColor : Colors.transparent, borderRadius: BorderRadius.circular(16)),
          child: compact
              ? Tooltip(
                  message: item.label,
                  child: hasCustomIcon
                      ? WdImagePreview(
                          imageUrl: item.iconUrl!,
                          size: isMobile
                              ? 18
                              : isTablet
                              ? 12
                              : 22,
                          shape: BoxShape.circle,
                        )
                      : Icon(
                          item.icon,
                          color: active ? Colors.white : Colors.grey.shade600,
                          size: isMobile
                              ? 18
                              : isTablet
                              ? 12
                              : 22,
                        ),
                )
              : Row(
                  children: [
                    hasCustomIcon
                        ? WdImagePreview(
                            imageUrl: item.iconUrl!,
                            size: isMobile
                                ? 18
                                : isTablet
                                ? 12
                                : 22,
                            shape: BoxShape.circle,
                          )
                        : Icon(
                            item.icon,
                            color: active ? Colors.white : Colors.grey.shade600,
                            size: isMobile
                                ? 18
                                : isTablet
                                ? 12
                                : 22,
                          ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          color: active ? Colors.white : Colors.grey.shade800,
                          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (item.isExternal) Icon(Iconsax.export_3, size: 16, color: active ? Colors.white.withValues(alpha: 0.85) : Colors.grey.shade500),
                  ],
                ),
        ),
      ),
    );
  }
}
