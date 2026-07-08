import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:watt/l10n/app_localizations.dart';
import 'package:watt/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:watt/src/features/company_dashboard/presentation/widgets/company_management_widgets.dart';
import 'package:watt/src/features/posters/presentation/controllers/company_posters_provider.dart';
import 'package:watt/src/features/posters/presentation/widgets/poster_card.dart';
import 'package:watt/src/features/posters/presentation/widgets/poster_delete_dialog.dart';
import 'package:watt/src/core/widgets/branded_empty_state.dart';
import 'package:watt/src/services/toast_service.dart';
import 'package:watt/src/shared/widgets/app_button.dart';

class CompanyPostersScreen extends ConsumerStatefulWidget {
  final bool embedded;

  const CompanyPostersScreen({super.key, this.embedded = false});

  @override
  ConsumerState<CompanyPostersScreen> createState() => _CompanyPostersScreenState();
}

class _CompanyPostersScreenState extends ConsumerState<CompanyPostersScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(() {
      final companyId = ref.read(authProvider).company?.id;
      if (companyId != null) {
        ref.read(companyPostersProvider.notifier).fetchPosters(companyId, refresh: true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController..removeListener(_onScroll)..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(companyPostersProvider);
    final auth = ref.watch(authProvider);
    final companyId = auth.company?.id;

    if (companyId == null) {
      return Center(child: Text(l10n.not_found));
    }

    final list = _buildList(l10n, companyId, state);

    if (widget.embedded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: CompanySectionIntro(
              title: l10n.posters,
              subtitle: l10n.posters_subtitle,
              action: AppButton(
                text: l10n.poster_create,
                icon: Iconsax.add_circle,
                onPressed: () => context.push('/companies/dashboard/content/posters/create'),
              ),
            ),
          ),
          Expanded(child: list),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.posters)),
      body: list,
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/companies/dashboard/content/posters/create'),
        child: const Icon(Iconsax.add),
      ),
    );
  }

  Widget _buildList(AppLocalizations l10n, int companyId, CompanyPostersState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null && state.items.isEmpty || state.items.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async => ref.read(companyPostersProvider.notifier).fetchPosters(companyId, refresh: true),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: 300,
            child: state.error != null
                ? BrandedEmptyState(icon: Icons.error_outline, title: state.error!)
                : BrandedEmptyState(icon: Icons.wifi_off, title: l10n.posters_empty),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => ref.read(companyPostersProvider.notifier).fetchPosters(companyId, refresh: true),
      child: Column(
        children: [
          _buildFilterBar(l10n, companyId),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
              itemBuilder: (_, i) {
                if (i == state.items.length) {
                  return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(strokeWidth: 2)));
                }
                final poster = state.items[i];
                return PosterCard(
                  poster: poster,
                  onToggleActive: poster.isApproved ? () => ref.read(companyPostersProvider.notifier).toggleActive(companyId, poster.id) : null,
                  onEdit: () => context.push('/companies/dashboard/content/posters/edit/${poster.id}'),
                  onDelete: () async {
                    final confirmed = await showPosterDeleteDialog(context);
                    if (confirmed && mounted) {
                      final error = await ref.read(companyPostersProvider.notifier).deletePoster(companyId, poster.id);
                      if (error != null && mounted) ToastService.error(context, 'Error', error);
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(AppLocalizations l10n, int companyId) {
    final current = ref.watch(companyPostersProvider).statusFilter;
    final filters = <String?, String>{
      null: l10n.all,
      'pending': l10n.status_pending,
      'approved': l10n.status_accepted,
      'rejected': l10n.status_rejected
    };
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: filters.entries.map((e) {
          final selected = current == e.key;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(e.value, style: TextStyle(fontSize: 12, color: selected ? Colors.white : null)),
              selected: selected,
              onSelected: (_) => ref.read(companyPostersProvider.notifier).setStatusFilter(companyId, e.key),
              selectedColor: const Color(0xFF00BFA5),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 300) {
      final auth = ref.read(authProvider);
      final companyId = auth.company?.id;
      if (companyId != null) {
        ref.read(companyPostersProvider.notifier).loadMore(companyId);
      }
    }
  }
}
