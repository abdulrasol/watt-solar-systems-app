import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/features/admin/controllers/admin_companies_controller.dart';
import 'package:solar_hub/models/company_model.dart';
import 'package:solar_hub/features/store/widgets/store_image.dart';

class AdminCompaniesPage extends StatelessWidget {
  const AdminCompaniesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminCompaniesController());

    return Column(
      children: [
        // Filter Chips
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).cardColor,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Obx(
              () => Row(
                children: [
                  _buildFilterChip(context, controller, 'pending', 'Pending', Colors.orange),
                  const SizedBox(width: 8),
                  _buildFilterChip(context, controller, 'active', 'Active', Colors.green),
                  const SizedBox(width: 8),
                  _buildFilterChip(context, controller, 'rejected', 'Rejected', Colors.red),
                  const SizedBox(width: 8),
                  _buildFilterChip(context, controller, 'all', 'All', Colors.blueGrey),
                ],
              ),
            ),
          ),
        ),
        const Divider(height: 1),

        // Company List
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.companies.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.business_outlined, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text('No companies found', style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.companies.length,
              itemBuilder: (context, index) {
                final company = controller.companies[index];
                return _buildCompanyCard(context, controller, company);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildFilterChip(BuildContext context, AdminCompaniesController controller, String value, String label, Color color) {
    final isSelected = controller.filterStatus.value == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => controller.setFilter(value),
      backgroundColor: Colors.transparent,
      selectedColor: color.withValues(alpha: 0.2),
      checkmarkColor: color,
      labelStyle: TextStyle(color: isSelected ? color : Colors.grey[600], fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
      side: BorderSide(color: isSelected ? color : Colors.grey[300]!),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildCompanyCard(BuildContext context, AdminCompaniesController controller, CompanyModel company) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showCompanyDetails(context, controller, company),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  StoreImage(url: company.logoUrl, isCircle: true, width: 50, height: 50),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(company.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(company.tier.name.toUpperCase(), style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                  _buildStatusBadge(company.status),
                ],
              ),
              if (company.description != null && company.description!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  company.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
              const SizedBox(height: 16),
              const Divider(),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // Chat / Contact
                  TextButton.icon(
                    onPressed: () => controller.contactOwner(company.id),
                    icon: const Icon(Iconsax.call_bold, size: 18),
                    label: const Text("Contact"),
                    style: TextButton.styleFrom(foregroundColor: Colors.blueGrey, padding: const EdgeInsets.symmetric(horizontal: 12)),
                  ),

                  // Actions (Only for Pending or Rejected/Active switching if needed)
                  if (company.status == 'pending') ...[
                    OutlinedButton.icon(
                      onPressed: () => controller.rejectCompany(company.id),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text("Reject"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => controller.approveCompany(company.id),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text("Approve"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  ] else if (company.status == 'rejected') ...[
                    TextButton(
                      onPressed: () => controller.approveCompany(company.id),
                      child: const Text("Reconsider", style: TextStyle(color: Colors.green)),
                    ),
                  ] else ...[
                    TextButton(
                      onPressed: () => controller.rejectCompany(company.id),
                      child: const Text("Suspend", style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCompanyDetails(BuildContext context, AdminCompaniesController controller, CompanyModel company) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                StoreImage(url: company.logoUrl, isCircle: true, width: 60, height: 60),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(company.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text("ID: ${company.id.substring(0, 8)}...", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    ],
                  ),
                ),
                _buildStatusBadge(company.status),
              ],
            ),
            const SizedBox(height: 24),
            const Text("Statistics", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            FutureBuilder<Map<String, int>>(
              future: controller.getCompanyStats(company.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final stats = snapshot.data ?? {'members': 0, 'products': 0, 'orders': 0, 'systems': 0};
                return GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  childAspectRatio: 2.1,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildStatItem(context, 'Members', stats['members']!, Iconsax.people_bold, Colors.blue),
                    _buildStatItem(context, 'Products', stats['products']!, Iconsax.box_bold, Colors.orange),
                    _buildStatItem(context, 'Orders', stats['orders']!, Iconsax.shopping_cart_bold, Colors.purple),
                    _buildStatItem(context, 'Systems', stats['systems']!, Iconsax.flash_bold, Colors.yellow[800]!),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildStatItem(BuildContext context, String title, int count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(count.toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'active':
        color = Colors.green;
        break;
      case 'rejected':
        color = Colors.red;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10),
      ),
    );
  }
}
