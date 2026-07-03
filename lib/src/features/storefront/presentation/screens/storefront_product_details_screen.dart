import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solar_hub/src/features/storefront/domain/entities/storefront_cart.dart';
import 'package:solar_hub/src/features/storefront/domain/entities/storefront_models.dart';
import 'package:solar_hub/src/features/storefront/presentation/providers/storefront_cart_controller.dart';
import 'package:solar_hub/src/features/storefront/presentation/providers/storefront_visibility.dart';
import 'package:solar_hub/src/features/storefront/presentation/screens/storefront_cart_screen.dart';
import 'package:solar_hub/src/features/storefront/presentation/utils/storefront_page_route.dart';
import 'package:solar_hub/src/features/storefront/presentation/widgets/details/storefront_product_gallery.dart';
import 'package:solar_hub/src/features/storefront/presentation/widgets/details/storefront_product_info_section.dart';
import 'package:solar_hub/src/features/storefront/presentation/widgets/details/storefront_product_options_section.dart';
import 'package:solar_hub/src/features/storefront/presentation/widgets/details/storefront_product_price_section.dart';
import 'package:solar_hub/src/features/storefront/presentation/widgets/storefront_cart_button.dart';

class StorefrontProductDetailsScreen extends ConsumerStatefulWidget {
  final StorefrontProduct product;
  final StorefrontAudience audience;

  const StorefrontProductDetailsScreen({
    super.key,
    required this.product,
    required this.audience,
  });

  @override
  ConsumerState<StorefrontProductDetailsScreen> createState() =>
      _StorefrontProductDetailsScreenState();
}

