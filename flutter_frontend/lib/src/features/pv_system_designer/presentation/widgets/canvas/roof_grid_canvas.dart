import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:watt/src/features/pv_system_designer/domain/entities/pv_system_design_state.dart';
import 'package:watt/src/features/pv_system_designer/presentation/controllers/pv_system_designer_controller.dart';
import 'package:watt/src/utils/app_theme.dart';

class RoofGridCanvas extends ConsumerStatefulWidget {
  const RoofGridCanvas({super.key});

  @override
  ConsumerState<RoofGridCanvas> createState() => _RoofGridCanvasState();
}

class _RoofGridCanvasState extends ConsumerState<RoofGridCanvas> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pvSystemDesignerProvider);
    final controller = ref.read(pvSystemDesignerProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cellSize = 40.w;
    final totalWidth = state.cols * cellSize;
    final totalHeight = state.rows * cellSize;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2220) : const Color(0xFFF5F7F6),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
      ),
      padding: EdgeInsets.all(12.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.grid_on_rounded, size: 16.sp, color: AppTheme.primaryColor),
              SizedBox(width: 6.w),
              Text(
                '${state.rows} × ${state.cols}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp),
              ),
              const Spacer(),
              Text(
                '${state.roofWidthM.toStringAsFixed(1)}m × ${state.roofLengthM.toStringAsFixed(1)}m',
                style: TextStyle(fontSize: 10.sp, color: Colors.grey),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: GestureDetector(
              onTap: () {},
              child: SizedBox(
                width: totalWidth,
                height: totalHeight,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: state.cols, mainAxisSpacing: 2, crossAxisSpacing: 2),
                  itemCount: state.grid.length,
                  itemBuilder: (context, index) => _buildCell(index, state, controller, isDark, cellSize),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCell(int index, PvSystemDesignState state, PvSystemDesignerController controller, bool isDark, double cellSize) {
    final cellType = state.grid[index];
    final row = index ~/ state.cols;
    final col = index % state.cols;
    final isInSetback = controller.isInSetbackZone(row, col);
    final isShaded = controller.shadingSourceCell(index) != null;

    Color bgColor;
    IconData? icon;
    Color iconColor = Colors.white;

    if (state.isSafeOverlayActive) {
      if (cellType == CellType.panel) {
        bgColor = isShaded ? Colors.orange.withValues(alpha: 0.7) : Colors.green.withValues(alpha: 0.7);
      } else if (isInSetback) {
        bgColor = Colors.amber.withValues(alpha: 0.5);
      } else {
        bgColor = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.1);
      }
    } else {
      switch (cellType) {
        case CellType.panel:
          bgColor = isShaded ? Colors.orange.withValues(alpha: 0.8) : Colors.amber.withValues(alpha: 0.85);
          icon = Iconsax.sun_1;
          iconColor = Colors.white;
        case CellType.obstacle:
          bgColor = Colors.redAccent.withValues(alpha: 0.8);
          icon = Icons.warning_amber_rounded;
          iconColor = Colors.white;
        case CellType.shadow:
          bgColor = Colors.grey.withValues(alpha: 0.6);
          icon = Icons.cloud_outlined;
          iconColor = Colors.white70;
        case CellType.tree:
          bgColor = Colors.green.withValues(alpha: 0.8);
          icon = Icons.park_rounded;
          iconColor = Colors.white;
        case CellType.excluded:
          bgColor = isDark ? Colors.white.withValues(alpha: 0.03) : Colors.grey.withValues(alpha: 0.15);
        case CellType.empty:
          if (isInSetback) {
            bgColor = Colors.amber.withValues(alpha: 0.2);
          } else {
            bgColor = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.1);
          }
      }
    }

    return GestureDetector(
      onTap: () => controller.handleCellTap(index),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(4.r),
          border: isInSetback && cellType == CellType.empty ? Border.all(color: Colors.amber.withValues(alpha: 0.4), width: 1) : null,
        ),
        child: icon != null ? Icon(icon, size: cellSize * 0.4, color: iconColor) : null,
      ),
    );
  }
}
