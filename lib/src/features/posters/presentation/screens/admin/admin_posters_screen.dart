import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/widgets/branded_empty_state.dart';
import 'package:solar_hub/src/features/posters/domain/entities/poster_entity.dart';
import 'package:solar_hub/src/features/posters/presentation/controllers/admin_posters_provider.dart';
import 'package:solar_hub/src/features/posters/presentation/widgets/poster_status_badge.dart';

class AdminPostersScreen extends ConsumerStatefulWidget {
  const AdminPostersScreen({super.key});

  @override
  ConsumerState<AdminPostersScreen> createState() => _AdminPostersScreenState();
}

class _AdminPostersScreenState extends ConsumerState<AdminPostersScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _scrollController..removeListener(_onScroll)..dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(adminPostersProvider);

    return Column(
      children: [
        _buildSearchBar(l10n),
        _buildFilterBar(l10n),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => ref.read(adminPostersProvider.notifier).fetchPosters(refresh: true),
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.error != null && state.items.isEmpty
                    ? BrandedEmptyState(icon: Icons.error_outline, title: state.error!)
                    : state.items.isEmpty
                        ? BrandedEmptyState(icon: Icons.wifi_off, title: l10n.posters_empty)
                        : _buildTable(l10n, state),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by company or text...',
          prefixIcon: const Icon(Icons.search, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(adminPostersProvider.notifier).setSearchQuery(null);
                  },
                )
              : null,
        ),
        onSubmitted: (v) => ref.read(adminPostersProvider.notifier).setSearchQuery(v.trim().isEmpty ? null : v.trim()),
        onChanged: (v) {
          if (v.trim().isEmpty && ref.read(adminPostersProvider).searchQuery != null) {
            ref.read(adminPostersProvider.notifier).setSearchQuery(null);
          }
        },
      ),
    );
  }

  Widget _buildFilterBar(AppLocalizations l10n) {
    final state = ref.watch(adminPostersProvider);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          _filterChip(l10n.status, state.statusFilter, [
            {'val': 'pending', 'label': l10n.status_pending},
            {'val': 'approved', 'label': l10n.status_accepted},
            {'val': 'rejected', 'label': l10n.status_rejected},
          ], (v) => ref.read(adminPostersProvider.notifier).setStatusFilter(v), l10n),
          const SizedBox(width: 8),
          _filterChip('Validity', state.validityFilter, [
            {'val': 'active', 'label': l10n.active},
            {'val': 'expired', 'label': 'Expired'},
          ], (v) => ref.read(adminPostersProvider.notifier).setValidityFilter(v), l10n),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String? current, List<Map<String, String>> options, void Function(String?) onSelected, AppLocalizations l10n) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label: ', style: const TextStyle(fontSize: 12)),
        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: FilterChip(
            label: Text(l10n.all, style: TextStyle(fontSize: 11, color: current == null ? Colors.white : null)),
            selected: current == null,
            onSelected: (_) => onSelected(null),
            selectedColor: const Color(0xFF00BFA5),
            visualDensity: VisualDensity.compact,
          ),
        ),
        ...options.map((opt) {
          final selected = current == opt['val'];
          return Padding(
            padding: const EdgeInsets.only(right: 4),
            child: FilterChip(
              label: Text(opt['label']!, style: TextStyle(fontSize: 11, color: selected ? Colors.white : null)),
              selected: selected,
              onSelected: (_) => onSelected(selected ? null : opt['val']),
              selectedColor: const Color(0xFF00BFA5),
              visualDensity: VisualDensity.compact,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTable(AppLocalizations l10n, AdminPostersState state) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (_, i) {
        if (i == state.items.length) {
          return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(strokeWidth: 2)));
        }
        final poster = state.items[i];
        return Card(
          clipBehavior: Clip.hardEdge,
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            dense: true,
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: poster.imageUrl != null
                  ? Image.network(poster.imageUrl!, width: 48, height: 48, fit: BoxFit.cover, cacheWidth: 96, cacheHeight: 96)
                  : Container(width: 48, height: 48, color: Colors.grey[200], child: const Icon(Icons.image, size: 24, color: Colors.grey)),
            ),
            title: Text(poster.companyName ?? 'Company #${poster.companyId}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            subtitle: Row(
              children: [
                Expanded(child: Text(poster.text ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11))),
                const SizedBox(width: 8),
                PosterStatusBadge(poster: poster),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (poster.isPending)
                  IconButton(
                    icon: const Icon(Icons.gavel, size: 18),
                    onPressed: () => _showReviewDialog(poster),
                    tooltip: 'Review',
                  ),
                if (poster.isApproved)
                  IconButton(
                    icon: const Icon(Icons.schedule, size: 18),
                    onPressed: () => _showExtendDialog(poster),
                    tooltip: 'Extend',
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showReviewDialog(PosterEntity poster) {
    final statusCtl = TextEditingController(text: 'approved');
    final durationCtl = TextEditingController(text: '7');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Review Poster'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Company: ${poster.companyName ?? "N/A"}', style: const TextStyle(fontSize: 12)),
            Text('Text: ${poster.text ?? "N/A"}', style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: 'approved',
              decoration: const InputDecoration(labelText: 'Decision', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'approved', child: Text('Approve')),
                DropdownMenuItem(value: 'rejected', child: Text('Reject')),
              ],
              onChanged: (v) => statusCtl.text = v!,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: durationCtl,
              decoration: const InputDecoration(labelText: 'Duration (days)', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final status = statusCtl.text;
              final duration = int.tryParse(durationCtl.text) ?? 7;
              Navigator.pop(ctx);
              final error = await ref.read(adminPostersProvider.notifier).reviewPoster(
                poster.id,
                status,
                durationDays: duration,
              );
              if (error != null && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _showExtendDialog(PosterEntity poster) {
    final dateCtl = TextEditingController(
      text: poster.expiresAt?.toIso8601String().substring(0, 16) ?? '',
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Extend Poster'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Company: ${poster.companyName ?? "N/A"}', style: const TextStyle(fontSize: 12)),
            Text('Expires: ${poster.expiresAt?.toString() ?? "N/A"}', style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 12),
            TextFormField(
              controller: dateCtl,
              decoration: const InputDecoration(labelText: 'New Expiry (ISO)', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final dateStr = dateCtl.text;
              Navigator.pop(ctx);
              final error = await ref.read(adminPostersProvider.notifier).extendPoster(poster.id, dateStr);
              if (error != null && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
              }
            },
            child: const Text('Extend'),
          ),
        ],
      ),
    );
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 300) {
      ref.read(adminPostersProvider.notifier).loadMore();
    }
  }
}
