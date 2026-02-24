import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_hub/features/orders/controllers/company_order_controller.dart';
import 'package:solar_hub/utils/app_theme.dart';
import 'package:solar_hub/models/enums.dart';
import 'package:solar_hub/controllers/company_controller.dart';
import 'package:toastification/toastification.dart';
import 'package:solar_hub/utils/price_format_utils.dart';

class CompanyCreateOrderPage extends StatefulWidget {
  final Map<String, dynamic> offer;
  final Map<String, dynamic> request;

  const CompanyCreateOrderPage({super.key, required this.offer, required this.request});

  @override
  State<CompanyCreateOrderPage> createState() => _CompanyCreateOrderPageState();
}

class _CompanyCreateOrderPageState extends State<CompanyCreateOrderPage> {
  final CompanyOrderController controller = Get.find<CompanyOrderController>();
  final _formKey = GlobalKey<FormState>();

  late double basePrice;
  late TextEditingController taxController;
  late TextEditingController discountController;
  late TextEditingController notesController;

  double get tax => double.tryParse(taxController.text) ?? 0.0;
  double get discount => double.tryParse(discountController.text) ?? 0.0;
  double get total => (basePrice - discount) + tax;

  @override
  void initState() {
    super.initState();
    basePrice = (widget.offer['price'] as num).toDouble();
    taxController = TextEditingController(text: '0.0');
    discountController = TextEditingController(text: '0.0');
    notesController = TextEditingController();
  }

  @override
  void dispose() {
    taxController.dispose();
    discountController.dispose();
    notesController.dispose();
    super.dispose();
  }

  void _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;

    final sellerCompanyId = widget.offer['company_id'];
    final buyerUserId = widget.request['user_id'];
    final offerId = widget.offer['id'];

    if (sellerCompanyId == null || buyerUserId == null) {
      toastification.show(title: Text('err_error'.tr), description: Text('invalid_data'.tr), type: ToastificationType.error);
      return;
    }

    final orderId = await controller.createOrder(
      items: [
        {
          'product_id': null,
          'quantity': 1,
          'unit_price': basePrice,
          'total_line_price': basePrice,
          'product_name_snapshot': widget.request['title'] ?? 'system_package'.tr,
          'selected_options': [], // Could add system specs here
        },
      ],
      totalAmount: total,
      paidAmount: 0.0, // Usually unpaid initially for offers unless marked otherwise
      orderType: OrderType.online_order,
      sellerCompanyId: sellerCompanyId,
      buyerUserId: buyerUserId,
      offerId: offerId,
      paymentMethod: 'system_offer',
      discountAmount: discount,
      taxAmount: tax,
    );

    if (orderId != null) {
      if (!mounted) return;
      Get.back(); // Close create page

      // extensive delay to prevent GetX snackbar/overlay race conditions
      await Future.delayed(const Duration(milliseconds: 300));
      Get.back(); // Close details sheet

      toastification.show(
        title: Text('success'.tr),
        description: Text('order_created_success'.tr),
        type: ToastificationType.success,
        autoCloseDuration: const Duration(seconds: 3),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("create_order".tr), elevation: 0, backgroundColor: Colors.white, foregroundColor: Colors.black),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.solar_power, color: AppTheme.primaryColor, size: 32),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.request['title'] ?? 'system_wizard'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text("${'owner'.tr}: ${widget.request['users']?['full_name'] ?? 'guest'.tr}", style: TextStyle(color: Colors.grey[700])),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Pricing Section
              Text("financials".tr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              _buildPriceRow("base_price".tr, basePrice),
              const Divider(),

              // Discount Input
              TextFormField(
                controller: discountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "discount_amount".tr,
                  prefixText: "- ",
                  border: const OutlineInputBorder(),
                  suffixText: Get.find<CompanyController>().effectiveCurrency.symbol,
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),

              // Tax Input
              TextFormField(
                controller: taxController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "tax_vat".tr,
                  prefixText: "+ ",
                  border: const OutlineInputBorder(),
                  suffixText: Get.find<CompanyController>().effectiveCurrency.symbol,
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 24),

              // Total
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("total_amount".tr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(
                      total.toPriceWithCurrency(Get.find<CompanyController>().effectiveCurrency.symbol),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              Text("additional_notes".tr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: notesController,
                maxLines: 3,
                decoration: InputDecoration(hintText: "notes_hint".tr, border: const OutlineInputBorder()),
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: Obx(
                  () => ElevatedButton(
                    onPressed: controller.isLoading.value ? null : _submitOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text("confirm_create_order".tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(
            amount.toPriceWithCurrency(Get.find<CompanyController>().effectiveCurrency.symbol),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
