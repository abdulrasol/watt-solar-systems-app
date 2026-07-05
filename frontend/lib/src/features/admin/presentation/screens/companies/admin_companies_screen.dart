import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solar_hub/src/features/admin/presentation/controllers/admin_companies_controller.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/admin_page_scaffold.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/company_card.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class AdminCompaniesScreen extends ConsumerStatefulWidget {
  const AdminCompaniesScreen({super.key});

  @override
  ConsumerState<AdminCompaniesScreen> createState() =>
      _AdminCompaniesScreenState();
}

class _AdminCompaniesScreenState extends ConsumerState<AdminCompaniesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final ScrollController _scrollController;

  final List<String?> _statusFilters = [
    null,
    'pending',
    'active',
    'rejected',
    'suspended',
    'cancelled',
  ];

  final List<String> _tabLabels = [
    'All',
    'Pending',
    'Active',
    'Rejected',
    'Suspended',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabLabels.length, vsync: this);
    _tabController.addListener(_handleTabChange);
    _scrollController = ScrollController()..addListener(_onScroll);
    Future.microtask(
      () => ref
          .read(adminCompaniesProvider.notifier)
          .fetchCompanies(isRefresh: true),
    );
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) return;
    ref.read(adminCompaniesProvider.notifier).fetchCompanies(
          status: _statusFilters[_tabController.index],
          isRefresh: true,
        );
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(adminCompaniesProvider.notifier).fetchNextPage();
    }
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_handleTabChange)
      ..dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminCompaniesProvider);

    return AdminPageScaffold(
      // title: 'Companies',
      // subtitle: 'Company data loads when this section opens.',
      child: state.isLoading && state.companies.isEmpty
          ? const AdminLoadingState(
              icon: Icons.business_rounded,
              message: 'Loading companies...',
            )
          : Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelColor: AppTheme.primaryColor,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: AppTheme.primaryColor,
                    tabs: _tabLabels.map((label) => Tab(text: label)).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(child: _buildContent(context, state)),
              ],
            ),
    );
  }

  Widget _buildContent(BuildContext context, AdminCompaniesState state) {
    if (state.error != null && state.companies.isEmpty) {
      return AdminErrorState(
        error: state.error!,
        onRetry: () => ref.read(adminCompaniesProvider.notifier).fetchCompanies(
              status: _statusFilters[_tabController.index],
              isRefresh: true,
            ),
      );
    }

    if (state.companies.isEmpty) {
      return const AdminEmptyState(
        icon: Icons.business_center_outlined,
        title: 'No companies found',
        subtitle: 'No companies match the active filter.',
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(adminCompaniesProvider.notifier).fetchCompanies(
            status: _statusFilters[_tabController.index],
            isRefresh: true,
          ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final columns = width >= 1180
              ? 3
              : width >= 760
              ? 2
              : 1;

          return GridView.builder(
            controller: _scrollController,
            itemCount: state.companies.length + (state.hasMore ? 1 : 0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: columns == 1 ? 2.1 : 2.3,
            ),
            itemBuilder: (context, index) {
              if (index == state.companies.length) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryColor,
                  ),
                );
              }

              final company = state.companies[index];
              return CompanyCard(
                company: company,
                onTap: () => context.go('/admin/companies/${company.id}'),
              );
            },
          );
        },
      ),
    );
  }
}
