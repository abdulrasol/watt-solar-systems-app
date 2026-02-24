import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_hub/features/systems/controllers/systems_controller.dart';
import 'package:solar_hub/features/systems/models/system_model.dart';
import 'package:solar_hub/controllers/company_controller.dart';
import 'package:solar_hub/utils/app_theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:solar_hub/features/systems/screens/system_form_page.dart';
import 'package:solar_hub/features/systems/screens/system_details_page.dart';
import 'package:solar_hub/features/company_dashboard/controllers/main_dashboard_controller.dart';

class SystemsPage extends StatefulWidget {
  const SystemsPage({super.key});

  @override
  State<SystemsPage> createState() => _SystemsPageState();
}

class _SystemsPageState extends State<SystemsPage> {
  final controller = Get.put(SystemsController());
  final companyController = Get.find<CompanyController>();
  final mainController = Get.find<MainDashboardController>();
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateActions();
      final companyId = companyController.company.value?.id;
      if (companyId != null) {
        controller.fetchCompanySystems(companyId);
      }
    });
  }

  void _updateActions() {
    final canManage = companyController.hasAnyRole(['owner', 'manager']);
    final companyId = companyController.company.value?.id;
    if (canManage) {
      mainController.actions.assignAll([
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => Get.to(() => SystemFormPage(isUserView: false, companyId: companyId)),
          tooltip: 'add_system'.tr,
        ),
      ]);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'search_systems'.tr,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
            ),
          ),
          Expanded(
            child: Obx(() {
              final canManage = companyController.hasAnyRole(['owner', 'manager']);

              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final filteredSystems = controller.companySystems.where((sys) {
                final notes = (sys.notes ?? '').toLowerCase();
                final owner = (sys.userName ?? '').toLowerCase();
                final city = (sys.city ?? '').toLowerCase();
                return notes.contains(_searchQuery) || owner.contains(_searchQuery) || city.contains(_searchQuery);
              }).toList();

              if (filteredSystems.isEmpty) {
                return Center(child: Text('no_data'.tr));
              }

              return RefreshIndicator(
                onRefresh: () async {
                  final companyId = companyController.company.value?.id;
                  if (companyId != null) {
                    await controller.fetchCompanySystems(companyId);
                  }
                },
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredSystems.length,
                  itemBuilder: (context, index) {
                    final system = filteredSystems[index];
                    return _buildSystemCard(context, system, canManage);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemCard(BuildContext context, SystemModel system, bool canManage) {
    final status = system.companyStatus;
    final ownerName = system.userName ?? 'not_assigned'.tr;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
          child: const Icon(FontAwesomeIcons.solarPanel, color: AppTheme.primaryColor, size: 24),
        ),
        title: Text(
          system.notes?.isNotEmpty == true ? system.notes! : "system_at".trParams({'city': system.city ?? 'N/A'}),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.bolt, size: 14, color: Colors.amber),
                const SizedBox(width: 4),
                Text('${system.pv.capacity * system.pv.count / 1000} kW'),
                const SizedBox(width: 12),
                const Icon(Icons.person, size: 14, color: Colors.blueGrey),
                const SizedBox(width: 4),
                Expanded(child: Text(ownerName, maxLines: 1, overflow: TextOverflow.ellipsis)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(child: _buildStatusChip(status)),
                if (status == 'pending' && canManage) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
                        onPressed: () => controller.updateStatus(system.id!, companyStatus: 'accepted'),
                        tooltip: 'approve'.tr,
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel_outlined, color: Colors.red, size: 20),
                        onPressed: () => controller.updateStatus(system.id!, companyStatus: 'rejected'),
                        tooltip: 'reject'.tr,
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'view') {
              Get.to(() => SystemDetailsPage(system: system, isCompanyView: true));
            } else if (value == 'edit') {
              Get.to(() => SystemFormPage(system: system, isUserView: false, companyId: system.installedBy));
            } else if (value == 'remove') {
              _confirmRemove(context, system.id!);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'view',
              child: Row(children: [const Icon(Icons.visibility), const SizedBox(width: 8), Text('view'.tr)]),
            ),
            if (canManage) ...[
              PopupMenuItem(
                value: 'edit',
                child: Row(children: [const Icon(Icons.edit), const SizedBox(width: 8), Text('edit'.tr)]),
              ),
              PopupMenuItem(
                value: 'remove',
                child: Row(
                  children: [
                    const Icon(Icons.delete, color: Colors.red),
                    const SizedBox(width: 8),
                    Text('remove'.tr),
                  ],
                ),
              ),
            ],
          ],
        ),
        onTap: () => Get.to(() => SystemDetailsPage(system: system, isCompanyView: true)),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label = status.tr;
    switch (status) {
      case 'accepted':
      case 'verified':
        color = Colors.green;
        label = 'verified'.tr;
        break;
      case 'rejected':
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
        label = 'pending'.tr;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _confirmRemove(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('confirm_remove_system'.tr),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('cancel'.tr)),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await controller.deleteSystem(id);
              if (context.mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('system_removed_success'.tr)));
              }
            },
            child: Text('remove'.tr, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
