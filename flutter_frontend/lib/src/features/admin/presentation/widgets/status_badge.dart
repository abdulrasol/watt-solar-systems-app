import 'package:flutter/material.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/status_helper.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

/// Reusable status badge widget
class StatusBadge extends StatelessWidget {
  final String status;
  final bool small;

  const StatusBadge({super.key, required this.status, this.small = false});

  @override
  Widget build(BuildContext context) {
    final color = StatusHelper.getStatusColor(status);
    final label = StatusHelper.getStatusLabel(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 6 : 10,
        vertical: small ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: small ? 6 : 8,
            height: small ? 6 : 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: small ? 4 : 6),
          Text(
            label,
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontWeight: FontWeight.bold,
            ).copyWith(color: color, fontSize: small ? 10 : 12),
          ),
        ],
      ),
    );
  }
}
