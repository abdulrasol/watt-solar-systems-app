import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:watt/src/features/admin/presentation/widgets/admin_page_scaffold.dart';


class AdminSubscriptionRequestsScreen extends StatelessWidget {
  const AdminSubscriptionRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminPageScaffold(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Iconsax.tree, size: 64, color: Theme.of(context).primaryColor.withAlpha(76)),
              const SizedBox(height: 24),
              Text('Subscription Requests', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(
                'This feature is not yet available as a REST API.\n'
                'Subscription requests can be managed via the Django admin panel:\n'
                'Admin → Config → Subscription Requests',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Iconsax.external_drive),
                label: const Text('Open Django Admin'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
