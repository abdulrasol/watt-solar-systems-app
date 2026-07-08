import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'mode_selector.dart';

class CompanyModeSelectorDelegate extends SliverPersistentHeaderDelegate {
  final CompanyDetailsMode currentMode;
  final ValueChanged<CompanyDetailsMode> onModeChanged;

  CompanyModeSelectorDelegate({
    required this.currentMode,
    required this.onModeChanged,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final theme = Theme.of(context);

    return SizedBox.expand(
      child: Container(
        color: theme.scaffoldBackgroundColor,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        alignment: Alignment.center,
        child: CompanyModeSelector(
          currentMode: currentMode,
          onModeChanged: onModeChanged,
        ),
      ),
    );
  }

  @override
  double get maxExtent => 72.h;

  @override
  double get minExtent => 72.h;

  @override
  bool shouldRebuild(covariant CompanyModeSelectorDelegate oldDelegate) {
    return oldDelegate.currentMode != currentMode;
  }
}
