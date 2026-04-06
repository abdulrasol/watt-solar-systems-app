import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/widgets/pre_scaffold.dart';
import 'package:solar_hub/src/features/offers/domain/entities/solar_offer.dart';
import 'package:solar_hub/src/utils/app_enums.dart';
import 'package:solar_hub/src/utils/app_theme.dart';
import '../providers/offers_provider.dart';
import '../widgets/cards/request_card.dart';
import '../widgets/cards/offer_card.dart';
import 'offer_details_screen.dart';

class UserRequestsScreen extends ConsumerStatefulWidget {
  const UserRequestsScreen({super.key});

  @override
  ConsumerState<UserRequestsScreen> createState() => _UserRequestsScreenState();
}

class _UserRequestsScreenState extends ConsumerState<UserRequestsScreen> {
  final ScrollController _scrollController = ScrollController();
  int? _expandedRequestId;
  RequestStatus? _statusFilter;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        ref.read(offersProvider.notifier).userRequestsNextPage();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refetchData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _refetchData() {
    ref.read(offersProvider.notifier).getUserRequests(isRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(offersProvider);
    final l10n = AppLocalizations.of(context)!;

    return PreScaffold(
      title: l10n.my_solar_project_inquiries,
      child: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: state.isLoading && state.userRequests.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : state.userRequests.isEmpty
                ? _buildEmptyState()
                : _buildRequestList(state),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () => context.push('/user-requests/new'),
      //   icon: const Icon(Iconsax.add_bold),
      //   label: Text(l10n.add_new_request),
      // ),
    );
  }

  Widget _buildRequestList(OffersState state) {
    return RefreshIndicator(
      onRefresh: () async => ref.read(offersProvider.notifier).getUserRequests(isRefresh: true),
      child: ListView.separated(
        controller: _scrollController,
        padding: EdgeInsets.all(20.r),
        itemCount: state.userRequests.length + (state.userRequestsHasMore ? 1 : 0),
        separatorBuilder: (c, i) => SizedBox(height: 16.h),
        itemBuilder: (context, index) {
          if (index == state.userRequests.length) {
            return const Center(
              child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()),
            );
          }

          final request = state.userRequests[index];
          final isExpanded = _expandedRequestId == request.id;
          final offers = state.offersByRequest[request.id] ?? [];

          return Column(
            children: [
              RequestCard(
                request: request,
                onTap: () {
                  setState(() {
                    _expandedRequestId = isExpanded ? null : request.id;
                  });
                  if (!isExpanded) {
                    ref.read(offersProvider.notifier).getOffersForRequest(request.id!, isRefresh: true);
                  }
                },
              ),
              if (isExpanded) _buildOffersSection(request.id!, offers, state.isLoading, state.requestOffersHasMore),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOffersSection(int requestId, List<dynamic> offers, bool isLoading, bool hasMore) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: EdgeInsets.only(top: 12.h, left: 16.w),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(16.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Iconsax.briefcase_bold, size: 16, color: AppTheme.primaryColor),
              SizedBox(width: 8.w),
              Text(
                l10n.received_offers_count(offers.length),
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          if (isLoading && offers.isEmpty)
            const Center(child: LinearProgressIndicator())
          else if (offers.isEmpty)
            Text(
              l10n.no_offers_received_yet,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey),
            )
          else ...[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: offers.length,
              separatorBuilder: (c, i) => SizedBox(height: 8.h),
              itemBuilder: (context, index) {
                final offer = offers[index];
                return OfferCard(offer: offer, onTap: () => _showOfferDetails(offer));
              },
            ),
            if (hasMore)
              Padding(
                padding: EdgeInsets.only(top: 12.h),
                child: TextButton(onPressed: () => ref.read(offersProvider.notifier).requestOffersNextPage(requestId), child: const Text('Load More Offers')),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      color: Colors.grey.withValues(alpha: 0.05),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: RequestStatus.values
                    .map(
                      (s) => _buildFilterChip(s.localizedLabel(AppLocalizations.of(context)!), _statusFilter == s, () {
                        setState(() => _statusFilter = _statusFilter == s ? null : s);
                        ref.read(offersProvider.notifier).updateRequestsStatus(_statusFilter?.name);
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
          style: TextStyle(fontSize: 10.sp, color: isSelected ? Colors.white : Colors.black, fontFamily: AppTheme.fontFamily),
        ),
        selected: isSelected,
        onSelected: (_) => onSelected(),
        selectedColor: AppTheme.primaryColor,
        checkmarkColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: 500.h,
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.folder_open_bold, size: 64.sp, color: Colors.grey.withValues(alpha: 0.2)),
            SizedBox(height: 16.h),
            Text(
              l10n.no_requests_posted,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Text(
              l10n.post_first_solar_request,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showOfferDetails(SolarOffer offer) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => OfferDetailsScreen(offer: offer)));
  }
}
