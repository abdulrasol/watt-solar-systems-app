import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/src/core/layout/app_breakpoints.dart';
import 'package:solar_hub/src/core/widgets/loading_widgets.dart';
import 'package:solar_hub/src/core/widgets/pre_scaffold.dart';
import 'package:solar_hub/src/features/admin/domain/models/admin_company_details.dart';
import 'package:solar_hub/src/features/admin/domain/models/company_service.dart';
import 'package:solar_hub/src/features/admin/presentation/controllers/admin_company_details_controller.dart';
import 'package:solar_hub/src/features/admin/presentation/forms/company_status_form.dart';
import 'package:solar_hub/src/features/admin/presentation/forms/service_review_form.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/admin_section_header.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/company_service_card.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/member_list_item.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/status_badge.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class AdminCompanyDetailsScreen extends ConsumerStatefulWidget {
  final int companyId;
  const AdminCompanyDetailsScreen({super.key, required this.companyId});

  @override
  ConsumerState<AdminCompanyDetailsScreen> createState() =>
      _AdminCompanyDetailsScreenState();
}

class _AdminCompanyDetailsScreenState
    extends ConsumerState<AdminCompanyDetailsScreen> {
  @override
  void initState() {
    super.initState();
    final notifier = ref.read(adminCompanyDetailsProvider.notifier);
    notifier.setCompanyId(widget.companyId);
    Future.microtask(() => notifier.fetchDetails());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminCompanyDetailsProvider);

    return PreScaffold(
      title: 'Company Details',
      actions: [
        if (state.details != null)
          IconButton(
            icon: Icon(
              Iconsax.edit_bold,
              color: AppTheme.primaryColor,
              size: 24.sp,
            ),
            onPressed: () => _showStatusUpdateForm(context),
          ),
      ],
      child: state.isLoading && state.details == null
          ? _buildLoadingState()
          : state.error != null
          ? AdminErrorState(
              error: state.error!,
              onRetry: () =>
                  ref.read(adminCompanyDetailsProvider.notifier).fetchDetails(),
            )
          : RefreshIndicator(
              onRefresh: () =>
                  ref.read(adminCompanyDetailsProvider.notifier).fetchDetails(),
              color: AppTheme.primaryColor,
              child: _buildContent(state),
            ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LoadingWidget.widget(context: context, size: 30),
          SizedBox(height: 16.h),
          Text(
            'Loading Details...',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey,
              fontFamily: AppTheme.fontFamily,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(AdminCompanyDetailsState state) {
    final details = state.details;
    if (details == null) return const SizedBox.shrink();
    final isWide = !AppBreakpoints.isMobile(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: AppBreakpoints.contentMaxWidth(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderSection(details),
              SizedBox(height: 24.h),
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildInfoSection(details)),
                    SizedBox(width: 24.w),
                    Expanded(child: _buildServicesSection(details)),
                  ],
                )
              else ...[
                _buildInfoSection(details),
                SizedBox(height: 24.h),
                _buildServicesSection(details),
              ],
              SizedBox(height: 24.h),
              _buildMembersSection(details),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(AdminCompanyDetails details) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final company = details.company;
    final isMobile = AppBreakpoints.isMobile(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.1),
            AppTheme.primaryColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : AppTheme.primaryColor.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildCompanyLogo(company.logo),
          SizedBox(height: 16.h),
          Text(
            company.name,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              fontFamily: AppTheme.fontFamily,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12.h),
          StatusBadge(status: company.status),
          SizedBox(height: 16.h),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: isMobile ? 12.w : 20.w,
            runSpacing: 12.h,
            children: [
              _buildStatItem(
                'Tier',
                company.tier ?? 'Standard',
                Iconsax.medal_bold,
                AppTheme.accentColor,
              ),
              _buildStatItem(
                'Type',
                company.type ?? 'N/A',
                Iconsax.building_bold,
                AppTheme.primaryColor,
              ),
              _buildStatItem(
                'B2B',
                company.allowsB2B ? 'Yes' : 'No',
                Iconsax.tick_circle_bold,
                company.allowsB2B ? AppTheme.successColor : Colors.grey,
              ),
              _buildStatItem(
                'B2C',
                company.allowsB2C ? 'Yes' : 'No',
                Iconsax.tick_circle_bold,
                company.allowsB2C ? AppTheme.successColor : Colors.grey,
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: (600).ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildCompanyLogo(String? logo) {
    return Container(
      width: 80.w,
      height: 80.h,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        image: logo != null
            ? DecorationImage(image: NetworkImage(logo), fit: BoxFit.cover)
            : null,
      ),
      child: logo == null
          ? Icon(
              Iconsax.building_bold,
              color: AppTheme.primaryColor,
              size: 40.sp,
            )
          : null,
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 14.sp),
            SizedBox(width: 4.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.grey,
                fontFamily: AppTheme.fontFamily,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.bold,
            fontFamily: AppTheme.fontFamily,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(AdminCompanyDetails details) {
    final company = details.company;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AdminSectionHeader(
          title: 'Information',
          subtitle: 'Company location and contact details',
        ),
        _buildInfoTile(
          Iconsax.location_bold,
          'Address',
          company.address ?? 'No address provided',
        ),
        SizedBox(height: 12.h),
        _buildInfoTile(
          Iconsax.global_bold,
          'City',
          company.city?.name ?? 'N/A',
        ),
        SizedBox(height: 12.h),
        _buildInfoTile(
          Iconsax.calendar_bold,
          'Joined',
          company.createdAt?.substring(0, 10) ?? 'N/A',
        ),
        if (company.description != null && company.description!.isNotEmpty) ...[
          SizedBox(height: 12.h),
          _buildInfoTile(
            Iconsax.note_bold,
            'Description',
            company.description!,
          ),
        ],
      ],
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 24.sp),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey,
                    fontFamily: AppTheme.fontFamily,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: AppTheme.fontFamily,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesSection(AdminCompanyDetails details) {
    if (details.services.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AdminSectionHeader(
          title: 'Services',
          subtitle: 'Tap a service to toggle its status',
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: details.services.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: AppBreakpoints.adaptiveGridCount(
              context,
              mobile: 1,
              tablet: 1,
              desktop: 1,
            ),
            mainAxisSpacing: 12.h,
            crossAxisSpacing: 12.w,
            childAspectRatio: AppBreakpoints.isMobile(context) ? 1.9 : 2.5,
          ),
          itemBuilder: (context, index) {
            final service = details.services[index];
            return CompanyServiceCard(
              service: service,
              onToggle: service.status != null
                  ? () => _confirmToggleService(context, service)
                  : null,
            );
          },
        ),
      ],
    );
  }

  Widget _buildMembersSection(AdminCompanyDetails details) {
    if (details.members.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AdminSectionHeader(
          title: 'Team Members',
          subtitle: 'People associated with this company',
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: details.members.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: AppBreakpoints.adaptiveGridCount(
              context,
              mobile: 1,
              tablet: 2,
              desktop: 2,
            ),
            mainAxisSpacing: 12.h,
            crossAxisSpacing: 12.w,
            childAspectRatio: AppBreakpoints.isMobile(context) ? 3.0 : 3.4,
          ),
          itemBuilder: (context, index) =>
              MemberListItem(member: details.members[index]),
        ),
      ],
    );
  }

  void _showStatusUpdateForm(BuildContext context) {
    final state = ref.read(adminCompanyDetailsProvider);
    if (state.details == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CompanyStatusForm(
        currentStatus: state.details!.company.status,
        onSubmit: (status) {
          ref.read(adminCompanyDetailsProvider.notifier).updateStatus(status);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _confirmToggleService(BuildContext context, CompanyService service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ServiceReviewForm(
        service: service,
        onSubmit: (data) {
          ref
              .read(adminCompanyDetailsProvider.notifier)
              .toggleService(service.serviceCode, data);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Service reviewed successfully'),
              backgroundColor: AppTheme.successColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }
}
