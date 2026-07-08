import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:watt/src/core/widgets/wd_image_preview.dart';
import 'package:watt/src/features/company_dashboard/presentation/models/nav_item.dart';
import 'package:watt/src/utils/app_theme.dart';

class NavItemTile extends StatefulWidget {
  final NavItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isCollapsed;

  const NavItemTile({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onTap,
    this.isCollapsed = false,
  });

  @override
  State<NavItemTile> createState() => _NavItemTileState();
}

class _NavItemTileState extends State<NavItemTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool hasCustomIcon =
        widget.item.iconUrl != null &&
        widget.item.iconUrl!.isNotEmpty &&
        widget.item.iconUrl != 'null';

    final content = AnimatedContainer(
      duration: 200.ms,
      padding: EdgeInsets.symmetric(
        horizontal: widget.isCollapsed ? 0 : 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: widget.isSelected
            ? AppTheme.primaryColor
            : _isHovered
                ? AppTheme.primaryColor.withValues(alpha: 0.1)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        boxShadow: widget.isSelected
            ? [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: Row(
        mainAxisAlignment:
            widget.isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          if (hasCustomIcon)
            WdImagePreview(
              imageUrl: widget.item.iconUrl!,
              size: 18,
              shape: BoxShape.circle,
            )
          else
            Icon(
              widget.item.icon,
              color: widget.isSelected
                  ? Colors.white
                  : _isHovered
                      ? AppTheme.primaryColor
                      : Colors.grey.shade600,
              size: 20,
            ),
          if (!widget.isCollapsed) ...[
            SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.item.label,
                style: TextStyle(
                  color: widget.isSelected
                      ? Colors.white
                      : _isHovered
                          ? AppTheme.primaryColor
                          : Colors.grey.shade700,
                  fontWeight: widget.isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );

    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Tooltip(
          message: widget.isCollapsed ? widget.item.label : '',
          child: InkWell(
            onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
            hoverColor: Colors.transparent,
            splashColor: AppTheme.primaryColor.withValues(alpha: 0.1),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: 200.ms,
                  width: widget.isSelected ? 4 : 0,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                if (widget.isSelected) SizedBox(width: 4),
                Expanded(child: content),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
