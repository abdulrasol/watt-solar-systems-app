// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:icons_plus/icons_plus.dart';
// import 'package:solar_hub/controllers/company_controller.dart';
// import 'package:solar_hub/core/di/get_it.dart';
// import 'package:solar_hub/features/auth/presentation/controllers/auth_controller.dart';
// import 'package:solar_hub/utils/app_theme.dart';
// import 'package:solar_hub/layouts/company/systems/company_systems_page.dart';
// import 'package:solar_hub/features/company_dashboard/controllers/main_dashboard_controller.dart';
// import 'package:cached_network_image/cached_network_image.dart';

// class CompanyProfilePage extends StatefulWidget {
//   final String companyId;

//   const CompanyProfilePage({super.key, required this.companyId});

//   @override
//   State<CompanyProfilePage> createState() => _CompanyProfilePageState();
// }

// class _CompanyProfilePageState extends State<CompanyProfilePage> {
//   final AuthController controller = getIt<AuthController>();
//   final CompanyController companyController = getIt<CompanyController>();

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Obx(() {
//       if (controller.user.value?.isCompanyMember ?? false) {
//         return const Center(child: CircularProgressIndicator());
//       }
//       final company = companyController.company.value;

//       return Scaffold(
//         backgroundColor: Colors.transparent,
//         body: SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               const SizedBox(height: 20),
//               // Company Logo
//               Container(
//                 padding: const EdgeInsets.all(4),
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   border: Border.all(color: AppTheme.primaryColor, width: 2),
//                 ),
//                 child: CircleAvatar(
//                   radius: 60,
//                   //   backgroundImage: (company?.logo != null && company?.logo.isNotEmpty) ? CachedNetworkImageProvider(company!.logo!) : null,
//                   // backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[200],
//                   child: (company?.logo == null || company?.logo.isEmpty) ? Icon(Iconsax.building_bold, size: 50, color: Colors.grey[600]) : null,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               // Company Name
//               Text(company?.name ?? '', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 8),
//               // Description
//               if (company?.description.isNotEmpty ?? false)
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 32),
//                   child: Text(
//                     company.description,
//                     textAlign: TextAlign.center,
//                     style: TextStyle(color: Colors.grey[600]),
//                   ),
//                 ),
//               const SizedBox(height: 32),
//               // Stats Cards
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Wrap(
//                   spacing: 12,
//                   runSpacing: 12,
//                   alignment: WrapAlignment.center,
//                   children: [
//                     _buildStatCard(
//                       icon: Iconsax.people_bold,
//                       label: 'members'.tr,
//                       value: '10', // TODO need to get value from api
//                       onTap: () => _navigateTo(10, 'members'),
//                     ),
//                     _buildStatCard(
//                       icon: Iconsax.setting_2_bold,
//                       label: 'systems'.tr,
//                       value: '12', // TODO need to get value from api
//                       onTap: () => Get.to(() => CompanySystemsPage(companyId: widget.companyId)),
//                     ),
//                     _buildStatCard(
//                       icon: Iconsax.box_bold,
//                       label: 'products'.tr,
//                       value: '12', // TODO need to get value from api
//                       onTap: _hasPermission(['owner', 'manager', 'inventory_manager', 'installer']) ? () => _navigateTo(4, 'inventory') : null,
//                     ),
//                     _buildStatCard(
//                       icon: Iconsax.shopping_cart_bold,
//                       label: 'orders'.tr,
//                       value: '12', // TODO need to get value from api
//                       onTap: _hasPermission(['owner', 'manager', 'sales', 'accountant']) ? () => _navigateTo(6, 'orders') : null,
//                     ),
//                     _buildStatCard(
//                       icon: Iconsax.profile_2user_bold,
//                       label: 'customers'.tr,
//                       value: '12', // TODO need to get value from api
//                       onTap: _hasPermission(['owner', 'manager', 'sales', 'accountant']) ? () => _navigateTo(12, 'customers') : null,
//                     ),
//                     _buildStatCard(
//                       icon: Icons.local_shipping,
//                       label: 'Delivery Rules',
//                       value: '', // TODO need to get value from api
//                       onTap: _hasPermission(['owner', 'manager']) ? () => _navigateTo(15, 'delivery') : null,
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 32),

//               // Contact Info
//               // if ((company.address != null && company.address!.isNotEmpty) || (company != null && company.contactPhone!.isNotEmpty)) ...[ TODO
//               if ((company.address != null && company.address!.isNotEmpty)) ...[
//                 _buildSectionHeader('contact_info'.tr),
//                 const SizedBox(height: 12),
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[900] : Colors.white,
//                     borderRadius: BorderRadius.circular(12),
//                     boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5)],
//                   ),
//                   child: Column(
//                     children: [
//                       if (company.address != null && company.address!.isNotEmpty)
//                         ListTile(
//                           contentPadding: EdgeInsets.zero,
//                           leading: Container(
//                             padding: const EdgeInsets.all(10),
//                             decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.1), shape: BoxShape.circle),
//                             child: const Icon(Iconsax.location_bold, color: AppTheme.primaryColor, size: 20),
//                           ),
//                           title: Text('address'.tr, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
//                           subtitle: Text(company.address!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
//                         ),
//                       //    if (company.address != null && company.address!.isNotEmpty && company.contactPhone != null && company.contactPhone!.isNotEmpty)
//                       //     Divider(height: 24, color: Colors.grey.withValues(alpha: 0.1)),
//                       //     if (company.contactPhone != null && company.contactPhone!.isNotEmpty) // TODO
//                       ListTile(
//                         contentPadding: EdgeInsets.zero,
//                         leading: Container(
//                           padding: const EdgeInsets.all(10),
//                           decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.1), shape: BoxShape.circle),
//                           child: const Icon(Iconsax.call_bold, color: AppTheme.primaryColor, size: 20),
//                         ),
//                         title: Text('phone_label'.tr, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
//                         //       subtitle: Text(company.contactPhone!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       );
//     });
//   }

//   Widget _buildStatCard({required IconData icon, required String label, required String value, VoidCallback? onTap}) {
//     // Only show visual feedback if clickable
//     final isClickable = onTap != null;

//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(12),
//         child: Container(
//           width: 100,
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: AppTheme.primaryColor.withValues(alpha: isClickable ? 0.1 : 0.05), // Slightly dimmer if disabled
//             borderRadius: BorderRadius.circular(12),
//             border: isClickable ? Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)) : null,
//           ),
//           child: Column(
//             children: [
//               Icon(icon, color: isClickable ? AppTheme.primaryColor : Colors.grey, size: 32),
//               const SizedBox(height: 8),
//               Text(
//                 value,
//                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isClickable ? null : Colors.grey),
//               ),
//               Text(
//                 label,
//                 style: TextStyle(color: Colors.grey[600], fontSize: 12),
//                 textAlign: TextAlign.center,
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   bool _hasPermission(List<String> allowedRoles) {
//     // If no role (public viewer), no permission
//     if (controller.user.value == null) return false;
//     // Check if role is in allowed list
//     return allowedRoles.contains(controller.role.value);
//   }

//   Widget _buildSectionHeader(String title) {
//     return Align(
//       alignment: Alignment.centerLeft,
//       child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//     );
//   }

//   void _navigateTo(int index, String routeName) {
//     if (Get.isRegistered<MainDashboardController>()) {
//       Get.find<MainDashboardController>().changePage(index, routeName);
//     }
//   }
// }
