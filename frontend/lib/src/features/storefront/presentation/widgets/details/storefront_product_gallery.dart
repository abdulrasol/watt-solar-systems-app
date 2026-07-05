import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class StorefrontProductGallery extends StatelessWidget {
  final String heroTag;
  final List<String> images;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;

  const StorefrontProductGallery({
    super.key,
    required this.heroTag,
    required this.images,
    required this.currentIndex,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return Hero(
        tag: heroTag,
        child: Container(
          height: 260.h,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(24.r),
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.image_outlined, size: 48),
        ),
      );
    }

    return Hero(
      tag: heroTag,
      child: Stack(
        children: [
          SizedBox(
            height: 280.h,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24.r),
              child: PageView.builder(
                itemCount: images.length,
                onPageChanged: onPageChanged,
                itemBuilder: (context, index) {
                  return CachedNetworkImage(
                    imageUrl: images[index],
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
          ),
          if (images.length > 1)
            PositionedDirectional(
              bottom: 16,
              end: 16,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.56),
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Text(
                  '${currentIndex + 1}/${images.length}',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
