import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/src/features/admin/presentation/controllers/notification_controller.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/admin_page_scaffold.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:solar_hub/src/utils/app_theme.dart';
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
            return const AdminLoadingState(icon: Iconsax.notification_bing_bold, message: 'Loading notification tools...');
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
      data = jsonDecode(_dataController.text) as Map<String, dynamic>;
    }

    final controller = ref.read(notificationProvider.notifier);
    if (_selectedType == 'broadcast') {
      controller.sendBroadcastNotification(title: _titleController.text.trim(), body: _bodyController.text.trim(), data: data);
      return;
    }

    controller.sendTopicNotification(topic: _selectedTopic, title: _titleController.text.trim(), body: _bodyController.text.trim(), data: data);
  }
}

class _StatsPanel extends StatelessWidget {
  const _StatsPanel({required this.state});

  final NotificationState state;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Devices', '${state.stats.devices.total}', Iconsax.mobile_bold),
      ('Active', '${state.stats.devices.active}', Iconsax.flash_circle_bold),
      ('Sent', '${state.stats.notifications.sent}', Iconsax.send_2_bold),
      ('Failed', '${state.stats.notifications.failed}', Iconsax.warning_2_bold),
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
                DropdownMenuItem(value: 'broadcast', child: Text('Broadcast')),
                DropdownMenuItem(value: 'topic', child: Text('Topic')),
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
              icon: const Icon(Iconsax.send_2_bold),
              label: Text(isSending ? 'Sending...' : 'Send Notification'),
            ),
          ],
        ),
      ),
    );
  }
}
