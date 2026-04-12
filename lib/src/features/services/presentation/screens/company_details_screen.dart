import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:solar_hub/src/core/widgets/loading_widgets.dart';
import 'package:solar_hub/src/shared/domain/company/company.dart';
import 'package:solar_hub/src/shared/domain/company/company_contact.dart';
import 'package:solar_hub/src/shared/domain/company/company_delivery_option.dart';
import 'package:solar_hub/src/features/services/presentation/providers/public_services_provider.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class CompanyDetailsScreen extends ConsumerWidget {
  final int companyId;

  const CompanyDetailsScreen({super.key, required this.companyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsAsync = ref.watch(publicCompanyDetailsProvider(companyId));

    return detailsAsync.when(
      data: (company) => _DetailsBody(company: company),
      error: (error, stackTrace) => Center(
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Text(error.toString(), textAlign: TextAlign.center),
        ),
      ),
      loading: () => Center(child: LoadingWidget.widget(context: context)),
    );
  }
}

class _DetailsBody extends StatelessWidget {
  final Company company;

  const _DetailsBody({required this.company});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final priceFormat = NumberFormat.decimalPattern();

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeroCard(company: company),
          SizedBox(height: 16.h),
          _SectionCard(
            title: l10n.services_company_info,
            child: Column(
              children: [
                _InfoTile(
                  icon: Iconsax.location_bold,
                  title: l10n.services_address,
                  value: company.address ?? l10n.services_no_address,
                ),
                _InfoTile(
                  icon: Iconsax.buildings_2_bold,
                  title: l10n.services_city_label,
                  value: company.city?.name ?? l10n.services_not_specified,
                ),
                _InfoTile(
                  icon: Iconsax.category_bold,
                  title: l10n.services_type_label,
                  value:
                      company.companyType?.name ??
                      company.companyType?.code ??
                      l10n.services_not_specified,
                ),
                _ActionTile(
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
          SizedBox(height: 16.h),
          _SectionCard(
            title: l10n.services_section_services,
            child: company.publicServices.isEmpty
                ? _EmptySection(message: l10n.services_no_public_services)
                : Column(
                    children: company.publicServices
                        .map(
                          (service) => Padding(
                            padding: EdgeInsets.only(bottom: 10.h),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(14.r),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withValues(
                                  alpha: 0.06,
                                ),
                                borderRadius: BorderRadius.circular(18.r),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          service.title,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        (service.price ?? 0) > 0
                                            ? '${priceFormat.format(service.price)} IQD'
                                            : l10n.services_price_on_request,
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: AppTheme.primaryColor,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if ((service.description ?? '')
                                      .trim()
                                      .isNotEmpty) ...[
                                    SizedBox(height: 8.h),
                                    Text(
                                      service.description!,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        height: 1.45,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ),
          SizedBox(height: 16.h),
          _SectionCard(
            title: l10n.services_contacts_title,
            child: company.contacts.isEmpty
                ? _EmptySection(message: l10n.services_no_contacts)
                : Column(
                    children: company.contacts
                        .map((contact) => _ContactTile(contact: contact))
                        .toList(),
                  ),
          ),
          SizedBox(height: 16.h),
          _SectionCard(
            title: l10n.services_delivery_options,
            child: company.deliveryOptions.isEmpty
                ? _EmptySection(message: l10n.services_no_delivery_options)
                : Column(
                    children: company.deliveryOptions
                        .map((option) => _DeliveryTile(option: option))
                        .toList(),
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

class _HeroCard extends StatelessWidget {
  final Company company;

  const _HeroCard({required this.company});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D3B66), Color(0xFF168AAD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18.r),
                child: Container(
                  width: 82.r,
                  height: 82.r,
                  color: Colors.white.withValues(alpha: 0.12),
                  child: company.logo == null || company.logo!.isEmpty
                      ? Icon(
                          Iconsax.building_bold,
                          size: 34.sp,
                          color: Colors.white,
                        )
                      : CachedNetworkImage(
                          imageUrl: company.logo!,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Icon(
                            Iconsax.building_bold,
                            size: 34.sp,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      company.name,
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    if ((company.companyType?.name ?? '').isNotEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(999.r),
                        ),
                        child: Text(
                          company.companyType!.name,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if ((company.description ?? '').trim().isNotEmpty) ...[
            SizedBox(height: 16.h),
            Text(
              company.description!,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 12.h),
          child,
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 18.sp),
          SizedBox(width: 10.w),
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
                SizedBox(height: 2.h),
                Text(value, style: TextStyle(fontSize: 12.sp, height: 1.45)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback? onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16.r),
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 18.sp),
            SizedBox(width: 10.w),
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
                  SizedBox(height: 2.h),
                  Text(value, style: TextStyle(fontSize: 12.sp, height: 1.45)),
                ],
              ),
            ),
            if (onTap != null) const Icon(Icons.open_in_new_rounded, size: 18),
          ],
        ),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final CompanyContact contact;

  const _ContactTile({required this.contact});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              contact.name,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800),
            ),
            if ((contact.phone ?? '').isNotEmpty) ...[
              SizedBox(height: 6.h),
              Text(contact.phone!, style: TextStyle(fontSize: 12.sp)),
            ],
            if ((contact.email ?? '').isNotEmpty) ...[
              SizedBox(height: 4.h),
              Text(contact.email!, style: TextStyle(fontSize: 12.sp)),
            ],
            if ((contact.notes ?? '').isNotEmpty) ...[
              SizedBox(height: 6.h),
              Text(
                contact.notes!,
                style: TextStyle(fontSize: 12.sp, height: 1.45),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DeliveryTile extends StatelessWidget {
  final CompanyDeliveryOption option;

  const _DeliveryTile({required this.option});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    option.name,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  option.cost != null
                      ? '${option.cost} IQD'
                      : l10n.services_flexible_delivery,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            if ((option.description ?? '').isNotEmpty) ...[
              SizedBox(height: 8.h),
              Text(
                option.description!,
                style: TextStyle(fontSize: 12.sp, height: 1.45),
              ),
            ],
            if (option.estimatedDaysMin != null ||
                option.estimatedDaysMax != null) ...[
              SizedBox(height: 8.h),
              Text(
                l10n.services_estimated_days(
                  option.estimatedDaysMin ?? '-',
                  option.estimatedDaysMax ?? '-',
                ),
                style: TextStyle(fontSize: 12.sp),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptySection extends StatelessWidget {
  final String message;

  const _EmptySection({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Text(message, style: TextStyle(fontSize: 12.sp)),
    );
  }
}
