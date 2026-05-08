import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WizardScroll extends StatelessWidget {
  const WizardScroll({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 28.h),
      child: child,
    );
  }
}
