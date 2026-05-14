import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:solar_hub/src/core/widgets/wd_image_preview.dart';
import 'package:solar_hub/src/features/admin/presentation/controllers/admin_systems_controller.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/admin_page_scaffold.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:solar_hub/src/features/calculations/domain/entities/system_model.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class AdminSystemsScreen extends ConsumerStatefulWidget {
  const AdminSystemsScreen({super.key});

  @override
  ConsumerState<AdminSystemsScreen> createState() => _AdminSystemsScreenState();
}

class _AdminSystemsScreenState extends ConsumerState<AdminSystemsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(adminSystemsProvider.notifier).fetchSystems(isRefresh: true),
    );
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(adminSystemsProvider.notifier).fetchNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminSystemsProvider);

    return AdminPageScaffold(
      actions: [
        IconButton(
          onPressed:
              () => ref.read(adminSystemsProvider.notifier).fetchSystems(
                isRefresh: true,
              ),
          icon: const Icon(Iconsax.refresh_bold),
        ),
      ],
      child:
          state.isLoading
              ? const AdminLoadingState(
                icon: Iconsax.sun_1_bold,
                message: 'Loading systems...',
              )
              : state.error != null
              ? AdminErrorState(
                error: state.error!,
                onRetry:
                    () => ref.read(adminSystemsProvider.notifier).fetchSystems(
                      isRefresh: true,
                    ),
              )
              : _buildContent(context, state),
    );
  }

  Widget _buildContent(BuildContext context, AdminSystemsState state) {
    if (state.systems.isEmpty) {
      return const AdminEmptyState(
        icon: Iconsax.sun_fog_bold,
        title: 'No systems found',
        subtitle: 'User solar systems list is currently empty.',
      );
    }

    return RefreshIndicator(
      onRefresh:
          () => ref.read(adminSystemsProvider.notifier).fetchSystems(
            isRefresh: true,
          ),
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.only(bottom: 100),
        itemCount: state.systems.length + (state.isMoreLoading ? 1 : 0),
        separatorBuilder: (_, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == state.systems.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }
          final system = state.systems[index];
          return _SystemAdminCard(system: system);
        },
      ),
    );
  }
}

class _SystemAdminCard extends StatelessWidget {
  const _SystemAdminCard({required this.system});

  final SystemModel system;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateStr = system.createdAt != null 
        ? DateFormat('yyyy-MM-dd').format(system.createdAt!) 
        : 'N/A';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: WdImagePreview(
                  imageUrl: system.imageUrl ?? '',
                  size: 60,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      system.systemName ?? 'Unnamed System',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Owner: ${system.userName}',
                      style: TextStyle(fontSize: 13, color: Theme.of(context).hintColor),
                    ),
                  ],
                ),
              ),
              _VerificationBadge(status: system.verificationStatus.name),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _InfoItem(label: 'Capacity', value: '${system.totalCapacityKw ?? 0} kW'),
              _InfoItem(label: 'Panels', value: '${system.panelCount}'),
              _InfoItem(label: 'Created', value: dateStr),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Theme.of(context).hintColor),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _VerificationBadge extends StatelessWidget {
  const _VerificationBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status.toLowerCase()) {
      case 'verified':
        color = Colors.green;
        break;
      case 'rejected':
        color = AppTheme.errorColor;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
