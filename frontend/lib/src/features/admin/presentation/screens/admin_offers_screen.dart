import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:solar_hub/src/core/services/dio.dart';
import 'package:solar_hub/src/core/models/response.dart' as api;
import 'package:solar_hub/src/features/admin/presentation/widgets/admin_page_scaffold.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:solar_hub/src/utils/app_urls.dart';

class AdminOffersScreen extends ConsumerStatefulWidget {
  const AdminOffersScreen({super.key});

  @override
  ConsumerState<AdminOffersScreen> createState() => _AdminOffersScreenState();
}

class _AdminOffersScreenState extends ConsumerState<AdminOffersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _offersLoading = false;
  bool _requestsLoading = false;
  String? _offersError;
  String? _requestsError;
  List<dynamic> _offers = [];
  List<dynamic> _requests = [];
  final ScrollController _offersScroll = ScrollController();
  final ScrollController _requestsScroll = ScrollController();
  int _offersPage = 1;
  int _requestsPage = 1;
  bool _hasMoreOffers = true;
  bool _hasMoreRequests = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchOffers();
    _fetchRequests();
    _offersScroll.addListener(_onOffersScroll);
    _requestsScroll.addListener(_onRequestsScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _offersScroll.dispose();
    _requestsScroll.dispose();
    super.dispose();
  }

  void _onOffersScroll() {
    if (_offersScroll.position.pixels >= _offersScroll.position.maxScrollExtent - 200 && _hasMoreOffers && !_offersLoading) {
      _offersPage++;
      _fetchOffers();
    }
  }

  void _onRequestsScroll() {
    if (_requestsScroll.position.pixels >= _requestsScroll.position.maxScrollExtent - 200 && _hasMoreRequests && !_requestsLoading) {
      _requestsPage++;
      _fetchRequests();
    }
  }

  Future<void> _fetchOffers({bool refresh = false}) async {
    if (refresh) {
      _offersPage = 1;
      _hasMoreOffers = true;
      _offers = [];
    }
    setState(() => _offersLoading = true);
    try {
      final dio = DioService();
      final response = await dio.get(AppUrls.adminOffers, queryParameters: {'page': _offersPage, 'page_size': 12}, isPagination: true);
      final paginated = response as api.PaginationResponse;
      final items = paginated.body ?? [];
      setState(() {
        _offers.addAll(items);
        _hasMoreOffers = items.length >= 12;
        _offersLoading = false;
        _offersError = null;
      });
    } catch (e) {
      setState(() {
        _offersError = e.toString();
        _offersLoading = false;
      });
    }
  }

  Future<void> _fetchRequests({bool refresh = false}) async {
    if (refresh) {
      _requestsPage = 1;
      _hasMoreRequests = true;
      _requests = [];
    }
    setState(() => _requestsLoading = true);
    try {
      final dio = DioService();
      final response = await dio.get(AppUrls.adminRequests, queryParameters: {'page': _requestsPage, 'page_size': 12}, isPagination: true);
      final paginated = response as api.PaginationResponse;
      final items = paginated.body ?? [];
      setState(() {
        _requests.addAll(items);
        _hasMoreRequests = items.length >= 12;
        _requestsLoading = false;
        _requestsError = null;
      });
    } catch (e) {
      setState(() {
        _requestsError = e.toString();
        _requestsLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminPageScaffold(
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Iconsax.shop), text: 'Offers'),
              Tab(icon: Icon(Iconsax.task_square), text: 'Requests'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOffersTab(),
                _buildRequestsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOffersTab() {
    if (_offersLoading && _offers.isEmpty) return const AdminLoadingState(icon: Iconsax.shop, message: 'Loading offers...');
    if (_offersError != null && _offers.isEmpty) return Center(child: Padding(padding: EdgeInsets.all(16), child: Text(_offersError!, style: const TextStyle(color: Colors.red))));
    if (_offers.isEmpty) return const AdminEmptyState(icon: Iconsax.shop, title: 'No offers found');

    return RefreshIndicator(
      onRefresh: () => _fetchOffers(refresh: true),
      child: ListView.builder(
        controller: _offersScroll,
        padding: const EdgeInsets.all(16),
        itemCount: _offers.length + (_hasMoreOffers ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _offers.length) return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()));
          final offer = _offers[index] as Map<String, dynamic>;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Icon(Iconsax.shop, color: Theme.of(context).primaryColor),
              title: Text(offer['company_name']?.toString() ?? 'Offer #${offer['id']}'),
              subtitle: Text('Status: ${offer['status'] ?? 'N/A'}'),
              trailing: Text('\$${offer['price'] ?? '0'}', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRequestsTab() {
    if (_requestsLoading && _requests.isEmpty) return const AdminLoadingState(icon: Iconsax.task_square, message: 'Loading requests...');
    if (_requestsError != null && _requests.isEmpty) return Center(child: Padding(padding: EdgeInsets.all(16), child: Text(_requestsError!, style: const TextStyle(color: Colors.red))));
    if (_requests.isEmpty) return const AdminEmptyState(icon: Iconsax.task_square, title: 'No requests found');

    return RefreshIndicator(
      onRefresh: () => _fetchRequests(refresh: true),
      child: ListView.builder(
        controller: _requestsScroll,
        padding: const EdgeInsets.all(16),
        itemCount: _requests.length + (_hasMoreRequests ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _requests.length) return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()));
          final request = _requests[index] as Map<String, dynamic>;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Icon(Iconsax.task_square, color: Theme.of(context).primaryColor),
              title: Text(request['user_name']?.toString() ?? 'Request #${request['id']}'),
              subtitle: Text('Status: ${request['status'] ?? 'N/A'}'),
              trailing: Chip(label: Text(request['status'] ?? 'N/A', style: const TextStyle(fontSize: 11))),
            ),
          );
        },
      ),
    );
  }
}
