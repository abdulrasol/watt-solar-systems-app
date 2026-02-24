import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_hub/models/customer_model.dart';
import 'package:solar_hub/controllers/company_controller.dart';
import 'package:solar_hub/services/supabase_service.dart';
import 'package:solar_hub/services/pdf_service.dart';
import 'package:intl/intl.dart';
import 'package:solar_hub/features/accounting/screens/add_payment_dialog.dart';

class CustomerDetailsPage extends StatefulWidget {
  final CustomerModel customer;

  const CustomerDetailsPage({super.key, required this.customer});

  @override
  State<CustomerDetailsPage> createState() => _CustomerDetailsPageState();
}

class _CustomerDetailsPageState extends State<CustomerDetailsPage> {
  final _dbService = SupabaseService();
  final _pdfService = PdfService();

  final customer = Rxn<CustomerModel>();
  final orders = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    customer.value = widget.customer; // Initial data
    _fetchCustomerDetails();
    _fetchOrders();
  }

  Future<void> _fetchCustomerDetails() async {
    try {
      final data = await _dbService.client.from('customers').select().eq('id', widget.customer.id!).single();
      customer.value = CustomerModel.fromJson(data);
    } catch (e) {
      // print("Error refreshing customer: $e");
    }
  }

  Future<void> _fetchOrders() async {
    isLoading.value = true;
    try {
      final response = await _dbService.client
          .from('orders')
          .select('*, order_items(*)')
          .eq('customer_id', widget.customer.id!)
          .order('created_at', ascending: false);

      orders.assignAll(List<Map<String, dynamic>>.from(response));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load orders: $e')));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _generatePdf(Map<String, dynamic> order) async {
    try {
      final items = List<Map<String, dynamic>>.from(order['order_items']);
      final total = (order['total_amount'] as num).toDouble();
      final date = DateTime.parse(order['created_at']);

      // Construct Seller Info (Fetch current company details if available, or just use placeholders if we are viewing as admin)
      // Since this is Company Dashboard, we use `CompanyController` if available, or fetch from order if needed.
      // Ideally, the order contains seller_company_id.
      Map<String, dynamic> sellerInfo = {
        'name': 'Company', // Default
      };

      // Try to fetch company details from CompanyController if we are logged in as company
      try {
        final companyController = Get.find<CompanyController>(); // Needs import if not present, but let's check imports
        if (companyController.company.value != null) {
          final c = companyController.company.value!;
          sellerInfo = {'name': c.name, 'address': c.address, 'contact_phone': c.contactPhone};
        }
      } catch (_) {}

      final buyerInfo = {'name': widget.customer.fullName, 'phone': widget.customer.phoneNumber, 'address': widget.customer.address};

      final pdfData = await _pdfService.generateInvoice(
        orderId: order['id'],
        orderNumber: order['order_number'],
        sellerInfo: sellerInfo,
        buyerInfo: buyerInfo,
        items: items,
        total: total,
        date: date,
        paymentMethod: order['payment_method'],
        paidAmount: (order['paid_amount'] as num?)?.toDouble(),
        currencySymbol: Get.find<CompanyController>().effectiveCurrency.symbol,
      );

      await _pdfService.printInvoice(pdfData);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to generate PDF: $e')));
    }
  }

  Future<void> _printStatement() async {
    try {
      final c = customer.value ?? widget.customer;
      final pdfData = await _pdfService.generateStatement(customer: c, orders: orders);
      await _pdfService.printInvoice(pdfData);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to generate statement: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('customer_details'.tr),
        actions: [IconButton(icon: const Icon(Icons.picture_as_pdf), tooltip: 'Print Statement', onPressed: _printStatement)],
      ),
      body: Column(
        children: [
          // Wrapped in Obx to show fresh data
          Obx(() {
            final c = customer.value ?? widget.customer;
            return Column(
              children: [
                // Header Card
                Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.fullName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.phone, size: 16),
                            const SizedBox(width: 8),
                            Expanded(child: Text(c.phoneNumber ?? 'No Phone', overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.email, size: 16),
                            const SizedBox(width: 8),
                            Expanded(child: Text(c.email ?? 'No Email', overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 16),
                            const SizedBox(width: 8),
                            Expanded(child: Text(c.address ?? 'No Address', overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Financial Overview Card
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildStatItem('total_sales'.tr, c.totalSales, Colors.purple),
                        const Divider(height: 24),
                        _buildStatItem('total_paid'.tr, c.totalPaid, Colors.green),
                        const Divider(height: 24),
                        _buildStatItem('on_account'.tr, c.balance, Colors.red),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final res = await showDialog(
                                context: context,
                                builder: (_) => AddPaymentDialog(initialCustomerId: c.id, initialAmount: c.balance > 0 ? c.balance : 0.0),
                              );
                              if (res == true) {
                                _fetchCustomerDetails();
                                _fetchOrders();
                                // Also tell parent to refresh if needed (e.g. AccountingPage)
                              }
                            },
                            icon: const Icon(Icons.payment, size: 20),
                            label: Text('receive_payment'.tr),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            );
          }),

          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('order_history'.tr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),

          // Orders List
          Expanded(
            child: Obx(() {
              if (isLoading.value) return const Center(child: CircularProgressIndicator());
              if (orders.isEmpty) return Center(child: Text('no_orders_found'.tr));

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  final total = (order['total_amount'] as num).toDouble();
                  final date = DateTime.parse(order['created_at']);
                  final itemsCount = (order['order_items'] as List).length;

                  return Card(
                    child: ListTile(
                      title: Text("${'order_label'.tr} #${order['order_number'] ?? order['id'].toString().substring(0, 8).toUpperCase()}"),
                      subtitle: Text("${DateFormat('yyyy-MM-dd HH:mm').format(date)} • $itemsCount ${'items'.tr}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "${Get.find<CompanyController>().effectiveCurrency.symbol}${total.toStringAsFixed(2)}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 12),
                          IconButton(icon: const Icon(Icons.print), onPressed: () => _generatePdf(order), tooltip: 'download_pdf'.tr),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, double value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            "${Get.find<CompanyController>().effectiveCurrency.symbol}${value.toStringAsFixed(2)}",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
        ),
      ],
    );
  }
}
