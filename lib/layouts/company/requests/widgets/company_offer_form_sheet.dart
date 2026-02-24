import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_hub/controllers/company_controller.dart';
import 'package:solar_hub/controllers/inventory_controller.dart';
import 'package:solar_hub/controllers/offer_requests_controller.dart';
import 'package:solar_hub/layouts/shared/widgets/custom_text_field.dart';
import 'package:solar_hub/features/store/models/product_model.dart';
import 'package:solar_hub/utils/app_theme.dart';
import 'package:toastification/toastification.dart';

class CompanyOfferFormSheet extends StatefulWidget {
  final String requestId;
  final String requestUserId;
  final Map<String, dynamic>? requestSpecs;

  const CompanyOfferFormSheet({super.key, required this.requestId, required this.requestUserId, this.requestSpecs});

  @override
  State<CompanyOfferFormSheet> createState() => _CompanyOfferFormSheetState();
}

class _CompanyOfferFormSheetState extends State<CompanyOfferFormSheet> {
  final _priceCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  // Selected Products
  ProductModel? _selectedPanel;
  ProductModel? _selectedBattery;
  ProductModel? _selectedInverter;

  // Quantities & Manual Overrides
  final _pvCountCtrl = TextEditingController();
  final _pvCapCtrl = TextEditingController();
  final _pvMarkCtrl = TextEditingController();

  final _battCountCtrl = TextEditingController();
  final _battCapCtrl = TextEditingController();
  final _battMarkCtrl = TextEditingController();

  final _invCountCtrl = TextEditingController();
  final _invCapCtrl = TextEditingController();
  final _invMarkCtrl = TextEditingController();
  final _invPhaseCtrl = TextEditingController(); // single or three

  // Involves
  final List<String> _possibleInvolves = ['Installation', 'Wires', 'Mounting', 'Transportation', 'Warranty', 'Maintenance'];
  final List<String> _selectedInvolves = [];

  late InventoryController _inventoryController;

  @override
  void initState() {
    super.initState();
    _inventoryController = Get.put(InventoryController());

    if (_inventoryController.products.isEmpty) {
      _inventoryController.fetchMyProducts(isRefresh: true);
    }
    _prefillFromRequest();
  }

  void _prefillFromRequest() {
    final specs = widget.requestSpecs;
    if (specs == null) return;

    // Panels
    if (specs.containsKey('panels') || specs.containsKey('panel')) {
      final p = specs['panels'] ?? specs['panel'];
      if (p is Map) {
        _pvCountCtrl.text = (p['count'] ?? 0).toString();
        _pvCapCtrl.text = (p['capacity'] ?? p['power'] ?? 0).toString();
      } else if (p is List && p.isNotEmpty) {
        _pvCountCtrl.text = (p.first['count'] ?? 0).toString();
        _pvCapCtrl.text = (p.first['capacity'] ?? p.first['power'] ?? 0).toString();
      }
    }

    // Batteries
    if (specs.containsKey('batteries') || specs.containsKey('battery')) {
      final b = specs['batteries'] ?? specs['battery'];
      if (b is Map) {
        _battCountCtrl.text = (b['count'] ?? 0).toString();
        _battCapCtrl.text = (b['capacity'] ?? b['ah'] ?? 0).toString();
      } else if (b is List && b.isNotEmpty) {
        _battCountCtrl.text = (b.first['count'] ?? 0).toString();
        _battCapCtrl.text = (b.first['capacity'] ?? b.first['ah'] ?? 0).toString();
      }
    }

    // Inverters
    if (specs.containsKey('inverters') || specs.containsKey('inverter')) {
      final i = specs['inverters'] ?? specs['inverter'];
      if (i is Map) {
        _invCountCtrl.text = (i['count'] ?? 0).toString();
        _invCapCtrl.text = (i['capacity'] ?? i['power'] ?? 0).toString();
        _invPhaseCtrl.text = (i['phase'] ?? '');
      } else if (i is List && i.isNotEmpty) {
        _invCountCtrl.text = (i.first['count'] ?? 0).toString();
        _invCapCtrl.text = (i.first['capacity'] ?? i.first['power'] ?? 0).toString();
        _invPhaseCtrl.text = (i.first['phase'] ?? '');
      }
    }
  }

