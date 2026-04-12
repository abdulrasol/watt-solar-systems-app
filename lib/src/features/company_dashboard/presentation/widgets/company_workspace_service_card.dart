import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/widgets/wd_image_preview.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/entities/service.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/service_request_bottom_sheet.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class CompanyWorkspaceServiceCard extends StatelessWidget {
  const CompanyWorkspaceServiceCard({
    super.key,
    required this.service,
    this.companyId,
    this.canManageActions = true,
  });

  final CompanyService service;
  final int? companyId;
  final bool canManageActions;

  bool get _isActive {
    final value = service.status?.toLowerCase();
    return value == 'active' || value == 'approved' || value == 'string';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final statusColor = _statusColor(service.status);
    final hasCustomIcon =
        service.icon != null &&
        service.icon!.isNotEmpty &&
        service.icon != 'null';

    return InkWell(
      onTap: () => _handleTap(context),
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: statusColor.withValues(alpha: 0.18)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 52,
                  width: 52,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: hasCustomIcon
                      ? WdImagePreview(
                          imageUrl: service.icon!,
                          size: 32,
                          shape: BoxShape.circle,
                        )
                      : Icon(
                          _serviceIcon(service.serviceCode),
                          color: statusColor,
                          size: 24,
                        ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _statusLabel(l10n),
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              service.serviceName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _description(l10n),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 12,
                height: 1.45,
                color: Theme.of(context).hintColor,
              ),
            ),
            const Spacer(),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  _isActive
                      ? service.serviceName
                      : canManageActions
                      ? l10n.request_access
                      : l10n.company_activation_required_short,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: AppTheme.primaryColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleTap(BuildContext context) {
    final targetRoute = _normalizedRoute(service.route);

    if (_isActive && targetRoute != null) {
      try {
        context.push(targetRoute);
      } catch (_) {
        _openStatusPage(context);
      }
      return;
    }

    if (!_isActive && !canManageActions) {
      return;
    }

    if (!_isActive && companyId != null) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => ServiceRequestBottomSheet(
          companyId: companyId!,
          serviceCode: service.serviceCode,
          serviceName: service.serviceName,
          onSuccess: () {},
        ),
      );
      return;
    }

    _openStatusPage(context);
  }

  void _openStatusPage(BuildContext context) {
    context.push(
      '/service-status',
      extra: {
        'name': service.serviceName,
        'code': service.serviceCode,
        'status': service.status,
        'icon': service.icon,
      },
    );
  }

  String _statusLabel(AppLocalizations l10n) {
    if (_isActive) return l10n.status_active;

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

  String _description(AppLocalizations l10n) {
    if (_isActive) return l10n.section_label(service.serviceName);
    return l10n.service_not_requested(service.serviceName);
  }

  Color _statusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
      case 'approved':
        return Colors.green;
      case 'pending':
      case 'requested':
        return Colors.orange;
      case 'rejected':
        return AppTheme.errorColor;
      case 'string':
        return AppTheme.primaryColor;
      default:
        return Colors.grey;
    }
  }

  String? _normalizedRoute(String? route) {
    if (route == null || route.isEmpty || route == 'null') return null;
    return route.startsWith('/') ? route : '/$route';
  }

  IconData _serviceIcon(String code) {
    switch (code) {
      case 'offers':
        return Iconsax.document_bold;
      case 'offers_catalog':
        return Iconsax.receipt_item_bold;
      case 'inventory':
        return Iconsax.box_bold;
      case 'accounting':
        return Iconsax.money_2_bold;
      case 'multi_member':
        return Iconsax.user_tag_bold;
      case 'storefront_b2c':
        return Iconsax.shop_bold;
      case 'storefront_b2b':
        return Iconsax.building_3_bold;
      case 'systems_portfolio':
        return Iconsax.sun_1_bold;
      case 'analytics':
        return Iconsax.chart_2_bold;
      default:
        return Iconsax.category_bold;
    }
  }
}
