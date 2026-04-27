import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/shared/domain/company/company.dart';
import 'package:solar_hub/src/shared/domain/company/company_contact.dart';
import 'package:solar_hub/src/utils/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import '../common_widgets.dart';

class CompanyInfoContactsTab extends StatelessWidget {
  final Company company;

  const CompanyInfoContactsTab({super.key, required this.company});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 24.h),
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CompanyFeatureBanner(
            icon: Iconsax.info_circle_bold,
            title: l10n.services_tab_info_contacts,
            subtitle: l10n.services_company_info,
          ),
          SizedBox(height: 14.h),
          CompanySurfaceCard(
            child: Column(
              children: [
                CompanyInfoTile(
                  icon: Iconsax.location_bold,
                  title: l10n.services_address,
                  value: company.address ?? l10n.services_no_address,
                ),
                CompanyInfoTile(
                  icon: Iconsax.buildings_2_bold,
                  title: l10n.services_city_label,
                  value: company.city?.name ?? l10n.services_not_specified,
                ),
                CompanyInfoTile(
                  icon: Iconsax.category_bold,
                  title: l10n.services_type_label,
                  value:
                      company.companyType?.name ??
                      company.companyType?.code ??
                      l10n.services_not_specified,
                ),
                CompanyActionTile(
                  icon: Iconsax.call_bold,
                  title: l10n.services_phone_label,
                  value: company.phone ?? l10n.services_no_phone,
                  onTap: company.phone?.isNotEmpty == true
                      ? () =>
                            _launchUri(Uri(scheme: 'tel', path: company.phone))
                      : null,
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          CompanySectionHeading(title: l10n.services_contacts_title),
          SizedBox(height: 10.h),
          if (company.contacts.isEmpty)
            CompanyEmptyStateCard(
              icon: Iconsax.profile_2user_bold,
              message: l10n.services_no_contacts,
            )
          else
            ...company.contacts.map(
              (contact) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: CompanyContactTile(contact: contact),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _launchUri(Uri uri) async {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class CompanyInfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const CompanyInfoTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38.r,
            height: 38.r,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 18.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(value, style: TextStyle(fontSize: 12.sp, height: 1.45)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CompanyActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback? onTap;

  const CompanyActionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18.r),
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38.r,
              height: 38.r,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: AppTheme.primaryColor, size: 18.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(value, style: TextStyle(fontSize: 12.sp, height: 1.45)),
                ],
              ),
            ),
            if (onTap != null)
              Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: Icon(
                  Icons.open_in_new_rounded,
                  size: 18.sp,
                  color: AppTheme.primaryColor,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class CompanyContactTile extends StatelessWidget {
  final CompanyContact contact;

  const CompanyContactTile({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    return CompanySurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42.r,
                height: 42.r,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(
                  Iconsax.user_bold,
                  color: AppTheme.primaryColor,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  contact.name,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          if ((contact.phone ?? '').isNotEmpty) ...[
            SizedBox(height: 10.h),
            CompanyContactMetaRow(
              icon: Iconsax.call_bold,
              value: contact.phone!,
            ),
          ],
          if ((contact.email ?? '').isNotEmpty) ...[
            SizedBox(height: 8.h),
            CompanyContactMetaRow(
              icon: Iconsax.sms_bold,
              value: contact.email!,
            ),
          ],
          if ((contact.notes ?? '').isNotEmpty) ...[
            SizedBox(height: 10.h),
            Text(
              contact.notes!,
              style: TextStyle(fontSize: 12.sp, height: 1.5),
            ),
          ],
        ],
      ),
    );
  }
}

class CompanyContactMetaRow extends StatelessWidget {
  final IconData icon;
  final String value;

  const CompanyContactMetaRow({
    super.key,
    required this.icon,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 15.sp),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(value, style: TextStyle(fontSize: 12.sp)),
        ),
      ],
    );
  }
}
