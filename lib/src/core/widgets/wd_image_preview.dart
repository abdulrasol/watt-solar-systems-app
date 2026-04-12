import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class WdImagePreview extends StatelessWidget {
  const WdImagePreview({super.key, this.size, required this.imageUrl, this.shape = BoxShape.circle, this.fit = BoxFit.cover});
  final int? size;
  final String imageUrl;
  final BoxShape shape;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty || imageUrl == 'null') return Icon(Iconsax.image_bold, size: 28.sp, color: Colors.grey);
    return ClipRRect(
      borderRadius: BorderRadius.circular(shape == BoxShape.circle ? 999.r : 24.r),
      child: Container(
        width: size?.w,
        height: size?.w,
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.primaryDarkColor, width: 1.r),
          shape: shape,
          // image: DecorationImage(image: CachedNetworkImageProvider(imageUrl), fit: fit),
        ),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: fit,
          errorWidget: (context, url, error) => Icon(Iconsax.building_bold, color: AppTheme.primaryColor, size: 28.sp),
        ),
      ),
    );
  }
}
