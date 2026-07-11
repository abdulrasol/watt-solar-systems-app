import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:watt/src/core/services/dio.dart';
import 'package:watt/src/core/models/response.dart' as api;
import 'package:watt/src/features/admin/presentation/widgets/admin_page_scaffold.dart';
import 'package:watt/src/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:watt/src/utils/app_urls.dart';
import 'package:watt/src/services/toast_service.dart';
import 'package:watt/src/utils/helper_methods.dart';
import 'package:watt/src/features/admin/presentation/widgets/dialogs/company_type_dialog.dart';

class AdminCompanyTypesScreen extends ConsumerStatefulWidget {
  const AdminCompanyTypesScreen({super.key});

  @override
  ConsumerState<AdminCompanyTypesScreen> createState() => _AdminCompanyTypesScreenState();
}

class _AdminCompanyTypesScreenState extends ConsumerState<AdminCompanyTypesScreen> {
  List<Map<String, dynamic>> _types = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchTypes();
  }

  Future<void> _fetchTypes() async {
    setState(() => _loading = true);
    try {
      final dio = DioService();
      final response = await dio.get(AppUrls.companyTypes, isPagination: true);
      final paginatedResponse = response as api.PaginationResponse;
      final items = (paginatedResponse.body as List?)?.map((e) => Map<String, dynamic>.from(e as Map)).toList() ?? [];
      setState(() {
        _types = items;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _showCompanyTypeDialog({Map<String, dynamic>? type}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => CompanyTypeDialog(type: type),
    );
    if (result == true) {
      _fetchTypes();
    }
  }

  Future<void> _confirmDelete(Map<String, dynamic> type) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Company Type'),
        content: Text('Are you sure you want to delete ${type['name']}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _loading = true);
      try {
        final dio = DioService();
        await dio.delete(AppUrls.adminCompanyType(type['id'] as int));
        if (mounted) ToastService.success(context, 'Success', 'Company type deleted successfully');
        _fetchTypes();
      } catch (e) {
        dPrint('Error deleting company type: $e', tag: 'AdminCompanyTypesScreen');
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminPageScaffold(
      actions: [
        FilledButton.icon(
          onPressed: () => _showCompanyTypeDialog(),
          icon: const Icon(Iconsax.add),
          label: const Text('Add'),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Row(
              children: [
                Icon(Iconsax.category, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                Text('Company Types', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Manage company types allowed in the system.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
          ),
          const SizedBox(height: 16),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const AdminLoadingState(icon: Iconsax.category, message: 'Loading types...');
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Error: $_error', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            ElevatedButton.icon(onPressed: _fetchTypes, icon: const Icon(Iconsax.refresh), label: const Text('Retry')),
          ],
        ),
      );
    }
    if (_types.isEmpty) return const AdminEmptyState(icon: Iconsax.category, title: 'No company types found');

    return RefreshIndicator(
      onRefresh: _fetchTypes,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _types.length,
        itemBuilder: (context, index) {
          final type = _types[index];
          final services = (type['allowed_services'] as List?)?.map((e) => Map<String, dynamic>.from(e as Map)).toList() ?? [];
          final plans = (type['allowed_subscription_plans'] as List?)?.map((e) => Map<String, dynamic>.from(e as Map)).toList() ?? [];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ExpansionTile(
              leading: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    _getInitials(type['code']?.toString()),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              title: Text(type['name']?.toString() ?? 'Unnamed'),
              subtitle: Text('${services.length} services | ${plans.length} plans'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showCompanyTypeDialog(type: type);
                      } else if (value == 'delete') {
                        _confirmDelete(type);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                  const Icon(Icons.keyboard_arrow_down),
                ],
              ),
              children: [
                if (services.isNotEmpty) ...[
                  Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 4), child: Align(alignment: Alignment.centerLeft, child: Text('Services:', style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).primaryColor)))),
                  ...services.map((s) => ListTile(
                    dense: true,
                    leading: Icon(Iconsax.buildings, size: 18, color: Theme.of(context).primaryColor),
                    title: Text(s['name']?.toString() ?? '', style: const TextStyle(fontSize: 13)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 32),
                  )),
                ],
                if (plans.isNotEmpty) ...[
                  Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 4), child: Align(alignment: Alignment.centerLeft, child: Text('Subscription Plans:', style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).primaryColor)))),
                  ...plans.map((p) => ListTile(
                    dense: true,
                    leading: Icon(Iconsax.crown, size: 18, color: Theme.of(context).primaryColor),
                    title: Text(p['name']?.toString() ?? '', style: const TextStyle(fontSize: 13)),
                    subtitle: p['price'] != null ? Text('\$${p['price']}', style: const TextStyle(fontSize: 11)) : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 32),
                  )),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  String _getInitials(String? code) {
    if (code == null || code.trim().isEmpty) return '?';
    final trimmed = code.trim();
    return trimmed.length >= 2 ? trimmed.substring(0, 2).toUpperCase() : trimmed.toUpperCase();
  }
}

