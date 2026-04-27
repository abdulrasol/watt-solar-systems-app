import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/widgets/wd_image_preview.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/entities/service.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class ServiceCard extends StatelessWidget {
  final CompanyService service;
  final int? companyId;

  const ServiceCard({super.key, required this.service, this.companyId});

  IconData _getServiceIcon(String code) {
    switch (code) {
      case 'offers':
        return Iconsax.document_bold;
      case 'offers_catalog':
        return Iconsax.receipt_item_bold;
      case 'inventory':
        return Iconsax.box_bold;
      case 'company_work':
        return Iconsax.gallery_bold;
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
      default:
        return Iconsax.category_bold;
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
    final bool isActive =
        service.status != null &&
        (service.status!.toLowerCase() == 'active' ||
            service.status!.toLowerCase() == 'approved' ||
            service.status!.toLowerCase() == 'string');

    final bool hasCustomIcon =
        service.icon != null &&
        service.icon!.isNotEmpty &&
        service.icon != 'null';

    return InkWell(
      onTap: () {
        if (isActive && _targetRoute != null) {
          final String targetRoute = _targetRoute!;

          try {
            // Use push instead of go for safer navigation and swipe-back support
            context.push(targetRoute);
          } catch (e) {
            // Fallback to service status if route matching fails
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
        } else if (!isActive) {
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
      },
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: _getStatusColor(service.status).withValues(alpha: 0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: _getStatusColor(
                      service.status,
                    ).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: hasCustomIcon
                      ? WdImagePreview(
                          imageUrl: service.icon!,
                          size: 24,
                          shape: BoxShape.circle,
                        )
                      : Icon(
                          _getServiceIcon(service.serviceCode),
                          color: _getStatusColor(service.status),
                          size: 20.sp,
                        ),
                ),
                if (!isActive)
                  Icon(
                    Iconsax.lock_bold,
                    color: Colors.grey.withValues(alpha: 0.5),
                    size: 14.sp,
                  ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              service.serviceName,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w800,
                fontFamily: AppTheme.fontFamily,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Container(
                  width: 6.w,
                  height: 6.w,
                  decoration: BoxDecoration(
                    color: _getStatusColor(service.status),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    _localizedStatusLabel(l10n, isActive),
                    style: TextStyle(
                      fontSize: 9.sp,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                      fontFamily: AppTheme.fontFamily,
                    ),
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
    if (service.route == null ||
        service.route!.isEmpty ||
        service.route == 'null') {
      return null;
    }
    return service.route!.startsWith('/')
        ? service.route!
        : '/${service.route}';
  }
}
