import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:watt/src/utils/app_theme.dart';
import 'package:watt/src/utils/app_urls.dart';

class WdImagePreview extends StatelessWidget {
  const WdImagePreview({super.key, this.size, required this.imageUrl, this.shape = BoxShape.circle, this.fit = BoxFit.cover});
  final int? size;
  final String imageUrl;
  final BoxShape shape;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 700;

    final finalSize = size == null ? null : (isDesktop ? size!.toDouble() : size!.w);
    final borderRadius = shape == BoxShape.circle ? 999.0 : (isDesktop ? 24.0 : 24.r);
    final borderWidth = isDesktop ? 1.0 : 1.r;
    final iconSize = isDesktop ? 28.0 : 28.sp;

    if (imageUrl.isEmpty || imageUrl == 'null') return Icon(Iconsax.image, size: iconSize, color: Colors.grey);
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        width: finalSize,
        height: finalSize,
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.primaryDarkColor, width: borderWidth),
          shape: shape,
        ),
        child: CachedNetworkImage(
          imageUrl: AppUrls.resolveMediaUrl(imageUrl),
          fit: fit,
          errorWidget: (context, url, error) => Icon(Iconsax.building, color: AppTheme.primaryColor, size: iconSize),
        ),
      ),
    );
  }
}
