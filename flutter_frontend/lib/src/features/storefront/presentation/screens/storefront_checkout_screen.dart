import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:watt/l10n/app_localizations.dart';
import 'package:watt/src/core/di/get_it.dart';
import 'package:watt/src/core/widgets/wizard_bottom_bar.dart';
import 'package:watt/src/core/widgets/wizard_step_indicator.dart';
import 'package:watt/src/features/orders_buyer/domain/repositories/orders_repository.dart';
import 'package:watt/src/features/orders_core/domain/entities/order_models.dart';
import 'package:watt/src/features/services/domain/repositories/public_services_repository.dart';
import 'package:watt/src/shared/domain/company/company.dart';
import 'package:watt/src/features/storefront/domain/entities/storefront_cart.dart';
import 'package:watt/src/features/storefront/domain/entities/storefront_models.dart';
import 'package:watt/src/features/storefront/domain/repositories/storefront_repository.dart';
import 'package:watt/src/features/storefront/presentation/providers/storefront_cart_controller.dart';
import 'package:watt/src/shared/widgets/app_card.dart';
import 'package:watt/src/utils/app_theme.dart';
import 'package:watt/src/utils/helper_methods.dart';

/// Dedicated full-screen checkout flow, replacing the old cramped
/// `showModalBottomSheet` (_CheckoutSheet) that used to pack payment method,
/// delivery method, and the price summary into one small scrollable sheet.
///
/// Three steps: Review Items -> Delivery, Payment & Address -> Confirm.
/// Each step gets its own screen real-estate, and the shipping-address
/// fields (already supported end-to-end by `StorefrontCompanyCart.shippingAddress`
/// and the backend's `shipping_address` JSON field, just never surfaced in
/// the UI before) are now actually captured when a delivery method other
/// than pickup is selected.
class StorefrontCheckoutScreen extends StatefulWidget {
  final int companyId;
  final StorefrontAudience audience;

  const StorefrontCheckoutScreen({super.key, required this.companyId, required this.audience});

  @override
  State<StorefrontCheckoutScreen> createState() => _StorefrontCheckoutScreenState();
}

class _StorefrontCheckoutScreenState extends State<StorefrontCheckoutScreen> {
  static const int _totalSteps = 3;

  int _currentStep = 0;
  bool _submitting = false;
  String? _validationError;

  late String _paymentMethod;
  String? _deliveryMethod;
  int? _deliveryOptionId;
  double _deliveryCost = 0;

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  StorefrontCompanyCart? get _cart => storefrontCart.cartForCompany(audience: widget.audience, companyId: widget.companyId);

  bool get _needsAddress => _deliveryMethod != null && _deliveryMethod != 'pickup';

