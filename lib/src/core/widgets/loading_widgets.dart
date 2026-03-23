import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingWidgets extends StatelessWidget {
  const LoadingWidgets({this.dimssable = false, this.size = 50.0, this.isThreeInOut = false, super.key});
  final bool dimssable;
  final double size;
  final bool isThreeInOut;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: isThreeInOut
          ? SpinKitThreeInOut(color: Theme.of(context).primaryColor, size: size.r)
          : SpinKitFoldingCube(color: Theme.of(context).primaryColor, size: size.r),
    );
  }
}
