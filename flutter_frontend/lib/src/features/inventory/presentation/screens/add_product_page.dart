import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:watt/l10n/app_localizations.dart';
import 'package:watt/src/core/widgets/pre_scaffold.dart';
import 'package:watt/src/core/widgets/wizard_bottom_bar.dart';
import 'package:watt/src/core/widgets/wizard_step_indicator.dart';
import 'package:watt/src/features/inventory/domain/entities/product.dart';
import 'package:watt/src/features/inventory/presentation/providers/product_form_provider.dart';
import 'package:watt/src/features/inventory/presentation/widgets/product_form/product_basic_info_form.dart';
import 'package:watt/src/features/inventory/presentation/widgets/product_form/product_pricing_form.dart';
import 'package:watt/src/features/inventory/presentation/widgets/product_form/product_inventory_form.dart';
import 'package:watt/src/features/inventory/presentation/widgets/product_form/product_category_form.dart';
import 'package:watt/src/features/inventory/presentation/widgets/product_form/product_image_picker.dart';
import 'package:watt/src/features/inventory/presentation/widgets/product_form/product_options_form.dart';
import 'package:watt/src/features/inventory/presentation/widgets/product_form/product_pricing_tiers_form.dart';
import 'package:watt/src/shared/widgets/app_card.dart';

/// Company-side add/edit product screen.
///
/// Previously this was a single ~500px-tall scrolling `Form` stacking all
/// 7 sections (basic info, images, pricing, inventory, categories, options,
/// pricing tiers) on top of each other — a "massive single-file UI widget"
/// pattern the project's own conventions call out to avoid. It's now a
/// 4-step wizard (Basics -> Pricing & Stock -> Categories & Options ->
/// Review) using the same `WizardStepIndicator`/`WizardBottomBar` shell as
/// the PV System Designer, and the hardcoded `Colors.white` /
/// `Colors.blueGrey` / manual `boxShadow` card styling has been replaced
/// with the shared `AppCard` (theme card color + themed border), matching
/// the visual language the rest of the storefront/company screens use.
class AddProductPage extends ConsumerStatefulWidget {
  final Product? product;

  const AddProductPage({super.key, this.product});

  @override
  ConsumerState<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends ConsumerState<AddProductPage> with SingleTickerProviderStateMixin {
  static const int _totalSteps = 4;

  final _formKey = GlobalKey<FormState>();
  late final TabController _tabController;
  int _currentStep = 0;

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
    _tabController = TabController(length: _totalSteps, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() => _currentStep = _tabController.index);
    });

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
    _tabController.dispose();
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

  void _goToStep(int step) => _tabController.animateTo(step);

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productFormNotifierProvider);
    final l10n = AppLocalizations.of(context)!;
    final isEditing = widget.product != null;

    final stepLabels = [
      l10n.productStepBasics,
      l10n.productStepPricing,
      l10n.productStepCategoriesOptions,
      l10n.productStepReview,
    ];

    return PreScaffold(
      title: isEditing ? l10n.editProduct : l10n.addProduct,
      child: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                WizardStepIndicator(currentStep: _currentStep, totalSteps: _totalSteps, stepLabels: stepLabels),
                if (state.error != null)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: 12.h),
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12.r)),
                      child: Text(state.error!, style: const TextStyle(color: Colors.red)),
                    ),
                  ),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: TabBarView(
                      controller: _tabController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _StepScroll(children: [
                          _buildSection(l10n.basicInformation, ProductBasicInfoForm(nameCtrl: _nameCtrl, descCtrl: _descCtrl, skuCtrl: _skuCtrl)),
                          SizedBox(height: 20.h),
                          _buildSection(l10n.productImages, const ProductImagePicker()),
                        ]),
                        _StepScroll(children: [
                          _buildSection(l10n.pricing, ProductPricingForm(retailPriceCtrl: _retailPriceCtrl, costPriceCtrl: _costPriceCtrl, wholesalePriceCtrl: _wholesalePriceCtrl)),
                          SizedBox(height: 20.h),
                          _buildSection(l10n.inventory, ProductInventoryForm(stockCtrl: _stockCtrl, minStockCtrl: _minStockCtrl)),
                        ]),
                        _StepScroll(children: [
                          _buildSection(l10n.all_categories, const ProductCategoryForm()),
                          SizedBox(height: 20.h),
                          _buildSection(l10n.productOptions, const ProductOptionsForm()),
                          SizedBox(height: 20.h),
                          _buildSection(l10n.pricing_tiers, const ProductPricingTiersForm()),
                        ]),
                        _StepScroll(children: [_buildReviewStep(l10n)]),
                      ],
                    ),
                  ),
                ),
                WizardBottomBar(
                  currentStep: _currentStep,
                  totalSteps: _totalSteps,
                  onBack: () => _goToStep(_currentStep - 1),
                  onNext: () => _goToStep(_currentStep + 1),
                  onFinish: _submit,
                  finishLabel: isEditing ? l10n.saveProduct : l10n.addProduct,
                  finishIcon: Icons.check_circle_outline_rounded,
                  isSubmitting: state.isSubmitting,
                ),
              ],
            ),
    );
  }

  Widget _buildReviewStep(AppLocalizations l10n) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.productStepReview, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
          const Divider(height: 24),
          _reviewRow(l10n.productName, _nameCtrl.text),
          _reviewRow(l10n.sku, _skuCtrl.text),
          _reviewRow(l10n.retail_price, _retailPriceCtrl.text),
          _reviewRow(l10n.wholesale_price, _wholesalePriceCtrl.text),
          _reviewRow(l10n.stockQuantity, _stockCtrl.text),
        ],
      ),
    );
  }

  Widget _reviewRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Expanded(child: Text(label, style: TextStyle(color: Colors.grey.shade600))),
          Text(value.isEmpty ? '-' : value, style: TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget child) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
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
    } else {
      // Validation failed somewhere in the form — jump back to the first
      // step so the user isn't stuck on Review wondering what's wrong.
      _goToStep(0);
    }
  }
}

class _StepScroll extends StatelessWidget {
  final List<Widget> children;

  const _StepScroll({required this.children});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Column(children: children),
    );
  }
}
