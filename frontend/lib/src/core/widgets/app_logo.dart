import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:solar_hub/src/utils/app_assets.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 50, this.withBorder = false, this.isCircle = true, this.withBorderColor});
  final double size;
  final bool withBorder;
  final bool isCircle;
  final Color? withBorderColor;

  @override
  Widget build(BuildContext context) {
    if (withBorder) {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: withBorderColor ?? Theme.of(context).primaryColor, strokeAlign: BorderSide.strokeAlignInside, width: 2),
          shape: BoxShape.circle,
        ),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: withBorderColor ?? Theme.of(context).primaryColor),
            shape: BoxShape.circle,
          ),
          child: CircleAvatar(backgroundColor: Colors.transparent, backgroundImage: AssetImage(AppAssets.logo), radius: size.r),
        ),
      );
    }
    return Image.asset(AppAssets.logo, width: size.w, height: size.h);
  }
}
