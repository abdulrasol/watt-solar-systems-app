import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:solar_hub/controllers/members_controller.dart';
import 'package:solar_hub/layouts/company/members/add_edit_member_dialog.dart';
import 'package:solar_hub/utils/app_theme.dart';
import 'package:solar_hub/services/supabase_service.dart';
import 'package:solar_hub/controllers/company_controller.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:solar_hub/features/company_dashboard/controllers/main_dashboard_controller.dart';

class MembersPage extends StatefulWidget {
  const MembersPage({super.key});

  @override
  State<MembersPage> createState() => _MembersPageState();
}

class _MembersPageState extends State<MembersPage> {
  final controller = Get.put(MembersController());
  final mainController = Get.find<MainDashboardController>();
  final companyController = Get.find<CompanyController>();
  final currentUserId = SupabaseService().client.auth.currentUser?.id;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final canManageMembers = companyController.hasAnyRole(['owner', 'manager']);
      if (canManageMembers) {
        mainController.actions.assignAll([IconButton(icon: const Icon(Icons.person_add), onPressed: () => Get.dialog(const AddEditMemberDialog()))]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final canManageMembers = companyController.hasAnyRole(['owner', 'manager']);

      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.members.isEmpty) {
        return Center(child: Text('no_data'.tr));
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.members.length,
        itemBuilder: (context, index) {
          final member = controller.members[index];

          Map<String, dynamic>? profile;
          final rawProfile = member['profiles'];
          if (rawProfile is List) {
            if (rawProfile.isNotEmpty) {
              profile = rawProfile.first as Map<String, dynamic>;
            }
          } else if (rawProfile is Map) {
            profile = rawProfile as Map<String, dynamic>;
          }

          final fullName = profile?['full_name'] ?? 'Unknown Member';
          final phoneNumber = profile?['phone_number'] ?? '';
          final avatarUrl = profile?['avatar_url'];
          final userId = member['user_id'];
          final isMe = userId == currentUserId;

          List<String> roles = [];
          if (member['roles'] != null) {
            roles = List<String>.from(member['roles']);
          } else if (member['role'] != null) {
            roles = [member['role'].toString()];
          } else {
            roles = ['staff'];
          }

          final isTargetOwner = roles.contains('owner');
          final showActions = canManageMembers && !isTargetOwner;

          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                    backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty) ? CachedNetworkImageProvider(avatarUrl) : null,
                    child: (avatarUrl == null || avatarUrl.isEmpty) ? Icon(_getRoleIcon(roles.first), color: AppTheme.primaryColor, size: 28) : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(fullName, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                            if (isMe)
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                                child: const Text(
                                  'Me',
                                  style: TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold),
                                ),
                              ),
                          ],
                        ),
                        if (phoneNumber.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Row(
                              children: [
                                const Icon(Icons.phone, size: 14, color: Colors.green),
                                const SizedBox(width: 4),
                                Text(
                                  phoneNumber,
                                  style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: roles.map((role) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getRoleColor(role).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: _getRoleColor(role).withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                _getRoleLabel(role),
                                style: TextStyle(fontSize: 12, color: _getRoleColor(role), fontWeight: FontWeight.bold),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  if (showActions)
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          showDialog(
                            context: context,
                            builder: (c) => AddEditMemberDialog(member: member),
                          );
                        } else if (value == 'remove') {
                          _confirmRemove(context, controller, member['id']);
                        }
                      },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(
                          value: 'edit',
                          child: Row(children: [const Icon(Icons.edit, size: 20), const SizedBox(width: 8), Text('edit_member'.tr)]),
                        ),
                        if (!isMe)
                          PopupMenuItem<String>(
                            value: 'remove',
                            child: Row(
                              children: [
                                const Icon(Icons.delete, color: Colors.red, size: 20),
                                const SizedBox(width: 8),
                                Text('remove_member'.tr),
                              ],
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.redAccent;
      case 'owner':
        return Colors.red;
      case 'manager':
        return Colors.orange;
      case 'accountant':
        return Colors.blue;
      case 'sales':
        return Colors.green;
      case 'inventory_manager':
        return Colors.purple;
      case 'installer':
        return Colors.teal;
      case 'driver':
        return Colors.brown;
      case 'technician':
        return Colors.blueGrey;
      default:
        return Colors.grey;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'owner':
        return FontAwesomeIcons.crown;
      case 'admin':
        return FontAwesomeIcons.userShield;
      case 'manager':
        return FontAwesomeIcons.userTie;
      case 'accountant':
        return FontAwesomeIcons.fileInvoiceDollar;
      case 'sales':
        return FontAwesomeIcons.cashRegister;
      case 'inventory_manager':
        return FontAwesomeIcons.boxesStacked;
      case 'installer':
        return FontAwesomeIcons.screwdriverWrench;
      case 'driver':
        return FontAwesomeIcons.truck;
      case 'technician':
        return FontAwesomeIcons.screwdriverWrench;
      default:
        return FontAwesomeIcons.user;
    }
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case 'admin':
        return 'role_admin'.tr;
      case 'owner':
        return 'role_owner'.tr;
      case 'manager':
        return 'role_manager'.tr;
      case 'accountant':
        return 'role_accountant'.tr;
      case 'sales':
        return 'role_sales'.tr;
      case 'inventory_manager':
        return 'role_inventory_manager'.tr;
      case 'installer':
        return 'role_installer'.tr;
      case 'staff':
        return 'role_staff'.tr;
      case 'driver':
        return 'role_driver'.tr;
      case 'technician':
        return 'role_technician'.tr;
      default:
        return role.toUpperCase();
    }
  }

  void _confirmRemove(BuildContext context, MembersController controller, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('remove_member'.tr),
        content: Text('confirm_remove_member'.tr),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('close'.tr)),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await controller.removeMember(id);
              if (context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('member_removed_success'.tr), backgroundColor: Colors.green));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to remove member'), backgroundColor: Colors.red));
                }
              }
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
