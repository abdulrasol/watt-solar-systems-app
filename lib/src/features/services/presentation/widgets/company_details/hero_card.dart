import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/src/shared/domain/company/company.dart';

class CompanyHeroCard extends StatelessWidget {
  final Company company;

  const CompanyHeroCard({super.key, required this.company});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D3B66), Color(0xFF168AAD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18.r),
                child: Container(
                  width: 82.r,
                  height: 82.r,
                  color: Colors.white.withValues(alpha: 0.12),
                  child: company.logo == null || company.logo!.isEmpty
                      ? Icon(
                          Iconsax.building_bold,
                          size: 34.sp,
                          color: Colors.white,
                        )
                      : CachedNetworkImage(
                          imageUrl: company.logo!,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Icon(
                            Iconsax.building_bold,
                            size: 34.sp,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      company.name,
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    if ((company.companyType?.name ?? '').isNotEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(999.r),
                        ),
                        child: Text(
                          company.companyType!.name,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if ((company.description ?? '').trim().isNotEmpty) ...[
            SizedBox(height: 16.h),
            Text(
              company.description!,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