  @override
  void initState() {
    super.initState();
    final cart = _cart;
    _paymentMethod = cart?.paymentMethod ?? (widget.audience == StorefrontAudience.b2b ? 'credit' : 'cash');
    _deliveryMethod = cart?.deliveryMethod;
    _deliveryOptionId = cart?.deliveryOptionId;
    _deliveryCost = cart?.deliveryCost ?? 0;

    final address = cart?.shippingAddress;
    if (address != null) {
      _nameCtrl.text = address['full_name']?.toString() ?? '';
      _phoneCtrl.text = address['phone']?.toString() ?? '';
      _addressCtrl.text = address['address_line']?.toString() ?? '';
      _cityCtrl.text = address['city']?.toString() ?? '';
      _notesCtrl.text = address['notes']?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  String _stepLabel(AppLocalizations l10n, int step) {
    switch (step) {
      case 0:
        return l10n.step_review_items;
      case 1:
        return l10n.step_delivery_payment;
      default:
        return l10n.step_confirm;
    }
  }

  Map<String, dynamic>? _buildShippingAddress() {
    if (!_needsAddress) return null;
    if (_nameCtrl.text.trim().isEmpty && _addressCtrl.text.trim().isEmpty) return null;
    return {
      'full_name': _nameCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'address_line': _addressCtrl.text.trim(),
      'city': _cityCtrl.text.trim(),
      'notes': _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    };
  }

  bool _canAdvanceFromDeliveryStep() {
    if (!_needsAddress) return true;
    return _addressCtrl.text.trim().isNotEmpty;
  }

  Future<void> _persistConfig() async {
    await storefrontCart.updateCompanyCartConfig(
      audience: widget.audience,
      companyId: widget.companyId,
      paymentMethod: _paymentMethod,
      deliveryMethod: _deliveryMethod,
      clearDeliveryMethod: _deliveryMethod == null,
      deliveryOptionId: _deliveryOptionId,
      clearDeliveryOptionId: _deliveryOptionId == null,
      deliveryCost: _deliveryCost,
      shippingAddress: _buildShippingAddress(),
      clearShippingAddress: _buildShippingAddress() == null,
    );
  }

  Future<void> _handleNext() async {
    final l10n = AppLocalizations.of(context)!;
    if (_currentStep == 1 && !_canAdvanceFromDeliveryStep()) {
      setState(() => _validationError = l10n.address_required_for_delivery);
      return;
    }
    setState(() => _validationError = null);
    await _persistConfig();
    if (!mounted) return;
    setState(() => _currentStep += 1);
  }

  void _handleBack() {
    setState(() => _currentStep -= 1);
  }

  Future<void> _handleSubmit() async {
    final l10n = AppLocalizations.of(context)!;
    final router = GoRouter.of(context);
    await _persistConfig();

    final latestCart = _cart;
    if (latestCart == null || latestCart.items.isEmpty) {
      if (!mounted) return;
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _submitting = true;
      _validationError = null;
    });

    try {
      final storefrontRepository = getIt<StorefrontRepository>();
      final validateRequest = StorefrontCartValidateRequest(
        audience: widget.audience.name,
        companyId: widget.companyId,
        deliveryOptionId: _deliveryOptionId,
        items: latestCart.items
            .map((item) => StorefrontCartValidateRequestItem(
                  productId: item.productId,
                  quantity: item.quantity,
                  selectedOptions: item.selectedOptionIds,
                ))
            .toList(),
      );

      final validateResponse = await storefrontRepository.validateCart(validateRequest);
      if (!validateResponse.valid) {
        if (!mounted) return;
        setState(() {
          _submitting = false;
          _validationError = validateResponse.message ?? l10n.cart_validation_failed;
        });
        return;
      }

      final repository = getIt<OrdersRepository>();
      final order = widget.audience == StorefrontAudience.b2b
          ? await repository.createB2bOrder(B2bOrderCreateRequest.fromCompanyCart(latestCart))
          : await repository.createB2cOrder(B2cOrderCreateRequest.fromCompanyCart(latestCart));

      await storefrontCart.clearCompanyCart(audience: widget.audience, companyId: widget.companyId);

      if (!mounted) return;
      router.replace('/storefront/order-result', extra: order);
    } catch (e, stackTrace) {
      dPrint('Submit Order Error: $e', stackTrace: stackTrace, tag: 'StorefrontCheckoutScreen');
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _validationError = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cart = _cart;

    if (cart == null || cart.items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.checkout)),
        body: Center(child: Text(l10n.cart_empty)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.checkout),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(56.h),
          child: WizardStepIndicator(
            currentStep: _currentStep,
            totalSteps: _totalSteps,
            stepLabels: [
              _stepLabel(l10n, 0),
              _stepLabel(l10n, 1),
              _stepLabel(l10n, 2),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_validationError != null) ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.r),
                margin: EdgeInsets.only(bottom: 16.h),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(_validationError!, style: const TextStyle(color: Colors.red)),
              ),
            ],
            switch (_currentStep) {
              0 => _ReviewItemsStep(cart: cart),
              1 => _DeliveryPaymentStep(
                  companyId: widget.companyId,
                  paymentMethod: _paymentMethod,
                  deliveryMethod: _deliveryMethod,
                  needsAddress: _needsAddress,
                  nameCtrl: _nameCtrl,
                  phoneCtrl: _phoneCtrl,
                  addressCtrl: _addressCtrl,
                  cityCtrl: _cityCtrl,
                  notesCtrl: _notesCtrl,
                  onPaymentMethodChanged: (value) => setState(() => _paymentMethod = value),
                  onDeliverySelected: (method, optionId, cost) {
                    setState(() {
                      _deliveryMethod = method;
                      _deliveryOptionId = optionId;
                      _deliveryCost = cost;
                    });
                  },
                ),
              _ => _ConfirmStep(
                  cart: cart,
                  paymentMethod: _paymentMethod,
                  deliveryMethod: _deliveryMethod,
                  deliveryCost: _deliveryCost,
                  shippingAddress: _buildShippingAddress(),
                ),
            },
          ],
        ),
      ),
      bottomNavigationBar: WizardBottomBar(
        currentStep: _currentStep,
        totalSteps: _totalSteps,
        onBack: _handleBack,
        onNext: _handleNext,
        onFinish: _handleSubmit,
        finishLabel: l10n.confirm_and_place_order,
        finishIcon: Icons.check_circle_outline_rounded,
        isSubmitting: _submitting,
      ),
    );
  }
}

