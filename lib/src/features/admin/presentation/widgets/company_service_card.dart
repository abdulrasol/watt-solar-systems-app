import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/src/features/admin/domain/models/company_service.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/status_badge.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class CompanyServiceCard extends StatelessWidget {
  const CompanyServiceCard({super.key, required this.service, this.onToggle});

  final CompanyService service;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: service.isActive
                ? AppTheme.successColor.withValues(alpha: 0.3)
                : (isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1)),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _buildIcon(),
                SizedBox(
                  width: MediaQuery.sizeOf(context).width < 700 ? 170 : 240,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.serviceName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          fontFamily: AppTheme.fontFamily,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        service.serviceCode,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                          fontFamily: AppTheme.fontFamily,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onToggle != null) _buildToggle(),
                StatusBadge(status: service.status ?? 'inactive', small: true),
              ],
            ),
            if (service.isActive) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  _buildInfoTag(
                    Iconsax.calendar_bold,
                    'Started: ${service.startsAt?.substring(0, 10) ?? 'N/A'}',
                  ),
                  _buildInfoTag(
                    Iconsax.calendar_tick_bold,
                    'Ends: ${service.endsAt?.substring(0, 10) ?? 'N/A'}',
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: service.isActive
            ? AppTheme.successColor.withValues(alpha: 0.1)
            : AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        image: service.icon != null
            ? DecorationImage(
                image: NetworkImage(service.icon!),
                fit: BoxFit.contain,
              )
            : null,
      ),
      child: service.icon == null
          ? Icon(
              Iconsax.setting_2_bold,
              color: service.isActive
                  ? AppTheme.successColor
                  : AppTheme.primaryColor,
              size: 20,
            )
          : null,
    );
  }

  Widget _buildToggle() {
    final isActive = service.isActive;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (isActive ? AppTheme.successColor : Colors.grey).withValues(
          alpha: 0.1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.cancel,
            size: 14,
            color: isActive ? AppTheme.successColor : Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(
            isActive ? 'ON' : 'OFF',
            style: TextStyle(
              color: isActive ? AppTheme.successColor : Colors.grey,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              fontFamily: AppTheme.fontFamily,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTag(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
            fontFamily: AppTheme.fontFamily,
          ),
        ),
      ],
    );
  }
}
