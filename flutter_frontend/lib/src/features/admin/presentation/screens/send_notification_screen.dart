import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:watt/src/features/admin/presentation/controllers/notification_controller.dart';
import 'package:watt/src/features/admin/presentation/widgets/admin_page_scaffold.dart';
import 'package:watt/src/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:watt/src/utils/app_theme.dart';
import 'package:toastification/toastification.dart';

class SendNotificationScreen extends ConsumerStatefulWidget {
  const SendNotificationScreen({super.key});

  @override
  ConsumerState<SendNotificationScreen> createState() => _SendNotificationScreenState();
}

class _SendNotificationScreenState extends ConsumerState<SendNotificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _dataController = TextEditingController();
  // Holds a company id, post id, or user id depending on `_selectedType` —
  // one field reused across the three "target a specific thing" types to
  // keep the form compact.
  final _targetIdController = TextEditingController();

  String _selectedType = 'broadcast';
  String _selectedTopic = 'general';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(notificationProvider.notifier).fetchStatistics());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _dataController.dispose();
    _targetIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationProvider);

    if (state.successMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        toastification.show(
          context: context,
          type: ToastificationType.success,
          title: const Text('Success'),
          description: Text(state.successMessage!),
          autoCloseDuration: const Duration(seconds: 4),
        );
        ref.read(notificationProvider.notifier).clearSuccessMessage();
      });
    }

    return AdminPageScaffold(
      // title: 'Push Notifications',
      // subtitle: 'Stats and delivery tools load only when this page is opened.',
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (state.isLoadingStats && state.stats.devices.total == 0) {
            return const AdminLoadingState(icon: Iconsax.notification_bing, message: 'Loading notification tools...');
          }

          final wide = constraints.maxWidth >= 920;
          final stats = _StatsPanel(state: state);
          final form = _NotificationForm(
            formKey: _formKey,
            selectedType: _selectedType,
            selectedTopic: _selectedTopic,
            titleController: _titleController,
            bodyController: _bodyController,
            dataController: _dataController,
            targetIdController: _targetIdController,
            isSending: state.isSending,
            onTypeChanged: (value) => setState(() => _selectedType = value),
            onTopicChanged: (value) => setState(() => _selectedTopic = value),
            onSubmit: _handleSubmit,
          );

          if (!wide) {
            return ListView(children: [stats, const SizedBox(height: 16), form]);
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: stats),
              const SizedBox(width: 16),
              Expanded(child: form),
            ],
          );
        },
      ),
    );
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    Map<String, dynamic>? data;
    if (_dataController.text.trim().isNotEmpty) {
      try {
        data = jsonDecode(_dataController.text) as Map<String, dynamic>;
      } catch (e) {
        toastification.show(
          context: context,
          type: ToastificationType.error,
          title: const Text('Error'),
          description: const Text('Invalid JSON in Custom Data field.'),
          autoCloseDuration: const Duration(seconds: 4),
        );
        return;
      }
    }

    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    final controller = ref.read(notificationProvider.notifier);

    switch (_selectedType) {
      case 'broadcast':
        controller.sendBroadcastNotification(title: title, body: body, data: data);
      case 'topic':
        controller.sendTopicNotification(topic: _selectedTopic, title: title, body: body, data: data);
      case 'group_company':
        controller.sendGroupNotification(
          groupType: 'company',
          groupId: int.tryParse(_targetIdController.text.trim()) ?? _targetIdController.text.trim(),
          title: title,
          body: body,
          data: data,
        );
      case 'group_followers':
        controller.sendGroupNotification(
          groupType: 'followers',
          groupId: int.tryParse(_targetIdController.text.trim()) ?? _targetIdController.text.trim(),
          title: title,
          body: body,
          data: data,
        );
      case 'user':
        final userId = int.tryParse(_targetIdController.text.trim());
        if (userId == null) return;
        controller.sendUserNotification(userId: userId, title: title, body: body, data: data);
    }
  }
}

class _StatsPanel extends StatelessWidget {
  const _StatsPanel({required this.state});

  final NotificationState state;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Devices', '${state.stats.devices.total}', Iconsax.mobile),
      ('Active', '${state.stats.devices.active}', Iconsax.flash_circle),
      ('Sent', '${state.stats.notifications.sent}', Iconsax.send_2),
      ('Failed', '${state.stats.notifications.failed}', Iconsax.warning_2),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Delivery Stats',
            style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.4),
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(18)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(item.$3, color: AppTheme.primaryColor),
                    const Spacer(),
                    Text(
                      item.$2,
                      style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 22, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      item.$1,
                      style: TextStyle(fontFamily: AppTheme.fontFamily, color: Theme.of(context).hintColor),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _NotificationForm extends StatelessWidget {
  const _NotificationForm({
    required this.formKey,
    required this.selectedType,
    required this.selectedTopic,
    required this.titleController,
    required this.bodyController,
    required this.dataController,
    required this.targetIdController,
    required this.isSending,
    required this.onTypeChanged,
    required this.onTopicChanged,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final String selectedType;
  final String selectedTopic;
  final TextEditingController titleController;
  final TextEditingController bodyController;
  final TextEditingController dataController;
  final TextEditingController targetIdController;
  final bool isSending;
  final ValueChanged<String> onTypeChanged;
  final ValueChanged<String> onTopicChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(24)),
      child: Form(
        key: formKey,
        child: ListView(
          shrinkWrap: true,
          children: [
            const Text(
              'Compose Message',
              style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: selectedType,
              items: const [
                DropdownMenuItem(value: 'broadcast', child: Text('Broadcast (everyone)')),
                DropdownMenuItem(value: 'topic', child: Text('Topic')),
                DropdownMenuItem(value: 'group_company', child: Text('Company (all members)')),
                DropdownMenuItem(value: 'group_followers', child: Text('Post Followers')),
                DropdownMenuItem(value: 'user', child: Text('Specific User')),
              ],
              onChanged: (value) => onTypeChanged(value ?? 'broadcast'),
              decoration: const InputDecoration(labelText: 'Target Type'),
            ),
            const SizedBox(height: 12),
            if (selectedType == 'topic') ...[
              DropdownButtonFormField<String>(
                initialValue: selectedTopic,
                items: const [
                  DropdownMenuItem(value: 'general', child: Text('general')),
                  DropdownMenuItem(value: 'promotions', child: Text('promotions')),
                  DropdownMenuItem(value: 'news', child: Text('news')),
                ],
                onChanged: (value) => onTopicChanged(value ?? 'general'),
                decoration: const InputDecoration(labelText: 'Topic'),
              ),
              const SizedBox(height: 12),
            ],
            if (selectedType == 'group_company' || selectedType == 'group_followers' || selectedType == 'user') ...[
              TextFormField(
                controller: targetIdController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: switch (selectedType) {
                    'group_company' => 'Company ID',
                    'group_followers' => 'Post ID',
                    _ => 'User ID',
                  },
                ),
                validator: (value) => value == null || value.trim().isEmpty ? 'This field is required' : null,
              ),
              const SizedBox(height: 12),
            ],
            TextFormField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (value) => value == null || value.trim().isEmpty ? 'Title is required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: bodyController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Body'),
              validator: (value) => value == null || value.trim().isEmpty ? 'Body is required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: dataController,
              maxLines: 5,
              decoration: const InputDecoration(labelText: 'Data (JSON, optional)'),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: isSending ? null : onSubmit,
              icon: const Icon(Iconsax.send_2),
              label: Text(isSending ? 'Sending...' : 'Send Notification'),
            ),
          ],
        ),
      ),
    );
  }
}
