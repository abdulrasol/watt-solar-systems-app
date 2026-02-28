import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_hub/features/community/controllers/community_controller.dart';
import 'package:solar_hub/features/community/models/community_post_model.dart';
import 'package:solar_hub/features/community/widgets/post_card.dart';
import 'package:solar_hub/features/systems/models/system_model.dart';

class SystemDetailsBottomSheet extends StatefulWidget {
  final SystemModel system;

  const SystemDetailsBottomSheet({super.key, required this.system});

  static void show(BuildContext context, SystemModel system) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SystemDetailsBottomSheet(system: system),
    );
  }

  @override
  State<SystemDetailsBottomSheet> createState() => _SystemDetailsBottomSheetState();
}

class _SystemDetailsBottomSheetState extends State<SystemDetailsBottomSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final CommunityController _communityController = Get.find<CommunityController>();
  List<CommunityPostModel> relatedPosts = [];
  bool isLoadingPosts = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchRelatedPosts();
  }

  Future<void> _fetchRelatedPosts() async {
    if (widget.system.id == null) return;
    final posts = await _communityController.fetchPostsBySystem(widget.system.id!);
    if (mounted) {
      setState(() {
        relatedPosts = posts;
        isLoadingPosts = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
              ),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "${(widget.system.pv.count * widget.system.pv.capacity / 1000).toStringAsFixed(1)} kW System",
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                  ],
                ),
              ),

              // Tabs
              TabBar(
                controller: _tabController,
                indicatorColor: Theme.of(context).primaryColor,
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Colors.grey,
                tabs: [
                  Tab(text: 'info'.tr),
                  Tab(text: 'posts'.tr),
                ],
              ),

              // Tab Content
              Expanded(
                child: TabBarView(controller: _tabController, children: [_buildInfoTab(scrollController), _buildPostsTab(scrollController)]),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoTab(ScrollController scrollController) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(24),
      children: [
        // Company Card
        if (widget.system.installedBy != null) ...[
          Text(
            'installed_by'.tr,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () {
              // Navigate to store
              if (widget.system.installedBy != null) {
                Get.toNamed('/store/${widget.system.installedBy}');
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
              ),
              child: Row(
                children: [
                  // We'd ideally have logoUrl in SystemModel, but for now we might only have companyName.
                  // If we don't have logoUrl, we show initial.
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      image: widget.system.companyLogo != null ? DecorationImage(image: NetworkImage(widget.system.companyLogo!), fit: BoxFit.cover) : null,
                    ),
                    child: widget.system.companyLogo == null
                        ? Center(
                            child: Text(
                              widget.system.companyName?.substring(0, 1).toUpperCase() ?? "C",
                              style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.system.companyName ?? 'Unknown Company', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('view_store'.tr, style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 13)),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Specs List
        Text(
          'specifications'.tr,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        _buildSpecRow(
          Icons.solar_power_outlined,
          'pv_panels'.tr,
          "${widget.system.pv.count} x ${widget.system.pv.capacity} W (${widget.system.pv.mark ?? 'N/A'})",
        ),
        _buildSpecRow(
          Icons.battery_charging_full_outlined,
          'batteries'.tr,
          "${widget.system.battery.count} x ${widget.system.battery.capacity} kWh (${widget.system.battery.mark ?? 'N/A'})",
        ),
        _buildSpecRow(
          Icons.settings_input_component_outlined,
          'inverter'.tr,
          "${widget.system.inverter.capacity} kVA (${widget.system.inverter.mark ?? 'N/A'}, ${widget.system.inverter.phase ?? '1'} Phase)",
        ),

        if (widget.system.notes != null && widget.system.notes!.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            'notes'.tr,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(widget.system.notes!, style: const TextStyle(fontSize: 14, height: 1.5)),
        ],

        const SizedBox(height: 24),
        Text(
          'location'.tr,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Text("${widget.system.city}, ${widget.system.country}", style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildSpecRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsTab(ScrollController scrollController) {
    if (isLoadingPosts) {
      return const Center(child: CircularProgressIndicator());
    }

    if (relatedPosts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.post_add_outlined, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('no_related_posts'.tr, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.all(24),
      itemCount: relatedPosts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) => PostCard(post: relatedPosts[index]),
    );
  }
}
