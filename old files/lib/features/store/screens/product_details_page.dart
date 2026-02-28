import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../lib/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solar_hub/features/store/controllers/cart_controller.dart';
import 'package:solar_hub/features/store/models/product_model.dart';
import 'package:solar_hub/features/compnay/controllers/auth_controller.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:solar_hub/features/store/widgets/store_image.dart';
import 'package:solar_hub/utils/toast_service.dart';
import 'package:solar_hub/controllers/currency_controller.dart';
import 'package:solar_hub/models/currency_model.dart';

class ProductPage extends StatefulWidget {
  final ProductModel product;

  const ProductPage({super.key, required this.product});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final Map<String, dynamic> selectedOptions = {}; // OptionID -> Selected Value Map (full object or subset)

  @override
  void initState() {
    super.initState();
  }

  CurrencyModel get currency {
    if (widget.product.currency != null) return widget.product.currency!;
    try {
      final currencyController = Get.find<CurrencyController>();
      return currencyController.defaultCurrency ?? CurrencyModel(id: 'manual', name: 'US Dollar', code: 'USD', symbol: '\$');
    } catch (_) {
      return CurrencyModel(id: 'manual', name: 'US Dollar', code: 'USD', symbol: '\$');
    }
  }

  void _onOptionSelected(ProductOption option, ProductOptionValue value) {
    setState(() {
      selectedOptions[option.id!] = {
        'option_id': option.id,
        'option_name': option.name,
        'value_id': value.id,
        'value': value.value,
        'extra_cost': value.extraCost,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.find();
    final AuthController authController = Get.find();
    final theme = Theme.of(context);
    final product = widget.product;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.3), shape: BoxShape.circle),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.3), shape: BoxShape.circle),
            child: IconButton(
              icon: const Icon(Icons.shopping_cart, color: Colors.white),
              onPressed: () => Get.toNamed('/cart'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Header
            Hero(
              tag: product.id ?? product.name,
              child: Container(
                height: 350,
                width: double.infinity,
                color: Colors.grey[200],
                child: StoreImage(url: product.imageUrl, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
              ),
            ),

            // Content
            Container(
              transform: Matrix4.translationValues(0, -20, 0),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(product.name, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                      ),
                      Text(
                        '${currency.symbol}${product.retailPrice.toStringAsFixed(0)}',
                        style: theme.textTheme.headlineSmall?.copyWith(color: theme.primaryColor, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Status
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: product.stockQuantity > 0 ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      product.stockQuantity > 0 ? 'In Stock (${product.stockQuantity})' : 'Out of Stock',
                      style: TextStyle(color: product.stockQuantity > 0 ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Pricing Tiers
                  Obx(() {
                    bool isCompanyMember = authController.user.value!.isCompanyMember;
                    if (isCompanyMember && product.pricingTiers.isNotEmpty) {
                      return _buildWholesalePricing(theme, product);
                    }
                    return const SizedBox.shrink();
                  }),

                  // Options Selector
                  if (product.options.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text('Options', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    ...product.options.map((option) => _buildOptionSelector(option, theme)),
                    const SizedBox(height: 10),
                  ],

                  // Company Categories
                  if (product.companyCategories.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16, top: 16),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: product.companyCategories.map((cat) {
                          return Chip(
                            label: Text(cat['name'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.white)),
                            backgroundColor: cat['color_hex'] != null
                                ? Color(int.parse((cat['color_hex'] as String).replaceAll('#', '0xff')))
                                : theme.primaryColor,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                          );
                        }).toList(),
                      ),
                    ),

                  // Description
                  Text('Description', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(product.description ?? 'No description available.', style: theme.textTheme.bodyMedium?.copyWith(height: 1.5, color: Colors.grey[600])),
                  const SizedBox(height: 20),

                  // Specs
                  if (product.specs.isNotEmpty) ...[
                    Text('Specifications', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    _buildSpecsGrid(product.specs, context),
                    const SizedBox(height: 20),
                  ],

                  // Add to Cart Button
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(FontAwesomeIcons.cartPlus),
                      label: const Text('Add to Cart'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                      ),
                      onPressed: product.stockQuantity > 0
                          ? () {
                              // Validate required options
                              for (var opt in product.options) {
                                if (opt.isRequired && !selectedOptions.containsKey(opt.id)) {
                                  ToastService.error("Incomplete Selection", "Please select ${opt.name}");
                                  return;
                                }
                              }
                              cartController.addToCart(product, selectedOptions: selectedOptions.values.toList().cast<Map<String, dynamic>>());
                            }
                          : null,
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionSelector(ProductOption option, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${option.name} ${option.isRequired ? "*" : ""}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: option.values.map((val) {
            final isSelected = selectedOptions[option.id]?['value_id'] == val.id;
            return ChoiceChip(
              label: Text('${val.value}${val.extraCost > 0 ? " (+${currency.symbol}${val.extraCost})" : ""}'),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) _onOptionSelected(option, val);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildWholesalePricing(ThemeData theme, ProductModel product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Wholesale Pricing",
            style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Table(
            columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(1)},
            children: [
              const TableRow(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Text("Min Qty", style: TextStyle(color: Colors.grey)),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Text("Unit Price", style: TextStyle(color: Colors.grey)),
                  ),
                ],
              ),
              ...product.pricingTiers.map((tier) {
                return TableRow(
                  children: [
                    Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Text("${tier.minQuantity}+")),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text("${currency.symbol}${tier.unitPrice.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecsGrid(Map<String, dynamic> specs, BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: specs.entries.map((e) {
        return Container(
          width: MediaQuery.of(context).size.width / 2 - 24, // 2 columns
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(e.key.capitalizeFirst ?? e.key, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 4),
              Text(e.value.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        );
      }).toList(),
    );
  }
}
