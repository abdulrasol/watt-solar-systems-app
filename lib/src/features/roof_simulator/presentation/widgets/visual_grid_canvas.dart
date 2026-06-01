import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/src/utils/app_theme.dart';
import 'package:solar_hub/src/services/toast_service.dart';
import 'package:solar_hub/src/features/roof_simulator/domain/models/roof_simulator_state.dart';
import 'package:solar_hub/src/features/roof_simulator/presentation/controllers/roof_simulator_controller.dart';
import 'package:solar_hub/src/features/roof_simulator/presentation/widgets/custom_polygon_painter.dart';

class VisualGridCanvas extends ConsumerStatefulWidget {
  const VisualGridCanvas({super.key});

  @override
  ConsumerState<VisualGridCanvas> createState() => _VisualGridCanvasState();
}

class _VisualGridCanvasState extends ConsumerState<VisualGridCanvas> {
  // Local state to track indices touched in a single drag paint stroke
  final Set<int> _draggedIndices = {};
  
  // Track which polygon vertex index is currently being dragged
  int? _draggedVertexIndex;

  bool _isArabic(BuildContext context) =>
      Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';

  String _tr(BuildContext context, String en, String ar) {
    return _isArabic(context) ? ar : en;
  }

  double _getCompassAngle(String panelOrientation) {
    switch (panelOrientation) {
      case 'North':
        return 0.0;
      case 'East':
        return math.pi / 2.0;
      case 'South':
        return math.pi;
      case 'West':
        return math.pi * 1.5;
      default:
        return math.pi;
    }
  }

