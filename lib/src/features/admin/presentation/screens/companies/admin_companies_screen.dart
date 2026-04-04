import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/src/core/widgets/loading_widgets.dart';
import 'package:solar_hub/src/features/admin/presentation/controllers/admin_companies_controller.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/company_card.dart';
import 'package:solar_hub/src/utils/app_theme.dart';
import 'package:go_router/go_router.dart';

class AdminCompaniesScreen extends ConsumerStatefulWidget {
  const AdminCompaniesScreen({super.key});

  @override
  ConsumerState<AdminCompaniesScreen> createState() => _AdminCompaniesScreenState();
}

class _AdminCompaniesScreenState extends ConsumerState<AdminCompaniesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String?> _statusFilters = [null, 'pending', 'active', 'rejected'];
  final List<String> _tabLabels = ['All', 'Pending', 'Active', 'Rejected'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabLabels.length, vsync: this);
    _tabController.addListener(_handleTabChange);
    Future.microtask(() => ref.read(adminCompaniesProvider.notifier).fetchCompanies());
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) return;
    final status = _statusFilters[_tabController.index];
    ref.read(adminCompaniesProvider.notifier).fetchCompanies(status: status);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminCompaniesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Joined Companies',
          style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.bold, fontSize: 18.sp),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primaryColor,
          indicatorWeight: 3.h,
          labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, fontFamily: AppTheme.fontFamily),
          tabs: _tabLabels.map((label) => Tab(text: label)).toList(),
        ),
      ),
      body: state.isLoading && state.companies.isEmpty
          ? _buildLoadingState()
          : RefreshIndicator(
              onRefresh: () => ref.read(adminCompaniesProvider.notifier).fetchCompanies(status: _statusFilters[_tabController.index]),
              color: AppTheme.primaryColor,
              child: _buildContent(state),
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
            style: TextStyle(fontSize: 14.sp, color: Colors.grey, fontFamily: AppTheme.fontFamily),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(AdminCompaniesState state) {
    if (state.companies.isEmpty && !state.isLoading) {
      return AdminEmptyState(
        icon: Iconsax.building_3_bold,
        title: 'No Companies Found',
        subtitle: 'There are no companies with this status.',
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(20.w),
      itemCount: state.companies.length,
      separatorBuilder: (context, index) => SizedBox(height: 16.h),
      itemBuilder: (context, index) {
        final company = state.companies[index];
        return CompanyCard(
          company: company,
          onTap: () => context.push('/admin/companies/${company.id}'),
        ).animate().fadeIn(delay: (index * 50).ms).slideY(begin: 0.1, end: 0);
      },
    );
  }
}
