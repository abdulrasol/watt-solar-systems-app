import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:solar_hub/src/core/layout/app_breakpoints.dart';
import 'package:solar_hub/src/core/widgets/loading_widgets.dart';
import 'package:solar_hub/src/core/widgets/pre_scaffold.dart';
import 'package:solar_hub/src/features/admin/presentation/controllers/admin_companies_controller.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/company_card.dart';
import 'package:solar_hub/src/utils/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:solar_hub/src/utils/helper_methods.dart';

class AdminCompaniesScreen extends ConsumerStatefulWidget {
  const AdminCompaniesScreen({super.key});

  @override
  ConsumerState<AdminCompaniesScreen> createState() =>
      _AdminCompaniesScreenState();
}

class _AdminCompaniesScreenState extends ConsumerState<AdminCompaniesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;

  // All status filters as per API: pending, active, rejected, suspended, cancelled
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

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(adminCompaniesProvider.notifier).fetchNextPage();
    }
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) return;
    final status = _statusFilters[_tabController.index];
    ref
        .read(adminCompaniesProvider.notifier)
        .fetchCompanies(status: status, isRefresh: true);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminCompaniesProvider);

    return PreScaffold(
      title: 'Companies',
      child: state.isLoading && state.companies.isEmpty
          ? _buildLoadingState()
          : RefreshIndicator(
              onRefresh: () => ref
                  .read(adminCompaniesProvider.notifier)
                  .fetchCompanies(
                    status: _statusFilters[_tabController.index],
                    isRefresh: true,
                  ),
              color: AppTheme.primaryColor,
              child: Column(
                children: [
                  _buildTabBar(),
                  Expanded(child: _buildContent(state)),
                ],
              ),
            ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: AppTheme.primaryColor,
        unselectedLabelColor: Colors.grey,
        indicatorColor: AppTheme.primaryColor,
        indicatorWeight: 3.h,
        labelStyle: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.bold,
          fontFamily: AppTheme.fontFamily,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 13.sp,
          fontFamily: AppTheme.fontFamily,
        ),
        tabs: _tabLabels.map((label) => Tab(text: label)).toList(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LoadingWidget.widget(context: context, size: 30),
          SizedBox(height: 16.h),
          Text(
            'Loading Companies...',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey,
              fontFamily: AppTheme.fontFamily,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(AdminCompaniesState state) {
    if (state.companies.isEmpty && !state.isLoading) {
      return AdminEmptyState(
        icon: Icons.business_outlined,
        title: 'No Companies Found',
        subtitle: 'There are no companies with this status.',
      );
    }

    final columns = AppBreakpoints.adaptiveGridCount(
      context,
      mobile: 1,
      tablet: 2,
      desktop: 2,
    );

    return GridView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: AppBreakpoints.isMobile(context) ? 2.25 : 2.7,
      ),
      itemCount: state.companies.length + (state.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.companies.length) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: LoadingWidget.widget(context: context, size: 25),
            ),
          );
        }

        final company = state.companies[index];
        dPrint('company state: ${company.status}');
        return CompanyCard(
              company: company,
              onTap: () => context.push('/admin/companies/${company.id}'),
            )
            .animate()
            .fadeIn(delay: (index % 10 * 50).ms)
            .slideY(begin: 0.1, end: 0);
      },
    );
  }
}
