import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/widgets/pre_scaffold.dart';
import 'package:solar_hub/src/features/inventory/domain/entities/product.dart';
import 'package:solar_hub/src/features/inventory/presentation/providers/product_form_provider.dart';
import 'package:solar_hub/src/features/inventory/presentation/widgets/product_form/product_basic_info_form.dart';
import 'package:solar_hub/src/features/inventory/presentation/widgets/product_form/product_pricing_form.dart';
import 'package:solar_hub/src/features/inventory/presentation/widgets/product_form/product_inventory_form.dart';
import 'package:solar_hub/src/features/inventory/presentation/widgets/product_form/product_category_form.dart';
import 'package:solar_hub/src/features/inventory/presentation/widgets/product_form/product_image_picker.dart';
import 'package:solar_hub/src/features/inventory/presentation/widgets/product_form/product_options_form.dart';
import 'package:solar_hub/src/features/inventory/presentation/widgets/product_form/product_pricing_tiers_form.dart';

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
  final _retailPriceCtrl = TextEditingController();
  final _costPriceCtrl = TextEditingController();
  final _wholesalePriceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _minStockCtrl = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productFormNotifierProvider);
    final l10n = AppLocalizations.of(context)!;
    final isEditing = widget.product != null;

    return PreScaffold(
      title: isEditing ? l10n.editProduct : l10n.addProduct,
      child: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.r),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (state.error != null)
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(bottom: 16.h),
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12.r)),
                        child: Text(state.error!, style: const TextStyle(color: Colors.red)),
                      ),
                    
                    _buildSection(l10n.basicInformation, ProductBasicInfoForm(nameCtrl: _nameCtrl, descCtrl: _descCtrl, skuCtrl: _skuCtrl)),
                    SizedBox(height: 20.h),
                    _buildSection(l10n.productImages, const ProductImagePicker()),
                    SizedBox(height: 20.h),
                    _buildSection(l10n.pricing, ProductPricingForm(retailPriceCtrl: _retailPriceCtrl, costPriceCtrl: _costPriceCtrl, wholesalePriceCtrl: _wholesalePriceCtrl)),
                    SizedBox(height: 20.h),
                    _buildSection(l10n.inventory, ProductInventoryForm(stockCtrl: _stockCtrl, minStockCtrl: _minStockCtrl)),
                    SizedBox(height: 20.h),
                    _buildSection(l10n.all_categories, const ProductCategoryForm()),
                    SizedBox(height: 20.h),
                    _buildSection(l10n.productOptions, const ProductOptionsForm()),
                    SizedBox(height: 20.h),
                    _buildSection(l10n.pricing_tiers, const ProductPricingTiersForm()),
                    
                    SizedBox(height: 40.h),
                    SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                        onPressed: _submit,
                        child: state.isSubmitting 
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(isEditing ? l10n.saveProduct : l10n.addProduct, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    SizedBox(height: 60.h),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSection(String title, Widget child) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.blueGrey[800])),
          const Divider(height: 24),
          child,
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
          );

      if (success && mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.productSaved)));
        context.pop();
      }
    }
  }
}