class _StorefrontProductDetailsScreenState
    extends ConsumerState<StorefrontProductDetailsScreen> {
  int _quantity = 1;
  int _galleryIndex = 0;
  late final Set<int> _selectedOptionIds;

  @override
  void initState() {
    super.initState();
    _selectedOptionIds = widget.product.options
        .where((option) => option.isRequired)
        .map((option) => option.id)
        .toSet();
  }

  List<StorefrontProductOption> get _selectedOptions {
    return widget.product.options
        .where((option) => _selectedOptionIds.contains(option.id))
        .toList();
  }

  Set<StorefrontAudience> get _existingAudiencesForCompany {
    return storefrontCart.audiencesForCompany(widget.product.company.id);
  }

  StorefrontAudience _previewAudience(bool isCompanyMember) {
    if (!isCompanyMember) return widget.audience;
    final existing = _existingAudiencesForCompany;
    if (existing.length == 1) return existing.first;
    return widget.audience;
  }

  StorefrontCartItemPricingTier? _bestTierForQuantity(int quantity) {
    final tiers = widget.product.pricingTiers
        .map(StorefrontCartItemPricingTier.fromStorefrontPricingTier)
        .where((tier) => quantity >= tier.quantity);

    StorefrontCartItemPricingTier? best;
    for (final tier in tiers) {
      if (best == null || tier.unitPrice < best.unitPrice) {
        best = tier;
      }
    }
    return best;
  }

  double _baseUnitPriceFor(StorefrontAudience audience) {
    final tier = _bestTierForQuantity(_quantity);
    if (tier != null) return tier.unitPrice;
    return audience == StorefrontAudience.b2b
        ? widget.product.wholesalePrice
        : widget.product.retailPrice;
  }

  double _optionsUnitPriceFor(StorefrontAudience audience) {
    return _selectedOptions.fold<double>(0, (sum, option) {
      return sum +
          (audience == StorefrontAudience.b2b
              ? option.wholesalePrice
              : option.retailPrice);
    });
  }

  double _effectiveUnitPriceFor(StorefrontAudience audience) {
    return _baseUnitPriceFor(audience) + _optionsUnitPriceFor(audience);
  }

  Future<StorefrontAudience> _resolveAudienceForAddToCart({
    required bool isCompanyMember,
  }) async {
    if (!isCompanyMember) return widget.audience;

    final existingAudiences = _existingAudiencesForCompany;
    if (existingAudiences.length == 1) return existingAudiences.first;

    final l10n = AppLocalizations.of(context)!;
    final selected = await showModalBottomSheet<StorefrontAudience>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.choose_cart_audience,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 16.h),
                ListTile(
                  leading: const Icon(Icons.store_mall_directory_rounded),
                  title: Text(l10n.b2b_cart),
                  subtitle: Text(l10n.add_to_b2b_cart),
                  onTap: () =>
                      Navigator.of(context).pop(StorefrontAudience.b2b),
                ),
                ListTile(
                  leading: const Icon(Icons.storefront_rounded),
                  title: Text(l10n.b2c_cart),
                  subtitle: Text(l10n.add_to_b2c_cart),
                  onTap: () =>
                      Navigator.of(context).pop(StorefrontAudience.b2c),
                ),
              ],
            ),
          ),
        );
      },
    );

    return selected ?? widget.audience;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authProvider);
    final isCompanyMember = authState.isCompanyMember;
    final canViewB2bDetails = canViewStorefrontB2bDetails(authState);
    final previewAudience = _previewAudience(isCompanyMember);
    final appliedTier = _bestTierForQuantity(_quantity);
    final baseUnitPrice = _baseUnitPriceFor(previewAudience);
    final optionsUnitPrice = _optionsUnitPriceFor(previewAudience);
    final effectiveUnitPrice = _effectiveUnitPriceFor(previewAudience);
    final lineTotal = effectiveUnitPrice * _quantity;
    final heroTag =
        '${widget.audience.name}_${widget.product.company.id}_${widget.product.id}';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.product_details),
        actions: [
          Padding(
            padding: EdgeInsetsDirectional.only(end: 12.w),
            child: StorefrontCartButton(
              audience: widget.audience,
              onPressed: () {
                Navigator.of(context).push(
                  buildStorefrontRoute(
                    context: context,
                    page: StorefrontCartScreen(audience: widget.audience),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16.r),
        children: [
          StorefrontProductGallery(
            heroTag: heroTag,
            images: widget.product.images,
            currentIndex: _galleryIndex,
            onPageChanged: (index) => setState(() => _galleryIndex = index),
          ),
          SizedBox(height: 20.h),
          Text(
            widget.product.name,
            style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 14.h),
          StorefrontProductInfoSection(
            companyName: widget.product.company.name,
            categoryLabel: widget.product.categoryLabel.isEmpty
                ? null
                : widget.product.categoryLabel,
            isAvailable: widget.product.isAvailable,
          ),
          SizedBox(height: 20.h),
          StorefrontProductPriceSection(
            product: widget.product,
            quantity: _quantity,
            baseUnitPrice: baseUnitPrice,
            optionsUnitPrice: optionsUnitPrice,
            effectiveUnitPrice: effectiveUnitPrice,
            lineTotal: lineTotal,
            canViewB2bDetails: canViewB2bDetails,
            appliedTier: canViewB2bDetails ? appliedTier : null,
          ),
          if ((widget.product.description ?? '').trim().isNotEmpty) ...[
            SizedBox(height: 16.h),
            _CardSection(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.description,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    widget.product.description!,
                    style: TextStyle(height: 1.6, fontSize: 13.sp),
                  ),
                ],
              ),
            ),
          ],
          if (widget.product.options.isNotEmpty) ...[
            SizedBox(height: 16.h),
            StorefrontProductOptionsSection(
              options: widget.product.options,
              selectedOptionIds: _selectedOptionIds,
              showB2bPricing: canViewB2bDetails,
              previewAudience: previewAudience,
              onToggleOption: (optionId) {
                setState(() {
                  if (_selectedOptionIds.contains(optionId)) {
                    _selectedOptionIds.remove(optionId);
                  } else {
                    _selectedOptionIds.add(optionId);
                  }
                });
              },
            ),
          ],
          if (canViewB2bDetails && widget.product.pricingTiers.isNotEmpty) ...[
            SizedBox(height: 16.h),
            _PricingTiersSection(tiers: widget.product.pricingTiers),
          ],
          SizedBox(height: 16.h),
          _QuantitySection(
            quantity: _quantity,
            onDecrease: () {
              if (_quantity > 1) setState(() => _quantity -= 1);
            },
            onIncrease: () => setState(() => _quantity += 1),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: EdgeInsets.all(16.r),
        child: ElevatedButton.icon(
          onPressed: () async {
            final audience = await _resolveAudienceForAddToCart(
              isCompanyMember: isCompanyMember,
            );
            await storefrontCart.addProduct(
              widget.product,
              audience: audience,
              quantity: _quantity,
              selectedOptions: _selectedOptions,
            );
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  audience == StorefrontAudience.b2b
                      ? l10n.added_to_b2b_cart
                      : l10n.added_to_b2c_cart,
                ),
              ),
            );
          },
          icon: const Icon(Icons.add_shopping_cart_rounded),
          label: Text(l10n.add_to_cart),
        ),
      ),
    );
  }
}

class _CardSection extends StatelessWidget {
  final Widget child;

  const _CardSection({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: child,
    );
  }
}

class _PricingTiersSection extends StatelessWidget {
  final List<StorefrontPricingTier> tiers;

  const _PricingTiersSection({required this.tiers});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _CardSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.pricing_tiers,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 10.h),
          ...tiers.map(
            (tier) => Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Text(
                l10n.pricing_tier_line(
                  tier.quantity,
                  tier.unitPrice.toStringAsFixed(0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantitySection extends StatelessWidget {
  final int quantity;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  const _QuantitySection({
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _CardSection(
      child: Row(
        children: [
          Text(
            l10n.quantity,
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15.sp),
          ),
          const Spacer(),
          _QtyControl(icon: Icons.remove, onTap: onDecrease),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: Text(
              '$quantity',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16.sp),
            ),
          ),
          _QtyControl(icon: Icons.add, onTap: onIncrease),
        ],
      ),
    );
  }
}

class _QtyControl extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyControl({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: 34.r,
        height: 34.r,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(icon, size: 18.sp),
      ),
    );
  }
}
