import 'package:flutter/material.dart';
import 'package:watt/src/core/di/get_it.dart';
import 'package:watt/src/core/widgets/branded_empty_state.dart';
import 'package:watt/src/features/admin/domain/repositories/admin_repository.dart';
import 'package:watt/src/features/admin/presentation/widgets/admin_page_scaffold.dart';
import 'package:watt/src/features/company_dashboard/domain/entities/company_subscription_request.dart';
import 'package:watt/src/features/admin/presentation/widgets/cards/subscription_request_card.dart';

class AdminSubscriptionRequestsScreen extends StatefulWidget {
  const AdminSubscriptionRequestsScreen({super.key});

  @override
  State<AdminSubscriptionRequestsScreen> createState() => _AdminSubscriptionRequestsScreenState();
}

class _AdminSubscriptionRequestsScreenState extends State<AdminSubscriptionRequestsScreen> {
  final _adminRepository = getIt<AdminRepository>();
  final ScrollController _scrollController = ScrollController();
  final int _pageSize = 12;

  String? _selectedStatus;
  final List<CompanySubscriptionRequest> _requests = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && !_isLoading && _hasMore) {
        _fetchRequests();
      }
    });
  }

  Future<void> _fetchRequests({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _requests.clear();
    }

    if (!_hasMore || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newItems = await _adminRepository.listSubscriptionRequests(status: _selectedStatus, page: _currentPage, pageSize: _pageSize);

      setState(() {
        if (newItems.length < _pageSize) {
          _hasMore = false;
        }
        _requests.addAll(newItems);
        _currentPage++;
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load requests: $error')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onStatusChanged(String? newStatus) {
    if (_selectedStatus == newStatus) return;
    setState(() {
      _selectedStatus = newStatus;
    });
    _fetchRequests(refresh: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminPageScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              spacing: 8.0,
              children: [
                ChoiceChip(label: const Text('All'), selected: _selectedStatus == null, onSelected: (selected) => _onStatusChanged(null)),
                ChoiceChip(label: const Text('Pending'), selected: _selectedStatus == 'pending', onSelected: (selected) => _onStatusChanged('pending')),
                ChoiceChip(label: const Text('Active'), selected: _selectedStatus == 'active', onSelected: (selected) => _onStatusChanged('active')),
                ChoiceChip(label: const Text('Rejected'), selected: _selectedStatus == 'rejected', onSelected: (selected) => _onStatusChanged('rejected')),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _fetchRequests(refresh: true),
              child: _requests.isEmpty && !_isLoading
                  ? ListView(
                      children: const [
                        SizedBox(height: 100),
                        BrandedEmptyState(icon: Icons.list_alt, title: 'No Requests'),
                      ],
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      itemCount: _requests.length + (_isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _requests.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final item = _requests[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: SubscriptionRequestCard(request: item, onStatusUpdated: () => _fetchRequests(refresh: true)),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
