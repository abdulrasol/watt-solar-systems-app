import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart'; // Ensure this package is available
import 'package:solar_hub/features/orders/controllers/company_order_controller.dart';
import 'package:intl/intl.dart';
import 'package:solar_hub/features/orders/screens/order_details_company.dart';
import 'package:solar_hub/models/enums.dart';
import 'package:solar_hub/utils/price_format_utils.dart';

class CompanyOrderListPage extends StatefulWidget {
  const CompanyOrderListPage({super.key});

  @override
  State<CompanyOrderListPage> createState() => _CompanyOrderListPageState();
}

class _CompanyOrderListPageState extends State<CompanyOrderListPage> {
  final CompanyOrderController controller = Get.put(CompanyOrderController());
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  // Track active filters for UI state
  final RxString selectedFilter = 'All'.obs;

  @override
  void initState() {
    super.initState();
    // Initial fetch
    controller.fetchCompanyOrders(refresh: true);

    // Pagination Listener
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        if (!controller.isMoreLoading.value && controller.hasMore.value) {
          controller.loadMore();
        }
      }
    });

    // Sync local filter selection with controller (optional, mainly for UI consistency)
    selectedFilter.value = controller.currentTypeFilter.value;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      controller.searchOrders(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search & Filter Section
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: Theme.of(context).cardColor,
            child: Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'search_order_hint'.tr,
                      prefixIcon: const Icon(AntDesign.search_outline),
                      filled: true,
                      fillColor: Theme.of(context).scaffoldBackgroundColor,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                      suffixIcon: Obx(() {
                        final hasDate = controller.dateRangeFilter.value != null;
                        return IconButton(
                          icon: Icon(hasDate ? Icons.event_available : Icons.event, color: hasDate ? Theme.of(context).primaryColor : Colors.grey),
                          onPressed: () async {
                            final picked = await showDateRangePicker(
                              context: context,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                              initialDateRange: controller.dateRangeFilter.value,
                            );
                            if (picked != null) {
                              controller.filterOrders(dateRange: picked);
                            } else if (hasDate) {
                              // Optional: Allow clearing via picker cancel? No, standard is picker cancel does nothing.
                              // We can add a "Clear" button in logic or unrelated.
                              // Let's rely on a separate clear mechanism or just re-picking.
                              // Actually, let's add a clear option if date is set.
                            }
                          },
                          tooltip: 'filter_date_range'.tr,
                        );
                      }),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Date Filter Display (if active)
                Obx(() {
                  if (controller.dateRangeFilter.value != null) {
                    final start = DateFormat('MMM d').format(controller.dateRangeFilter.value!.start);
                    final end = DateFormat('MMM d').format(controller.dateRangeFilter.value!.end);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Row(
                        children: [
                          Text(
                            '${'date_label'.tr}: $start - $end',
                            style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () => controller.clearDateFilter(),
                            child: const Icon(Icons.close, size: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),

                // Filter Chips
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 600;

                    if (isMobile) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                _buildFilterChip('all'.tr, labelKey: 'all'),
                                const SizedBox(width: 8),
                                _buildFilterChip('pending'.tr, isStatus: true, labelKey: 'Pending'),
                                const SizedBox(width: 8),
                                _buildFilterChip('mark_in_progress'.tr, isStatus: true, labelKey: 'In Progress'),
                                const SizedBox(width: 8),
                                _buildFilterChip('completed'.tr, isStatus: true, labelKey: 'Completed'),
                                const SizedBox(width: 8),
                                _buildFilterChip('cancelled'.tr, isStatus: true, labelKey: 'Cancelled'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                _buildFilterChip('pos'.tr, labelKey: 'POS'),
                                const SizedBox(width: 8),
                                _buildFilterChip('online'.tr, labelKey: 'Online'),
                                const SizedBox(width: 8),
                                _buildFilterChip('online_b2b'.tr, labelKey: 'Online B2B'),
                              ],
                            ),
                          ),
                        ],
                      );
                    } else {
                      // Desktop/Tablet: Single Row
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            _buildFilterChip('All'),
                            const SizedBox(width: 8),
                            _buildFilterChip('Pending', isStatus: true),
                            const SizedBox(width: 8),
                            _buildFilterChip('In Progress', isStatus: true),
                            const SizedBox(width: 8),
                            _buildFilterChip('Completed', isStatus: true),
                            const SizedBox(width: 8),
                            _buildFilterChip('Cancelled', isStatus: true),
                            const VerticalDivider(width: 24),
                            _buildFilterChip('POS'),
                            const SizedBox(width: 8),
                            _buildFilterChip('Online'),
                            const SizedBox(width: 8),
                            _buildFilterChip('Online B2B'),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),

          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.companyOrders.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.companyOrders.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text('no_orders_found'.tr, style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async => controller.fetchCompanyOrders(refresh: true),
                child: ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.companyOrders.length + (controller.hasMore.value ? 1 : 0),
                  separatorBuilder: (c, i) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    if (index == controller.companyOrders.length) {
                      return const Center(
                        child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()),
                      );
                    }

                    final order = controller.companyOrders[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: _getTypeColor(order.orderType),
                        child: Icon(_getTypeIcon(order.orderType), color: Colors.white, size: 20),
                      ),
                      title: Text(
                        '${order.orderNumber != null ? '${'order_label'.tr} #${order.orderNumber}' : '#${order.id.substring(0, 8)}'} • ${order.totalAmount.toPriceWithCurrency(order.currencySymbol)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(order.effectiveCustomerName),
                          Text(
                            DateFormat('yyyy-MM-dd HH:mm').format(order.createdAt ?? DateTime.now()),
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Chip(
                            label: Text(order.status.name.tr, style: const TextStyle(fontSize: 10)),
                            backgroundColor: _getStatusColor(order.status).withAlpha(128),
                            labelPadding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ],
                      ),
                      onTap: () {
                        Get.to(() => CompanyOrderDetailsPage(order: order));
                      },
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, {bool isStatus = false, String? labelKey}) {
    final key = labelKey ?? label;
    return Obx(() {
      // Simple UI logic: If 'All' is clicked, it usually resets everything or just one category.
      // Let's separate 'All' logic:
      // If label is 'All', check if type and status are 'All'.

      bool selected = false;
      if (key == 'all' || key == 'All') {
        selected = controller.currentStatusFilter.value == 'All' && controller.currentTypeFilter.value == 'All';
      } else if (isStatus) {
        selected = controller.currentStatusFilter.value == key;
      } else {
        selected = controller.currentTypeFilter.value == key;
      }

      return FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (bool value) {
          if (key == 'all' || key == 'All') {
            controller.filterOrders(status: 'All', type: 'All');
          } else if (isStatus) {
            // Toggle off if already selected? Or just switch. Usually switch.
            controller.filterOrders(status: selected ? 'All' : key);
          } else {
            controller.filterOrders(type: selected ? 'All' : key);
          }
        },
        backgroundColor: Theme.of(Get.context!).cardColor,
        selectedColor: Theme.of(Get.context!).primaryColor.withAlpha(128),
        checkmarkColor: Theme.of(Get.context!).primaryColor,
        labelStyle: TextStyle(color: selected ? Theme.of(Get.context!).primaryColor : Theme.of(Get.context!).textTheme.bodyMedium?.color),
      );
    });
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.completed:
      case OrderStatus.done:
        return Colors.green;
      case OrderStatus.pending:
      case OrderStatus.waiting:
        return Colors.orange;
      case OrderStatus.in_progress:
      case OrderStatus.processing:
        return Colors.blue;
      case OrderStatus.cancelled:
      case OrderStatus.returned:
        return Colors.red;
    }
  }

  Color _getTypeColor(OrderType type) {
    switch (type.name) {
      case 'pos_sale':
        return Colors.purple;
      case 'online_order':
        return Colors.blue;
      case 'b2b_supply':
        return Colors.orangeAccent;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(OrderType type) {
    switch (type.name) {
      case 'pos_sale':
        return Icons.point_of_sale;
      case 'online_order':
        return Icons.shopping_cart;
      case 'b2b_supply':
        return Icons.business_center; // New icon for B2B
      default:
        return Icons.receipt;
    }
  }
}
