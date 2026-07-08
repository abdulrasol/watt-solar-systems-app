import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:watt/l10n/app_localizations.dart';
import 'package:watt/src/core/widgets/wd_image_preview.dart';
import 'package:watt/src/features/company_dashboard/domain/entities/service.dart';
import 'package:watt/src/utils/app_theme.dart';

class ServiceCard extends StatelessWidget {
  final CompanyService service;
  final int? companyId;

  const ServiceCard({super.key, required this.service, this.companyId});

  IconData _getServiceIcon(String code) {
    switch (code) {
      case 'offers':
        return Iconsax.document;
      case 'offers_catalog':
        return Iconsax.receipt_item;
      case 'inventory':
        return Iconsax.box;
      case 'company_work':
        return Iconsax.gallery;
      case 'accounting':
        return Iconsax.money_2;
      case 'multi_member':
        return Iconsax.user_tag;
      case 'storefront_b2c':
        return Iconsax.shop;
      case 'storefront_b2b':
        return Iconsax.building_3;
      case 'systems_portfolio':
        return Iconsax.sun_1;
      default:
        return Iconsax.category;
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
      case 'approved':
        return Colors.green;
      case 'pending':
      case 'requested':
        return Colors.orange;
      case 'string': // Placeholder from server?
        return AppTheme.primaryColor;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bool isActive = service.isActive;

    final bool hasCustomIcon = service.icon != null && service.icon!.isNotEmpty && service.icon != 'null';

    return InkWell(
      onTap: () {
        if (isActive && _targetRoute != null) {
          final String targetRoute = _targetRoute!;

          try {
            // Use push instead of go for safer navigation and swipe-back support
            context.push(targetRoute);
          } catch (e) {
            // Fallback to service status if route matching fails
            context.push('/service-status', extra: {'name': service.serviceName, 'code': service.serviceCode, 'status': service.status, 'icon': service.icon});
          }
        } else if (!isActive) {
          context.push('/service-status', extra: {'name': service.serviceName, 'code': service.serviceCode, 'status': service.status, 'icon': service.icon});
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _getStatusColor(service.status).withValues(alpha: 0.2), width: 1.5),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(color: _getStatusColor(service.status).withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: hasCustomIcon
                      ? WdImagePreview(imageUrl: service.icon!, size: 24, shape: BoxShape.circle)
                      : Icon(_getServiceIcon(service.serviceCode), color: _getStatusColor(service.status), size: 20),
                ),
                if (!isActive) Icon(Iconsax.lock, color: Colors.grey.withValues(alpha: 0.5), size: 14),
              ],
            ),
            SizedBox(height: 12),
            Text(
              service.serviceName,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, fontFamily: AppTheme.fontFamily),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(color: _getStatusColor(service.status), shape: BoxShape.circle),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    _localizedStatusLabel(l10n, isActive),
                    style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.w600, fontFamily: AppTheme.fontFamily),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _localizedStatusLabel(AppLocalizations l10n, bool isActive) {
    if (isActive) return l10n.status_active;
    switch (service.status?.toLowerCase()) {
      case 'pending':
      case 'requested':
        return l10n.status_pending;
      case 'rejected':
        return l10n.status_rejected;
      case 'suspended':
        return l10n.status_suspended;
      case 'cancelled':
        return l10n.status_cancelled;
      default:
        return l10n.status_unavailable;
    }
  }

  String? get _targetRoute {
    if (service.serviceCode == 'company_work') return '/company-work';
    if (service.route == null || service.route!.isEmpty || service.route == 'null') {
      return null;
    }
    return service.route!.startsWith('/') ? service.route! : '/${service.route}';
  }
}
