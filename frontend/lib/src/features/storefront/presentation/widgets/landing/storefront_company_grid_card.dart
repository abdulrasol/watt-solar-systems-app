import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:solar_hub/src/features/storefront/domain/entities/storefront_models.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class StorefrontCompanyGridCard extends StatelessWidget {
  final StorefrontCompanyListItem company;
  final VoidCallback onTap;

  const StorefrontCompanyGridCard({
    super.key,
    required this.company,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Ink(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.08),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _CompanyAvatar(company: company),
                SizedBox(height: 12.h),
                Text(
                  company.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if ((company.cityName ?? '').isNotEmpty) ...[
                  SizedBox(height: 6.h),
                  Text(
                    company.cityName!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.60),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
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
        borderRadius: BorderRadius.circular(18.r),
        child: CachedNetworkImage(
          imageUrl: company.logo!,
          width: 56.r,
          height: 56.r,
          fit: BoxFit.cover,
        ),
      );
    }

    return Container(
      width: 56.r,
      height: 56.r,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18.r),
      ),
      alignment: Alignment.center,
      child: Text(
        company.name.isEmpty ? '?' : company.name.substring(0, 1),
        style: TextStyle(
          color: AppTheme.primaryColor,
          fontWeight: FontWeight.w900,
          fontSize: 20.sp,
        ),
      ),
    );
  }
}
