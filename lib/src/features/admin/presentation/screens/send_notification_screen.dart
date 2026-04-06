import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/src/core/layout/app_breakpoints.dart';
import 'package:solar_hub/src/utils/app_theme.dart';
import 'package:toastification/toastification.dart';

import '../controllers/notification_controller.dart';
import '../widgets/admin_drawer.dart';

class SendNotificationScreen extends ConsumerStatefulWidget {
  const SendNotificationScreen({super.key});

  @override
  ConsumerState<SendNotificationScreen> createState() =>
      _SendNotificationScreenState();
}

class _SendNotificationScreenState
    extends ConsumerState<SendNotificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _dataController = TextEditingController();

  String _selectedType = 'broadcast';
  String _selectedTopic = 'general';

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(notificationProvider.notifier).fetchStatistics(),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _dataController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (state.successMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        toastification.show(
          type: ToastificationType.success,
          title: const Text('Success'),
          description: Text(state.successMessage!),
          autoCloseDuration: const Duration(seconds: 5),
          alignment: Alignment.topCenter,
        );
        ref.read(notificationProvider.notifier).clearSuccessMessage();
      });
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      drawer: AppBreakpoints.isDesktop(context) ? null : const AdminDrawer(),
      body: SingleChildScrollView(
        padding: AppBreakpoints.pagePadding(context),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: AppBreakpoints.contentMaxWidth(context),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, isDark),
                SizedBox(height: 24.h),
                if (AppBreakpoints.isDesktop(context))
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildStatistics(context, state, isDark)),
                      SizedBox(width: 24.w),
                      Expanded(
                        child: _buildNotificationForm(context, state, isDark),
                      ),
                    ],
                  )
                else ...[
                  _buildStatistics(context, state, isDark),
                  SizedBox(height: 32.h),
                  _buildNotificationForm(context, state, isDark),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        'Send Notification',
        style: const TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      centerTitle: AppBreakpoints.isMobile(context),
      leading: IconButton(
        icon: Icon(Iconsax.arrow_left_bold, size: 24.sp),
        onPressed: () => context.go('/admin'),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
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
          ),
          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Icon(
                        Iconsax.notification_bing_bold,
                        color: AppTheme.primaryColor,
                        size: 32.sp,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    _buildHeaderText(isDark),
                  ],
                )
              : Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Icon(
                        Iconsax.notification_bing_bold,
                        color: AppTheme.primaryColor,
                        size: 32.sp,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(child: _buildHeaderText(isDark)),
                  ],
                ),
        )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 600))
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildHeaderText(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Push Notifications',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
            fontFamily: AppTheme.fontFamily,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Send server push to all active devices or a subscribed topic',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontFamily: AppTheme.fontFamily,
          ),
        ),
      ],
    );
  }

  Widget _buildStatistics(
    BuildContext context,
    NotificationState state,
    bool isDark,
  ) {
    final columns = AppBreakpoints.adaptiveGridCount(
      context,
      mobile: 1,
      tablet: 3,
      desktop: 3,
    );

    return Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Iconsax.devices_bold,
                    color: AppTheme.primaryColor,
                    size: 24.sp,
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Notification Stats',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppTheme.fontFamily,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: columns,
                crossAxisSpacing: 16.w,
                mainAxisSpacing: 16.h,
                childAspectRatio: AppBreakpoints.isMobile(context) ? 3.2 : 1.3,
                children: [
                  _buildStatItem(
                    'Active',
                    '${state.stats.devices.active}',
                    Colors.blue,
                    isDark,
                  ),
                  _buildStatItem(
                    'iOS',
                    '${state.stats.devices.ios}',
                    Colors.grey,
                    isDark,
                  ),
                  _buildStatItem(
                    'Android',
                    '${state.stats.devices.android}',
                    Colors.green,
                    isDark,
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: columns,
                crossAxisSpacing: 16.w,
                mainAxisSpacing: 16.h,
                childAspectRatio: AppBreakpoints.isMobile(context) ? 3.2 : 1.3,
                children: [
                  _buildStatItem(
                    'Sent',
                    '${state.stats.notifications.sent}',
                    AppTheme.primaryColor,
                    isDark,
                  ),
                  _buildStatItem(
                    'Failed',
                    '${state.stats.notifications.failed}',
                    AppTheme.errorColor,
                    isDark,
                  ),
                  _buildStatItem(
                    'Total',
                    '${state.stats.notifications.total}',
                    AppTheme.warningColor,
                    isDark,
                  ),
                ],
              ),
              if (state.isLoadingStats) ...[
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.w,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'Loading notification statistics...',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey,
                        fontFamily: AppTheme.fontFamily,
                      ),
                    ),
                  ],
                ),
              ],
              if (state.error != null) ...[
                SizedBox(height: 16.h),
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppTheme.errorColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Iconsax.info_circle_bold,
                        color: AppTheme.errorColor,
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          state.error!,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppTheme.errorColor,
                            fontFamily: AppTheme.fontFamily,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        )
        .animate()
        .fadeIn(delay: const Duration(milliseconds: 200))
        .slideY(begin: 0.3, end: 0, delay: const Duration(milliseconds: 200));
  }

  Widget _buildStatItem(String label, String value, Color color, bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(Iconsax.people_bold, color: color, size: 20.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              fontFamily: AppTheme.fontFamily,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontFamily: AppTheme.fontFamily,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationForm(
    BuildContext context,
    NotificationState state,
    bool isDark,
  ) {
    return Form(
          key: _formKey,
          child: Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Compose Notification',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppTheme.fontFamily,
                  ),
                ),
                SizedBox(height: 24.h),
                _buildTypeSelector(isDark),
                SizedBox(height: 20.h),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    hintText: 'Enter notification title',
                    prefixIcon: Icon(Iconsax.text_bold, size: 20.sp),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: AppTheme.primaryColor,
                        width: 2.w,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: _bodyController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Message',
                    hintText: 'Enter notification message',
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(bottom: 80.h),
                      child: Icon(Iconsax.message_circle_bold, size: 20.sp),
                    ),
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: AppTheme.primaryColor,
                        width: 2.w,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a message';
                    }
                    if (value.trim().length < 10) {
                      return 'Message must be at least 10 characters';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: _dataController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Additional Data (JSON)',
                    hintText: '{"key": "value"} (Optional)',
                    prefixIcon: Icon(Iconsax.code_bold, size: 20.sp),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: AppTheme.primaryColor,
                        width: 2.w,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                if (state.isSending)
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 24.w,
                          height: 24.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.w,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          'Sending server push...',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey,
                            fontFamily: AppTheme.fontFamily,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton.icon(
                      onPressed: _sendNotification,
                      icon: Icon(Iconsax.send_bold, size: 20.sp),
                      label: Text(
                        'Send Notification',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: AppTheme.fontFamily,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(delay: const Duration(milliseconds: 400))
        .slideY(begin: 0.3, end: 0, delay: const Duration(milliseconds: 400));
  }

  Widget _buildTypeSelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notification Type',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            fontFamily: AppTheme.fontFamily,
          ),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          children: [
            _buildTypeChip('Broadcast', 'broadcast', isDark),
            _buildTypeChip('Topic', 'topic', isDark),
          ],
        ),
        if (_selectedType == 'topic') ...[
          SizedBox(height: 12.h),
          DropdownButtonFormField<String>(
            initialValue: _selectedTopic,
            decoration: InputDecoration(
              labelText: 'Select Topic',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: AppTheme.primaryColor,
                  width: 2.w,
                ),
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'general', child: Text('General')),
              DropdownMenuItem(value: 'info', child: Text('Info')),
              DropdownMenuItem(value: 'updates', child: Text('Updates')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedTopic = value!;
              });
            },
          ),
        ],
      ],
    );
  }

  Widget _buildTypeChip(String label, String value, bool isDark) {
    final isSelected = _selectedType == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedType = selected ? value : _selectedType;
        });
      },
      selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
      checkmarkColor: AppTheme.primaryColor,
      labelStyle: TextStyle(
        color: isSelected
            ? AppTheme.primaryColor
            : (isDark ? Colors.grey[400] : Colors.grey[600]),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontFamily: AppTheme.fontFamily,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.r),
        side: BorderSide(
          color: isSelected ? AppTheme.primaryColor : Colors.grey,
        ),
      ),
    );
  }

  void _sendNotification() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Map<String, dynamic>? additionalData;
    if (_dataController.text.trim().isNotEmpty) {
      try {
        additionalData =
            jsonDecode(_dataController.text.trim()) as Map<String, dynamic>?;
      } catch (_) {
        toastification.show(
          type: ToastificationType.error,
          title: const Text('Invalid JSON'),
          description: const Text('Please enter valid JSON data'),
          alignment: Alignment.topCenter,
        );
        return;
      }
    }

    final controller = ref.read(notificationProvider.notifier);
    if (_selectedType == 'topic') {
      controller.sendTopicNotification(
        topic: _selectedTopic,
        title: _titleController.text.trim(),
        body: _bodyController.text.trim(),
        data: additionalData,
      );
      return;
    }

    controller.sendBroadcastNotification(
      title: _titleController.text.trim(),
      body: _bodyController.text.trim(),
      data: additionalData,
    );
  }
}
