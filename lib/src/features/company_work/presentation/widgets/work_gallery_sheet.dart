import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/company_work/domain/entities/company_work.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class WorkGallerySheet extends StatelessWidget {
  const WorkGallerySheet({
    super.key,
    required this.work,
    this.isPublicView = false,
    this.embedded = false,
  });

  final CompanyWork work;
  final bool isPublicView;
  final bool embedded;

  static Future<void> show(
    BuildContext context, {
    required CompanyWork work,
    bool isPublicView = false,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WorkGallerySheet(work: work, isPublicView: isPublicView),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (embedded) {
      return _GalleryContent(work: work, isPublicView: isPublicView);
    }

    final theme = Theme.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      minChildSize: 0.5,
      maxChildSize: 0.96,
      builder: (context, controller) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          ),
          child: _GalleryContent(
            work: work,
            isPublicView: isPublicView,
            controller: controller,
          ),
        );
      },
    );
  }
}

class _GalleryContent extends StatelessWidget {
  const _GalleryContent({
    required this.work,
    required this.isPublicView,
    this.controller,
  });

  final CompanyWork work;
  final bool isPublicView;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return ListView(
      controller: controller,
      padding: EdgeInsets.fromLTRB(18.r, 14.r, 18.r, bottomPadding + 24.r),
      children: [
        Center(
          child: Container(
            width: 44.w,
            height: 5.h,
            decoration: BoxDecoration(
              color: theme.dividerColor.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(999.r),
            ),
          ),
        ),
        SizedBox(height: 18.h),
        _WorkGalleryPager(work: work),
        SizedBox(height: 18.h),
        Row(
          children: [
            Expanded(
              child: Text(
                work.title,
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          children: [
            _MetaChip(
              icon: Icons.photo_library_outlined,
              label: l10n.company_work_images_count(work.images.length),
            ),
            if (work.updatedAt != null)
              _MetaChip(
                icon: Icons.update_rounded,
                label: l10n.company_work_updated_at(
                  _formatDate(work.updatedAt!),
                ),
              )
            else if (work.createdAt != null)
              _MetaChip(
                icon: Icons.schedule_rounded,
                label: l10n.company_work_created_at(
                  _formatDate(work.createdAt!),
                ),
              ),
            if (isPublicView)
              _MetaChip(
                icon: Icons.public_rounded,
                label: l10n.company_work_public_showcase,
              ),
          ],
        ),
        if (work.body?.trim().isNotEmpty == true) ...[
          SizedBox(height: 18.h),
          Text(
            l10n.description,
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            work.body!.trim(),
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 14,
              height: 1.6,
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.88),
            ),
          ),
        ],
      ],
    );
  }

  String _formatDate(DateTime value) {
    return '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
  }
}

class _WorkGalleryPager extends StatefulWidget {
  const _WorkGalleryPager({required this.work});

  final CompanyWork work;

  @override
  State<_WorkGalleryPager> createState() => _WorkGalleryPagerState();
}

class _WorkGalleryPagerState extends State<_WorkGalleryPager> {
  late final PageController _controller;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final work = widget.work;
    if (work.images.isEmpty) {
      return Container(
        height: 260.h,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
        ),
        child: const Center(
          child: Icon(Icons.photo_library_outlined, size: 64),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 280.h,
          child: PageView.builder(
            controller: _controller,
            itemCount: work.images.length,
            onPageChanged: (value) => setState(() => _index = value),
            itemBuilder: (context, index) {
              final image = work.images[index];
              return ClipRRect(
                borderRadius: BorderRadius.circular(24.r),
                child: CachedNetworkImage(
                  imageUrl: image.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, placeholderUrl) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (_, imageUrl, error) =>
                      const Center(child: Icon(Icons.broken_image_outlined)),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            work.images.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: EdgeInsets.symmetric(horizontal: 3.w),
              width: _index == index ? 18.w : 6.w,
              height: 6.h,
              decoration: BoxDecoration(
                color: _index == index
                    ? AppTheme.primaryColor
                    : Colors.grey.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(999.r),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.sp, color: AppTheme.primaryColor),
          SizedBox(width: 6.w),
          Text(
            label,
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class LocalWorkImagePreview extends StatelessWidget {
  const LocalWorkImagePreview({super.key, required this.file});

  final File file;

  @override
  Widget build(BuildContext context) {
    return Image.file(file, fit: BoxFit.cover);
  }
}
