import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:watt/src/core/services/dio.dart';
import 'package:watt/src/core/models/response.dart' as api;
import 'package:watt/src/features/admin/presentation/widgets/admin_page_scaffold.dart';
import 'package:watt/src/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:watt/src/utils/app_urls.dart';

class AdminCompanyInspectorScreen extends ConsumerStatefulWidget {
  const AdminCompanyInspectorScreen({super.key});

  @override
  ConsumerState<AdminCompanyInspectorScreen> createState() => _AdminCompanyInspectorScreenState();
}

class _AdminCompanyInspectorScreenState extends ConsumerState<AdminCompanyInspectorScreen> {
  List<Map<String, dynamic>> _companies = [];
  bool _loading = false;
  bool _initialLoading = true;
  String? _error;
  final TextEditingController _searchCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  int _page = 1;
  bool _hasMore = true;

  Map<String, dynamic>? _selectedCompany;
  Map<String, dynamic>? _companyDetails;
  List<Map<String, dynamic>> _companyServices = [];
  bool _detailsLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCompanies();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200 && _hasMore && !_loading) {
      _page++;
      _fetchCompanies();
    }
  }

  Future<void> _fetchCompanies({bool refresh = false}) async {
    if (refresh) {
      _page = 1;
      _hasMore = true;
      _companies = [];
    }
    setState(() => _loading = true);
    try {
      final dio = DioService();
      final response = await dio.get(
        AppUrls.companies,
        queryParameters: {
          'page': _page,
          'page_size': 12,
          if (_searchCtrl.text.isNotEmpty) 'search': _searchCtrl.text,
        },
        isPagination: true,
      );
      final paginated = response as api.PaginationResponse;
      final List<dynamic> bodyList = (paginated.body as List?) ?? [];
      final items = bodyList.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      setState(() {
        _companies.addAll(items);
        _hasMore = items.length >= 12;
        _loading = false;
        _initialLoading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
        _initialLoading = false;
      });
    }
  }

  Future<void> _inspectCompany(Map<String, dynamic> company) async {
    setState(() {
      _selectedCompany = company;
      _detailsLoading = true;
      _companyDetails = null;
      _companyServices = [];
    });
    try {
      final dio = DioService();
      final id = company['id'] as int;
      final detailsResp = await dio.get(AppUrls.companyAdminDetails(id));
      final details = detailsResp as api.Response;
      final servicesResp = await dio.get(AppUrls.companyAdminServices(id), isPagination: true);
      final servicesPaginated = servicesResp as api.PaginationResponse;
      setState(() {
        _companyDetails = details.body is Map ? Map<String, dynamic>.from(details.body as Map) : null;
        final List<dynamic> servicesList = (servicesPaginated.body as List?) ?? [];
        _companyServices = servicesList.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        _detailsLoading = false;
      });
    } catch (e) {
      setState(() {
        _detailsLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminPageScaffold(
      child: _selectedCompany == null ? _buildCompanyList() : _buildInspectorView(),
    );
  }

  Widget _buildCompanyList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Search companies...',
              prefixIcon: const Icon(Iconsax.search_normal),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchCtrl.clear(); _fetchCompanies(refresh: true); })
                  : null,
            ),
            onSubmitted: (_) => _fetchCompanies(refresh: true),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(child: _buildListBody()),
      ],
    );
  }

  Widget _buildListBody() {
    if (_initialLoading) return const AdminLoadingState(icon: Iconsax.buildings, message: 'Loading companies...');
    if (_error != null && _companies.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Error: $_error', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            ElevatedButton.icon(onPressed: () => _fetchCompanies(refresh: true), icon: const Icon(Iconsax.refresh), label: const Text('Retry')),
          ],
        ),
      );
    }
    if (_companies.isEmpty) return const AdminEmptyState(icon: Iconsax.buildings, title: 'No companies found');

    return RefreshIndicator(
      onRefresh: () => _fetchCompanies(refresh: true),
      child: ListView.builder(
        controller: _scrollCtrl,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _companies.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _companies.length) return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()));
          final company = _companies[index];
          final name = company['name']?.toString() ?? 'Company #${company['id']}';
          final status = company['status']?.toString() ?? 'N/A';
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(backgroundColor: Theme.of(context).primaryColor.withAlpha(25), child: Icon(Iconsax.buildings, color: Theme.of(context).primaryColor)),
              title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('Status: $status | ID: ${company['id']}'),
              trailing: Icon(Iconsax.arrow_right, color: Theme.of(context).primaryColor),
              onTap: () => _inspectCompany(company),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInspectorView() {
    final company = _selectedCompany!;
    final name = company['name']?.toString() ?? 'Company #${company['id']}';
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Iconsax.arrow_left),
                onPressed: () => setState(() => _selectedCompany = null),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
              ),
              Chip(label: Text(company['status']?.toString() ?? 'N/A', style: const TextStyle(fontSize: 11))),
            ],
          ),
        ),
        const Divider(),
        Expanded(child: _buildDetailsBody()),
      ],
    );
  }

  Widget _buildDetailsBody() {
    if (_detailsLoading) return const AdminLoadingState(icon: Iconsax.buildings, message: 'Loading details...');

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_companyDetails != null) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Details', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ..._companyDetails!.entries.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 140, child: Text('${e.key}:', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey))),
                        Expanded(child: Text('${e.value ?? 'N/A'}')),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        Text('Services (${_companyServices.length})', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (_companyServices.isEmpty)
          const AdminEmptyState(icon: Iconsax.shop, title: 'No services found')
        else
          ..._companyServices.map((s) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Icon(Iconsax.buildings, color: Theme.of(context).primaryColor),
              title: Text(s['name']?.toString() ?? 'Service #${s['id']}'),
              subtitle: Text('Status: ${s['status'] ?? 'N/A'}'),
            ),
          )),
      ],
    );
  }
}
