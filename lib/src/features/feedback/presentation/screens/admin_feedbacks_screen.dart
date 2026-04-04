import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/widgets/loading_widgets.dart';
import 'package:solar_hub/src/features/admin/presentation/controllers/admin_controller.dart';
import 'package:solar_hub/src/features/feedback/domain/entities/feedback_entity.dart';
import 'package:solar_hub/src/utils/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminFeedbacksScreen extends ConsumerStatefulWidget {
  const AdminFeedbacksScreen({super.key});

  @override
  ConsumerState<AdminFeedbacksScreen> createState() => _AdminFeedbacksScreenState();
}

class _AdminFeedbacksScreenState extends ConsumerState<AdminFeedbacksScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  String _filterMode = 'all'; // all, unread, read

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
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
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context, state, l10n),
      body: state.isLoading
          ? _buildLoadingState()
          : state.error != null
          ? _buildErrorState(context, state.error!, l10n)
          : _buildContent(context, state, l10n, isDark),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, AdminState state, AppLocalizations l10n) {
    return AppBar(
      title: Text(
        l10n.user_feedbacks,
        style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.bold, fontSize: 20.sp),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(Iconsax.refresh_bold, size: 24.sp),
          onPressed: () => ref.read(adminProvider.notifier).fetchFeedbacks(),
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
            'Loading Feedbacks...',
            style: TextStyle(fontSize: 16.sp, color: Colors.grey, fontFamily: AppTheme.fontFamily),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.warning_2_bold, size: 80.sp, color: AppTheme.errorColor.withValues(alpha: 0.5)),
          SizedBox(height: 24.h),
          Text(
            'Failed to load feedbacks',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, fontFamily: AppTheme.fontFamily),
          ),
          SizedBox(height: 8.h),
          Text(
            error,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey, fontFamily: AppTheme.fontFamily),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: () => ref.read(adminProvider.notifier).fetchFeedbacks(),
            icon: Icon(Iconsax.refresh_bold, size: 20.sp),
            label: Text('Retry', style: TextStyle(fontSize: 14.sp)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, AdminState state, AppLocalizations l10n, bool isDark) {
    final filteredFeedbacks = _getFilteredFeedbacks(state.feedbacks);

    return Column(
      children: [
        _buildFilterChips(context, isDark),
        Expanded(
          child: filteredFeedbacks.isEmpty
              ? _buildEmptyState(context, l10n)
              : RefreshIndicator(
                  color: AppTheme.primaryColor,
                  backgroundColor: Theme.of(context).cardColor,
                  onRefresh: () => ref.read(adminProvider.notifier).fetchFeedbacks(),
                  child: ListView.separated(
                    padding: EdgeInsets.all(20.w),
                    itemCount: filteredFeedbacks.length,
                    separatorBuilder: (context, index) => SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      final feedback = filteredFeedbacks[index];
                      return _buildFeedbackCard(context, feedback, isDark, l10n)
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
                ),
        ),
      ],
    );
  }

  List<FeedbackEntity> _getFilteredFeedbacks(List<FeedbackEntity> feedbacks) {
    switch (_filterMode) {
      case 'unread':
        return feedbacks.where((f) => !f.isRead).toList();
      case 'read':
        return feedbacks.where((f) => f.isRead).toList();
      default:
        return feedbacks;
    }
  }

  Widget _buildFilterChips(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Row(
        children: [
          _buildFilterChip('All', 'all'),
          SizedBox(width: 8.w),
          _buildFilterChip('Unread', 'unread'),
          SizedBox(width: 8.w),
          _buildFilterChip('Read', 'read'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String mode) {
    final isSelected = _filterMode == mode;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 13.sp,
          fontFamily: AppTheme.fontFamily,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected
              ? Colors.white
              : Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black87,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterMode = mode;
        });
      },
      backgroundColor: Theme.of(context).cardColor,
      selectedColor: AppTheme.primaryColor,
      checkmarkColor: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
        side: BorderSide(color: isSelected ? AppTheme.primaryColor : Colors.grey.withValues(alpha: 0.3)),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.message_circle_bold, size: 80.sp, color: Colors.grey.withValues(alpha: 0.5)),
          SizedBox(height: 24.h),
          Text(
            _filterMode == 'all'
                ? l10n.no_feedbacks_yet
                : _filterMode == 'unread'
                ? 'No unread feedbacks'
                : 'No read feedbacks',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, fontFamily: AppTheme.fontFamily, color: Colors.grey),
          ),
          SizedBox(height: 8.h),
          Text(
            'Feedbacks will appear here',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey.withValues(alpha: 0.7), fontFamily: AppTheme.fontFamily),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(BuildContext context, FeedbackEntity feedback, bool isDark, AppLocalizations l10n) {
    return InkWell(
      onTap: () => _showFeedbackDetails(context, feedback, l10n),
      onLongPress: () => _showActionsBottomSheet(context, feedback, l10n),
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: feedback.isRead
                ? isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1)
                : AppTheme.primaryColor.withValues(alpha: 0.3),
            width: feedback.isRead ? 1.w : 2.w,
          ),
          boxShadow: [
            BoxShadow(
              color: feedback.isRead ? Colors.black.withValues(alpha: 0.03) : AppTheme.primaryColor.withValues(alpha: 0.1),
              blurRadius: feedback.isRead ? 10 : 15,
              offset: Offset(0, feedback.isRead ? 4 : 8.h),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 24.r,
                  backgroundColor: feedback.isRead ? Colors.grey.withValues(alpha: 0.2) : AppTheme.primaryColor.withValues(alpha: 0.2),
                  child: Text(
                    feedback.name[0].toUpperCase(),
                    style: TextStyle(
                      color: feedback.isRead ? Colors.grey : AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                      fontFamily: AppTheme.fontFamily,
                    ),
                  ),
                ),
                if (!feedback.isRead)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14.w,
                      height: 14.h,
                      decoration: BoxDecoration(
                        color: AppTheme.successColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2.w),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          feedback.name,
                          style: TextStyle(fontWeight: feedback.isRead ? FontWeight.normal : FontWeight.bold, fontSize: 15.sp, fontFamily: AppTheme.fontFamily),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatTime(feedback.createdAt),
                        style: TextStyle(fontSize: 11.sp, color: isDark ? Colors.grey[400] : Colors.grey[600], fontFamily: AppTheme.fontFamily),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    feedback.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13.sp, color: isDark ? Colors.grey[400] : Colors.grey[600], fontFamily: AppTheme.fontFamily, height: 1.4),
                  ),
                  if (feedback.imageData != null) ...[
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(Iconsax.image_bold, size: 14.sp, color: AppTheme.primaryColor),
                        SizedBox(width: 4.w),
                        Text(
                          'Has attachment',
                          style: TextStyle(fontSize: 11.sp, color: AppTheme.primaryColor, fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: 12.w),
            _buildMoreButton(context, feedback, l10n),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(dateTime);
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE').format(dateTime);
    } else {
      return DateFormat('MMM d').format(dateTime);
    }
  }

  Widget _buildMoreButton(BuildContext context, FeedbackEntity feedback, AppLocalizations l10n) {
    return PopupMenuButton<String>(
      icon: Icon(Iconsax.more_bold, size: 22.sp, color: Colors.grey),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      elevation: 8,
      onSelected: (value) {
        if (value == 'toggle') {
          ref.read(adminProvider.notifier).toggleFeedbackReadStatus(feedback.id!, !feedback.isRead);
        } else if (value == 'delete') {
          _confirmDelete(context, feedback.id!, l10n);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'toggle',
          child: Row(
            children: [
              Icon(
                feedback.isRead ? Iconsax.message_circle_bold : Iconsax.check_bold,
                size: 20.sp,
                color: feedback.isRead ? Colors.grey : AppTheme.successColor,
              ),
              SizedBox(width: 12.w),
              Text(
                feedback.isRead ? l10n.mark_as_unread : l10n.mark_as_read,
                style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 14.sp),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Iconsax.trash_bold, size: 20.sp, color: AppTheme.errorColor),
              SizedBox(width: 12.w),
              Text(
                l10n.delete_feedback,
                style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 14.sp, color: AppTheme.errorColor),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showFeedbackDetails(BuildContext context, FeedbackEntity feedback, AppLocalizations l10n) {
    if (!feedback.isRead) {
      ref.read(adminProvider.notifier).toggleFeedbackReadStatus(feedback.id!, true);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildDetailsSheet(context, feedback, l10n),
    );
  }

  Widget _buildDetailsSheet(BuildContext context, FeedbackEntity feedback, AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48.w,
                height: 5.h,
                decoration: BoxDecoration(color: isDark ? Colors.grey[700] : Colors.grey[300], borderRadius: BorderRadius.circular(3.r)),
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                CircleAvatar(
                  radius: 28.r,
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.15),
                  child: Text(
                    feedback.name[0].toUpperCase(),
                    style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 22.sp, fontFamily: AppTheme.fontFamily),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feedback.name,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp, fontFamily: AppTheme.fontFamily),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        DateFormat('MMM d, yyyy - HH:mm').format(feedback.createdAt),
                        style: TextStyle(fontSize: 13.sp, color: isDark ? Colors.grey[400] : Colors.grey[600], fontFamily: AppTheme.fontFamily),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: feedback.isRead ? AppTheme.successColor.withValues(alpha: 0.1) : AppTheme.warningColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    feedback.isRead ? 'Read' : 'Unread',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: feedback.isRead ? AppTheme.successColor : AppTheme.warningColor,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppTheme.fontFamily,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            Divider(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.2), height: 1.h),
            SizedBox(height: 20.h),
            Expanded(
              child: ListView(
                controller: scrollController,
                children: [
                  Text(
                    feedback.message,
                    style: TextStyle(fontSize: 15.sp, height: 1.6, fontFamily: AppTheme.fontFamily, color: isDark ? Colors.white : Colors.black87),
                  ),
                  if (feedback.imageData != null) ...[
                    SizedBox(height: 20.h),
                    Text(
                      'Attachment',
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, fontFamily: AppTheme.fontFamily),
                    ),
                    SizedBox(height: 12.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: Container(
                        width: double.infinity,
                        constraints: BoxConstraints(maxHeight: 300.h),
                        decoration: BoxDecoration(border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.2))),
                        child: Image.memory(
                          base64Decode(feedback.imageData!.split(',').last),
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              padding: EdgeInsets.all(40.w),
                              color: isDark ? Colors.grey[800] : Colors.grey[100],
                              child: Column(
                                children: [
                                  Icon(Iconsax.image_bold, size: 50.sp, color: Colors.grey),
                                  SizedBox(height: 12.h),
                                  Text(
                                    'Image unavailable',
                                    style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 20.h),
            if (feedback.phoneNumber != null && feedback.phoneNumber!.isNotEmpty) ...[
              Divider(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.2), height: 1.h),
              SizedBox(height: 20.h),
              Text(
                'Contact',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, fontFamily: AppTheme.fontFamily),
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => launchUrl(Uri.parse('tel:${feedback.phoneNumber}')),
                      icon: Icon(Iconsax.call_bold, size: 20.sp),
                      label: Text(l10n.call, style: TextStyle(fontSize: 14.sp)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final whatsappUrl = "https://wa.me/${feedback.phoneNumber.toString().replaceAll(' ', '').replaceAll('+', '')}";
                        launchUrl(Uri.parse(whatsappUrl), mode: LaunchMode.externalApplication);
                      },
                      icon: Icon(Iconsax.whatsapp_bold, size: 20.sp),
                      label: Text(l10n.whatsapp, style: TextStyle(fontSize: 14.sp)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }

  void _showActionsBottomSheet(BuildContext context, FeedbackEntity feedback, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48.w,
              height: 5.h,
              decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(3.r)),
            ),
            SizedBox(height: 20.h),
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: feedback.isRead ? Colors.grey.withValues(alpha: 0.2) : AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  feedback.isRead ? Iconsax.message_circle_bold : Iconsax.check_bold,
                  color: feedback.isRead ? Colors.grey : AppTheme.primaryColor,
                  size: 24.sp,
                ),
              ),
              title: Text(
                feedback.isRead ? l10n.mark_as_unread : l10n.mark_as_read,
                style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 15.sp),
              ),
              onTap: () {
                Navigator.pop(context);
                ref.read(adminProvider.notifier).toggleFeedbackReadStatus(feedback.id!, !feedback.isRead);
              },
            ),
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(color: AppTheme.errorColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10.r)),
                child: Icon(Iconsax.trash_bold, color: AppTheme.errorColor, size: 24.sp),
              ),
              title: Text(
                l10n.delete_feedback,
                style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 15.sp, color: AppTheme.errorColor),
              ),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context, feedback.id!, l10n);
              },
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(color: AppTheme.errorColor.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(Iconsax.warning_2_bold, color: AppTheme.errorColor, size: 24.sp),
            ),
            SizedBox(width: 12.w),
            Text(l10n.delete_feedback),
          ],
        ),
        content: Text(
          l10n.delete_feedback_confirm,
          style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 14.sp),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(adminProvider.notifier).deleteFeedback(id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            child: Text(
              l10n.delete_feedback,
              style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 14.sp, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
