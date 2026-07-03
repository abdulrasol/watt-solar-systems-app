import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/storefront/domain/entities/storefront_models.dart';
import 'package:solar_hub/src/features/storefront/presentation/providers/storefront_provider.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class StorefrontCompanyPicker extends StatelessWidget {
  final StorefrontFilterSheetState filterSheet;
  final ScrollController scrollController;
  final int? selectedCompanyId;
  final ValueChanged<StorefrontCompanyListItem> onCompanyTap;

  const StorefrontCompanyPicker({
    super.key,
    required this.filterSheet,
    required this.scrollController,
    required this.selectedCompanyId,
    required this.onCompanyTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (filterSheet.isLoadingCompanies && filterSheet.companies.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (filterSheet.companiesError != null && filterSheet.companies.isEmpty) {
      return _InlineMessage(message: filterSheet.companiesError!);
    }

    if (filterSheet.companies.isEmpty) {
      return _InlineMessage(message: l10n.no_company_found);
    }

    return Container(
      constraints: BoxConstraints(maxHeight: 260.h),
      child: ListView.separated(
        controller: scrollController,
        shrinkWrap: true,
        itemCount:
            filterSheet.companies.length +
            (filterSheet.isLoadingMoreCompanies ? 1 : 0),
        separatorBuilder: (_, _) => Divider(height: 1.h),
        itemBuilder: (context, index) {
          if (index >= filterSheet.companies.length) {
            return Padding(
              padding: EdgeInsets.all(12.r),
              child: const Center(child: CircularProgressIndicator()),
            );
          }

          final company = filterSheet.companies[index];
          final selected = selectedCompanyId == company.id;

          return ListTile(
            onTap: () => onCompanyTap(company),
            contentPadding: EdgeInsets.zero,
            leading: _CompanyAvatar(company: company),
            title: Text(
              company.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: company.cityName == null
                ? null
                : Text(
                    company.cityName!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
            trailing: selected
                ? Icon(Icons.check_circle_rounded, color: AppTheme.primaryColor)
                : null,
          );
        },
      ),
    );
  }
}

class _CompanyAvatar extends StatelessWidget {
  final StorefrontCompanyListItem company;

  const _CompanyAvatar({required this.company});

  @override
  Widget build(BuildContext context) {
    if ((company.logo ?? '').isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14.r),
        child: CachedNetworkImage(
          imageUrl: company.logo!,
          width: 44.r,
          height: 44.r,
          fit: BoxFit.cover,
        ),
      );
    }

    return CircleAvatar(
      backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.12),
      child: Text(
        company.name.isEmpty ? '?' : company.name.substring(0, 1),
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _InlineMessage extends StatelessWidget {
  final String message;

  const _InlineMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 13.sp),
      ),
    );
  }
}
