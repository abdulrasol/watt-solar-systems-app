import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:watt/src/core/widgets/wd_image_preview.dart';
import 'package:watt/src/features/admin/presentation/controllers/admin_products_controller.dart';
import 'package:watt/src/features/admin/presentation/widgets/admin_page_scaffold.dart';
import 'package:watt/src/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:watt/src/features/storefront/domain/entities/storefront_models.dart';
import 'package:watt/src/utils/app_theme.dart';
import 'package:watt/src/utils/price_format_utils.dart';
import 'package:toastification/toastification.dart';

class AdminProductsScreen extends ConsumerStatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  ConsumerState<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends ConsumerState<AdminProductsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(adminProductsProvider.notifier).fetchProducts(isRefresh: true));
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(adminProductsProvider.notifier).fetchNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminProductsProvider);

    return AdminPageScaffold(
      actions: [
        IconButton(onPressed: () => _openProductForm(context), icon: const Icon(Iconsax.add_circle)),
        IconButton(onPressed: () => ref.read(adminProductsProvider.notifier).fetchProducts(isRefresh: true), icon: const Icon(Iconsax.refresh)),
      ],
      child: state.isLoading
          ? const AdminLoadingState(icon: Iconsax.box, message: 'Loading products...')
          : state.error != null
          ? AdminErrorState(error: state.error!, onRetry: () => ref.read(adminProductsProvider.notifier).fetchProducts(isRefresh: true))
          : _buildContent(context, state),
    );
  }

  Future<void> _openProductForm(BuildContext context, {StorefrontProduct? product}) async {
    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _AdminProductFormSheet(
        product: product,
        onSubmit: (values) async {
          final controller = ref.read(adminProductsProvider.notifier);
          try {
            if (product == null) {
              await controller.createProduct(
                companyId: values.companyId!,
                name: values.name,
                sku: values.sku,
                globalCategoryId: values.globalCategoryId,
                description: values.description,
                costPrice: values.costPrice ?? 0,
                retailPrice: values.retailPrice ?? 0,
                wholesalePrice: values.wholesalePrice ?? 0,
                discount: values.discount ?? 0,
                stockQuantity: values.stockQuantity ?? 0,
                minStockAlert: values.minStockAlert ?? 5,
                status: values.status ?? 'active',
              );
            } else {
              await controller.updateProduct(
                product.id,
                companyId: values.companyId,
                name: values.name,
                sku: values.sku,
                globalCategoryId: values.globalCategoryId,
                description: values.description,
                retailPrice: values.retailPrice,
                wholesalePrice: values.wholesalePrice,
                discount: values.discount,
                stockQuantity: values.stockQuantity,
                minStockAlert: values.minStockAlert,
                status: values.status,
              );
            }
            if (context.mounted) {
              toastification.show(
                context: context,
                type: ToastificationType.success,
                title: Text(product == null ? 'Product created' : 'Product updated'),
                autoCloseDuration: const Duration(seconds: 3),
              );
            }
          } catch (e) {
            if (context.mounted) {
              toastification.show(
                context: context,
                type: ToastificationType.error,
                title: const Text('Save failed'),
                description: Text(e.toString()),
                autoCloseDuration: const Duration(seconds: 4),
              );
            }
            rethrow;
          }
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, StorefrontProduct product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete product'),
        content: Text('Delete "${product.name}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(adminProductsProvider.notifier).deleteProduct(product.id);
      if (context.mounted) {
        toastification.show(context: context, type: ToastificationType.success, title: const Text('Product deleted'), autoCloseDuration: const Duration(seconds: 3));
      }
    } catch (e) {
      if (context.mounted) {
        toastification.show(context: context, type: ToastificationType.error, title: const Text('Delete failed'), description: Text(e.toString()), autoCloseDuration: const Duration(seconds: 4));
      }
    }
  }

  Widget _buildContent(BuildContext context, AdminProductsState state) {
    if (state.products.isEmpty) {
      return const AdminEmptyState(icon: Iconsax.box_search, title: 'No products found', subtitle: 'Global product list is currently empty.');
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(adminProductsProvider.notifier).fetchProducts(isRefresh: true),
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.only(bottom: 100),
        itemCount: state.products.length + (state.isMoreLoading ? 1 : 0),
        separatorBuilder: (_, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == state.products.length) {
            return const Center(
              child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()),
            );
          }
          final product = state.products[index];
          return _ProductAdminCard(
            product: product,
            onEdit: () => _openProductForm(context, product: product),
            onDelete: () => _confirmDelete(context, product),
          );
        },
      ),
    );
  }
}

class _ProductAdminCard extends StatelessWidget {
  const _ProductAdminCard({required this.product, required this.onEdit, required this.onDelete});

