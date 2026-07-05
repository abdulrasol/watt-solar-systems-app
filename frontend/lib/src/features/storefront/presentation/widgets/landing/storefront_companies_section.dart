import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/storefront/domain/entities/storefront_models.dart';
import 'package:solar_hub/src/features/storefront/presentation/utils/storefront_layout.dart';
import 'package:solar_hub/src/features/storefront/presentation/widgets/landing/storefront_company_grid_card.dart';
import 'package:solar_hub/src/features/storefront/presentation/widgets/landing/storefront_section_header.dart';
import 'package:solar_hub/src/features/storefront/presentation/widgets/products/storefront_products_empty_state.dart';

class StorefrontCompaniesSection extends StatelessWidget {
  final List<StorefrontCompanyListItem> companies;
  final String? error;
  final bool isLoading;
  final VoidCallback onViewMore;
  final ValueChanged<StorefrontCompanyListItem> onCompanyTap;

  const StorefrontCompaniesSection({
    super.key,
    required this.companies,
    required this.error,
    required this.isLoading,
    required this.onViewMore,
    required this.onCompanyTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = storefrontSquareGridColumns(width);
    final previewItems = companies.take(storefrontTwoRowSquareCount(width)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StorefrontSectionHeader(title: l10n.companies, actionLabel: l10n.view_more, onAction: onViewMore),
        SizedBox(height: 12.h),
        if (isLoading && previewItems.isEmpty)
          const Center(child: CircularProgressIndicator())
        else if (previewItems.isEmpty)
          StorefrontProductsEmptyState(message: error ?? l10n.no_company_found, showErrorStyle: error != null)
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: previewItems.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              final company = previewItems[index];
              return StorefrontCompanyGridCard(company: company, onTap: () => onCompanyTap(company));
            },
          ),
      ],
    );
  }
}
