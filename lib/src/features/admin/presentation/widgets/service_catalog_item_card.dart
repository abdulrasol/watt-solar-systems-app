import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/src/features/admin/domain/models/service_catalog_item.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class ServiceCatalogItemCard extends StatelessWidget {
  final ServiceCatalogItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final int? index; // For drag and drop handle

  const ServiceCatalogItemCard({super.key, required this.item, required this.onEdit, required this.onDelete, this.index});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: item.isActive ? AppTheme.primaryColor.withOpacity(0.2) : (isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.1)),
        ),
      ),
      child: Row(
        children: [
          if (index != null)
            ReorderableDragStartListener(
              index: index!,
              child: Padding(
                padding: EdgeInsets.only(right: 12.w),
                child: Icon(Iconsax.document_bold, color: Colors.grey, size: 20.sp),
              ),
            ),
          _buildIcon(context),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp, fontFamily: AppTheme.fontFamily),
                    ),
                    _buildActiveBadge(context),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  item.description ?? 'No description available.',
                  style: TextStyle(fontSize: 12.sp, color: isDark ? Colors.grey[400] : Colors.grey[600], fontFamily: AppTheme.fontFamily),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    _buildCategoryTag(context, item.category),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Iconsax.edit_2_bold, color: AppTheme.primaryColor, size: 18.sp),
                      onPressed: onEdit,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    SizedBox(width: 12.w),
                    IconButton(
                      icon: Icon(Iconsax.trash_bold, color: AppTheme.errorColor, size: 18.sp),
                      onPressed: onDelete,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    return Container(
      width: 48.w,
      height: 48.h,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10.r),
        image: item.icon != null ? DecorationImage(image: NetworkImage(item.icon!), fit: BoxFit.contain) : null,
      ),
      child: item.icon == null ? Icon(Iconsax.setting_2_bold, color: AppTheme.primaryColor, size: 24.sp) : null,
    );
  }

  Widget _buildActiveBadge(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(color: (item.isActive ? Colors.green : Colors.grey).withOpacity(0.1), borderRadius: BorderRadius.circular(4.r)),
      child: Text(
        item.isActive ? 'ACTIVE' : 'INACTIVE',
        style: TextStyle(color: item.isActive ? Colors.green : Colors.grey, fontSize: 9.sp, fontWeight: FontWeight.bold, fontFamily: AppTheme.fontFamily),
      ),
    );
  }

  Widget _buildCategoryTag(BuildContext context, String? category) {
    if (category == null) return const SizedBox.shrink();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4.r)),
      child: Text(
        category.toUpperCase(),
        style: TextStyle(color: AppTheme.primaryColor, fontSize: 9.sp, fontWeight: FontWeight.w600, fontFamily: AppTheme.fontFamily),
      ),
    );
  }
}
