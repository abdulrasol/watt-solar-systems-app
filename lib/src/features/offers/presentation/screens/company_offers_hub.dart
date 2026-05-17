import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/offers/presentation/screens/involves_catalog_screen.dart';
import 'package:solar_hub/src/features/offers/presentation/screens/offer_details_screen.dart';
import 'package:solar_hub/src/utils/app_enums.dart';
import 'package:solar_hub/src/utils/app_theme.dart';
import '../providers/offers_provider.dart';
import '../widgets/cards/request_card.dart';
import '../widgets/cards/offer_card.dart';
import 'package:solar_hub/src/core/widgets/branded_empty_state.dart';
import 'package:solar_hub/src/features/offers/domain/entities/solar_request.dart';
import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';
import '../widgets/bottomsheets/request_detail_bottom_sheet.dart';

class CompanyOffersHub extends ConsumerStatefulWidget {
  final bool embedded;
  const CompanyOffersHub({super.key, this.embedded = false});

  @override
  ConsumerState<CompanyOffersHub> createState() => _CompanyOffersHubState();
}

class _CompanyOffersHubState extends ConsumerState<CompanyOffersHub>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _availableScrollController = ScrollController();
  final ScrollController _myOffersScrollController = ScrollController();

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

    _availableScrollController.addListener(() {
      if (_availableScrollController.position.pixels >=
          _availableScrollController.position.maxScrollExtent - 200) {
        ref.read(offersProvider.notifier).availableRequestsNextPage();
      }
    });

    _myOffersScrollController.addListener(() {
      if (_myOffersScrollController.position.pixels >=
          _myOffersScrollController.position.maxScrollExtent - 200) {
        ref.read(offersProvider.notifier).myOffersNextPage();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _refetchData());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _availableScrollController.dispose();
    _myOffersScrollController.dispose();
    super.dispose();
  }

  void _refetchData() {
    if (_tabController.index == 0) {
      ref.read(offersProvider.notifier).getAvailableRequests(isRefresh: true);
    } else {
      ref.read(offersProvider.notifier).getMyOffers(isRefresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(offersProvider);
    final l10n = AppLocalizations.of(context)!;

    final content = Column(
      children: [
        if (widget.embedded)
          TabBar(
            controller: _tabController,
            indicatorColor: AppTheme.primaryColor,
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(
                text: l10n.available_requests,
                icon: const Icon(Iconsax.radar_bold),
              ),
              Tab(text: l10n.my_bids, icon: const Icon(Iconsax.briefcase_bold)),
            ],
          ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [_buildAvailableRequests(state), _buildMyOffers(state)],
          ),
        ),
      ],
    );

    if (widget.embedded) {
      return content;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.offers_marketplace),
        actions: [
          IconButton(
            tooltip: l10n.catalog_tooltip,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const InvolvesCatalogScreen(),
                ),
              );
            },
            icon: const Icon(Iconsax.receipt_item_bold),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryColor,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(
              text: l10n.available_requests,
              icon: const Icon(Iconsax.radar_bold),
            ),
            Tab(text: l10n.my_bids, icon: const Icon(Iconsax.briefcase_bold)),
          ],
        ),
      ),
      body: content,
    );
  }

  Widget _buildAvailableRequests(OffersState state) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        _buildFilterBar(),
        Expanded(
          child: state.isLoading && state.availableRequests.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : state.availableRequests.isEmpty
              ? BrandedEmptyState(
                  icon: Iconsax.radar_bold,
                  title: l10n.no_requests_found,
                  subtitle: l10n.new_projects_will_appear_here,
                )
              : RefreshIndicator(
                  onRefresh: () async => ref
                      .read(offersProvider.notifier)
                      .getAvailableRequests(isRefresh: true),
                  child: ListView.separated(
                    controller: _availableScrollController,
                    padding: EdgeInsets.all(20.r),
                    itemCount:
                        state.availableRequests.length +
                        (state.availableRequestsHasMore ? 1 : 0),
                    separatorBuilder: (c, i) => SizedBox(height: 16.h),
                    itemBuilder: (context, index) {
                      if (index == state.availableRequests.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      final request = state.availableRequests[index];
                      return RequestCard(
                        request: request,
                        onTap: () => _showRequestDetails(request),
                        onConvertToLead: () => _handleConvertToLead(request),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildMyOffers(OffersState state) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        _buildFilterBar(),
        Expanded(
          child: state.isLoading && state.myOffers.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : state.myOffers.isEmpty
              ? BrandedEmptyState(
                  icon: Iconsax.briefcase_bold,
                  title: l10n.no_offers_found,
                  subtitle: l10n.browse_requests_to_start_bidding,
                )
              : RefreshIndicator(
                  onRefresh: () async => ref
                      .read(offersProvider.notifier)
                      .getMyOffers(isRefresh: true),
                  child: ListView.separated(
                    controller: _myOffersScrollController,
                    padding: EdgeInsets.all(20.r),
                    itemCount:
                        state.myOffers.length + (state.myOffersHasMore ? 1 : 0),
                    separatorBuilder: (c, i) => SizedBox(height: 16.h),
                    itemBuilder: (context, index) {
                      if (index == state.myOffers.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      final offer = state.myOffers[index];
                      return OfferCard(
                        offer: offer,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => OfferDetailsScreen(
                              offer: offer,
                              isCompanyView: true,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
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
                            (s) => _buildFilterChip(
                              s.localizedLabel(AppLocalizations.of(context)!),
                              _requestFilter == s,
                              () {
                                setState(
                                  () => _requestFilter = _requestFilter == s
                                      ? null
                                      : s,
                                );
                                ref
                                    .read(offersProvider.notifier)
                                    .updateAvailableRequestsStatus(
                                      _requestFilter?.name,
                                    );
                              },
                            ),
                          )
                          .toList()
                    : OfferStatus.values
                          .map(
                            (s) => _buildFilterChip(
                              s.localizedLabel(AppLocalizations.of(context)!),
                              _offerFilter == s,
                              () {
                                setState(
                                  () => _offerFilter = _offerFilter == s
                                      ? null
                                      : s,
                                );
                                ref
                                    .read(offersProvider.notifier)
                                    .updateMyOffersStatus(_offerFilter?.name);
                              },
                            ),
                          )
                          .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    bool isSelected,
    VoidCallback onSelected,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: InkWell(
        onTap: onSelected,
        borderRadius: BorderRadius.circular(999.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor : theme.cardColor,
            borderRadius: BorderRadius.circular(999.r),
            border: Border.all(
              color: isSelected
                  ? AppTheme.primaryColor
                  : theme.colorScheme.onSurface.withValues(alpha: 0.08),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: isSelected
                  ? Colors.white
                  : theme.colorScheme.onSurface.withValues(alpha: 0.78),
              fontFamily: AppTheme.fontFamily,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }


  void _showRequestDetails(dynamic request) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RequestDetailBottomSheet(request: request),
    );
  }

  Future<void> _handleConvertToLead(SolarRequest request) async {
    final companyId = ref.read(authProvider).user?.company?.id;
    if (companyId == null) return;

    final success = await ref
        .read(offersProvider.notifier)
        .convertToLead(companyId, request);

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.success),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
    }
  }
}
