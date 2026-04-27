import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/company_work/domain/entities/company_work.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class CompanyWorkCard extends StatelessWidget {
  const CompanyWorkCard({
    super.key,
    required this.work,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  final CompanyWork work;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22.r),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
                child: _CardImage(work: work),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          work.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (onEdit != null || onDelete != null)
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert_rounded),
                          onSelected: (value) {
                            if (value == 'edit') {
                              onEdit?.call();
                            } else if (value == 'delete') {
                              onDelete?.call();
                            }
                          },
                          itemBuilder: (context) => [
                            if (onEdit != null)
                              PopupMenuItem<String>(
                                value: 'edit',
                                child: Text(l10n.edit),
                              ),
                            if (onDelete != null)
                              PopupMenuItem<String>(
                                value: 'delete',
                                child: Text(l10n.delete_action),
                              ),
                          ],
                        ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    work.body?.trim().isNotEmpty == true
                        ? work.body!.trim()
                        : l10n.company_work_no_description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 12,
                      height: 1.5,
                      color: theme.hintColor,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      const Icon(
                        Iconsax.gallery_bold,
                        size: 16,
                        color: AppTheme.primaryColor,
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          l10n.company_work_images_count(work.images.length),
                          style: const TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 18.sp,
                        color: AppTheme.primaryColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardImage extends StatelessWidget {
  const _CardImage({required this.work});

  final CompanyWork work;

  @override
  Widget build(BuildContext context) {
    if (work.coverImageUrl == null || work.coverImageUrl!.isEmpty) {
      return Container(
        color: AppTheme.primaryColor.withValues(alpha: 0.08),
        child: const Center(
          child: Icon(
            Iconsax.gallery_bold,
            size: 42,
            color: AppTheme.primaryColor,
          ),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: work.coverImageUrl!,
      fit: BoxFit.cover,
      placeholder: (_, placeholderUrl) => Container(
        color: Colors.grey.withValues(alpha: 0.08),
        child: const Center(child: CircularProgressIndicator()),
      ),
      errorWidget: (_, imageUrl, error) => Container(
        color: Colors.grey.withValues(alpha: 0.08),
        child: const Center(child: Icon(Icons.broken_image_outlined)),
      ),
    );
  }
}
