import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:solar_hub/src/features/admin/domain/models/admin_user.dart';
import 'package:solar_hub/src/features/admin/presentation/controllers/admin_users_controller.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/admin_page_scaffold.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(adminUsersProvider.notifier).fetchUsers(isRefresh: true));
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(adminUsersProvider.notifier).fetchNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminUsersProvider);

    return AdminPageScaffold(
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: state.isLoading
                ? const AdminLoadingState(message: 'Loading Users...')
                : state.error != null && state.users.isEmpty
                ? AdminErrorState(error: state.error!, onRetry: () => ref.read(adminUsersProvider.notifier).fetchUsers(isRefresh: true))
                : RefreshIndicator(
                    onRefresh: () => ref.read(adminUsersProvider.notifier).fetchUsers(isRefresh: true),
                    child: state.users.isEmpty
                        ? const AdminEmptyState(icon: Iconsax.user, title: 'No Users Found')
                        : ListView.builder(
                            controller: _scrollController,
                            padding: EdgeInsets.all(20.w),
                            itemCount: state.users.length + (state.isMoreLoading ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == state.users.length) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              return _UserCard(user: state.users[index]);
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'User Management',
            style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, fontFamily: AppTheme.fontFamily),
          ),
          Text(
            'Promote or demote system users',
            style: TextStyle(fontSize: 13.sp, color: Colors.grey, fontFamily: AppTheme.fontFamily),
          ),
        ],
      ),
    );
  }
}

class _UserCard extends ConsumerWidget {
  final AdminUser user;
  const _UserCard({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25.r,
            backgroundImage: user.image != null ? NetworkImage(user.image!) : null,
            child: user.image == null ? Icon(Iconsax.user, size: 24.sp) : null,
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${user.firstName ?? ""} ${user.lastName ?? ""}'.trim().isEmpty ? user.username : '${user.firstName} ${user.lastName}',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
                Text(
                  '@${user.username}',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                ),
                if (user.isSuperuser)
                  Container(
                    margin: EdgeInsets.only(top: 4.h),
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4.r)),
                    child: Text(
                      'SUPERUSER',
                      style: TextStyle(fontSize: 9.sp, color: Colors.amber, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),
          Switch(value: user.isSuperuser, onChanged: (v) => _confirmPromotion(context, ref, v), activeThumbColor: Colors.amber),
        ],
      ),
    );
  }

  void _confirmPromotion(BuildContext context, WidgetRef ref, bool promote) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(promote ? 'Promote to Superuser' : 'Demote from Superuser'),
        content: Text('Are you sure you want to ${promote ? "promote" : "demote"} ${user.username}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(adminUsersProvider.notifier).promoteUser(user.username, promote);
              Navigator.pop(context);
            },
            child: Text(promote ? 'Promote' : 'Demote', style: TextStyle(color: promote ? Colors.amber : Colors.red)),
          ),
        ],
      ),
    );
  }
}
