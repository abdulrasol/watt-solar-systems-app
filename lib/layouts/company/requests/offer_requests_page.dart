import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:solar_hub/controllers/company_controller.dart';
import 'package:solar_hub/controllers/offer_requests_controller.dart';
import 'package:solar_hub/layouts/company/requests/request_details_page.dart';
import 'package:solar_hub/layouts/company/requests/widgets/company_offer_details_sheet.dart';

class OfferRequestsPage extends StatefulWidget {
  const OfferRequestsPage({super.key});

  @override
  State<OfferRequestsPage> createState() => _OfferRequestsPageState();
}

class _OfferRequestsPageState extends State<OfferRequestsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final OfferRequestsController controller = Get.put(OfferRequestsController());

  final ScrollController _requestsScroll = ScrollController();
  final ScrollController _offersScroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _requestsScroll.addListener(() {
      if (_requestsScroll.position.pixels >= _requestsScroll.position.maxScrollExtent - 200) {
        controller.fetchOpenRequests();
      }
    });

    _offersScroll.addListener(() {
      if (_offersScroll.position.pixels >= _offersScroll.position.maxScrollExtent - 200) {
        controller.fetchMyOffers();
      }
    });

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging && _tabController.index == 1) {
        controller.fetchMyOffers(isRefresh: true);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _requestsScroll.dispose();
    _offersScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0, // Hide main toolbar area if redundant
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).primaryColor,
          tabs: [
            Tab(text: 'open_requests'.tr),
            Tab(text: 'my_offers'.tr),
          ],
        ),
      ),
      body: TabBarView(controller: _tabController, children: [_buildOpenRequestsList(), _buildMyOffersList()]),
    );
  }

  Widget _buildOpenRequestsList() {
    return Obx(() {
      if (controller.isRequestsLoading.value && controller.openRequests.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.openRequests.isEmpty) {
        return Center(child: Text('no_open_requests'.tr));
      }

      return RefreshIndicator(
        onRefresh: () async => controller.fetchOpenRequests(isRefresh: true),
        child: ListView.separated(
          controller: _requestsScroll,
          padding: const EdgeInsets.all(16),
          itemCount: controller.openRequests.length + (controller.isMoreRequestsLoading.value ? 1 : 0),
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index == controller.openRequests.length) {
              return const Center(
                child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator()),
              );
            }

            final req = controller.openRequests[index];
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: InkWell(
                onTap: () => Get.to(() => RequestDetailsPage(requestData: req)),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundImage: req['profiles']?['avatar_url'] != null ? CachedNetworkImageProvider(req['profiles']['avatar_url']) : null,
                            child: req['profiles']?['avatar_url'] == null ? const Icon(Icons.person, size: 18) : null,
                          ),
                          const SizedBox(width: 10),
                          Text(req['profiles']?['full_name'] ?? 'Unknown User', style: const TextStyle(fontWeight: FontWeight.bold)),
                          const Spacer(),
                          Text(_timeAgo(DateTime.parse(req['created_at'])), style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
                        ],
                      ),
                      const Divider(height: 20),
                      Text(req['title'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(
                        req['description'] ?? '',
                        style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.8)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'view_details'.tr,
                          style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildMyOffersList() {
    return Obx(() {
      if (controller.isOffersLoading.value && controller.myOffers.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.myOffers.isEmpty) {
        return Center(child: Text('no_my_offers'.tr));
      }

      return RefreshIndicator(
        onRefresh: () async => controller.fetchMyOffers(isRefresh: true),
        child: ListView.separated(
          controller: _offersScroll,
          padding: const EdgeInsets.all(16),
          itemCount: controller.myOffers.length + (controller.isMoreOffersLoading.value ? 1 : 0),
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index == controller.myOffers.length) {
              return const Center(
                child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator()),
              );
            }

            final offer = controller.myOffers[index];
            final requestTitle = offer['offer_requests']?['title'] ?? 'Unknown Request';
            final status = offer['status'] ?? 'pending';

            Color statusColor = Colors.orange;
            if (status == 'accepted') statusColor = Colors.green;
            if (status == 'rejected') statusColor = Colors.red;

            return Card(
              elevation: 1,
              child: ListTile(
                onTap: () => _showMyOfferSheet(offer),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                title: Text(
                  requestTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      Text("${Get.find<CompanyController>().effectiveCurrency.symbol}${offer['price']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              ),
            );
          },
        ),
      );
    });
  }

  void _showMyOfferSheet(Map<String, dynamic> offer) {
    Get.bottomSheet(CompanyOfferDetailsSheet(offer: offer), isScrollControlled: true);
  }

  // _detailRow and _timeAgo removed as _detailRow is moved to widget
  // keeping _timeAgo if used elsewhere. It IS used in open requests list. keeping it.

  String _timeAgo(DateTime d) {
    Duration diff = DateTime.now().difference(d);
    if (diff.inDays > 30) return "${(diff.inDays / 30).floor()}mo ago";
    if (diff.inDays > 0) return "${diff.inDays}d ago";
    if (diff.inHours > 0) return "${diff.inHours}h ago";
    if (diff.inMinutes > 0) return "${diff.inMinutes}m ago";
    return "Just now";
  }
}
