import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:solar_hub/src/core/layout/app_breakpoints.dart';
import 'package:solar_hub/src/core/widgets/loading_widgets.dart';
import 'package:solar_hub/src/core/widgets/pre_scaffold.dart';
import 'package:solar_hub/src/features/admin/domain/models/service_request.dart';
import 'package:solar_hub/src/features/admin/presentation/controllers/admin_service_requests_controller.dart';
import 'package:solar_hub/src/features/admin/presentation/forms/service_review_form.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/service_request_card.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class AdminServiceRequestsScreen extends ConsumerStatefulWidget {
  const AdminServiceRequestsScreen({super.key});

  @override
  ConsumerState<AdminServiceRequestsScreen> createState() =>
      _AdminServiceRequestsScreenState();
}

class _AdminServiceRequestsScreenState
    extends ConsumerState<AdminServiceRequestsScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    Future.microtask(
      () => ref
          .read(adminServiceRequestsProvider.notifier)
          .fetchServiceRequests(isRefresh: true),
    );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(adminServiceRequestsProvider.notifier).fetchNextPage();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminServiceRequestsProvider);

    return PreScaffold(
      title: 'Service Requests',
      child: state.isLoading && state.requests.isEmpty
          ? _buildLoadingState()
          : RefreshIndicator(
              onRefresh: () => ref
                  .read(adminServiceRequestsProvider.notifier)
                  .fetchServiceRequests(isRefresh: true),
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

  Widget _buildContent(AdminServiceRequestsState state) {
    if (state.requests.isEmpty && !state.isLoading) {
      return AdminEmptyState(
        icon: Icons.business_center_outlined,
        title: 'No Pending Requests',
        subtitle: 'Company service requests will appear here.',
      );
    }

    return GridView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: AppBreakpoints.adaptiveGridCount(
          context,
          mobile: 1,
          tablet: 2,
          desktop: 2,
        ),
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: AppBreakpoints.isMobile(context) ? 1.45 : 1.65,
      ),
      itemCount: state.requests.length + (state.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.requests.length) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: LoadingWidget.widget(context: context, size: 25),
            ),
          );
        }

        final request = state.requests[index];
        return ServiceRequestCard(
              request: request,
              onReview: () => _showReviewForm(context, request),
            )
            .animate()
            .fadeIn(delay: (index % 10 * 50).ms)
            .slideY(begin: 0.1, end: 0);
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
            ref
                .read(adminServiceRequestsProvider.notifier)
                .reviewRequest(request.companyId!, request.serviceCode, data);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Service request reviewed successfully'),
                backgroundColor: AppTheme.successColor,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      ),
    );
  }
}