  void _onProductSelected(String type, ProductModel? product) {
    if (product == null) return;

    // Auto-fill from product specs if available
    // Assuming specs might contain keys like 'capacity', 'brand', 'mark', 'phase'
    final specs = product.specs;
    final capacity = specs['capacity'] ?? specs['power'] ?? specs['wattage'] ?? '';
    final mark = specs['brand'] ?? specs['mark'] ?? product.name; // Use product name as fallback for brand

    setState(() {
      if (type == 'pv') {
        _pvCapCtrl.text = capacity.toString();
        _pvMarkCtrl.text = mark.toString();
        _selectedPanel = product;
      } else if (type == 'batt') {
        _battCapCtrl.text = capacity.toString();
        _battMarkCtrl.text = mark.toString();
        _selectedBattery = product;
      } else if (type == 'inv') {
        _invCapCtrl.text = capacity.toString();
        _invMarkCtrl.text = mark.toString();
        _invPhaseCtrl.text = specs['phase']?.toString() ?? '';
        _selectedInverter = product;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OfferRequestsController>();
    final companyController = Get.find<CompanyController>();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.95), // Increased height
      child: Column(
        children: [
          // Handle Bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              margin: const EdgeInsets.only(bottom: 24),
            ),
          ),
          Text('make_offer'.tr, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Panels Section
                  _buildSectionTitle('panels'.tr, Icons.wb_sunny, 'panel'),
                  _buildProductSelector(
                    label: 'Select Panel (Optional)',
                    categoryDetails: ['solar', 'panel'],
                    selectedProduct: _selectedPanel,
                    onChanged: (val) => _onProductSelected('pv', val),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(controller: _pvCountCtrl, hintText: 'Count', keyboardType: TextInputType.number),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: CustomTextField(controller: _pvCapCtrl, hintText: 'Capacity (W)', keyboardType: TextInputType.number),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(controller: _pvMarkCtrl, hintText: 'Brand/Mark'),

                  const SizedBox(height: 24),

                  // Batteries Section
                  _buildSectionTitle('batteries'.tr, Icons.battery_charging_full, 'battery'),
                  _buildProductSelector(
                    label: 'Select Battery (Optional)',
                    categoryDetails: ['battery'],
                    selectedProduct: _selectedBattery,
                    onChanged: (val) => _onProductSelected('batt', val),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(controller: _battCountCtrl, hintText: 'Count', keyboardType: TextInputType.number),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: CustomTextField(controller: _battCapCtrl, hintText: 'Capacity (Ah/kWh)', keyboardType: TextInputType.number),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(controller: _battMarkCtrl, hintText: 'Brand/Mark'),

                  const SizedBox(height: 24),

                  // Inverters Section
                  _buildSectionTitle('Inverter'.tr, Icons.flash_on, 'inverter'),
                  _buildProductSelector(
                    label: 'Select Inverter (Optional)',
                    categoryDetails: ['inverter'],
                    selectedProduct: _selectedInverter,
                    onChanged: (val) => _onProductSelected('inv', val),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(controller: _invCountCtrl, hintText: 'Count', keyboardType: TextInputType.number),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: CustomTextField(controller: _invCapCtrl, hintText: 'Capacity (kVA/kW)', keyboardType: TextInputType.number),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(controller: _invMarkCtrl, hintText: 'Brand/Mark'),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: CustomTextField(controller: _invPhaseCtrl, hintText: 'Phase (1/3)'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  _buildSectionTitle('includes'.tr, Icons.check_box, 'includes'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _possibleInvolves.map((item) {
                      final isSelected = _selectedInvolves.contains(item);
                      return FilterChip(
                        label: Text(item),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedInvolves.add(item);
                            } else {
                              _selectedInvolves.remove(item);
                            }
                          });
                        },
                        selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                        checkmarkColor: AppTheme.primaryColor,
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _priceCtrl,
                    hintText: 'total_price'.tr,
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.attach_money),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(controller: _notesCtrl, hintText: 'offer_notes'.tr, maxLines: 3),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),

          SizedBox(
            width: double.infinity,
            child: Obx(
              () => ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: controller.isSubmitting.value ? null : () => _submit(controller, companyController),
                child: controller.isSubmitting.value
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text('submit_offer'.tr),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductSelector({
    required String label,
    required List<String> categoryDetails,
    required ProductModel? selectedProduct,
    required ValueChanged<ProductModel?> onChanged,
  }) {
    return Obx(() {
      final products = _inventoryController.products.where((p) {
        final cat = p.category?.toLowerCase() ?? '';
        final name = p.name.toLowerCase();
        return categoryDetails.any((d) => cat.contains(d) || name.contains(d));
      }).toList();

      if (products.isEmpty) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text("No items in inventory (Manual entry only)", style: const TextStyle(color: Colors.grey, fontSize: 13)),
        );
      }

      return DropdownButtonFormField<ProductModel>(
        initialValue: selectedProduct,
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        isExpanded: true,
        items: products
            .map(
              (p) => DropdownMenuItem(
                value: p,
                child: Text("${p.name} (Stock: ${p.stockQuantity})", overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14)),
              ),
            )
            .toList(),
        onChanged: onChanged,
      );
    });
  }

  Widget _buildSectionTitle(String title, IconData icon, String categoryKey) {
    // ... same as before but simplified if needed ...
    // Keeping logic basic for brevity in this update
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.primaryColor),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  void _submit(OfferRequestsController controller, CompanyController companyController) {
    if (_priceCtrl.text.isEmpty) {
      _showError('price_required'.tr);
      return;
    }

    // Validate selections
    if (_selectedPanel != null && _pvCountCtrl.text.isNotEmpty) {
      if ((int.tryParse(_pvCountCtrl.text) ?? 0) > _selectedPanel!.stockQuantity) {
        _showError('Insufficient stock for ${_selectedPanel!.name}');
        return;
      }
    }
    if (_selectedBattery != null && _battCountCtrl.text.isNotEmpty) {
      if ((int.tryParse(_battCountCtrl.text) ?? 0) > _selectedBattery!.stockQuantity) {
        _showError('Insufficient stock for ${_selectedBattery!.name}');
        return;
      }
    }
    if (_selectedInverter != null && _invCountCtrl.text.isNotEmpty) {
      if ((int.tryParse(_invCountCtrl.text) ?? 0) > _selectedInverter!.stockQuantity) {
        _showError('Insufficient stock for ${_selectedInverter!.name}');
        return;
      }
    }

    final price = double.tryParse(_priceCtrl.text);
    if (price == null) return;

    final company = companyController.company.value;
    if (company == null) return;

    final pb = _selectedPanel;
    final bb = _selectedBattery;
    final ib = _selectedInverter;

    final offerData = {
      'company_id': company.id,
      'company_name': company.name, // Extra meta not in SQL but useful
      'request_user_id': widget.requestUserId,
      'price': price,
      'notes': _notesCtrl.text,
      'pv_specs': {
        'count': int.tryParse(_pvCountCtrl.text) ?? 0,
        'capacity': double.tryParse(_pvCapCtrl.text) ?? 0,
        'mark': _pvMarkCtrl.text,
        'product_id': pb?.id, // Storing ID for order processing later
      },
      'battery_specs': {
        'count': int.tryParse(_battCountCtrl.text) ?? 0,
        'capacity': double.tryParse(_battCapCtrl.text) ?? 0,
        'mark': _battMarkCtrl.text,
        'product_id': bb?.id,
      },
      'inverter_specs': {
        'count': int.tryParse(_invCountCtrl.text) ?? 0,
        'capacity': double.tryParse(_invCapCtrl.text) ?? 0,
        'mark': _invMarkCtrl.text,
        'phase': _invPhaseCtrl.text,
        'product_id': ib?.id,
      },
      'involves': _selectedInvolves,
    };

    // Explicitly send specific keys to match what controller might expect or DB triggers
    // The JSON structure matches the User Request:
    // pv: {count, capacity, mark}
    // battery: {count, capacity, mark}
    // inverter: {count, capacity, mark, phase}

    controller.submitOffer(widget.requestId, offerData);
  }

  void _showError(String msg) {
    toastification.show(
      title: Text('err_error'.tr),
      description: Text(msg),
      type: ToastificationType.error,
      style: ToastificationStyle.flat,
      autoCloseDuration: const Duration(seconds: 3),
    );
  }
}
