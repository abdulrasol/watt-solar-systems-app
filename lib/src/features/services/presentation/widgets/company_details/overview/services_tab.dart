import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/shared/domain/company/company.dart';
import 'package:solar_hub/src/utils/app_theme.dart';
import '../common_widgets.dart';

class CompanyServicesTab extends StatelessWidget {
  final Company company;

  const CompanyServicesTab({super.key, required this.company});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final priceFormat = NumberFormat.decimalPattern();

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 24.h),
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CompanyFeatureBanner(
            icon: Iconsax.briefcase_bold,
            title: l10n.services_section_services,
            subtitle: l10n.services_services_count(
              company.publicServices.length,
            ),
          ),
          SizedBox(height: 14.h),
          if (company.publicServices.isEmpty)
            CompanyEmptyStateCard(
              icon: Iconsax.briefcase_bold,
              message: l10n.services_no_public_services,
            )
          else
            ...company.publicServices.map(
              (service) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: CompanyServiceShowcaseCard(
                  title: service.title,
                  description: service.description,
                  priceLabel: (service.price ?? 0) > 0
                      ? '${priceFormat.format(service.price)} IQD'
                      : l10n.services_price_on_request,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class CompanyServiceShowcaseCard extends StatelessWidget {
  final String title;
  final String? description;
  final String priceLabel;

  const CompanyServiceShowcaseCard({
    super.key,
    required this.title,
    required this.description,
    required this.priceLabel,
  });

  @override
  Widget build(BuildContext context) {
    return CompanySurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Text(
                  priceLabel,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          if ((description ?? '').trim().isNotEmpty) ...[
            SizedBox(height: 10.h),
            Text(
              description!,
              style: TextStyle(
                fontSize: 12.sp,
                height: 1.55,
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withValues(alpha: 0.82),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
