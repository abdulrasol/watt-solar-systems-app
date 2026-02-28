import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:solar_hub/utils/app_theme.dart';

class WdImagePreview extends StatelessWidget {
  const WdImagePreview({super.key, required this.size, required this.imageUrl, this.shape = BoxShape.circle});
  final int size;
  final String imageUrl;
  final BoxShape shape;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.primaryDarkColor, width: 1.r),
        shape: shape,
        image: DecorationImage(image: CachedNetworkImageProvider(imageUrl), fit: BoxFit.cover),
      ),
    );
  }
}
