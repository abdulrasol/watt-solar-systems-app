import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/src/core/layout/app_breakpoints.dart';
import 'package:solar_hub/src/core/widgets/loading_widgets.dart';
import 'package:solar_hub/src/utils/app_theme.dart';
import '../controllers/admin_controller.dart';
import '../widgets/admin_drawer.dart';

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    Future.microtask(() => ref.read(adminProvider.notifier).fetchFeedbacks());
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminProvider);
    final unreadFeedbacks = state.feedbacks.where((f) => !f.isRead).length;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = AppBreakpoints.isDesktop(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(
        context,
        unreadFeedbacks,
        showDrawerButton: !isDesktop,
      ),
      drawer: isDesktop ? null : const AdminDrawer(),
      body: state.isLoading
          ? _buildLoadingState()
          : RefreshIndicator(
              color: AppTheme.primaryColor,
              backgroundColor: Theme.of(context).cardColor,
              onRefresh: () =>
                  ref.read(adminProvider.notifier).fetchFeedbacks(),
              child: _buildContent(context, state, isDark, isDesktop),
            ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    int unreadFeedbacks, {
    required bool showDrawerButton,
  }) {
    return AppBar(
      title: Text(
        'Admin Dashboard',
        style: const TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      centerTitle: AppBreakpoints.isMobile(context),
      automaticallyImplyLeading: showDrawerButton,
      actions: [
        Stack(
          children: [
            IconButton(
              icon: Icon(Iconsax.notification_bing_bold, size: 24.sp),
              onPressed: () {},
            ),
            if (unreadFeedbacks > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      width: 2.w,
                    ),
                  ),
                  constraints: BoxConstraints(minWidth: 18.w, minHeight: 18.h),
                  child: Text(
                    unreadFeedbacks > 99 ? '99+' : '$unreadFeedbacks',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ).animate().scale(
                duration: const Duration(milliseconds: 300),
                begin: const Offset(0.5, 0.5),
              ),
          ],
        ),
        SizedBox(width: 8.w),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LoadingWidget.widget(context: context, size: 30),
          SizedBox(height: 24.h),
          Text(
            'Loading Dashboard...',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontFamily: AppTheme.fontFamily,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AdminState state,
    bool isDark,
    bool isDesktop,
  ) {
    final pagePadding = AppBreakpoints.pagePadding(context);
    final maxWidth = AppBreakpoints.contentMaxWidth(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isDesktop)
          Container(
            width: 300,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(
                right: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
              ),
            ),
            child: const AdminDrawer(embedded: true),
          ),
        Expanded(
          child: SingleChildScrollView(
            padding: pagePadding,
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderSection(context, state, isDark),
                    SizedBox(height: 24.h),
                    _buildStatsGrid(context, state, isDark),
                    SizedBox(height: 32.h),
                    _buildQuickActionsSection(context, isDark),
                    if (state.feedbacks.isNotEmpty) ...[
                      SizedBox(height: 32.h),
                      _buildRecentFeedbacksSection(context, state, isDark),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderSection(
    BuildContext context,
    AdminState state,
    bool isDark,
  ) {
    final unreadCount = state.feedbacks.where((f) => !f.isRead).length;
    final isMobile = AppBreakpoints.isMobile(context);

    return Container(
          width: double.infinity,
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor.withValues(alpha: isDark ? 0.3 : 0.15),
                Theme.of(context).cardColor,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : AppTheme.primaryColor.withValues(alpha: 0.2),
              width: 1.5.w,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: Offset(0, 10.h),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 16.w,
                runSpacing: 16.h,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Icon(
                      Iconsax.user_cirlce_add_bold,
                      color: AppTheme.primaryColor,
                      size: 32.sp,
                    ),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isMobile ? double.infinity : 420.w,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Admin Panel',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                            fontFamily: AppTheme.fontFamily,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Manage your platform',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            fontFamily: AppTheme.fontFamily,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Wrap(
                spacing: 16.w,
                runSpacing: 16.h,
                children: [
                  SizedBox(
                    width: isMobile ? double.infinity : 220.w,
                    child: _buildHeaderStat(
                      context,
                      'Total Feedbacks',
                      '${state.feedbacks.length}',
                      Iconsax.message_circle_bold,
                      Colors.blue,
                      isDark,
                    ),
                  ),
                  SizedBox(
                    width: isMobile ? double.infinity : 220.w,
                    child: _buildHeaderStat(
                      context,
                      'Unread',
                      '$unreadCount',
                      Iconsax.notification_bing_bold,
                      unreadCount > 0 ? AppTheme.warningColor : Colors.grey,
                      isDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 600))
        .slideY(
          begin: 0.3,
          end: 0,
          duration: const Duration(milliseconds: 600),
        );
  }

  Widget _buildHeaderStat(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24.sp),
          SizedBox(height: 8.h),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: AppTheme.fontFamily,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontFamily: AppTheme.fontFamily,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, AdminState state, bool isDark) {
    final crossAxisCount = AppBreakpoints.adaptiveGridCount(
      context,
      mobile: 2,
      tablet: 2,
      desktop: 4,
    );

    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistics',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: AppTheme.fontFamily,
              ),
            ),
            SizedBox(height: 16.h),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              childAspectRatio: AppBreakpoints.isDesktop(context) ? 1.2 : 1.1,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              children: [
                _buildStatCard(
                  context,
                  'Total Feedbacks',
                  '${state.feedbacks.length}',
                  Iconsax.message_circle_bold,
                  Colors.blue,
                  isDark,
                  onTap: () => context.go('/admin/feedbacks'),
                ),
                _buildStatCard(
                  context,
                  'Active Companies',
                  '12',
                  Iconsax.building_bold,
                  Colors.orange,
                  isDark,
                  onTap: () => context.go('/admin/companies'),
                ),
                _buildStatCard(
                  context,
                  'New Users',
                  '5',
                  Iconsax.people_bold,
                  Colors.green,
                  isDark,
                  onTap: () {},
                ),
                _buildStatCard(
                  context,
                  'Marketplace',
                  '${state.feedbacks.length}',
                  Iconsax.shop_bold,
                  Colors.purple,
                  isDark,
                  onTap: () => context.push('/admin-marketplace'),
                ),
              ],
            ),
          ],
        )
        .animate()
        .fadeIn(delay: const Duration(milliseconds: 200))
        .slideY(begin: 0.3, end: 0, delay: const Duration(milliseconds: 200));
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    bool isDark, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: Offset(0, 8.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(icon, color: color, size: 24.sp),
            ),
            SizedBox(height: 12.h),
            Flexible(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppTheme.fontFamily,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: 4.h),
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontFamily: AppTheme.fontFamily,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context, bool isDark) {
    final actions = [
      _DashboardAction(
        'Manage Companies',
        'View and approve registered solar companies',
        Iconsax.building_bold,
        () => context.go('/admin/companies'),
      ),
      _DashboardAction(
        'Service Catalog',
        'Manage global services and subscription offers',
        Iconsax.category_2_bold,
        () => context.go('/admin/service-catalog'),
      ),
      _DashboardAction(
        'Service Requests',
        'Review company requests for catalog services',
        Iconsax.briefcase_bold,
        () => context.go('/admin/service-requests'),
      ),
      _DashboardAction(
        'User Feedbacks',
        'Read and respond to user messages',
        Iconsax.message_circle_bold,
        () => context.go('/admin/feedbacks'),
      ),
      _DashboardAction(
        'App Configurations',
        'Manage feature flags and settings',
        Iconsax.setting_2_bold,
        () => context.go('/admin/configs'),
      ),
      _DashboardAction(
        'Send Notifications',
        'Push notifications to all users',
        Iconsax.notification_bing_bold,
        () => context.go('/admin/send-notification'),
      ),
      _DashboardAction(
        'Marketplace Oversight',
        'Manage all solar requests and bidded offers',
        Iconsax.shop_bold,
        () => context.push('/admin-marketplace'),
      ),
      _DashboardAction(
        'System Settings',
        'Configure app-wide parameters',
        Iconsax.setting_bold,
        () {},
      ),
    ];
    final columns = AppBreakpoints.adaptiveGridCount(
      context,
      mobile: 1,
      tablet: 2,
      desktop: 2,
    );

    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: AppTheme.fontFamily,
              ),
            ),
            SizedBox(height: 16.h),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: actions.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                childAspectRatio: AppBreakpoints.isMobile(context) ? 3.1 : 3.6,
              ),
              itemBuilder: (context, index) {
                final action = actions[index];
                return _buildActionTile(
                  context,
                  action.title,
                  action.subtitle,
                  action.icon,
                  action.onTap,
                  isDark,
                );
              },
            ),
          ],
        )
        .animate()
        .fadeIn(delay: const Duration(milliseconds: 400))
        .slideY(begin: 0.3, end: 0, delay: const Duration(milliseconds: 400));
  }

  Widget _buildActionTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
    bool isDark,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(icon, color: AppTheme.primaryColor, size: 24.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      fontFamily: AppTheme.fontFamily,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontFamily: AppTheme.fontFamily,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Iconsax.arrow_right_bold,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentFeedbacksSection(
    BuildContext context,
    AdminState state,
    bool isDark,
  ) {
    final recentFeedbacks = state.feedbacks.take(3).toList();
    final columns = AppBreakpoints.adaptiveGridCount(
      context,
      mobile: 1,
      tablet: 2,
      desktop: 3,
    );

    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Feedbacks',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppTheme.fontFamily,
                  ),
                ),
                TextButton(
                  onPressed: () => context.go('/admin/feedbacks'),
                  child: Text(
                    'View All',
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 14,
                      fontFamily: AppTheme.fontFamily,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentFeedbacks.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                childAspectRatio: AppBreakpoints.isMobile(context) ? 2.9 : 3.15,
              ),
              itemBuilder: (context, index) {
                final feedback = recentFeedbacks[index];
                return _buildRecentFeedbackCard(context, feedback, isDark);
              },
            ),
          ],
        )
        .animate()
        .fadeIn(delay: const Duration(milliseconds: 600))
        .slideY(begin: 0.3, end: 0, delay: const Duration(milliseconds: 600));
  }

  Widget _buildRecentFeedbackCard(
    BuildContext context,
    dynamic feedback,
    bool isDark,
  ) {
    return InkWell(
      onTap: () => context.go('/admin/feedbacks'),
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: feedback.isRead
                ? isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1)
                : AppTheme.primaryColor.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22.r,
              backgroundColor: feedback.isRead
                  ? Colors.grey.withValues(alpha: 0.2)
                  : AppTheme.primaryColor.withValues(alpha: 0.2),
              child: Text(
                feedback.name[0].toUpperCase(),
                style: TextStyle(
                  color: feedback.isRead ? Colors.grey : AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFamily: AppTheme.fontFamily,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          feedback.name,
                          style: TextStyle(
                            fontWeight: feedback.isRead
                                ? FontWeight.normal
                                : FontWeight.bold,
                            fontSize: 14,
                            fontFamily: AppTheme.fontFamily,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!feedback.isRead)
                        Container(
                          width: 8.w,
                          height: 8.h,
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    feedback.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontFamily: AppTheme.fontFamily,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardAction {
  const _DashboardAction(this.title, this.subtitle, this.icon, this.onTap);

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
}
