import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/utils/app_enums.dart';
import 'package:solar_hub/src/utils/app_theme.dart';
import '../providers/offers_provider.dart';
import '../widgets/cards/request_card.dart';
import '../widgets/cards/offer_card.dart';

class AdminOffersDashboard extends ConsumerStatefulWidget {
  const AdminOffersDashboard({super.key});

  @override
  ConsumerState<AdminOffersDashboard> createState() => _AdminOffersDashboardState();
}

class _AdminOffersDashboardState extends ConsumerState<AdminOffersDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _requestsScrollController = ScrollController();
  final ScrollController _offersScrollController = ScrollController();

  RequestStatus? _requestFilter;
  OfferStatus? _offerFilter;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _refetchData();
      }
    });

    _requestsScrollController.addListener(() {
      if (_requestsScrollController.position.pixels >= _requestsScrollController.position.maxScrollExtent - 200) {
        ref.read(offersProvider.notifier).adminRequestsNextPage();
      }
    });

    _offersScrollController.addListener(() {
      if (_offersScrollController.position.pixels >= _offersScrollController.position.maxScrollExtent - 200) {
        ref.read(offersProvider.notifier).adminOffersNextPage();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _refetchData());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _requestsScrollController.dispose();
    _offersScrollController.dispose();
    super.dispose();
  }

  void _refetchData() {
    if (_tabController.index == 0) {
      ref.read(offersProvider.notifier).getAllRequests(isRefresh: true);
    } else {
      ref.read(offersProvider.notifier).getAllOffers(isRefresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(offersProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.admin_marketplace_oversight),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryColor,
          tabs: [
            Tab(text: l10n.all_requests, icon: const Icon(Iconsax.document_text_bold)),
            Tab(text: l10n.all_offers, icon: const Icon(Iconsax.receipt_2_bold)),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: TabBarView(controller: _tabController, children: [_buildRequestsList(state), _buildOffersList(state)]),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    final isRequestTab = _tabController.index == 0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      color: Colors.grey.withValues(alpha: 0.05),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: isRequestTab
                    ? RequestStatus.values
                          .map(
                            (s) => _buildFilterChip(s.localizedLabel(AppLocalizations.of(context)!), _requestFilter == s, () {
                              setState(() => _requestFilter = _requestFilter == s ? null : s);
                              ref.read(offersProvider.notifier).updateAdminRequestsStatus(_requestFilter?.name);
                            }),
                          )
                          .toList()
                    : OfferStatus.values
                          .map(
                            (s) => _buildFilterChip(s.localizedLabel(AppLocalizations.of(context)!), _offerFilter == s, () {
                              setState(() => _offerFilter = _offerFilter == s ? null : s);
                              ref.read(offersProvider.notifier).updateAdminOffersStatus(_offerFilter?.name);
                            }),
                          )
                          .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onSelected) {
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(fontSize: 10.sp, color: isSelected ? Colors.white : Colors.black),
        ),
        selected: isSelected,
        onSelected: (_) => onSelected(),
        selectedColor: AppTheme.primaryColor,
        checkmarkColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
      ),
    );
  }

  Widget _buildRequestsList(OffersState state) {
    if (state.isLoading && state.adminRequests.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!state.isLoading && state.adminRequests.isEmpty) {
      return _buildEmptyState(AppLocalizations.of(context)!.no_requests_found);
    }

    return RefreshIndicator(
      onRefresh: () async => ref.read(offersProvider.notifier).getAllRequests(isRefresh: true),
      child: ListView.separated(
        controller: _requestsScrollController,
        padding: EdgeInsets.all(20.r),
        itemCount: state.adminRequests.length + (state.adminRequestsHasMore ? 1 : 0),
        separatorBuilder: (c, i) => SizedBox(height: 16.h),
        itemBuilder: (context, index) {
          if (index == state.adminRequests.length) {
            return const Center(
              child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()),
            );
          }
          final request = state.adminRequests[index];
          return RequestCard(request: request, onTap: () {});
        },
      ),
    );
  }

  Widget _buildOffersList(OffersState state) {
    if (state.isLoading && state.adminOffers.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!state.isLoading && state.adminOffers.isEmpty) {
      return _buildEmptyState(AppLocalizations.of(context)!.no_offers_found);
    }

    return RefreshIndicator(
      onRefresh: () async => ref.read(offersProvider.notifier).getAllOffers(isRefresh: true),
      child: ListView.separated(
        controller: _offersScrollController,
        padding: EdgeInsets.all(20.r),
        itemCount: state.adminOffers.length + (state.adminOffersHasMore ? 1 : 0),
        separatorBuilder: (c, i) => SizedBox(height: 16.h),
        itemBuilder: (context, index) {
          if (index == state.adminOffers.length) {
            return const Center(
              child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()),
            );
          }
          final offer = state.adminOffers[index];
          return OfferCard(offer: offer, onTap: () {});
        },
      ),
    );
  }

  Widget _buildEmptyState(String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Iconsax.search_status_bold, size: 64, color: Colors.grey),
          SizedBox(height: 16.h),
          Text(
            title,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
