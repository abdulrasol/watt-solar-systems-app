import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:solar_hub/src/core/widgets/wd_image_preview.dart';
import 'package:solar_hub/src/features/admin/presentation/controllers/admin_controller.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/admin_page_scaffold.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:solar_hub/src/features/feedback/domain/entities/feedback_entity.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class AdminFeedbacksScreen extends ConsumerStatefulWidget {
  const AdminFeedbacksScreen({super.key});

  @override
  ConsumerState<AdminFeedbacksScreen> createState() =>
      _AdminFeedbacksScreenState();
}

class _AdminFeedbacksScreenState extends ConsumerState<AdminFeedbacksScreen> {
  String _filterMode = 'all';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(adminProvider.notifier).fetchFeedbacks());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminProvider);

    return AdminPageScaffold(
      // title: 'User Feedbacks',
      // subtitle: 'Messages load only when this route is opened.',
      actions: [
        IconButton(
          onPressed: () => ref.read(adminProvider.notifier).fetchFeedbacks(),
          icon: const Icon(Iconsax.refresh_bold),
        ),
      ],
      child: state.isLoading
          ? const AdminLoadingState(
              icon: Iconsax.message_bold,
              message: 'Loading feedbacks...',
            )
          : state.error != null
          ? AdminErrorState(
              error: state.error!,
              onRetry: () => ref.read(adminProvider.notifier).fetchFeedbacks(),
            )
          : _buildContent(context, state),
    );
  }

  Widget _buildContent(BuildContext context, AdminState state) {
    final filtered = _getFilteredFeedbacks(state.feedbacks);

    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip(context, 'All', 'all'),
              _buildFilterChip(context, 'Unread', 'unread'),
              _buildFilterChip(context, 'Read', 'read'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: filtered.isEmpty
              ? const AdminEmptyState(
                  icon: Iconsax.message_question_bold,
                  title: 'No feedbacks found',
                  subtitle: 'There are no feedback items for this filter.',
                )
              : RefreshIndicator(
                  onRefresh: () =>
                      ref.read(adminProvider.notifier).fetchFeedbacks(),
                  child: ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final feedback = filtered[index];
                      return _FeedbackCard(
                        feedback: feedback,
                        onToggleRead: feedback.id == null
                            ? null
                            : () => ref
                                .read(adminProvider.notifier)
                                .toggleFeedbackReadStatus(
                                  feedback.id!,
                                  !feedback.isRead,
                                ),
                        onDelete: feedback.id == null
                            ? null
                            : () => ref
                                .read(adminProvider.notifier)
                                .deleteFeedback(feedback.id!),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, String mode) {
    final isSelected = _filterMode == mode;
    return FilterChip(
      selected: isSelected,
      onSelected: (_) => setState(() => _filterMode = mode),
      label: Text(
        label,
        style: TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? Colors.white : null,
        ),
      ),
      selectedColor: AppTheme.primaryColor,
      checkmarkColor: Colors.white,
    );
  }

  List<FeedbackEntity> _getFilteredFeedbacks(List<FeedbackEntity> feedbacks) {
    switch (_filterMode) {
      case 'unread':
        return feedbacks.where((feedback) => !feedback.isRead).toList();
      case 'read':
        return feedbacks.where((feedback) => feedback.isRead).toList();
      default:
        return feedbacks;
    }
  }
}

class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({
    required this.feedback,
    required this.onToggleRead,
    required this.onDelete,
  });

  final FeedbackEntity feedback;
  final VoidCallback? onToggleRead;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final createdAt = DateFormat('yyyy-MM-dd HH:mm').format(feedback.createdAt);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: feedback.isRead
              ? Colors.grey.withValues(alpha: 0.2)
              : AppTheme.primaryColor.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.14 : 0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                child: feedback.imageData != null && feedback.imageData!.isNotEmpty
                    ? ClipOval(
                        child: WdImagePreview(
                          imageUrl: feedback.imageData!,
                          size: 48,
                        ),
                      )
                    : const Icon(
                        Iconsax.user_bold,
                        color: AppTheme.primaryColor,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feedback.name.isNotEmpty ? feedback.name : 'Anonymous',
                      style: const TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if ((feedback.phoneNumber ?? '').isNotEmpty)
                      Text(
                        feedback.phoneNumber!,
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 13,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: (feedback.isRead
                          ? Colors.grey
                          : AppTheme.primaryColor)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  feedback.isRead ? 'READ' : 'UNREAD',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    color: feedback.isRead ? Colors.grey : AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            feedback.message,
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _MetaChip(icon: Iconsax.calendar_bold, label: createdAt),
              if ((feedback.phoneNumber ?? '').isNotEmpty)
                _MetaChip(
                  icon: Iconsax.call_bold,
                  label: feedback.phoneNumber!,
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              TextButton.icon(
                onPressed: onToggleRead,
                icon: Icon(
                  feedback.isRead
                      ? Iconsax.eye_slash_bold
                      : Iconsax.eye_bold,
                ),
                label: Text(feedback.isRead ? 'Mark unread' : 'Mark read'),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: onDelete,
                icon: const Icon(Iconsax.trash_bold, color: AppTheme.errorColor),
                label: const Text(
                  'Delete',
                  style: TextStyle(color: AppTheme.errorColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).chipTheme.backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Theme.of(context).hintColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 12,
              color: Theme.of(context).hintColor,
            ),
          ),
        ],
      ),
    );
  }
}
