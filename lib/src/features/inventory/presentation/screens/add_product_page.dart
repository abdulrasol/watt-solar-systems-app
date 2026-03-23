import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import '../../domain/entities/product.dart';
import '../providers/product_form_provider.dart';

class AddProductPage extends ConsumerStatefulWidget {
  final Product? product;

  const AddProductPage({super.key, this.product});

  @override
  ConsumerState<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends ConsumerState<AddProductPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _skuCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _retailPriceCtrl = TextEditingController(text: '0');
  final _costPriceCtrl = TextEditingController(text: '0');
  final _wholesalePriceCtrl = TextEditingController(text: '0');
  final _stockCtrl = TextEditingController(text: '0');
  final _minStockCtrl = TextEditingController(text: '5');

  // Category management would typically load from a provider. For now we use ID or leave null
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productFormNotifierProvider.notifier).initializeWithProduct(widget.product);

      if (widget.product != null) {
        _nameCtrl.text = widget.product!.name;
        _skuCtrl.text = widget.product!.sku ?? '';
        _descCtrl.text = widget.product!.description ?? '';
        _retailPriceCtrl.text = widget.product!.retailPrice.toString();
        _costPriceCtrl.text = widget.product!.costPrice.toString();
        _wholesalePriceCtrl.text = widget.product!.wholesalePrice.toString();
        _stockCtrl.text = widget.product!.stockQuantity.toString();
        _minStockCtrl.text = widget.product!.minStockAlert.toString();
        _selectedCategoryId = widget.product!.category?.id;
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _skuCtrl.dispose();
    _descCtrl.dispose();
    _retailPriceCtrl.dispose();
    _costPriceCtrl.dispose();
    _wholesalePriceCtrl.dispose();
    _stockCtrl.dispose();
    _minStockCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source, maxWidth: 1024, maxHeight: 1024);
      if (pickedFile != null) {
        ref.read(productFormNotifierProvider.notifier).setImage(File(pickedFile.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to pick image')));
      }
    }
  }

  Future<void> _scanBarcode() async {
    try {
      final result = await BarcodeScanner.scan();
      if (result.type == ResultType.Barcode && result.rawContent.isNotEmpty) {
        setState(() {
          _skuCtrl.text = result.rawContent;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to scan barcode')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productFormNotifierProvider);
    final isEditing = widget.product != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Product' : 'Add Product')),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (state.error != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        color: Colors.red.withValues(alpha: 0.1),
                        child: Text(state.error!, style: const TextStyle(color: Colors.red)),
                      ),

                    // -- Basic Info
                    _buildSectionCard("Basic Information", [
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(labelText: 'Product Name', border: OutlineInputBorder()),
                        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descCtrl,
                        decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _skuCtrl,
                        decoration: InputDecoration(
                          labelText: 'SKU / Barcode',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(icon: const Icon(Icons.qr_code_scanner), onPressed: _scanBarcode, tooltip: 'Scan Barcode'),
                        ),
                      ),
                    ]),

                    const SizedBox(height: 24),

                    // -- Image Upload
                    _buildSectionCard("Product Image", [
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (_) => SafeArea(
                                child: Wrap(
                                  children: [
                                    ListTile(
                                      leading: const Icon(Icons.photo_library),
                                      title: const Text('Gallery'),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _pickImage(ImageSource.gallery);
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.camera_alt),
                                      title: const Text('Camera'),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _pickImage(ImageSource.camera);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: state.selectedImage != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(state.selectedImage!, fit: BoxFit.cover),
                                  )
                                : (state.existingImageUrl != null)
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: CachedNetworkImage(imageUrl: state.existingImageUrl!, fit: BoxFit.cover),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_a_photo, size: 40, color: Colors.grey[400]),
                                      const SizedBox(height: 8),
                                      Text('Add Image', style: TextStyle(color: Colors.grey[600])),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                      if (state.selectedImage != null || state.existingImageUrl != null)
                        Center(
                          child: TextButton.icon(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            label: const Text("Remove Image", style: TextStyle(color: Colors.red)),
                            onPressed: () => ref.read(productFormNotifierProvider.notifier).clearImage(),
                          ),
                        ),
                    ]),

                    const SizedBox(height: 24),

                    // -- Pricing
                    _buildSectionCard("Pricing", [
                      TextFormField(
                        controller: _retailPriceCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Retail Price', border: OutlineInputBorder()),
                        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _costPriceCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Cost Price', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _wholesalePriceCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Wholesale Price', border: OutlineInputBorder()),
                      ),
                    ]),

                    const SizedBox(height: 24),

                    // -- Inventory
                    _buildSectionCard("Inventory", [
                      TextFormField(
                        controller: _stockCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Initial Stock Quantity', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _minStockCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Low Stock Alert Limit', border: OutlineInputBorder()),
                      ),
                    ]),

                    const SizedBox(height: 24),

                    // -- Options
                    _buildSectionCard(
                      "Product Options (Variants)",
                      [
                        if (state.options.isEmpty) const Text("No options currently added."),
                        ...state.options.asMap().entries.map((req) {
                          final idx = req.key;
                          final opt = req.value;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            color: Colors.grey[50],
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                            child: ListTile(
                              title: Text(opt.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('+\$${opt.retailPrice} Retail \n+\$${opt.cost} Cost'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                tooltip: 'Remove Option',
                                onPressed: () => ref.read(productFormNotifierProvider.notifier).removeOption(idx),
                              ),
                            ),
                          );
                        }),
                      ],
                      headerAction: IconButton(
                        icon: const Icon(Icons.add_circle, color: Colors.blue),
                        tooltip: 'Add Option',
                        onPressed: _showAddOptionDialog,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // -- Pricing Tiers
                    _buildSectionCard(
                      "Quantity Discounts (Pricing Tiers)",
                      [
                        if (state.pricingTiers.isEmpty) const Text("No tiers currently added."),
                        ...state.pricingTiers.asMap().entries.map((req) {
                          final idx = req.key;
                          final tier = req.value;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            color: Colors.grey[50],
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                            child: ListTile(
                              title: Text('Min Qty: ${tier.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('Unit Price: \$${tier.unitPrice}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                tooltip: 'Remove Tier',
                                onPressed: () => ref.read(productFormNotifierProvider.notifier).removePricingTier(idx),
                              ),
                            ),
                          );
                        }),
                      ],
                      headerAction: IconButton(
                        icon: const Icon(Icons.add_circle, color: Colors.blue),
                        tooltip: 'Add Tier',
                        onPressed: _showAddTierDialog,
                      ),
                    ),

                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _submit,
                        child: Text(isEditing ? 'Save Changes' : 'Create Product', style: const TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children, {Widget? headerAction}) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              ?headerAction,
            ],
          ),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }

  void _showAddOptionDialog() {
    String name = '';
    double ret = 0;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Option'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Option Name (e.g. Size M)'),
              onChanged: (v) => name = v,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Additional Price'),
              keyboardType: TextInputType.number,
              onChanged: (v) => ret = double.tryParse(v) ?? 0,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (name.isNotEmpty) {
                ref.read(productFormNotifierProvider.notifier).addOption(ProductOption(name: name, retailPrice: ret));
              }
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddTierDialog() {
    int qty = 10;
    double price = 0;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Pricing Tier'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Minimum Quantity'),
              keyboardType: TextInputType.number,
              onChanged: (v) => qty = int.tryParse(v) ?? 10,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Unit Offer Price'),
              keyboardType: TextInputType.number,
              onChanged: (v) => price = double.tryParse(v) ?? 0,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (price > 0) {
                ref.read(productFormNotifierProvider.notifier).addPricingTier(ProductPricingTier(quantity: qty, unitPrice: price));
              }
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final success = await ref
          .read(productFormNotifierProvider.notifier)
          .saveProduct(
            currentProductId: widget.product?.id,
            name: _nameCtrl.text,
            sku: _skuCtrl.text,
            description: _descCtrl.text,
            retailPrice: double.tryParse(_retailPriceCtrl.text) ?? 0,
            costPrice: double.tryParse(_costPriceCtrl.text) ?? 0,
            wholesalePrice: double.tryParse(_wholesalePriceCtrl.text) ?? 0,
            stockQuantity: int.tryParse(_stockCtrl.text) ?? 0,
            minStockAlert: int.tryParse(_minStockCtrl.text) ?? 5,
            categoryId: _selectedCategoryId,
          );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product saved successfully')));
        if (widget.product != null) {
          context.go('/company-dashboard/inventory'); // Go back to list, details might be stale unless they refresh it
        } else {
          context.pop();
        }
      }
    }
  }
}
