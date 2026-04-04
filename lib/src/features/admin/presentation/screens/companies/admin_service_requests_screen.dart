import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/src/core/widgets/loading_widgets.dart';
import 'package:solar_hub/src/features/admin/domain/models/service_request.dart';
import 'package:solar_hub/src/features/admin/presentation/controllers/admin_service_requests_controller.dart';
import 'package:solar_hub/src/features/admin/presentation/forms/service_review_form.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/service_request_card.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class AdminServiceRequestsScreen extends ConsumerStatefulWidget {
  const AdminServiceRequestsScreen({super.key});

  @override
  ConsumerState<AdminServiceRequestsScreen> createState() => _AdminServiceRequestsScreenState();
}

class _AdminServiceRequestsScreenState extends ConsumerState<AdminServiceRequestsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(adminServiceRequestsProvider.notifier).fetchServiceRequests());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminServiceRequestsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Service Requests',
          style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.bold, fontSize: 18.sp),
        ),
        centerTitle: true,
      ),
      body: state.isLoading && state.requests.isEmpty
          ? _buildLoadingState()
          : RefreshIndicator(
              onRefresh: () => ref.read(adminServiceRequestsProvider.notifier).fetchServiceRequests(),
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
            'Loading Requests...',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey, fontFamily: AppTheme.fontFamily),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(AdminServiceRequestsState state) {
    if (state.requests.isEmpty && !state.isLoading) {
      return AdminEmptyState(icon: Iconsax.briefcase_bold, title: 'No Pending Requests', subtitle: 'Company service requests will appear here.');
    }

    return ListView.separated(
      padding: EdgeInsets.all(20.w),
      itemCount: state.requests.length,
      separatorBuilder: (context, index) => SizedBox(height: 16.h),
      itemBuilder: (context, index) {
        final request = state.requests[index];
        return ServiceRequestCard(
          request: request,
          onReview: () => _showReviewForm(context, request),
        ).animate().fadeIn(delay: (index * 50).ms).slideY(begin: 0.1, end: 0);
      },
    );
  }

  void _showReviewForm(BuildContext context, ServiceRequest request) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ServiceReviewForm(
        request: request,
        onSubmit: (data) {
          if (request.companyId != null) {
            ref.read(adminServiceRequestsProvider.notifier).reviewRequest(request.companyId!, request.serviceCode, data);
          }
        },
      ),
    );
  }
}
