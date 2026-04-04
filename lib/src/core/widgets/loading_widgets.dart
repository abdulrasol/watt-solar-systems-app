import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingWidget extends StatelessWidget {
  final bool isThreeInOut;
  final double size;

  const LoadingWidget({
    this.isThreeInOut = false,
    this.size = 50.0,
    super.key,
  });

  /// Use this for a semi-transparent dialog loading
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white.withValues(alpha: 0.3),
      elevation: 0,
      child: widget(
        context: context,
        size: size,
        isThreeInOut: isThreeInOut,
      ),
    );
  }

  /// Use this for inline loading widgets
  static Widget widget({
    required BuildContext context,
    double size = 50.0,
    bool isThreeInOut = false,
  }) {
    return isThreeInOut
        ? SpinKitThreeInOut(color: Theme.of(context).primaryColor, size: size.r)
        : SpinKitFoldingCube(color: Theme.of(context).primaryColor, size: size.r);
  }

  /// Helper to show it as a dialog
  static void show(
    BuildContext context, {
    bool dismissible = false,
    bool isThreeInOut = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: dismissible,
      builder: (context) => LoadingWidget(isThreeInOut: isThreeInOut),
    );
  }
}
