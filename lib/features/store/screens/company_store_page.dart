import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_hub/features/store/controllers/store_controller.dart';
import 'package:solar_hub/features/store/screens/product_details_page.dart';
import 'package:solar_hub/features/systems/screens/system_form_page.dart';
import 'package:solar_hub/models/company_model.dart';
import 'package:solar_hub/features/systems/screens/system_details_page.dart';
import 'package:solar_hub/features/systems/widgets/system_card.dart'; // Added SystemCard import
import 'package:solar_hub/features/store/widgets/store_image.dart';
import 'package:solar_hub/features/auth/controllers/auth_controller.dart';

class ShopPage extends StatefulWidget {
  final CompanyModel company;
  const ShopPage({super.key, required this.company});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late StoreController shopController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    shopController = Get.put(StoreController(), tag: widget.company.id);
    shopController.fetchProducts(shopId: widget.company.id);
    shopController.fetchSystems(widget.company.id);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.company.status != 'active') {
      return Scaffold(
        appBar: AppBar(title: Text(widget.company.name)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.block, size: 64, color: Colors.orange),
              const SizedBox(height: 16),
              Text('store_inactive_msg'.tr, style: TextStyle(fontSize: 18, color: Theme.of(context).disabledColor)),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  'store_verification_pending'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 240, // Increased height for better fit
              pinned: true,
              stretch: true,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              backgroundColor: Theme.of(context).primaryColor,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background Image (Blurred Logo or Pattern)
                    if (widget.company.logoUrl != null && widget.company.logoUrl!.isNotEmpty)
                      StoreImage(url: widget.company.logoUrl, fit: BoxFit.cover, backgroundColor: Colors.grey[900])
                    else
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blueGrey[900]!, Colors.blueGrey[700]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),

                    // Blur Effect
                    BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.4), // Dark overlay
                      ),
                    ),

                    // Content
                    Positioned(
                      bottom: 60, // Above tabs
                      left: 0,
                      right: 0,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
                            ),
                            child: StoreImage(url: widget.company.logoUrl, isCircle: true, width: 80, height: 80, backgroundColor: Colors.grey[200]),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.company.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              shadows: [Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 2))],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                            child: Text(
                              widget.company.tier.name.capitalizeFirst!,
                              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  color: Theme.of(context).cardColor, // Tab bar background
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: Theme.of(context).colorScheme.primary,
                    indicatorWeight: 3,
                    labelColor: Theme.of(context).colorScheme.primary,
                    unselectedLabelColor: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                    tabs: [
                      Tab(text: 'products'.tr),
                      Tab(text: 'systems'.tr), // Now using Hub view
                      Tab(text: 'about'.tr),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // Products Tab
            Obx(() {
              if (shopController.isLoading.value) return const Center(child: CircularProgressIndicator());
              if (shopController.products.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text('no_products'.tr, style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                );
              }

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 250, // Responsive width
                      childAspectRatio: 0.75,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                    ),
                    itemCount: shopController.products.length,
                    itemBuilder: (context, index) {
                      final product = shopController.products[index];
                      return GestureDetector(
                        onTap: () => Get.to(() => ProductPage(product: product)),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Hero(
                                  tag: 'product_${product.id}',
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                    child: StoreImage(url: product.imageUrl, width: double.infinity, height: double.infinity, fit: BoxFit.cover),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${product.currency?.symbol ?? '\$'}${product.retailPrice.toStringAsFixed(0)}',
                                      style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w800, fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            }),

            // Systems Tab (Hub Style)
            Obx(() {
              final auth = Get.find<AuthController>();
              final isUser = auth.role.value == 'user';

              if (shopController.companySystems.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.solar_power_outlined, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text('no_systems'.tr, style: TextStyle(color: Colors.grey[600])),
                      if (isUser) ...[
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => Get.to(() => SystemFormPage(isUserView: true, companyId: widget.company.id)),
                          icon: const Icon(Icons.add),
                          label: const Text("I have a system from this company"),
                        ),
                      ],
                    ],
                  ),
                );
              }
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (isUser) ...[
                    Card(
                      elevation: 0,
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Theme.of(context).primaryColor.withValues(alpha: 0.2)),
                      ),
                      child: ListTile(
                        leading: Icon(Icons.add_circle_outline, color: Theme.of(context).primaryColor),
                        title: const Text("Add My Installation", style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: const Text("Link your system provided by this company"),
                        onTap: () => Get.to(() => SystemFormPage(isUserView: true, companyId: widget.company.id)),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  ...shopController.companySystems.map(
                    (system) => SystemCard(
                      system: system,
                      onTap: () => Get.to(() => SystemDetailsPage(system: system)),
                    ),
                  ),
                ],
              );
            }),

            // About Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.company.description != null) ...[
                    Text(
                      'about_us'.tr,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
                    ),
                    const SizedBox(height: 12),
                    Text(widget.company.description!, style: TextStyle(fontSize: 15, height: 1.5, color: Theme.of(context).textTheme.bodyMedium?.color)),
                    const SizedBox(height: 24),
                  ],
                  Text(
                    'contact_info'.tr,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 0,
                    color: Theme.of(context).cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Theme.of(context).dividerColor),
                    ),
                    child: Column(
                      children: [
                        if (widget.company.address != null)
                          ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.location_on, color: Colors.blue),
                            ),
                            title: Text('address'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            subtitle: Text(widget.company.address!),
                          ),
                        if (widget.company.contactPhone != null) ...[
                          Divider(height: 1, indent: 16, endIndent: 16, color: Theme.of(context).dividerColor),
                          ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.phone, color: Colors.green),
                            ),
                            title: Text('phone'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            subtitle: Text(widget.company.contactPhone!),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