  final StorefrontProduct product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: WdImagePreview(imageUrl: product.primaryImage ?? '', size: 80),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _StatusBadge(status: product.status),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Company: ${product.company.name}', style: TextStyle(fontSize: 13, color: Theme.of(context).hintColor)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      product.displayPrice.toPrice(),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.primaryColor),
                    ),
                    const Spacer(),
                    Text(
                      'Stock: ${product.stockQuantity}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: product.stockQuantity <= product.minStockAlert ? AppTheme.errorColor : Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(onPressed: onEdit, icon: const Icon(Iconsax.edit_2, size: 18), tooltip: 'Edit'),
              IconButton(onPressed: onDelete, icon: const Icon(Iconsax.trash, size: 18, color: Colors.redAccent), tooltip: 'Delete'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = status.toLowerCase() == 'active' ? Colors.green : Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}

/// Parsed form output — nullable fields mean "leave unchanged" on edit,
/// since the backend's `AdminProductUpdateSchema` only touches whichever
/// fields are actually present in the request payload.
class _ProductFormValues {
  const _ProductFormValues({
    required this.name,
    this.companyId,
    this.sku,
    this.globalCategoryId,
    this.description,
    this.costPrice,
    this.retailPrice,
    this.wholesalePrice,
    this.discount,
    this.stockQuantity,
    this.minStockAlert,
    this.status,
  });

  final String name;
  final int? companyId;
  final String? sku;
  final int? globalCategoryId;
  final String? description;
  final double? costPrice;
  final double? retailPrice;
  final double? wholesalePrice;
  final double? discount;
  final int? stockQuantity;
  final int? minStockAlert;
  final String? status;
}

/// Product create/edit form. Deliberately scoped to the core fields
/// (name, company, category, pricing, stock, status) rather than the full
/// options/pricing-tier/image-upload complexity the company-side product
/// form supports — this closes the "admin can only view, not manage"
/// gap without trying to fully replicate that more complex flow.
class _AdminProductFormSheet extends StatefulWidget {
  const _AdminProductFormSheet({required this.onSubmit, this.product});

  final StorefrontProduct? product;
  final Future<void> Function(_ProductFormValues values) onSubmit;

  @override
  State<_AdminProductFormSheet> createState() => _AdminProductFormSheetState();
}

class _AdminProductFormSheetState extends State<_AdminProductFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _skuController;
  late final TextEditingController _companyIdController;
  late final TextEditingController _categoryIdController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _costController;
  late final TextEditingController _retailController;
  late final TextEditingController _wholesaleController;
  late final TextEditingController _discountController;
  late final TextEditingController _stockController;
  late final TextEditingController _minStockController;
  String _status = 'active';
  bool _isSubmitting = false;

  bool get _isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: p?.name ?? '');
    _skuController = TextEditingController(text: p?.sku ?? '');
    _companyIdController = TextEditingController(text: p != null ? '${p.company.id}' : '');
    _categoryIdController = TextEditingController(text: p?.globalCategory?.id != null ? '${p!.globalCategory!.id}' : '');
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _costController = TextEditingController();
    _retailController = TextEditingController(text: p != null ? '${p.retailPrice}' : '');
    _wholesaleController = TextEditingController(text: p != null ? '${p.wholesalePrice}' : '');
    _discountController = TextEditingController(text: p != null ? '${p.discount}' : '0');
    _stockController = TextEditingController(text: p != null ? '${p.stockQuantity}' : '0');
    _minStockController = TextEditingController(text: p != null ? '${p.minStockAlert}' : '5');
    _status = p?.status ?? 'active';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _companyIdController.dispose();
    _categoryIdController.dispose();
    _descriptionController.dispose();
    _costController.dispose();
    _retailController.dispose();
    _wholesaleController.dispose();
    _discountController.dispose();
    _stockController.dispose();
    _minStockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: screenHeight * 0.85),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_isEdit ? 'Edit Product' : 'New Product', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _companyIdController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Company ID',
                    helperText: _isEdit ? 'Change to reassign this product to a different company' : 'The company this product belongs to',
                  ),
                  validator: (v) {
                    if (_isEdit) return null; // optional on edit — only reassigns if changed
                    if (v == null || v.trim().isEmpty || int.tryParse(v.trim()) == null) return 'A numeric company ID is required';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextFormField(controller: _skuController, decoration: const InputDecoration(labelText: 'SKU (optional)'))),
                    const SizedBox(width: 12),
                    Expanded(child: TextFormField(controller: _categoryIdController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Category ID (optional)'))),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(controller: _descriptionController, maxLines: 3, decoration: const InputDecoration(labelText: 'Description (optional)')),
                const SizedBox(height: 12),
                if (!_isEdit) ...[
                  TextFormField(
                    controller: _costController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Cost Price'),
                  ),
                  const SizedBox(height: 12),
                ],
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _retailController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Retail Price'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _wholesaleController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Wholesale Price'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _discountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Discount'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(controller: _stockController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Stock Qty')),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(controller: _minStockController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Min Stock Alert')),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _status,
                  items: const [
                    DropdownMenuItem(value: 'active', child: Text('Active')),
                    DropdownMenuItem(value: 'draft', child: Text('Draft')),
                    DropdownMenuItem(value: 'archived', child: Text('Archived')),
                  ],
                  onChanged: (v) => setState(() => _status = v ?? 'active'),
                  decoration: const InputDecoration(labelText: 'Status'),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isSubmitting ? null : _handleSubmit,
                    child: Text(_isSubmitting ? 'Saving...' : 'Save'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      final values = _ProductFormValues(
        name: _nameController.text.trim(),
        companyId: int.tryParse(_companyIdController.text.trim()),
        sku: _skuController.text.trim().isEmpty ? null : _skuController.text.trim(),
        globalCategoryId: int.tryParse(_categoryIdController.text.trim()),
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        costPrice: double.tryParse(_costController.text.trim()),
        retailPrice: double.tryParse(_retailController.text.trim()),
        wholesalePrice: double.tryParse(_wholesaleController.text.trim()),
        discount: double.tryParse(_discountController.text.trim()),
        stockQuantity: int.tryParse(_stockController.text.trim()),
        minStockAlert: int.tryParse(_minStockController.text.trim()),
        status: _status,
      );
      await widget.onSubmit(values);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
