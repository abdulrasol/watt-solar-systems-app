import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/shared/domain/company/company.dart';
import 'package:solar_hub/src/utils/app_theme.dart';
import 'info_contacts_tab.dart';
import 'services_tab.dart';
import 'works_tab.dart';

class CompanyOverviewSection extends StatelessWidget {
  final Company company;

  const CompanyOverviewSection({super.key, required this.company});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(4.r),
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(22.r),
                border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
              ),
              child: TabBar(
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(18.r),
                  color: AppTheme.primaryColor,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.22),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: theme.textTheme.bodyMedium?.color
                    ?.withValues(alpha: 0.72),
                labelStyle: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                ),
                tabs: [
                  Tab(text: l10n.services_tab_works),
                  Tab(text: l10n.services_section_services),
                  Tab(text: l10n.services_tab_info_contacts),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: TabBarView(
                children: [
                  CompanyWorksTab(company: company),
                  CompanyServicesTab(company: company),
                  CompanyInfoContactsTab(company: company),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
