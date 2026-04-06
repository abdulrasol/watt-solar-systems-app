import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/src/core/layout/app_breakpoints.dart';
import 'package:solar_hub/src/features/admin/domain/entities/app_config.dart';
import 'package:solar_hub/src/features/admin/presentation/controllers/app_config_controller.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class AppConfigsScreen extends ConsumerStatefulWidget {
  const AppConfigsScreen({super.key});

  @override
  ConsumerState<AppConfigsScreen> createState() => _AppConfigsScreenState();
}

class _AppConfigsScreenState extends ConsumerState<AppConfigsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(appConfigProvider.notifier).fetchConfigs());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appConfigProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: state.isLoading
          ? _buildLoadingState()
          : state.error != null
          ? _buildErrorState(context, state.error!)
          : _buildContent(context, state, isDark),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        'App Configurations',
        style: const TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(Iconsax.add_bold, size: 24.sp),
          onPressed: () => _showAddConfigDialog(context),
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
          Icon(
            Iconsax.setting_bold,
            size: 80.sp,
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
          ),
          SizedBox(height: 24.h),
          Text(
            'Loading Configurations...',
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

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80.sp,
            color: AppTheme.errorColor.withValues(alpha: 0.5),
          ),
          SizedBox(height: 24.h),
          Text(
            'Failed to load configurations',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: AppTheme.fontFamily,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            error,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontFamily: AppTheme.fontFamily,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: () =>
                ref.read(appConfigProvider.notifier).fetchConfigs(),
            icon: Icon(Iconsax.refresh_bold, size: 20.sp),
            label: const Text('Retry', style: TextStyle(fontSize: 14)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppConfigState state,
    bool isDark,
  ) {
    return RefreshIndicator(
      color: AppTheme.primaryColor,
      backgroundColor: Theme.of(context).cardColor,
      onRefresh: () => ref.read(appConfigProvider.notifier).fetchConfigs(),
      child: GridView.builder(
        padding: EdgeInsets.all(20.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: AppBreakpoints.adaptiveGridCount(
            context,
            mobile: 1,
            tablet: 2,
            desktop: 2,
          ),
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          childAspectRatio: AppBreakpoints.isMobile(context) ? 2.6 : 3.0,
        ),
        itemCount: state.configs.length,
        itemBuilder: (context, index) {
          final config = state.configs[index];
          return _buildConfigCard(context, config, isDark, state.isSubmitting)
              .animate()
              .fadeIn(
                delay: Duration(milliseconds: index * 50),
                duration: const Duration(milliseconds: 400),
              )
              .slideX(
                begin: 0.1,
                end: 0,
                delay: Duration(milliseconds: index * 50),
                duration: const Duration(milliseconds: 400),
              );
        },
      ),
    );
  }

  Widget _buildConfigCard(
    BuildContext context,
    AppConfig config,
    bool isDark,
    bool isSubmitting,
  ) {
    return Dismissible(
      key: Key(config.key),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        decoration: BoxDecoration(
          color: AppTheme.errorColor,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Icon(Iconsax.trash_bold, color: Colors.white, size: 24.sp),
      ),
      confirmDismiss: (direction) => _confirmDelete(context, config),
      onDismissed: (direction) {
        ref.read(appConfigProvider.notifier).deleteConfig(config.key);
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: config.value
                ? AppTheme.successColor.withValues(alpha: 0.3)
                : isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: config.value
                    ? AppTheme.successColor.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                config.value ? Iconsax.check_bold : Iconsax.close_circle_bold,
                color: config.value ? AppTheme.successColor : Colors.grey,
                size: 28.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    config.key,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                      fontFamily: AppTheme.fontFamily,
                    ),
                  ),
                  if (config.description != null &&
                      config.description!.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      config.description!,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontFamily: AppTheme.fontFamily,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: 12.w),
            Opacity(
              opacity: isSubmitting ? 0.5 : 1.0,
              child: Switch(
                value: config.value,
                onChanged: isSubmitting
                    ? null
                    : (value) {
                        ref
                            .read(appConfigProvider.notifier)
                            .toggleConfig(config.key, value);
                      },
                activeThumbColor: AppTheme.successColor,
                activeTrackColor: AppTheme.successColor.withValues(alpha: 0.3),
              ),
            ),
            SizedBox(width: 8.w),
            PopupMenuButton<String>(
              icon: Icon(Iconsax.more_bold, size: 22.sp, color: Colors.grey),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditConfigDialog(context, config);
                } else if (value == 'delete') {
                  _confirmDelete(context, config);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(
                        Iconsax.edit_bold,
                        size: 20.sp,
                        color: AppTheme.primaryColor,
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'Edit',
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        Iconsax.trash_bold,
                        size: 20.sp,
                        color: AppTheme.errorColor,
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'Delete',
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 14.sp,
                          color: AppTheme.errorColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context, AppConfig config) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Iconsax.warning_2_bold,
                color: AppTheme.errorColor,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Text('Delete Config'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${config.key}"?',
          style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 14.sp,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              'Delete',
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    return confirm ?? false;
  }

  void _showAddConfigDialog(BuildContext context) {
    final keyController = TextEditingController();
    final descriptionController = TextEditingController();
    bool value = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Iconsax.add_bold,
                  color: AppTheme.primaryColor,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Add Configuration',
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: keyController,
                  decoration: InputDecoration(
                    labelText: 'Config Key',
                    hintText: 'e.g., community, store, auth',
                    labelStyle: TextStyle(fontFamily: AppTheme.fontFamily),
                  ),
                  textCapitalization: TextCapitalization.none,
                ),
                SizedBox(height: 16.h),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description (Optional)',
                    hintText: 'What does this config do?',
                    labelStyle: TextStyle(fontFamily: AppTheme.fontFamily),
                  ),
                  maxLines: 2,
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Text(
                      'Default Value:',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Switch(
                      value: value,
                      onChanged: (newValue) {
                        setDialogState(() {
                          value = newValue;
                        });
                      },
                      activeThumbColor: AppTheme.primaryColor,
                    ),
                    Text(
                      value ? 'Enabled' : 'Disabled',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 14.sp,
                        fontWeight: value ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 14.sp,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (keyController.text.trim().isNotEmpty) {
                  ref
                      .read(appConfigProvider.notifier)
                      .createConfig(
                        key: keyController.text.trim(),
                        value: value,
                        description: descriptionController.text.trim().isEmpty
                            ? null
                            : descriptionController.text.trim(),
                      );
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Add',
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditConfigDialog(BuildContext context, AppConfig config) {
    final keyController = TextEditingController(text: config.key);
    final descriptionController = TextEditingController(
      text: config.description,
    );
    bool value = config.value;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Iconsax.edit_bold,
                  color: AppTheme.primaryColor,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Edit Configuration',
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: keyController,
                  decoration: InputDecoration(
                    labelText: 'Config Key',
                    labelStyle: TextStyle(fontFamily: AppTheme.fontFamily),
                  ),
                ),
                SizedBox(height: 16.h),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description (Optional)',
                    labelStyle: TextStyle(fontFamily: AppTheme.fontFamily),
                  ),
                  maxLines: 2,
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Text(
                      'Value:',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Switch(
                      value: value,
                      onChanged: (newValue) {
                        setDialogState(() {
                          value = newValue;
                        });
                      },
                      activeThumbColor: AppTheme.primaryColor,
                    ),
                    Text(
                      value ? 'Enabled' : 'Disabled',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 14.sp,
                        fontWeight: value ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 14.sp,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (keyController.text.trim().isNotEmpty) {
                  ref
                      .read(appConfigProvider.notifier)
                      .updateConfig(
                        oldKey: config.key,
                        newKey: keyController.text.trim(),
                        value: value,
                        description: descriptionController.text.trim().isEmpty
                            ? null
                            : descriptionController.text.trim(),
                      );
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Update',
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
