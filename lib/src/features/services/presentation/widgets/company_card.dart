import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/widgets/wd_image_preview.dart';
import 'package:solar_hub/src/shared/domain/company/company.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class CompanyCard extends StatelessWidget {
  final Company company;
  final VoidCallback onTap;

  const CompanyCard({super.key, required this.company, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: onSurface.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(22.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Logo(logo: company.logo),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          company.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        if ((company.typeLabel ?? '').isNotEmpty)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(999.r),
                            ),
                            child: Text(
                              company.typeLabel!,
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              // if ((company.description ?? '').trim().isNotEmpty)
              //   Text(
              //     company.description!.trim(),
              //     maxLines: 2,
              //     overflow: TextOverflow.ellipsis,
              //     style: TextStyle(fontSize: 12.sp, color: onSurface.withValues(alpha: 0.66), height: 1.4),
              //   ),
              // if ((company.description ?? '').trim().isNotEmpty) SizedBox(height: 12.h),
              Row(
                spacing: 8.w,
                children: [
                  Flexible(
                    child: _InfoRow(
                      icon: Iconsax.location_bold,
                      label:
                          company.city?.name ??
                          company.address ??
                          l10n.services_no_address,
                    ),
                  ),
                  Flexible(
                    child: _InfoRow(
                      icon: Iconsax.call_bold,
                      label: company.phone?.trim().isNotEmpty == true
                          ? company.phone!
                          : l10n.services_no_phone,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  _Badge(
                    label: company.allowsB2C == true
                        ? 'B2C'
                        : l10n.services_public_badge,
                  ),
                  _Badge(
                    label: l10n.services_services_count(
                      company.publicServices.length,
                    ),
                  ),
                  if (company.contacts.isNotEmpty)
                    _Badge(
                      label: l10n.services_contacts_count(
                        company.contacts.length,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  final String? logo;

  const _Logo({required this.logo});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        width: 64.r,
        height: 64.r,
        color: AppTheme.primaryColor.withValues(alpha: 0.08),
        child: logo == null || logo!.isEmpty
            ? Icon(
                Iconsax.building_bold,
                color: AppTheme.primaryColor,
                size: 28.sp,
              )
            : WdImagePreview(
                imageUrl: logo!,
                // fit: BoxFit.cover,
                // errorWidget: (context, url, error) => Icon(Iconsax.building_bold, color: AppTheme.primaryColor, size: 28.sp),
              ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15.sp, color: onSurface.withValues(alpha: 0.55)),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.sp,
              color: onSurface.withValues(alpha: 0.74),
            ),
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;

  const _Badge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700),
      ),
    );
  }
}
