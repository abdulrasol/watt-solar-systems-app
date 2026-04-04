import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/src/core/widgets/loading_widgets.dart';
import 'package:solar_hub/src/features/admin/domain/models/admin_company_details.dart';
import 'package:solar_hub/src/features/admin/presentation/controllers/admin_company_details_controller.dart';
import 'package:solar_hub/src/features/admin/presentation/forms/company_status_form.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/admin_section_header.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/company_service_card.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/member_list_item.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class AdminCompanyDetailsScreen extends ConsumerStatefulWidget {
  final int companyId;
  const AdminCompanyDetailsScreen({super.key, required this.companyId});

  @override
  ConsumerState<AdminCompanyDetailsScreen> createState() => _AdminCompanyDetailsScreenState();
}

class _AdminCompanyDetailsScreenState extends ConsumerState<AdminCompanyDetailsScreen> {
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

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Company Details',
          style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.bold, fontSize: 18.sp),
        ),
        actions: [
          if (state.details != null)
            IconButton(
              icon: Icon(Iconsax.edit_bold, color: AppTheme.primaryColor, size: 24.sp),
              onPressed: () => _showStatusUpdateForm(context),
            ),
        ],
      ),
      body: state.isLoading && state.details == null
          ? _buildLoadingState()
          : state.error != null
          ? AdminErrorState(error: state.error!, onRetry: () => ref.read(adminCompanyDetailsProvider.notifier).fetchDetails())
          : RefreshIndicator(
              onRefresh: () => ref.read(adminCompanyDetailsProvider.notifier).fetchDetails(),
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
            style: TextStyle(fontSize: 14.sp, color: Colors.grey, fontFamily: AppTheme.fontFamily),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(AdminCompanyDetailsState state) {
    final details = state.details;
    if (details == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderSection(details),
          SizedBox(height: 32.h),
          _buildInfoSection(details),
          SizedBox(height: 32.h),
          _buildServicesSection(details),
          SizedBox(height: 32.h),
          _buildMembersSection(details),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(AdminCompanyDetails details) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final company = details.company;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : AppTheme.primaryColor.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.1), blurRadius: 20, offset: Offset(0, 10.h))],
      ),
      child: Column(
        children: [
          _buildCompanyLogo(company.logo),
          SizedBox(height: 16.h),
          Text(
            company.name,
            style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, fontFamily: AppTheme.fontFamily),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          _buildStatusBadge(company.status),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatItem('Tier', company.tier ?? 'Standard', Iconsax.medal_bold, Colors.orange),
              Container(
                width: 1.w,
                height: 30.h,
                color: Colors.grey.withOpacity(0.2),
                margin: EdgeInsets.symmetric(horizontal: 20.w),
              ),
              _buildStatItem('Type', company.type ?? 'N/A', Iconsax.building_bold, AppTheme.primaryColor),
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
        color: AppTheme.primaryColor.withOpacity(0.1),
        shape: BoxShape.circle,
        image: logo != null ? DecorationImage(image: NetworkImage(logo), fit: BoxFit.cover) : null,
      ),
      child: logo == null ? Icon(Iconsax.building_bold, color: AppTheme.primaryColor, size: 40.sp) : null,
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'active':
        color = Colors.green;
        break;
      case 'pending':
        color = AppTheme.warningColor;
        break;
      case 'rejected':
        color = AppTheme.errorColor;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8.w,
            height: 8.h,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 8.w),
          Text(
            status.toUpperCase(),
            style: TextStyle(color: color, fontSize: 12.sp, fontWeight: FontWeight.bold, fontFamily: AppTheme.fontFamily),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16.sp),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey, fontFamily: AppTheme.fontFamily),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, fontFamily: AppTheme.fontFamily),
        ),
      ],
    );
  }

  Widget _buildInfoSection(AdminCompanyDetails details) {
    final company = details.company;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AdminSectionHeader(title: 'Information', subtitle: 'Company location and contact details'),
        _buildInfoTile(Iconsax.location_bold, 'Address', company.address ?? 'No address provided'),
        SizedBox(height: 12.h),
        _buildInfoTile(Iconsax.global_bold, 'City', company.cityName ?? 'Unknown City'),
        SizedBox(height: 12.h),
        _buildInfoTile(Iconsax.calendar_bold, 'Joined', company.createdAt?.substring(0, 10) ?? 'N/A'),
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
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.1)),
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
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey, fontFamily: AppTheme.fontFamily),
                ),
                Text(
                  value,
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, fontFamily: AppTheme.fontFamily),
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
        const AdminSectionHeader(title: 'Active Services', subtitle: 'Global services enabled for this company'),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: details.services.length,
          separatorBuilder: (context, index) => SizedBox(height: 12.h),
          itemBuilder: (context, index) => CompanyServiceCard(service: details.services[index]),
        ),
      ],
    );
  }

  Widget _buildMembersSection(AdminCompanyDetails details) {
    if (details.members.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AdminSectionHeader(title: 'Team Members', subtitle: 'People associated with this company'),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: details.members.length,
          separatorBuilder: (context, index) => SizedBox(height: 12.h),
          itemBuilder: (context, index) => MemberListItem(member: details.members[index]),
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
        },
      ),
    );
  }
}
