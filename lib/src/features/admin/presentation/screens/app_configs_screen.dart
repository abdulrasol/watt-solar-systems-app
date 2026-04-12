import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/src/features/admin/domain/entities/app_config.dart';
import 'package:solar_hub/src/features/admin/presentation/controllers/app_config_controller.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/admin_page_scaffold.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/admin_widgets.dart';
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

    return AdminPageScaffold(
      // title: 'App Configurations',
      // subtitle: 'Flags and settings are fetched only for this route.',
      actions: [
        FilledButton.icon(
          onPressed: state.isSubmitting ? null : () => _showConfigDialog(context),
          icon: const Icon(Iconsax.add_bold),
          label: const Text('New Config'),
        ),
      ],
      child: state.isLoading
          ? const AdminLoadingState(
              icon: Iconsax.setting_bold,
              message: 'Loading configurations...',
            )
          : state.error != null && state.configs.isEmpty
          ? AdminErrorState(
              error: state.error!,
              onRetry: () => ref.read(appConfigProvider.notifier).fetchConfigs(),
            )
          : _buildContent(context, state),
    );
  }

  Widget _buildContent(BuildContext context, AppConfigState state) {
    if (state.configs.isEmpty) {
      return const AdminEmptyState(
        icon: Iconsax.setting_2_bold,
        title: 'No configurations found',
        subtitle: 'Create your first configuration flag.',
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(appConfigProvider.notifier).fetchConfigs(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final columns = width >= 1180
              ? 3
              : width >= 760
              ? 2
              : 1;

          if (columns == 1) {
            return ListView.separated(
              itemCount: state.configs.length,
              separatorBuilder: (_, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final config = state.configs[index];
                return _ConfigCard(
                  config: config,
                  isSubmitting: state.isSubmitting,
                  onTap: () => _showConfigDialog(context, config: config),
                  onDelete: () => ref
                      .read(appConfigProvider.notifier)
                      .deleteConfig(config.key),
                  onToggle: (value) => ref
                      .read(appConfigProvider.notifier)
                      .toggleConfig(config.key, value),
                );
              },
            );
          }

          return GridView.builder(
            itemCount: state.configs.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: columns == 2 ? 2.0 : 2.15,
            ),
            itemBuilder: (context, index) {
              final config = state.configs[index];
              return _ConfigCard(
                config: config,
                isSubmitting: state.isSubmitting,
                onTap: () => _showConfigDialog(context, config: config),
                onDelete: () => ref
                    .read(appConfigProvider.notifier)
                    .deleteConfig(config.key),
                onToggle: (value) => ref
                    .read(appConfigProvider.notifier)
                    .toggleConfig(config.key, value),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showConfigDialog(
    BuildContext context, {
    AppConfig? config,
  }) async {
    final keyController = TextEditingController(text: config?.key ?? '');
    final descriptionController = TextEditingController(
      text: config?.description ?? '',
    );
    var value = config?.value ?? false;

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(config == null ? 'Create Config' : 'Edit Config'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: keyController,
                enabled: config == null,
                decoration: const InputDecoration(labelText: 'Key'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                value: value,
                contentPadding: EdgeInsets.zero,
                title: const Text('Enabled'),
                onChanged: (nextValue) => setState(() => value = nextValue),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (config == null) {
                  ref.read(appConfigProvider.notifier).createConfig(
                        key: keyController.text,
                        value: value,
                        description: descriptionController.text,
                      );
                } else {
                  ref.read(appConfigProvider.notifier).updateConfig(
                        oldKey: config.key,
                        newKey: keyController.text,
                        value: value,
                        description: descriptionController.text,
                      );
                }
                Navigator.pop(context);
              },
              child: Text(config == null ? 'Create' : 'Save'),
            ),
          ],
        ),
      ),
    );

    keyController.dispose();
    descriptionController.dispose();
  }
}

class _ConfigCard extends StatelessWidget {
  const _ConfigCard({
    required this.config,
    required this.isSubmitting,
    required this.onTap,
    required this.onDelete,
    required this.onToggle,
  });

  final AppConfig config;
  final bool isSubmitting;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: config.value
                ? AppTheme.successColor.withValues(alpha: 0.4)
                : Colors.grey.withValues(alpha: 0.2),
          ),
        ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (config.value ? AppTheme.successColor : Colors.grey)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      config.value
                          ? Iconsax.tick_circle_bold
                          : Iconsax.close_circle_bold,
                      color: config.value ? AppTheme.successColor : Colors.grey,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: isSubmitting ? null : onDelete,
                    icon: const Icon(
                      Iconsax.trash_bold,
                      color: AppTheme.errorColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                config.key,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if ((config.description ?? '').isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  config.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 13,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      config.value ? 'Enabled' : 'Disabled',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontFamily: AppTheme.fontFamily),
                    ),
                  ),
                  Switch.adaptive(
                    value: config.value,
                    onChanged: isSubmitting ? null : onToggle,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