class _ReviewItemsStep extends StatelessWidget {
  final StorefrontCompanyCart cart;

  const _ReviewItemsStep({required this.cart});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final money = NumberFormat.decimalPattern();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(cart.companyName, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800)),
        SizedBox(height: 4.h),
        Text(cart.audience == StorefrontAudience.b2b ? l10n.b2b_cart : l10n.b2c_cart),
        SizedBox(height: 16.h),
        ...cart.items.map(
          (item) => Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: AppCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Container(
                      width: 56.r,
                      height: 56.r,
                      color: AppTheme.primaryColor.withValues(alpha: 0.08),
                      child: item.imageUrl == null
                          ? const Icon(Icons.image_outlined)
                          : CachedNetworkImage(imageUrl: item.imageUrl!, fit: BoxFit.cover),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.sp)),
                        SizedBox(height: 4.h),
                        Text('${l10n.quantity}: ${item.quantity}', style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                  Text(
                    l10n.iqd_price(money.format(item.lineTotal)),
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.sp),
                  ),
                ],
              ),
            ),
          ),
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SummaryRow(label: l10n.total_items, value: '${cart.totalItems}'),
              _SummaryRow(label: l10n.subtotal, value: l10n.iqd_price(money.format(cart.subtotal))),
            ],
          ),
        ),
      ],
    );
  }
}

class _DeliveryPaymentStep extends StatelessWidget {
  final int companyId;
  final String paymentMethod;
  final String? deliveryMethod;
  final bool needsAddress;
  final TextEditingController nameCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController addressCtrl;
  final TextEditingController cityCtrl;
  final TextEditingController notesCtrl;
  final ValueChanged<String> onPaymentMethodChanged;
  final void Function(String? method, int? optionId, double cost) onDeliverySelected;

  const _DeliveryPaymentStep({
    required this.companyId,
    required this.paymentMethod,
    required this.deliveryMethod,
    required this.needsAddress,
    required this.nameCtrl,
    required this.phoneCtrl,
    required this.addressCtrl,
    required this.cityCtrl,
    required this.notesCtrl,
    required this.onPaymentMethodChanged,
    required this.onDeliverySelected,
  });

  static const _paymentMethods = <String>['cash', 'credit', 'payment_upon_receipt'];

