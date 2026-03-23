import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:solar_hub/src/utils/app_enums.dart';

class DashboardMenuCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final int? badge;
  final Permissions permission;

  const DashboardMenuCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    this.badge,
    this.permission = Permissions.read,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = permission != Permissions.none;
    final displayColor = isEnabled ? color : Colors.grey.shade400;

    return Card(
      elevation: 0,
      color: isEnabled ? Theme.of(context).cardColor : Colors.grey.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
      ),
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(16.r),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: displayColor.withValues(alpha: isEnabled ? 0.1 : 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: displayColor, size: 28),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: isEnabled ? null : Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            if (badge != null && isEnabled)
              Positioned(
                top: 12.r,
                right: 12.r,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 4.r),
                  decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12.r)),
                  child: Text(
                    badge!.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
