import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shimmer/shimmer.dart';

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

/// Base shimmering box used to compose skeleton placeholders. Kept generic
/// (just a shaped, colored box) so it can stand in for text lines, images,
/// or whole card outlines depending on the width/height/radius passed in.
class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const ShimmerBox({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      height: height.r,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(radius.r),
      ),
    );
  }
}

/// Skeleton placeholder for a single storefront product card, matching the
/// rough proportions of `StorefrontProductCard` (image, title line, price
/// line). Used while the first page of a product grid is loading, replacing
/// the bare `CircularProgressIndicator` that used to show instead.
class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade300,
      highlightColor: isDark ? Colors.white.withValues(alpha: 0.14) : Colors.grey.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: ShimmerBox(height: double.infinity, radius: 16)),
          SizedBox(height: 10.h),
          ShimmerBox(height: 12, width: 100.w),
          SizedBox(height: 6.h),
          ShimmerBox(height: 12, width: 60.w),
        ],
      ),
    );
  }
}

/// Grid of [ProductCardSkeleton]s, sized to match `StorefrontProductsGridSliver`'s
/// 2-column layout, for use as the initial-load placeholder.
class ProductGridSkeleton extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;

  const ProductGridSkeleton({super.key, this.itemCount = 6, this.crossAxisCount = 2});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: itemCount,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 12.w,
        crossAxisSpacing: 12.w,
        childAspectRatio: crossAxisCount == 1 ? 0.96 : 0.72,
      ),
      itemBuilder: (context, index) => const ProductCardSkeleton(),
    );
  }
}

/// Skeleton placeholder for a single list row (orders, cart summaries, etc.),
/// matching the rough proportions of `SectionCard`/`AppCard`-based tiles.
class ListTileSkeleton extends StatelessWidget {
  const ListTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade300,
      highlightColor: isDark ? Colors.white.withValues(alpha: 0.14) : Colors.grey.shade100,
      child: Container(
        padding: EdgeInsets.all(16.r),
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(height: 14, width: 140.w),
                  SizedBox(height: 8.h),
                  ShimmerBox(height: 12, width: 200.w),
                  SizedBox(height: 8.h),
                  ShimmerBox(height: 20, width: 90.w, radius: 999),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            ShimmerBox(height: 16, width: 60.w),
          ],
        ),
      ),
    );
  }
}

/// A vertical list of [ListTileSkeleton]s, for use as an initial-load
/// placeholder on order lists / cart previews.
class ListSkeleton extends StatelessWidget {
  final int itemCount;

  const ListSkeleton({super.key, this.itemCount = 4});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(itemCount, (_) => const ListTileSkeleton()),
    );
  }
}
