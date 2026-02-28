import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_hub/controllers/inventory_controller.dart';
import 'package:solar_hub/controllers/company_controller.dart';
import 'package:solar_hub/layouts/shared/widgets/custom_text_field.dart';
import 'package:solar_hub/layouts/shared/widgets/responsive_row_column.dart';

import 'package:solar_hub/features/store/models/product_model.dart';
import 'package:solar_hub/services/supabase_service.dart';
import 'package:solar_hub/utils/app_theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AddProductPage extends StatefulWidget {
  final ProductModel? product; // Null for create, non-null for edit
  const AddProductPage({super.key, this.product});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final InventoryController controller = Get.find();
  final CompanyController companyController = Get.find();

  // Basic Info
  final nameCtrl = TextEditingController();
  final skuCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final imageUrlCtrl = TextEditingController();
  File? _selectedImage;
  String? _uploadedImageUrl;

  // Categorization
  String? selectedGlobalCategory;
  List<Map<String, dynamic>> globalCategories = [];
  final companyCategories = <Map<String, dynamic>>[];
  final selectedCategoryIds = <String>[].obs;

  // Pricing
  final costPriceCtrl = TextEditingController(text: '0');
  final retailPriceCtrl = TextEditingController();
  final wholesalePriceCtrl = TextEditingController();
  final pricingTiers = <ProductPricingTier>[].obs;

  // Inventory
  final stockCtrl = TextEditingController(text: '0');
  final minStockCtrl = TextEditingController(text: '5');

  // Options (Variants)
  final productOptions = <ProductOption>[].obs;

  final isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _fetchMetadata();

    if (widget.product != null) {
      _prefillData(widget.product!);
      _uploadedImageUrl = widget.product!.imageUrl;
    }
  }

  void _prefillData(ProductModel p) {
    nameCtrl.text = p.name;
    skuCtrl.text = p.sku ?? '';
    descCtrl.text = p.description ?? '';
    imageUrlCtrl.text = p.imageUrl ?? '';
    selectedGlobalCategory = p.category;

    retailPriceCtrl.text = p.retailPrice.toString();
    costPriceCtrl.text = p.costPrice.toString();
    wholesalePriceCtrl.text = p.wholesalePrice.toString();

    stockCtrl.text = p.stockQuantity.toString();
    minStockCtrl.text = p.minStockAlert.toString();

    pricingTiers.assignAll(p.pricingTiers);
    productOptions.assignAll(p.options);
    selectedCategoryIds.assignAll(p.companyCategoryIds);
  }

  void _checkPermissions() {
    final role = companyController.currentRole.value;
    if (!['owner', 'manager', 'inventory_manager'].contains(role)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed('/company_dashboard');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("You do not have permission to manage inventory."), backgroundColor: Colors.red));
        }
      });
    }
  }

  Future<void> _fetchMetadata() async {
    isLoading.value = true;
    try {
      final db = SupabaseService().client;
      final globalResp = await db.from('global_categories').select().order('name');
      setState(() {
        globalCategories = List<Map<String, dynamic>>.from(globalResp);
      });

      await _refreshCompanyCategories();
    } catch (e) {
      debugPrint('Error fetching metadata: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _refreshCompanyCategories() async {
    final db = SupabaseService().client;
    // Filter by company? RLS handles it usually, or we filter by company_id if needed
    final companyId = companyController.company.value?.id;
    if (companyId != null) {
      final companyCatsResp = await db.from('company_categories').select().eq('company_id', companyId).order('name');
      companyCategories.clear();
      companyCategories.addAll(List<Map<String, dynamic>>.from(companyCatsResp));
      setState(() {});
    }
  }

  Future<void> _createCompanyCategory(String name) async {
    try {
      final companyId = companyController.company.value?.id;
      if (companyId == null) return;

      await SupabaseService().client.from('company_categories').insert({
        'company_id': companyId,
        'name': name,
        'color_hex': '#000000', // Default
      });
      await _refreshCompanyCategories();
      await _refreshCompanyCategories();
      await _refreshCompanyCategories();
      if (mounted) Navigator.of(context).pop(); // Close dialog safely

      Future.delayed(const Duration(milliseconds: 300), () {
        Get.showSnackbar(
          GetSnackBar(
            title: "success".tr,
            message: "success_create_category".tr.replaceAll('@name', name),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      });
    } catch (e) {
      if (mounted) Navigator.of(context).pop(); // Close dialog safely

      Future.delayed(const Duration(milliseconds: 300), () {
        Get.showSnackbar(
          GetSnackBar(title: "error".tr, message: "${'error_create_category'.tr}: $e", backgroundColor: Colors.red, duration: const Duration(seconds: 3)),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.product == null ? "Add Product" : "Edit Product")),
      body: Obx(() {
        if (isLoading.value) return const Center(child: CircularProgressIndicator());

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Basic Info ---
                  _buildSectionCard(
                    title: "Basic Information",
                    icon: Icons.info_outline,
                    children: [
                      CustomTextField(controller: nameCtrl, hintText: "product_name".tr),
                      const SizedBox(height: 16),
                      // Image Upload Section
                      Center(
                        child: GestureDetector(
                          onTap: _showImagePickerOptions,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: _selectedImage != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(_selectedImage!, fit: BoxFit.cover),
                                  )
                                : (_uploadedImageUrl != null && _uploadedImageUrl!.isNotEmpty)
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: CachedNetworkImage(
                                      imageUrl: _uploadedImageUrl!,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                      errorWidget: (context, url, error) => const Icon(Icons.error),
                                    ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_a_photo, size: 40, color: Colors.grey[400]),
                                      const SizedBox(height: 8),
                                      Text("add_image".tr, style: TextStyle(color: Colors.grey[600])),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                      if (_uploadedImageUrl != null && _selectedImage == null)
                        Center(
                          child: TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _uploadedImageUrl = null;
                                imageUrlCtrl.clear();
                              });
                            },
                            icon: const Icon(Icons.delete, color: Colors.red),
                            label: const Text('Remove Image', style: TextStyle(color: Colors.red)),
                          ),
                        ),
                      const SizedBox(height: 16),
                      CustomTextField(controller: descCtrl, hintText: "description_hint".tr, maxLines: 3),
                      const SizedBox(height: 16),
                      ResponsiveRowColumn(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(controller: skuCtrl, hintText: "sku_hint".tr),
                              ),
                              const SizedBox(width: 8),
                              IconButton.filledTonal(onPressed: _scanBarcode, icon: const Icon(Icons.qr_code_scanner), tooltip: 'Scan Barcode'),
                            ],
                          ),
                          // CustomTextField(controller: imageUrlCtrl, hintText: "image_url_hint".tr), // Hidden or used as fallback
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // --- Categorization ---
                  _buildSectionCard(
                    title: "categorization".tr,
                    icon: Icons.category,
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: globalCategories.any((c) => c['name'] == selectedGlobalCategory) ? selectedGlobalCategory : null,
                        decoration: InputDecoration(labelText: "global_category".tr, border: const OutlineInputBorder()),
                        items: globalCategories.map((c) => DropdownMenuItem(value: c['name'] as String, child: Text(c['name']))).toList(),
                        onChanged: (v) => setState(() => selectedGlobalCategory = v),
                      ),
                      const SizedBox(height: 16),
                      Builder(
                        builder: (context) {
                          if (companyCategories.isEmpty) {
                            return Text("${'company_tags'.tr} (Loading...)");
                          }
                          return Obx(
                            () => Wrap(
                              spacing: 8,
                              children: companyCategories.map((cat) {
                                final isSelected = selectedCategoryIds.contains(cat['id']);
                                return FilterChip(
                                  label: Text(cat['name']),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    if (selected) {
                                      selectedCategoryIds.add(cat['id']);
                                    } else {
                                      selectedCategoryIds.remove(cat['id']);
                                    }
                                  },
                                );
                              }).toList(),
                            ),
                          );
                        },
                      ),
                    ],
                    headerAction: TextButton.icon(
                      onPressed: () {
                        final TextEditingController newCatCtrl = TextEditingController();
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text("create_category".tr),
                            content: CustomTextField(controller: newCatCtrl, hintText: "new_category_name".tr),
                            actions: [
                              TextButton(onPressed: () => Navigator.of(context).pop(), child: Text("cancel".tr)),
                              ElevatedButton(
                                onPressed: () {
                                  if (newCatCtrl.text.isNotEmpty) {
                                    _createCompanyCategory(newCatCtrl.text);
                                  }
                                },
                                child: Text("confirm".tr),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: Text("add_rule".tr), // Reusing 'Add Rule' or 'Add' context
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- Pricing ---
                  _buildSectionCard(
                    title: "pricing".tr,
                    icon: Icons.attach_money,
                    children: [
                      ResponsiveRowColumn(
                        children: [
                          CustomTextField(
                            controller: retailPriceCtrl,
                            hintText: "${'retail_price'.tr} (${companyController.effectiveCurrency.symbol})",
                            keyboardType: TextInputType.number,
                          ),
                          CustomTextField(
                            controller: costPriceCtrl,
                            hintText: "${'cost_price'.tr} (${companyController.effectiveCurrency.symbol})",
                            keyboardType: TextInputType.number,
                          ),
                          CustomTextField(
                            controller: wholesalePriceCtrl,
                            hintText: "${'wholesale_price'.tr} (${companyController.effectiveCurrency.symbol})",
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // --- Pricing Tiers ---
                  _buildSectionCard(
                    title: "quantity_discounts".tr,
                    icon: Icons.discount,
                    headerAction: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          pricingTiers.add(ProductPricingTier(minQuantity: 10, unitPrice: 0));
                        });
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: Text("add_rule".tr),
                    ),
                    children: [
                      if (pricingTiers.isEmpty) const Padding(padding: EdgeInsets.all(8.0), child: Text("No tiered pricing. Standard Retail Price applies.")),
                      ...pricingTiers.asMap().entries.map((entry) {
                        final index = entry.key;
                        final tier = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: ResponsiveRowColumn(
                                  children: [
                                    TextFormField(
                                      initialValue: tier.minQuantity.toString(),
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(labelText: "min_qty".tr, isDense: true, border: const OutlineInputBorder()),
                                      onChanged: (v) => pricingTiers[index] = ProductPricingTier(minQuantity: int.tryParse(v) ?? 1, unitPrice: tier.unitPrice),
                                    ),
                                    TextFormField(
                                      initialValue: tier.unitPrice.toString(),
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: "offer_price".tr,
                                        isDense: true,
                                        border: const OutlineInputBorder(),
                                        prefixText: companyController.effectiveCurrency.symbol,
                                      ),
                                      onChanged: (v) =>
                                          pricingTiers[index] = ProductPricingTier(minQuantity: tier.minQuantity, unitPrice: double.tryParse(v) ?? 0),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.grey),
                                onPressed: () => pricingTiers.removeAt(index),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // --- Product Options (Variants) ---
                  _buildSectionCard(
                    title: "product_options".tr,
                    icon: Icons.checklist_rtl,
                    headerAction: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          productOptions.add(ProductOption(name: "", values: []));
                        });
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: Text("add_option".tr),
                    ),
                    children: [
                      if (productOptions.isEmpty) const Padding(padding: EdgeInsets.all(8.0), child: Text("No options defined (Simple Product).")),
                      ...productOptions.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final opt = entry.value;
                        return Card(
                          elevation: 0,
                          color: Colors.grey.withValues(alpha: 0.05),
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        initialValue: opt.name,
                                        decoration: InputDecoration(labelText: "option_name_hint".tr),
                                        onChanged: (v) => productOptions[idx] = ProductOption(name: v, values: opt.values, isRequired: opt.isRequired),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                                      onPressed: () => productOptions.removeAt(idx),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Checkbox(
                                      value: opt.isRequired,
                                      onChanged: (v) => productOptions[idx] = ProductOption(name: opt.name, values: opt.values, isRequired: v ?? false),
                                    ),
                                    Text("required".tr),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    ...opt.values.asMap().entries.map((vEntry) {
                                      final vIdx = vEntry.key;
                                      final val = vEntry.value;
                                      return Chip(
                                        label: Text("${val.value} (+${val.extraCost})"),
                                        onDeleted: () {
                                          var newValues = List<ProductOptionValue>.from(opt.values);
                                          newValues.removeAt(vIdx);
                                          productOptions[idx] = ProductOption(name: opt.name, isRequired: opt.isRequired, values: newValues);
                                        },
                                      );
                                    }),
                                    ActionChip(label: Text("add_value".tr), onPressed: () => _showAddValueDialog(idx)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // --- Inventory ---
                  _buildSectionCard(
                    title: "inventory".tr,
                    icon: FontAwesomeIcons.boxesStacked,
                    children: [
                      ResponsiveRowColumn(
                        children: [
                          CustomTextField(controller: stockCtrl, hintText: "initial_stock".tr, keyboardType: TextInputType.number),
                          CustomTextField(controller: minStockCtrl, hintText: "low_stock_limit".tr, keyboardType: TextInputType.number),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                  Obx(
                    () => controller.isLoading.value
                        ? const Center(child: CircularProgressIndicator())
                        : SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white),
                              onPressed: _submit,
                              child: Text(widget.product != null ? "update_product".tr : "save_product".tr),
                            ),
                          ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required List<Widget> children, Widget? headerAction}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryColor),
              const SizedBox(width: 12),
              Flexible(
                child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              if (headerAction != null) ...[const SizedBox(width: 8), headerAction],
            ],
          ),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }

  void _showAddValueDialog(int optionIndex) {
    String valName = "";
    String extraCost = "0";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("add_value_title".tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(labelText: "value_hint".tr),
              onChanged: (v) => valName = v,
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(labelText: "extra_cost_hint".tr),
              keyboardType: TextInputType.number,
              onChanged: (v) => extraCost = v,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text("cancel".tr)),
          ElevatedButton(
            onPressed: () {
              if (valName.isNotEmpty) {
                var newValues = List<ProductOptionValue>.from(productOptions[optionIndex].values);
                newValues.add(ProductOptionValue(value: valName, extraCost: double.tryParse(extraCost) ?? 0));
                productOptions[optionIndex] = ProductOption(
                  name: productOptions[optionIndex].name,
                  isRequired: productOptions[optionIndex].isRequired,
                  values: newValues,
                );
              }
              Navigator.of(context).pop();
            },
            child: Text("add_btn".tr),
          ),
        ],
      ),
    );
  }

  void _submit() async {
    if (nameCtrl.text.isEmpty || retailPriceCtrl.text.isEmpty) {
      Get.showSnackbar(
        const GetSnackBar(
          title: "Missing Info",
          message: "Name and Retail Price are required.",
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    isLoading.value = true;

    final productData = {
      'name': nameCtrl.text,
      'sku': skuCtrl.text,
      'description': descCtrl.text,
      'image_url': _uploadedImageUrl ?? imageUrlCtrl.text, // Use manually entered URL if no upload/existing

      'category': selectedGlobalCategory,
      'retail_price': double.tryParse(retailPriceCtrl.text) ?? 0,
      'wholesale_price': double.tryParse(wholesalePriceCtrl.text) ?? 0,
      'cost_price': double.tryParse(costPriceCtrl.text) ?? 0,
      'stock_quantity': int.tryParse(stockCtrl.text) ?? 0,
      'min_stock_alert': int.tryParse(minStockCtrl.text) ?? 5,
      'status': 'active',
      'specs': {},
    };

    try {
      if (widget.product == null) {
        // Handle Image Upload
        if (_selectedImage != null) {
          final url = await controller.uploadProductImage(_selectedImage!);
          if (url != null) productData['image_url'] = url;
        }

        // Create
        await controller.addProduct(productData, tiers: pricingTiers, categoryIds: selectedCategoryIds, options: productOptions);
        Get.offNamed('/company_dashboard');

        Future.delayed(const Duration(milliseconds: 500), () {
          Get.showSnackbar(GetSnackBar(message: "product_added_success".tr, backgroundColor: Colors.green, duration: const Duration(seconds: 2)));
        });
      } else {
        // Handle Image Upload
        if (_selectedImage != null) {
          final url = await controller.uploadProductImage(_selectedImage!);
          if (url != null) productData['image_url'] = url;
        } else if (_uploadedImageUrl == null && imageUrlCtrl.text.isEmpty) {
          // If user removed image and didn't select new one, clear it?
          // Currently logic assumes empty string or null means no image.
          productData['image_url'] = "";
        }

        // Update
        if (widget.product?.id == null) throw "Product ID missing";
        await controller.updateProduct(widget.product!.id!, productData, tiers: pricingTiers, categoryIds: selectedCategoryIds, options: productOptions);
        if (mounted) Navigator.of(context).pop();

        Future.delayed(const Duration(milliseconds: 500), () {
          Get.showSnackbar(GetSnackBar(message: "product_updated_success".tr, backgroundColor: Colors.green, duration: const Duration(seconds: 2)));
        });
      }
    } catch (e) {
      Get.showSnackbar(
        GetSnackBar(message: "error_adding_product".tr.replaceAll('@error', e.toString()), backgroundColor: Colors.red, duration: const Duration(seconds: 3)),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _showImagePickerOptions() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source, maxWidth: 1024, maxHeight: 1024, imageQuality: 85);

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> _scanBarcode() async {
    try {
      var result = await BarcodeScanner.scan();
      if (result.type == ResultType.Barcode) {
        setState(() {
          skuCtrl.text = result.rawContent;
        });
        Get.snackbar(
          'Success',
          'Barcode scanned: ${result.rawContent}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(milliseconds: 1500),
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to scan barcode: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }
}