  String _paymentLabel(AppLocalizations l10n, String value) {
    switch (value) {
      case 'cash':
        return l10n.payment_cash;
      case 'credit':
        return l10n.payment_credit;
      case 'payment_upon_receipt':
        return l10n.payment_upon_receipt;
      default:
        return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final money = NumberFormat.decimalPattern();

    return FutureBuilder<Company>(
      future: getIt<PublicServicesRepository>().getCompanyDetails(companyId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Text(snapshot.error?.toString() ?? l10n.error_loading_data);
        }

        final deliveryOptions = snapshot.data!.deliveryOptions.where((option) => option.isActive).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.payment_method, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800)),
            SizedBox(height: 8.h),
            AppCard(
              child: DropdownButtonFormField<String>(
                initialValue: paymentMethod,
                decoration: InputDecoration(labelText: l10n.payment_method, border: InputBorder.none),
                items: _paymentMethods
                    .map((method) => DropdownMenuItem(value: method, child: Text(_paymentLabel(l10n, method))))
                    .toList(),
                onChanged: (value) {
                  if (value != null) onPaymentMethodChanged(value);
                },
              ),
            ),
            SizedBox(height: 20.h),
            Text(l10n.delivery_details, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800)),
            SizedBox(height: 8.h),
            AppCard(
              child: DropdownButtonFormField<String?>(
                initialValue: deliveryMethod,
                isExpanded: true,
                decoration: InputDecoration(labelText: l10n.shipping_method, border: InputBorder.none),
                items: [
                  DropdownMenuItem<String?>(value: null, child: Text(l10n.no_delivery_selected)),
                  DropdownMenuItem<String?>(value: 'pickup', child: Text(l10n.pickup_from_company)),
                  ...deliveryOptions.map(
                    (option) => DropdownMenuItem<String?>(
                      value: option.name,
                      child: Text(option.cost == null ? option.name : '${option.name} • ${money.format(option.cost)}'),
                    ),
                  ),
                ],
                onChanged: (value) {
                  if (value == null || value == 'pickup') {
                    onDeliverySelected(value, null, 0);
                    return;
                  }
                  final selected = deliveryOptions.firstWhere((option) => option.name == value);
                  onDeliverySelected(value, selected.id, selected.cost?.toDouble() ?? 0);
                },
              ),
            ),
            if (needsAddress) ...[
              SizedBox(height: 20.h),
              Text(l10n.shipping_address, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800)),
              SizedBox(height: 8.h),
              AppCard(
                child: Column(
                  children: [
                    TextField(controller: nameCtrl, decoration: InputDecoration(labelText: l10n.name)),
                    SizedBox(height: 12.h),
                    TextField(controller: phoneCtrl, keyboardType: TextInputType.phone, decoration: InputDecoration(labelText: l10n.phone_number)),
                    SizedBox(height: 12.h),
                    TextField(controller: addressCtrl, decoration: InputDecoration(labelText: l10n.address_line)),
                    SizedBox(height: 12.h),
                    TextField(controller: cityCtrl, decoration: InputDecoration(labelText: l10n.city)),
                    SizedBox(height: 12.h),
                    TextField(controller: notesCtrl, maxLines: 2, decoration: InputDecoration(labelText: l10n.additional_notes_optional)),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _ConfirmStep extends StatelessWidget {
  final StorefrontCompanyCart cart;
  final String paymentMethod;
  final String? deliveryMethod;
  final double deliveryCost;
  final Map<String, dynamic>? shippingAddress;

  const _ConfirmStep({
    required this.cart,
    required this.paymentMethod,
    required this.deliveryMethod,
    required this.deliveryCost,
    required this.shippingAddress,
  });

  String _paymentLabel(AppLocalizations l10n, String value) {
    switch (value) {
      case 'cash':
        return l10n.payment_cash;
      case 'credit':
        return l10n.payment_credit;
      case 'payment_upon_receipt':
        return l10n.payment_upon_receipt;
      default:
        return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final money = NumberFormat.decimalPattern();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.review_your_order, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: Colors.grey.shade600)),
        SizedBox(height: 16.h),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.order_summary, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800)),
              SizedBox(height: 10.h),
              _SummaryRow(label: l10n.total_items, value: '${cart.totalItems}'),
              _SummaryRow(label: l10n.payment_method, value: _paymentLabel(l10n, paymentMethod)),
              _SummaryRow(label: l10n.shipping_method, value: deliveryMethod ?? l10n.no_delivery_selected),
              _SummaryRow(label: l10n.subtotal, value: l10n.iqd_price(money.format(cart.subtotal))),
              _SummaryRow(label: l10n.delivery, value: l10n.iqd_price(money.format(deliveryCost))),
              const Divider(),
              _SummaryRow(label: l10n.estimated_total, value: l10n.iqd_price(money.format(cart.subtotal + deliveryCost)), emphasize: true),
            ],
          ),
        ),
        if (shippingAddress != null) ...[
          SizedBox(height: 16.h),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.contact_details, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800)),
                SizedBox(height: 10.h),
                if ((shippingAddress!['full_name'] ?? '').toString().isNotEmpty) Text(shippingAddress!['full_name'].toString()),
                if ((shippingAddress!['phone'] ?? '').toString().isNotEmpty) Text(shippingAddress!['phone'].toString()),
                if ((shippingAddress!['address_line'] ?? '').toString().isNotEmpty) Text(shippingAddress!['address_line'].toString()),
                if ((shippingAddress!['city'] ?? '').toString().isNotEmpty) Text(shippingAddress!['city'].toString()),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasize;

  const _SummaryRow({required this.label, required this.value, this.emphasize = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            value,
            style: TextStyle(
              fontWeight: emphasize ? FontWeight.w900 : FontWeight.w800,
              fontSize: emphasize ? 16.sp : 14.sp,
              color: emphasize ? AppTheme.primaryColor : null,
            ),
          ),
        ],
      ),
    );
  }
}
