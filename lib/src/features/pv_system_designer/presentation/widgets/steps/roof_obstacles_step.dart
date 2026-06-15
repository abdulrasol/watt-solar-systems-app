import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/entities/obstacle.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/entities/panel_layout.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/entities/pv_system_design_state.dart';
import 'package:solar_hub/src/features/pv_system_designer/presentation/controllers/pv_system_design_controller.dart';
import 'package:solar_hub/src/features/pv_system_designer/presentation/controllers/pv_system_design_providers.dart';
import 'package:solar_hub/src/features/pv_system_designer/presentation/widgets/canvas/pv_design_canvas.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

String _uniqueId() => DateTime.now().millisecondsSinceEpoch.toString();

class RoofObstaclesStep extends ConsumerWidget {
  const RoofObstaclesStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pvSystemDesignControllerProvider);
    final notifier = ref.read(pvSystemDesignControllerProvider.notifier);

    return Column(
      children: [
        Expanded(
          child: PvDesignCanvas(
            state: state,
            onCellTap: (index) => _handleCellTap(notifier, state, index),
            onCanvasTap: (pos) => _handleCanvasTap(notifier, state, pos),
          ),
        ),
        _buildToolBar(context, state, notifier),
      ],
    );
  }

  void _handleCellTap(PvSystemDesignController notifier, PvSystemDesignState state, int index) {
    switch (state.activeTool) {
      case PvToolMode.placeObstacle:
        notifier.setCell(index, PvCellType.obstacle);
      case PvToolMode.placeTree:
        notifier.setCell(index, PvCellType.tree);
      case PvToolMode.excludeRoof:
        notifier.setCell(index, PvCellType.excluded);
      case PvToolMode.erase:
        notifier.setCell(index, PvCellType.empty);
      default:
        break;
    }
  }

  void _handleCanvasTap(PvSystemDesignController notifier, PvSystemDesignState state, Offset pos) {
    switch (state.activeTool) {
      case PvToolMode.placeWall:
        notifier.addObstacle(
          Obstacle(
            id: _uniqueId(),
            type: ObstacleType.wall,
            position: pos,
            size: const Size(0.5, 0.3),
            heightM: 1.5,
          ),
        );
      case PvToolMode.placeChimney:
        notifier.addObstacle(
          Obstacle(
            id: _uniqueId(),
            type: ObstacleType.chimney,
            position: pos,
            size: const Size(0.6, 0.6),
            heightM: 1.2,
          ),
        );
      case PvToolMode.placeVent:
        notifier.addObstacle(
          Obstacle(
            id: _uniqueId(),
            type: ObstacleType.vent,
            position: pos,
            size: const Size(0.4, 0.4),
            heightM: 0.5,
          ),
        );
      default:
        break;
    }
  }

  Widget _buildToolBar(BuildContext context, PvSystemDesignState state, PvSystemDesignController notifier) {
    final tools = [
      (PvToolMode.placeObstacle, Icons.block, 'Obstacle'),
      (PvToolMode.placeTree, Icons.park, 'Tree'),
      (PvToolMode.placeWall, Icons.square, 'Wall'),
      (PvToolMode.placeChimney, Icons.crop_square, 'Chimney'),
      (PvToolMode.placeVent, Icons.circle, 'Vent'),
      (PvToolMode.excludeRoof, Icons.not_interested, 'Exclude'),
      (PvToolMode.erase, Icons.delete_outline, 'Erase'),
    ];

    return Container(
      height: 72.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tools.length,
        separatorBuilder: (context, index) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final tool = tools[index];
          final selected = state.activeTool == tool.$1;
          return ChoiceChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(tool.$2, size: 18.sp),
                SizedBox(width: 6.w),
                Text(tool.$3),
              ],
            ),
            selected: selected,
            selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
            onSelected: (_) => notifier.setActiveTool(tool.$1),
          );
        },
      ),
    );
  }
}
