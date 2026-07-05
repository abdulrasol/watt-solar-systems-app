import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/admin_page_scaffold.dart';

class AdminApiLabScreen extends StatelessWidget {
  const AdminApiLabScreen({super.key});

  static const _tools = [
    _ApiTool('Company Details', 'GET /api/v1/admin/companies/{id}/details', Iconsax.buildings, 'Inspect full company profile, services, and metadata.'),
    _ApiTool('Service Catalog', 'GET /api/v1/admin/companies/catalog/services', Iconsax.shop, 'Manage all service types available on the platform.'),
    _ApiTool('Offers API', 'GET /api/v1/offers/admin/offers', Iconsax.shop, 'List and manage all offers across companies.'),
    _ApiTool('Requests API', 'GET /api/v1/offers/admin/requests', Iconsax.task_square, 'Review and manage all offer requests.'),
    _ApiTool('Company Status', 'POST /api/v1/admin/companies/{id}/status', Iconsax.toggle_on, 'Activate, suspend, or verify companies.'),
    _ApiTool('Users', 'GET /api/v1/users', Iconsax.people, 'List and manage all platform users.'),
    _ApiTool('Feedbacks', 'GET /api/v1/admin/feedbacks', Iconsax.message, 'View and manage user feedback and reports.'),
    _ApiTool('Config', 'GET /api/v1/admin/config', Iconsax.setting, 'Manage application-level configuration values.'),
  ];

  @override
  Widget build(BuildContext context) {
    return AdminPageScaffold(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Row(
            children: [
              Icon(Iconsax.code, color: Theme.of(context).primaryColor),
              const SizedBox(width: 12),
              Text('API Lab', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text('Reference tool for exploring available admin API endpoints.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
          const SizedBox(height: 24),
          ..._tools.map((tool) => _ApiToolCard(tool: tool)),
        ],
      ),
    );
  }
}

class _ApiTool {
  final String name;
  final String endpoint;
  final IconData icon;
  final String description;
  const _ApiTool(this.name, this.endpoint, this.icon, this.description);
}

class _ApiToolCard extends StatelessWidget {
  final _ApiTool tool;
  const _ApiToolCard({required this.tool});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(tool.icon, color: Theme.of(context).primaryColor),
        title: Text(tool.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(tool.endpoint, style: TextStyle(fontSize: 11, fontFamily: 'monospace', color: Colors.grey[700])),
            ),
            const SizedBox(height: 4),
            Text(tool.description, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}
