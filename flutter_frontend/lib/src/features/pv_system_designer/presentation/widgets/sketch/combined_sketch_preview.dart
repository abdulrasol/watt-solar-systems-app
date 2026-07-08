import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watt/src/features/pv_system_designer/presentation/controllers/pv_system_designer_controller.dart';
import 'package:watt/src/features/pv_system_designer/presentation/widgets/sketch/frame_sketch_painter.dart';

class CombinedSketchPreview extends ConsumerWidget {
  const CombinedSketchPreview({super.key, this.height});

  final double? height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pvSystemDesignerProvider);
    final controller = ref.read(pvSystemDesignerProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final result = controller.frameResult;
    final viewHeight = height ?? 400;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: CustomPaint(
        size: Size(double.infinity, viewHeight),
        painter: FrameSketchPainter(
          state: state,
          frameResult: result,
          isDark: isDark,
          viewMode: SketchViewMode.all,
        ),
      ),
    );
  }
}