  Widget _buildCompassOverlayInline(bool isDark, String panelOrientation) {
    final double angle = _getCompassAngle(panelOrientation);

    return Container(
      width: 42.r,
      height: 42.r,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2624) : const Color(0xFFF0F4F2),
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.08),
          width: 1.5,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Rotating arrow indicator
          Transform.rotate(
            angle: angle,
            child: Icon(
              Icons.navigation_rounded,
              color: Colors.orangeAccent,
              size: 16.sp,
            ),
          ),
          // Subtle cardinal markers
          Positioned(
            top: 2.h,
            child: Text(
              'N',
              style: TextStyle(
                fontSize: 7.sp,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
            ),
          ),
          Positioned(
            bottom: 2.h,
            child: Text(
              'S',
              style: TextStyle(
                fontSize: 7.sp,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _buildCellDecoration(CellType type, int index, RoofSimulatorState simulator, RoofSimulatorController controller, bool isDark) {
    switch (type) {
      case CellType.empty:
        final r = index ~/ simulator.cols;
        final c = index % simulator.cols;
        final inSetback = controller.isInSetbackZone(r, c);
        if (inSetback) {
          return BoxDecoration(
            color: isDark ? const Color(0xFF2C2415) : const Color(0xFFFEF9EB),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: Colors.amber.withValues(alpha: isDark ? 0.35 : 0.5),
              width: 1,
            ),
          );
        }
        return BoxDecoration(
          color: isDark ? Colors.grey[900]?.withValues(alpha: 0.4) : Colors.grey[50],
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: Colors.grey.withValues(alpha: isDark ? 0.15 : 0.25),
            width: 1,
          ),
        );
      case CellType.panel:
        final r = index ~/ simulator.cols;
        final c = index % simulator.cols;
        final inSetback = controller.isInSetbackZone(r, c);
        final isShaded = controller.isCellShaded(index);
        if (isShaded) {
          return BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF90A4AE), Color(0xFF607D8B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8.r),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withValues(alpha: 0.25),
                blurRadius: 6,
                offset: const Offset(0, 2),
              )
            ],
            border: Border.all(color: Colors.orange, width: 2.0),
          );
        }
        if (inSetback) {
          return BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFE082), Color(0xFFFFB300)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8.r),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withValues(alpha: 0.25),
                blurRadius: 6,
                offset: const Offset(0, 2),
              )
            ],
            border: Border.all(color: Colors.orangeAccent, width: 2.0),
          );
        }
        return BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD54F), Color(0xFFFFB300)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            )
          ],
          border: Border.all(color: const Color(0xFFFFA000), width: 1.5),
        );
      case CellType.obstacle:
        return BoxDecoration(
          color: isDark ? const Color(0xFF263238) : const Color(0xFFECEFF1),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4), width: 1.5),
        );
      case CellType.shadow:
        return BoxDecoration(
          color: isDark ? const Color(0xFF212121).withValues(alpha: 0.6) : Colors.grey[300]!.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.blueGrey.withValues(alpha: 0.4), width: 1.5),
        );
      case CellType.tree:
        return BoxDecoration(
          color: isDark ? const Color(0xFF1B5E20).withValues(alpha: 0.3) : const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.green.withValues(alpha: 0.4), width: 1.5),
        );
      case CellType.excluded:
        return BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.redAccent.withValues(alpha: 0.15), width: 1.0),
        );
    }
  }

  Widget? _buildCellIcon(CellType type, int index, RoofSimulatorState simulator, RoofSimulatorController controller) {
    switch (type) {
      case CellType.empty:
        return null;
      case CellType.panel:
        final isShaded = controller.isCellShaded(index);
        final r = index ~/ simulator.cols;
        final c = index % simulator.cols;
        final inSetback = controller.isInSetbackZone(r, c);
        if (isShaded) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Iconsax.sun_1_bold,
                color: Colors.white.withValues(alpha: 0.4),
                size: (180.w / simulator.cols).clamp(12.0, 24.0),
              ),
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orangeAccent,
                size: (180.w / simulator.cols).clamp(10.0, 20.0),
              ),
            ],
          );
        }
        if (inSetback) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Iconsax.sun_1_bold,
                color: Colors.white,
                size: (180.w / simulator.cols).clamp(12.0, 24.0),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.deepOrangeAccent,
                  size: (180.w / simulator.cols).clamp(8.0, 14.0),
                ),
              ),
            ],
          );
        }
        return Icon(
          Iconsax.sun_1_bold,
          color: Colors.white,
          size: (180.w / simulator.cols).clamp(12.0, 24.0),
        );
      case CellType.obstacle:
        return Icon(
          Icons.warning_amber_rounded,
          color: Colors.redAccent,
          size: (180.w / simulator.cols).clamp(12.0, 24.0),
        );
      case CellType.shadow:
        return Icon(
          Icons.nights_stay_rounded,
          color: Colors.blueGrey,
          size: (180.w / simulator.cols).clamp(12.0, 24.0),
        );
      case CellType.tree:
        return Icon(
          Icons.park_rounded,
          color: Colors.green,
          size: (180.w / simulator.cols).clamp(12.0, 24.0),
        );
      case CellType.excluded:
        return Icon(
          Icons.close_rounded,
          color: Colors.redAccent.withValues(alpha: 0.5),
          size: (180.w / simulator.cols).clamp(12.0, 24.0),
        );
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // PAN GESTURE TRACKING & VELOCITY BRUSH
  // ───────────────────────────────────────────────────────────────────────────

  void _handlePanStart(Offset localPosition, double containerWidth, double containerHeight, RoofSimulatorState simulator, RoofSimulatorController controller) {
    final padding = 12.r;
    final gridWidth = containerWidth - padding * 2;
    final gridHeight = containerHeight - padding * 2;

    final cellWidth = gridWidth / simulator.cols;
    final cellHeight = gridHeight / simulator.rows;

    // Check if drawing custom polygon, allow dragging existing vertices!
    if (simulator.isPolygonSketchMode) {
      _draggedVertexIndex = null;
      for (int i = 0; i < simulator.polygonVertices.length; i++) {
        final vertex = simulator.polygonVertices[i];
        final center = Offset((vertex.dx + 0.5) * cellWidth, (vertex.dy + 0.5) * cellHeight);
        final dist = (localPosition - Offset(center.dx + padding, center.dy + padding)).distance;
        if (dist < 28.0) {
          _draggedVertexIndex = i;
          break;
        }
      }
      return;
    }

    _draggedIndices.clear();
    controller.saveStateToHistory(); // Save standard history at stroke commencement
    _handlePanPaint(localPosition, containerWidth, containerHeight, simulator, controller);
  }

  void _handlePanUpdate(Offset localPosition, double containerWidth, double containerHeight, RoofSimulatorState simulator, RoofSimulatorController controller) {
    final padding = 12.r;
    final gridWidth = containerWidth - padding * 2;
    final gridHeight = containerHeight - padding * 2;

    final cellWidth = gridWidth / simulator.cols;
    final cellHeight = gridHeight / simulator.rows;

    if (simulator.isPolygonSketchMode) {
      if (_draggedVertexIndex != null) {
        final double x = localPosition.dx - padding;
        final double y = localPosition.dy - padding;
        final double c = (x / cellWidth) - 0.5;
        final double r = (y / cellHeight) - 0.5;
        controller.updatePolygonVertex(
          _draggedVertexIndex!,
          Offset(c.clamp(0.0, simulator.cols - 1.0), r.clamp(0.0, simulator.rows - 1.0)),
        );
      }
      return;
    }

    _handlePanPaint(localPosition, containerWidth, containerHeight, simulator, controller);
  }

  void _handlePanEnd() {
    _draggedVertexIndex = null;
  }

  void _handlePanPaint(Offset localPosition, double containerWidth, double containerHeight, RoofSimulatorState simulator, RoofSimulatorController controller) {
    final padding = 12.r;
    final gridWidth = containerWidth - padding * 2;
    final gridHeight = containerHeight - padding * 2;

    final x = localPosition.dx - padding;
    final y = localPosition.dy - padding;

    // Boundary containment check
    if (x < 0 || x > gridWidth || y < 0 || y > gridHeight) return;

    final cellWidth = gridWidth / simulator.cols;
    final cellHeight = gridHeight / simulator.rows;

    final col = (x / cellWidth).floor().clamp(0, simulator.cols - 1);
    final row = (y / cellHeight).floor().clamp(0, simulator.rows - 1);
    final index = row * simulator.cols + col;

    if (_draggedIndices.contains(index)) return; // Avoid re-triggering cells in single pan stroke
    _draggedIndices.add(index);

    final currentType = simulator.grid[index];
    CellType targetType = currentType;

    switch (simulator.activeTool) {
      case ToolMode.placePanel:
        if (currentType == CellType.obstacle ||
            currentType == CellType.shadow ||
            currentType == CellType.tree ||
            currentType == CellType.excluded) {
          return;
        }
        targetType = CellType.panel;
        break;
      case ToolMode.placeObstacle:
        targetType = CellType.obstacle;
        break;
      case ToolMode.placeShadow:
        targetType = CellType.shadow;
        break;
      case ToolMode.placeTree:
        targetType = CellType.tree;
        break;
      case ToolMode.excludeRoof:
        targetType = CellType.excluded;
        break;
      case ToolMode.erase:
        targetType = CellType.empty;
        break;
    }

    if (currentType != targetType) {
      final List<CellType> updatedGrid = List<CellType>.from(simulator.grid);
      updatedGrid[index] = targetType;
      ref.read(roofSimulatorProvider.notifier).updateGrid(updatedGrid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final simulator = ref.watch(roofSimulatorProvider);
    final controller = ref.read(roofSimulatorProvider.notifier);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width - 32;

    final aspect = simulator.roofLengthM / simulator.roofWidthM;
    final clampedAspect = aspect.clamp(0.4, 1.5);
    final canvasHeight = screenWidth * clampedAspect;

    final gridWidth = screenWidth - 24.r;
    final gridHeight = canvasHeight - 24.r;
    final childAspectRatio = (gridWidth * simulator.rows) / (gridHeight * simulator.cols);

    final canUndo = simulator.undoStack.isNotEmpty;
    final canRedo = simulator.redoStack.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Elegant Header strip
        Padding(
          padding: EdgeInsets.only(bottom: 8.h, left: 4.w, right: 4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _tr(context, 'Solar Roof Layout', 'رسم مخطط السطح'),
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.sp),
                  ),
                  _buildCompassOverlayInline(isDark, simulator.panelOrientation),
                ],
              ),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E2624) : const Color(0xFFF7F9F8),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
                    width: 1.0,
                  ),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.draw_rounded,
                          size: 18.sp,
                          color: simulator.isPolygonSketchMode ? Colors.blueAccent : null,
                        ),
                        tooltip: _tr(context, 'Sketch Custom Roof', 'رسم سقف مخصص'),
                        onPressed: () {
                          controller.togglePolygonSketchMode();
                          if (ref.read(roofSimulatorProvider).isPolygonSketchMode) {
                            ToastService.info(
                              context,
                              _tr(context, 'Sketch Mode Active', 'وضع الرسم نشط'),
                              _tr(context, 'Tap on the canvas cells to draw a roof perimeter.', 'انقر على خلايا اللوحة لتحديد زوايا السقف المخصص.'),
                            );
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.explore_rounded,
                          size: 18.sp,
                          color: simulator.panelOrientation == 'South' ? Colors.orangeAccent : null,
                        ),
                        tooltip: _tr(context, 'Orient South', 'توجيه للجنوب'),
                        onPressed: () {
                          controller.alignLayoutToSouth();
                          ToastService.success(
                            context,
                            _tr(context, 'Oriented to Solar South', 'تم التوجيه نحو الجنوب الشمسي'),
                            _tr(context, 'Layout aligned with maximum solar gains.', 'تم محاذاة المخطط للحصول على أقصى إنتاج شمسي.'),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          simulator.isSafeOverlayActive ? Icons.wb_sunny_rounded : Icons.wb_sunny_outlined,
                          size: 18.sp,
                          color: simulator.isSafeOverlayActive ? Colors.green : (isDark ? Colors.white60 : Colors.grey[700]),
                        ),
                        tooltip: _tr(context, 'Toggle Safety Heatmap', 'تفعيل خريطة المناطق الآمنة'),
                        onPressed: () {
                          controller.toggleSafeOverlay();
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.rotate_90_degrees_cw_rounded, size: 18.sp),
                        tooltip: _tr(context, 'Rotate Layout 90°', 'تدوير المخطط 90 درجة'),
                        onPressed: () {
                          controller.rotateGrid90Clockwise();
                          ToastService.success(
                            context,
                            _tr(context, 'Layout Rotated 90°', 'تم تدوير المخطط 90 درجة'),
                            _tr(context, 'Layout rotated and setbacks updated.', 'تم تدوير المخطط وتحديث الارتدادات الجانبية.'),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.undo_rounded, size: 18.sp),
                        tooltip: _tr(context, 'Undo', 'تراجع'),
                        color: canUndo ? AppTheme.primaryColor : Colors.grey.withValues(alpha: 0.4),
                        onPressed: canUndo ? () => controller.undo() : null,
                      ),
                      IconButton(
                        icon: Icon(Icons.redo_rounded, size: 18.sp),
                        tooltip: _tr(context, 'Redo', 'إعادة'),
                        color: canRedo ? AppTheme.primaryColor : Colors.grey.withValues(alpha: 0.4),
                        onPressed: canRedo ? () => controller.redo() : null,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // 2. Active Polygon Sketch Toolbar
        if (simulator.isPolygonSketchMode)
          Container(
            margin: EdgeInsets.only(bottom: 8.h),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _tr(
                      context,
                      '📌 Polygon: Tap to place vertices. Drag nodes to reshape.',
                      '📌 المضلع: انقر لتحديد الزوايا. اسحب النقاط لتغيير الشكل.',
                    ),
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        controller.applyPolygonSketch();
                        ToastService.success(
                          context,
                          _tr(context, 'Sketch Applied', 'تم تطبيق الرسم'),
                          _tr(context, 'All layout cells outside perimeter have been excluded.', 'تم استبعاد جميع خلايا اللوحة الواقعة خارج محيط الرسم.'),
                        );
                      },
                      icon: Icon(Icons.check_circle_rounded, size: 12.sp, color: Colors.green),
                      label: Text(
                        _tr(context, 'Apply', 'تطبيق'),
                        style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        controller.clearPolygonVertices();
                        ToastService.info(
                          context,
                          _tr(context, 'Perimeter Reset', 'تمت إعادة تعيين الرسم'),
                          _tr(context, 'All sketched vertices cleared.', 'تم مسح جميع النقاط المرسومة.'),
                        );
                      },
                      icon: Icon(Icons.refresh_rounded, size: 12.sp, color: Colors.orange),
                      label: Text(
                        _tr(context, 'Reset', 'إعادة'),
                        style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.bold, color: Colors.orange),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        controller.togglePolygonSketchMode();
                      },
                      icon: const Icon(Icons.close_rounded, color: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
          ),

        // 3. Zoomable interactive viewer and repaint boundary for grid canvas
        InteractiveViewer(
          minScale: 0.8,
          maxScale: 4.0,
          child: RepaintBoundary(
            child: GestureDetector(
              onPanStart: (details) => _handlePanStart(
                details.localPosition,
                screenWidth,
                canvasHeight,
                simulator,
                controller,
              ),
              onPanUpdate: (details) => _handlePanUpdate(
                details.localPosition,
                screenWidth,
                canvasHeight,
                simulator,
                controller,
              ),
              onPanEnd: (_) => _handlePanEnd(),
              onTapUp: (details) {
                if (simulator.isPolygonSketchMode) {
                  final padding = 12.r;
                  final gridWidth = screenWidth - padding * 2;
                  final gridHeight = canvasHeight - padding * 2;
                  final x = details.localPosition.dx - padding;
                  final y = details.localPosition.dy - padding;
                  if (x >= 0 && x <= gridWidth && y >= 0 && y <= gridHeight) {
                    final cellWidth = gridWidth / simulator.cols;
                    final cellHeight = gridHeight / simulator.rows;
                    final col = (x / cellWidth).floor().clamp(0, simulator.cols - 1);
                    final row = (y / cellHeight).floor().clamp(0, simulator.rows - 1);
                    final newVertex = Offset(col.toDouble(), row.toDouble());
                    controller.addPolygonVertex(newVertex);
                  }
                }
              },
              child: Container(
                width: screenWidth,
                height: canvasHeight,
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF161E1C) : Colors.white,
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: const [
                    BoxShadow(color: Color(0x06000000), blurRadius: 16, offset: Offset(0, 8))
                  ],
                  border: Border.all(
                    color: Colors.grey.withValues(alpha: isDark ? 0.08 : 0.12),
                    width: 1.4,
                  ),
                ),
                child: Stack(
                  children: [
                    GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: simulator.cols,
                        crossAxisSpacing: 6.r,
                        mainAxisSpacing: 6.r,
                        childAspectRatio: childAspectRatio,
                      ),
                      itemCount: simulator.cols * simulator.rows,
                      itemBuilder: (context, index) {
                        final cell = simulator.grid[index];
                        final r = index ~/ simulator.cols;
                        final c = index % simulator.cols;

                        // Safety heatmap overlay
                        Widget? safetyOverlay;
                        if (simulator.isSafeOverlayActive) {
                          final bool isExcluded = cell == CellType.excluded;
                          final bool isObstacle = cell == CellType.obstacle || cell == CellType.tree;
                          final bool isShaded = controller.isCellShaded(index);
                          final bool inSetback = controller.isInSetbackZone(r, c);

                          if (isExcluded) {
                            safetyOverlay = Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.45),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.close_rounded,
                                  color: Colors.white70,
                                  size: (120.w / simulator.cols).clamp(8.0, 16.0),
                                ),
                              ),
                            );
                          } else if (isObstacle) {
                            safetyOverlay = Container(
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.35),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.error_outline_rounded,
                                  color: Colors.white,
                                  size: (120.w / simulator.cols).clamp(8.0, 16.0),
                                ),
                              ),
                            );
                          } else if (isShaded) {
                            safetyOverlay = Container(
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.35),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.wb_cloudy_rounded,
                                  color: Colors.white,
                                  size: (120.w / simulator.cols).clamp(8.0, 16.0),
                                ),
                              ),
                            );
                          } else if (inSetback) {
                            safetyOverlay = Container(
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.35),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.space_bar_rounded,
                                  color: Colors.white,
                                  size: (120.w / simulator.cols).clamp(8.0, 16.0),
                                ),
                              ),
                            );
                          } else {
                            safetyOverlay = Container(
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.35),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.check_circle_rounded,
                                  color: Colors.white,
                                  size: (120.w / simulator.cols).clamp(8.0, 16.0),
                                ),
                              ),
                            );
                          }
                        }

                        return GestureDetector(
                          onTap: () {
                            if (!simulator.isPolygonSketchMode) {
                              controller.handleCellTap(index);
                            }
                          },
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  decoration: _buildCellDecoration(
                                    cell,
                                    index,
                                    simulator,
                                    controller,
                                    isDark,
                                  ),
                                  child: Center(
                                    child: _buildCellIcon(cell, index, simulator, controller),
                                  ),
                                ),
                              ),
                              if (safetyOverlay != null) Positioned.fill(child: safetyOverlay),
                            ],
                          ),
                        );
                      },
                    ),

                    // Custom Polygon Drawing and active vertices
                    if (simulator.isPolygonSketchMode || simulator.polygonVertices.isNotEmpty)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: CustomPaint(
                            painter: CustomPolygonPainter(
                              vertices: simulator.polygonVertices,
                              rows: simulator.rows,
                              cols: simulator.cols,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
