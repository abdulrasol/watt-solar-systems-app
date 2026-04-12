import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_hub/src/features/admin/domain/models/service_request.dart';
import 'package:solar_hub/src/features/admin/presentation/controllers/admin_service_requests_controller.dart';
import 'package:solar_hub/src/features/admin/presentation/forms/service_review_form.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/admin_page_scaffold.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/service_request_card.dart';

class AdminServiceRequestsScreen extends ConsumerStatefulWidget {
  const AdminServiceRequestsScreen({super.key});

  @override
  ConsumerState<AdminServiceRequestsScreen> createState() => _AdminServiceRequestsScreenState();
}

class _AdminServiceRequestsScreenState extends ConsumerState<AdminServiceRequestsScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    Future.microtask(() => ref.read(adminServiceRequestsProvider.notifier).fetchServiceRequests(isRefresh: true));
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
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

    return AdminPageScaffold(
      child: state.isLoading && state.requests.isEmpty
          ? const AdminLoadingState(icon: Icons.work_outline_rounded, message: 'Loading requests...')
          : _buildContent(context, state),
    );
  }

  Widget _buildContent(BuildContext context, AdminServiceRequestsState state) {
    if (state.error != null && state.requests.isEmpty) {
      return AdminErrorState(error: state.error!, onRetry: () => ref.read(adminServiceRequestsProvider.notifier).fetchServiceRequests(isRefresh: true));
    }

    if (state.requests.isEmpty) {
      return const AdminEmptyState(icon: Icons.pending_actions_outlined, title: 'No service requests', subtitle: 'Incoming service requests will appear here.');
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(adminServiceRequestsProvider.notifier).fetchServiceRequests(isRefresh: true),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final columns = width >= 1180
              ? 3
              : width >= 760
              ? 2
              : 1;

          return GridView.builder(
            controller: _scrollController,
            itemCount: state.requests.length + (state.hasMore ? 1 : 0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: columns == 1 ? 1.42 : 1.34,
            ),
            itemBuilder: (context, index) {
              if (index == state.requests.length) {
                return const Center(child: CircularProgressIndicator());
              }

              final request = state.requests[index];
              return ServiceRequestCard(request: request, onReview: () => _showReviewForm(context, request));
            },
          );
        },
      ),
    );
  }

  void _showReviewForm(BuildContext context, ServiceRequest request) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ServiceReviewForm(
        request: request,
        onSubmit: (data) {
          if (request.companyId == null) return;
          ref.read(adminServiceRequestsProvider.notifier).reviewRequest(request.companyId!, request.serviceCode, data);
        },
      ),
    );
  }
}
