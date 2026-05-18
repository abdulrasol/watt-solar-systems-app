import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/src/services/toast_service.dart';
import 'package:solar_hub/src/utils/app_theme.dart';
import 'package:solar_hub/src/features/calculations/presentation/widgets/explanation_button.dart';
import 'package:solar_hub/src/utils/app_explanations.dart';

enum CellType { empty, panel, obstacle, shadow, tree }

enum ToolMode { placePanel, placeObstacle, placeShadow, placeTree, erase }

class RoofSimulatorPage extends ConsumerStatefulWidget {
  const RoofSimulatorPage({super.key});

  @override
  ConsumerState<RoofSimulatorPage> createState() => _RoofSimulatorPageState();
}

class _RoofSimulatorPageState extends ConsumerState<RoofSimulatorPage> {
  // Grid parameters (dynamically computed from roof and panel dimensions)
  int _cols = 9;
  int _rows = 3;

  // Roof dimensions
  double _roofWidthM = 10.0;
  double _roofLengthM = 8.0;

  // Panel specifications (pre-filled with default/initial data)
  double _panelPowerW = 620.0;
  double _panelLengthM = 2.2;
  double _panelWidthM = 1.1;
  double _panelWeightKg = 22.0;

  late final TextEditingController _powerController;
  late final TextEditingController _lengthController;
  late final TextEditingController _widthController;
  late final TextEditingController _roofWidthController;
  late final TextEditingController _roofLengthController;

  // Selected tool mode
  ToolMode _activeTool = ToolMode.placePanel;

  // Grid representation (row-major list)
  List<CellType> _grid = List.filled(27, CellType.empty);

  // Sunlight and Shading Buffer Configuration
  String _panelOrientation = 'South';
  bool _shadeBufferAvoidance = true;

  @override
  void initState() {
    super.initState();
    
    _powerController = TextEditingController(text: '620');
    _powerController.addListener(() {
      final val = double.tryParse(_powerController.text) ?? 620.0;
      setState(() {
        _panelPowerW = val;
      });
    });

    _lengthController = TextEditingController(text: '2.2');
    _lengthController.addListener(() {
      final val = double.tryParse(_lengthController.text) ?? 2.2;
      setState(() {
        _panelLengthM = val;
        _updateGridFromDimensions();
      });
    });

    _widthController = TextEditingController(text: '1.1');
    _widthController.addListener(() {
      final val = double.tryParse(_widthController.text) ?? 1.1;
      setState(() {
        _panelWidthM = val;
        _updateGridFromDimensions();
      });
    });

    _roofWidthController = TextEditingController(text: '10.0');
    _roofWidthController.addListener(() {
      final val = double.tryParse(_roofWidthController.text) ?? 10.0;
      setState(() {
        _roofWidthM = val;
        _updateGridFromDimensions();
      });
    });

    _roofLengthController = TextEditingController(text: '8.0');
    _roofLengthController.addListener(() {
      final val = double.tryParse(_roofLengthController.text) ?? 8.0;
      setState(() {
        _roofLengthM = val;
        _updateGridFromDimensions();
      });
    });

    // Make sure we have initial computed layout
    _updateGridFromDimensions();
  }

  @override
  void dispose() {
    _powerController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
    _roofWidthController.dispose();
    _roofLengthController.dispose();
    super.dispose();
  }

  void _updateGridFromDimensions() {
    final computedCols = (_roofWidthM / _panelWidthM).floor().clamp(2, 18);
    final computedRows = (_roofLengthM / _panelLengthM).floor().clamp(2, 18);
    if (computedCols != _cols || computedRows != _rows) {
      final oldCols = _cols;
      final oldRows = _rows;
      _cols = computedCols;
      _rows = computedRows;
      _recreateGrid(oldCols: oldCols, oldRows: oldRows);
    }
  }

  void _recreateGrid({int? oldCols, int? oldRows}) {
    setState(() {
      if (oldCols == null || oldRows == null) {
        _grid = List.filled(_cols * _rows, CellType.empty);
        return;
      }
      final newGrid = List.filled(_cols * _rows, CellType.empty);
      for (int r = 0; r < _rows; r++) {
        for (int c = 0; c < _cols; c++) {
          if (r < oldRows && c < oldCols) {
            newGrid[r * _cols + c] = _grid[r * oldCols + c];
          }
        }
      }
      _grid = newGrid;
    });
  }

  bool _isArabic(BuildContext context) => Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';

  String _tr(BuildContext context, String en, String ar) {
    return _isArabic(context) ? ar : en;
  }

  // Calculate live statistics
  int get _panelsCount => _grid.where((c) => c == CellType.panel).length;
  int get _obstaclesCount => _grid.where((c) => c == CellType.obstacle || c == CellType.shadow || c == CellType.tree).length;
  int get _onlyObstaclesCount => _grid.where((c) => c == CellType.obstacle).length;
  int get _shadowsCount => _grid.where((c) => c == CellType.shadow).length;
  int get _treesCount => _grid.where((c) => c == CellType.tree).length;

  double get _panelAreaM2 => _panelLengthM * _panelWidthM;

  double get _peakPower {
    double total = 0.0;
    for (int i = 0; i < _grid.length; i++) {
      if (_grid[i] == CellType.panel) {
        if (_isCellShaded(i)) {
          total += (_panelPowerW * 0.3) / 1000.0; // 70% shading loss!
        } else {
          total += _panelPowerW / 1000.0;
        }
      }
    }
    return total;
  }

  bool _isCellShaded(int index) {
    int row = index ~/ _cols;
    int col = index % _cols;

    bool isBlocker(int r, int c) {
      if (r < 0 || r >= _rows || c < 0 || c >= _cols) return false;
      final type = _grid[r * _cols + c];
      return type == CellType.obstacle || type == CellType.shadow || type == CellType.tree;
    }

    if (_panelOrientation == 'South') {
      // Check cells directly South, South-East, South-West
      return isBlocker(row + 1, col) || isBlocker(row + 1, col - 1) || isBlocker(row + 1, col + 1);
    } else if (_panelOrientation == 'North') {
      // Check cells directly North, North-East, North-West
      return isBlocker(row - 1, col) || isBlocker(row - 1, col - 1) || isBlocker(row - 1, col + 1);
    } else if (_panelOrientation == 'East') {
      // Check cells directly East, North-East, South-East
      return isBlocker(row, col + 1) || isBlocker(row - 1, col + 1) || isBlocker(row + 1, col + 1);
    } else if (_panelOrientation == 'West') {
      // Check cells directly West, North-West, South-West
      return isBlocker(row, col - 1) || isBlocker(row - 1, col - 1) || isBlocker(row + 1, col - 1);
    }
    return false;
  }

  double get _totalArea => _panelsCount * _panelAreaM2;
  double get _totalWeight => _panelsCount * _panelWeightKg;

  void _onCellTapped(int index) {
    setState(() {
      switch (_activeTool) {
        case ToolMode.placePanel:
          if (_grid[index] == CellType.obstacle || _grid[index] == CellType.shadow || _grid[index] == CellType.tree) {
            ToastService.warning(
              context,
              _tr(context, 'Blocked Area', 'منطقة محجوبة'),
              _tr(context, 'Cannot place a panel on obstacles or shaded areas!', 'لا يمكن وضع لوح شمسي على عوائق أو مناطق مظللة!'),
            );
          } else {
            _grid[index] = CellType.panel;
          }
          break;
        case ToolMode.placeObstacle:
          _grid[index] = CellType.obstacle;
          break;
        case ToolMode.placeShadow:
          _grid[index] = CellType.shadow;
          break;
        case ToolMode.placeTree:
          _grid[index] = CellType.tree;
          break;
        case ToolMode.erase:
          _grid[index] = CellType.empty;
          break;
      }
    });
  }

  void _clearAll() {
    setState(() {
      _grid.fillRange(0, _grid.length, CellType.empty);
    });
    ToastService.info(context, _tr(context, 'Cleared', 'تمت الإعادة'), _tr(context, 'Roof canvas cleared successfully.', 'تم تفريغ سطح المحاكاة بنجاح.'));
  }

  void _autofillRoof() {
    setState(() {
      for (int i = 0; i < _grid.length; i++) {
        if (_grid[i] == CellType.empty) {
          if (_shadeBufferAvoidance && _isCellShaded(i)) {
            continue; // Keep panels away from shaded cells!
          }
          _grid[i] = CellType.panel;
        }
      }
    });
    ToastService.success(
      context,
      _tr(context, 'Autofill Complete', 'اكتمل الملء التلقائي'),
      _tr(context, 'Successfully populated all available space with panels.', 'تم ملء جميع المساحات المتاحة بالألواح بنجاح.'),
    );
  }

  void _showExportDialog() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        backgroundColor: isDark ? const Color(0xFF161E1C) : Colors.white,
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12.r)),
              child: const Icon(Iconsax.document_text_bold, color: AppTheme.primaryColor),
            ),
            SizedBox(width: 10.w),
            Text(
              _tr(context, 'Roof Proposal Summary', 'ملخص مقترح السطح'),
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18.sp),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _tr(
                  context,
                  'Here is the complete layout plan for your roof installation. You can save this design or share it directly with companies to request custom quotes.',
                  'إليك مخطط توزيع الألواح الخاص بسطحك. يمكنك حفظ هذا التصميم أو مشاركته مباشرة مع الشركات لطلب عروض أسعار مخصصة.',
                ),
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13.sp, color: isDark ? Colors.white70 : Colors.grey[700], height: 1.45),
              ),
              SizedBox(height: 18.h),
              _buildDialogStatRow(
                context,
                label: _tr(context, 'Total Solar Panels', 'إجمالي الألواح الشمسية'),
                value: '$_panelsCount ${_tr(context, 'Panels', 'لوح')}',
                icon: Iconsax.sun_1_bold,
                iconColor: Colors.amber,
              ),
              const Divider(),
              _buildDialogStatRow(
                context,
                label: _tr(context, 'Peak Output (kWp)', 'قدرة الإنتاج القصوى (ك.و)'),
                value: '${_peakPower.toStringAsFixed(2)} kWp',
                icon: Iconsax.flash_1_bold,
                iconColor: Colors.redAccent,
              ),
              const Divider(),
              _buildDialogStatRow(
                context,
                label: _tr(context, 'Roof Area Occupied', 'المساحة المشغولة'),
                value: '${_totalArea.toStringAsFixed(1)} m²',
                icon: Iconsax.grid_5_bold,
                iconColor: Colors.blueAccent,
              ),
              const Divider(),
              _buildDialogStatRow(
                context,
                label: _tr(context, 'Structural Weight Load', 'الوزن الهيكلي الإضافي'),
                value: '${_totalWeight.toStringAsFixed(0)} kg',
                icon: Icons.fitness_center,
                iconColor: Colors.teal,
              ),
              const Divider(),
              _buildDialogStatRow(
                context,
                label: _tr(context, 'Total Obstacles & Shadows', 'إجمالي العوائق والظلال'),
                value: '$_obstaclesCount ${_tr(context, 'Cells', 'خلايا')}',
                icon: Icons.warning_amber_rounded,
                iconColor: Colors.amber[800]!,
              ),
              if (_onlyObstaclesCount > 0) ...[
                const Divider(),
                _buildDialogStatRow(
                  context,
                  label: _tr(context, '   • Building Structures / ACs', '   • الهياكل والمكيفات'),
                  value: '$_onlyObstaclesCount ${_tr(context, 'Cells', 'خلايا')}',
                  icon: Icons.warning_amber_rounded,
                  iconColor: Colors.redAccent,
                ),
              ],
              if (_shadowsCount > 0) ...[
                const Divider(),
                _buildDialogStatRow(
                  context,
                  label: _tr(context, '   • Parapets & Wall Shadows', '   • ظلال الجدران'),
                  value: '$_shadowsCount ${_tr(context, 'Cells', 'خلايا')}',
                  icon: Icons.nights_stay_rounded,
                  iconColor: Colors.blueGrey,
                ),
              ],
              if (_treesCount > 0) ...[
                const Divider(),
                _buildDialogStatRow(
                  context,
                  label: _tr(context, '   • Trees & Foliage Shade', '   • ظلال الأشجار'),
                  value: '$_treesCount ${_tr(context, 'Cells', 'خلايا')}',
                  icon: Icons.park_rounded,
                  iconColor: Colors.green,
                ),
              ],
            ],
          ),
        ),
        actionsPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    ToastService.success(
                      context,
                      _tr(context, 'Saved Successfully', 'تم الحفظ بنجاح'),
                      _tr(context, 'Solar layout has been saved to your offline designs list.', 'تم حفظ مخطط الألواح بنجاح في قائمة تصاميمك المحلية.'),
                    );
                  },
                  child: Text(_tr(context, 'Save Design', 'حفظ التصميم')),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    ToastService.success(
                      context,
                      _tr(context, 'Proposal Submitted', 'تم إرسال المقترح'),
                      _tr(
                        context,
                        'Your roof visual proposal has been sent to partner suppliers.',
                        'تمت مشاركة مقترح السطح البصري الخاص بك مع الشركات المزودة للخدمة.',
                      ),
                    );
                  },
                  child: Text(_tr(context, 'Share & Quote', 'طلب عروض')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDialogStatRow(BuildContext context, {required String label, required String value, required IconData icon, required Color iconColor}) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6.r),
            decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8.r)),
            child: Icon(icon, color: iconColor, size: 18.sp),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: theme.brightness == Brightness.dark ? Colors.white70 : Colors.grey[700]),
            ),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w900, color: AppTheme.primaryColor),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_tr(context, 'Roof Panel Simulator', 'محاكي الأسطح والألواح')),
        actions: [
          ExplanationButton(
            explanations: [
              ExplanationItem(
                title: _tr(context, 'Interactive Visual Simulator', 'المحاكي البصري التفاعلي'),
                description: _tr(
                  context,
                  'Configure your roof columns and rows, select a tool (Panels, Obstacles, or Eraser), and tap on grid cells to interactively customize your solar installation layout.',
                  'اضبط أعمدة وصفوف السطح، واختر الأداة (الألواح، العوائق، أو الممحاة)، ثم اضغط على مربعات الشبكة لتصميم توزيع النظام الشمسي الخاص بك بشكل تفاعلي.',
                ),
              ),
              ExplanationItem(
                title: _tr(context, 'Custom Specifications', 'مواصفات الألواح المخصصة'),
                description: _tr(
                  context,
                  'Type the power rating in Watts and specify the physical length and width of your panels to automatically determine the exact surface area occupied and overall structural weight.',
                  'أدخل قدرة اللوح بالواط وحدد الطول والعرض الفعليين لألواحك لحساب مساحة السطح الدقيقة التي تشغلها وإجمالي الوزن الإنشائي الحامل تلقائيًا.',
                ),
              ),
              ExplanationItem(
                title: _tr(context, 'Autofill & Share', 'التعبئة التلقائية والتصدير'),
                description: _tr(
                  context,
                  'Use "Autofill" to instantly populate maximum panels avoiding obstacles, or tap the share icon to export your visual system layout and specs into a professional proposal mockup PDF.',
                  'استخدم "ملء تلقائي" لتعبئة أكبر عدد ممكن من الألواح متجنبًا العوائق، أو اضغط على أيقونة المشاركة لتصدير توزيع الألواح ومواصفات المنظومة في نموذج عرض سعر احترافي.',
                ),
              ),
            ],
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Live statistics row
            _buildLiveStatsRow(),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Column(
                  children: [
                    // Grid dimensions controller
                    _buildDimensionsControl(),

                    SizedBox(height: 14.h),

                    // Panel Specifications Configuration
                    _buildPanelSpecsControl(),

                    SizedBox(height: 14.h),

                    // Sunlight Facing & Smart Shading Card
                    _buildShadingSpecsControl(),

                    SizedBox(height: 14.h),

                    // Active Tools bar
                    _buildToolSelectionBar(),

                    SizedBox(height: 18.h),

                    // Interactive Grid Visual Canvas
                    _buildVisualGridCanvas(),

                    SizedBox(height: 20.h),

                    // Primary Action Buttons
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveStatsRow() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 10.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131A18) : const Color(0xFFF4FAF7),
        border: Border(bottom: BorderSide(color: AppTheme.primaryColor.withValues(alpha: 0.1), width: 1.5)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildStatChip(_tr(context, 'Panels', 'الألواح'), '$_panelsCount', Iconsax.sun_1_bold, Colors.amber),
            SizedBox(width: 8.w),
            _buildStatChip(_tr(context, 'Output', 'القدرة'), '${_peakPower.toStringAsFixed(2)} kWp', Iconsax.flash_1_bold, Colors.redAccent),
            SizedBox(width: 8.w),
            _buildStatChip(_tr(context, 'Area', 'المساحة'), '${_totalArea.toStringAsFixed(1)} m²', Iconsax.grid_5_bold, Colors.blueAccent),
            SizedBox(width: 8.w),
            _buildStatChip(_tr(context, 'Weight', 'الوزن'), '${_totalWeight.toStringAsFixed(0)} kg', Icons.fitness_center, Colors.teal),
            SizedBox(width: 8.w),
            _buildStatChip(_tr(context, 'Obstacles', 'العوائق'), '$_obstaclesCount', Icons.warning_amber_rounded, Colors.orangeAccent),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, String value, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B2523) : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: const [BoxShadow(color: Color(0x05000000), blurRadius: 8, offset: Offset(0, 4))],
        border: Border.all(color: color.withValues(alpha: 0.15), width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16.sp),
          SizedBox(width: 6.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 9.sp, color: Colors.grey[600], fontWeight: FontWeight.w600),
              ),
              Text(
                value,
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w900, color: AppTheme.primaryColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDimensionsControl() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161E1C) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: const [BoxShadow(color: Color(0x04000000), blurRadius: 12, offset: Offset(0, 6))],
        border: Border.all(color: Colors.grey.withValues(alpha: isDark ? 0.08 : 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _tr(context, 'Roof Dimensions Configuration', 'تهيئة أبعاد السطح'),
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.sp),
              ),
              Icon(Iconsax.setting_3_bold, color: AppTheme.primaryColor, size: 16.sp),
            ],
          ),
          SizedBox(height: 12.h),

          // Roof Width and Length side-by-side in one row with Explanation Button
          Padding(
            padding: EdgeInsets.symmetric(vertical: 4.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _roofWidthController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: _tr(context, 'Roof Width (meters)', 'عرض السطح (متر)'),
                      labelStyle: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                      suffixText: 'm',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: TextField(
                    controller: _roofLengthController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: _tr(context, 'Roof Length (meters)', 'طول السطح (متر)'),
                      labelStyle: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                      suffixText: 'm',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
                ExplanationButton(
                  explanations: [
                    ExplanationItem(
                      title: _tr(context, 'Roof Physical Grid Area', 'مساحة السطح الفعالة'),
                      description: _tr(
                        context,
                        'Enter your actual physical roof width and length in meters. The canvas grid columns and rows will automatically calculate and scale based on your selected solar panel length and width, showing exactly how many panels can fit on your roof.',
                        'أدخل العرض والطول الفعليين للسطح بالمتر. سيتم تلقائيًا حساب أعمدة وصفوف شبكة الرسم وتغيير حجمها بناءً على طول وعرض الألواح الشمسية المحددة، مما يوضح لك بدقة عدد الألواح التي يمكن وضعها على سطحك.',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 10.h),

          // Computed Layout Feedback Box
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2624) : const Color(0xFFF0F7F4),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              children: [
                Icon(Iconsax.info_circle_bold, color: AppTheme.primaryColor, size: 14.sp),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    _tr(
                      context,
                      'Resulting Grid: $_cols Columns × $_rows Rows (${_cols * _rows} total cells)',
                      'الشبكة الناتجة: $_cols أعمدة × $_rows صفوف (إجمالي ${_cols * _rows} خلايا)',
                    ),
                    style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPanelSpecsControl() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161E1C) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: const [BoxShadow(color: Color(0x04000000), blurRadius: 12, offset: Offset(0, 6))],
        border: Border.all(color: Colors.grey.withValues(alpha: isDark ? 0.08 : 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _tr(context, 'Panel Specifications Configuration', 'مواصفات الألواح الشمسية'),
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.sp),
              ),
              Icon(Iconsax.sun_1_bold, color: Colors.amber, size: 16.sp),
            ],
          ),
          SizedBox(height: 12.h),

          // Power Input (Number Text Input)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: TextField(
              controller: _powerController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: _tr(context, 'Panel Rated Power (Watts)', 'قدرة اللوح الواحد (واط)'),
                labelStyle: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                suffixText: 'W',
                suffixStyle: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor, fontSize: 13.sp),
                contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              ),
            ),
          ),

          SizedBox(height: 8.h),

          // Length and Width inputs in one row with Explanation Dialog
          Padding(
            padding: EdgeInsets.symmetric(vertical: 4.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _lengthController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: _tr(context, 'Length (meters)', 'الطول (متر)'),
                      labelStyle: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                      suffixText: 'm',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: TextField(
                    controller: _widthController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: _tr(context, 'Width (meters)', 'العرض (متر)'),
                      labelStyle: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                      suffixText: 'm',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
                ExplanationButton(
                  explanations: [
                    ExplanationItem(
                      title: _tr(context, 'Solar Panel Dimensions', 'أبعاد اللوح الشمسي'),
                      description: _tr(
                        context,
                        'Enter the exact physical length and width of a single solar panel in meters. These dimensions are multiplied to calculate the occupied surface area per panel (default: 2.2m x 1.1m = 2.42 m²).',
                        'أدخل الطول والعرض الفعليين للوح الشمسي الواحد بالمتر. يتم ضرب هذه الأبعاد لحساب مساحة السطح التي يشغلها كل لوح تلقائيًا (الافتراضي: 2.2 م × 1.1 م = 2.42 م²).',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Calculated Surface Area Indicator
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
            margin: EdgeInsets.only(bottom: 12.h, top: 4.h),
            decoration: BoxDecoration(color: isDark ? const Color(0xFF1E2624) : const Color(0xFFF0F7F4), borderRadius: BorderRadius.circular(10.r)),
            child: Row(
              children: [
                Icon(Iconsax.grid_5_bold, color: AppTheme.primaryColor, size: 14.sp),
                SizedBox(width: 8.w),
                Text(
                  _tr(context, 'Calculated Surface Area:', 'المساحة السطحية المحسوبة:'),
                  style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Text(
                  '${_panelAreaM2.toStringAsFixed(2)} m²',
                  style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w900, color: AppTheme.primaryColor),
                ),
              ],
            ),
          ),

          // Structural Weight Slider
          Row(
            children: [
              Text(
                _tr(context, 'Structural Weight (kg)', 'وزن اللوح الحامل (كجم)'),
                style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                '${_panelWeightKg.toStringAsFixed(0)} kg',
                style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.primaryColor),
              ),
            ],
          ),
          Slider(
            value: _panelWeightKg,
            min: 15,
            max: 30,
            divisions: 15,
            activeColor: Colors.teal,
            inactiveColor: Colors.teal.withValues(alpha: 0.15),
            onChanged: (v) {
              setState(() {
                _panelWeightKg = v;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildShadingSpecsControl() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161E1C) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: const [BoxShadow(color: Color(0x04000000), blurRadius: 12, offset: Offset(0, 6))],
        border: Border.all(color: Colors.grey.withValues(alpha: isDark ? 0.08 : 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _tr(context, 'Sunlight Orientation & Smart Shading', 'توجيه الشمس والظل الذكي'),
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.sp),
              ),
              Icon(Iconsax.sun_bold, color: Colors.orangeAccent, size: 16.sp),
            ],
          ),
          SizedBox(height: 12.h),

          // Dropdown for Panel Facing Direction and Switch for Shade Avoidance in one row
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _panelOrientation,
                  dropdownColor: isDark ? const Color(0xFF1E2624) : Colors.white,
                  decoration: InputDecoration(
                    labelText: _tr(context, 'Panel Facing Direction', 'اتجاه وجه الألواح'),
                    labelStyle: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'South',
                      child: Text(
                        _tr(context, 'South (الجنوب) [Best]', 'الجنوب [موصى به]'),
                        style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'North',
                      child: Text(
                        _tr(context, 'North (الشمال)', 'الشمال'),
                        style: TextStyle(fontSize: 11.sp),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'East',
                      child: Text(
                        _tr(context, 'East (الشرق)', 'الشرق'),
                        style: TextStyle(fontSize: 11.sp),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'West',
                      child: Text(
                        _tr(context, 'West (الغرب)', 'الغرب'),
                        style: TextStyle(fontSize: 11.sp),
                      ),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _panelOrientation = val;
                      });
                    }
                  },
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Text(
                      _tr(context, 'Shade Buffer', 'وقاية الظل'),
                      style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold),
                    ),
                    Switch(
                      value: _shadeBufferAvoidance,
                      activeColor: AppTheme.primaryColor,
                      onChanged: (val) {
                        setState(() {
                          _shadeBufferAvoidance = val;
                        });
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(width: 4.w),
              ExplanationButton(
                explanations: [
                  ExplanationItem(
                    title: _tr(context, 'Sunlight Orientation & Shadows', 'توجيه الشمس وظلال المنظومة'),
                    description: _tr(
                      context,
                      'Solar panels in the Northern Hemisphere perform best facing South to capture max sun path. Trees, parapets, and chimneys cast shadows opposite to sun direction. When "Shade Buffer" is enabled, Smart Autofill leaves a 1-cell buffer zone to prevent shadowing your solar panels, and manually placed panels in shaded areas display warnings.',
                      'تعمل الألواح الشمسية في نصف الكرة الشمالي بشكل أفضل عند توجيهها للجنوب لالتقاط مسار الشمس الأقصى. تلقي الأشجار والسترات والمداخن ظلالًا في الاتجاه المعاكس لاتجاه الشمس. عند تفعيل "وقاية الظل"، يتجنب الملء التلقائي الذكي مساحة خلية واحدة خلف أي عائق لمنع تظليل ألواحك الشمسية، وتظهر تحذيرات على الألواح الموضوعة يدويًا في مناطق الظل.',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToolSelectionBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(6.r),
      decoration: BoxDecoration(color: isDark ? const Color(0xFF131A18) : Colors.grey[100], borderRadius: BorderRadius.circular(16.r)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            SizedBox(
              width: 90.w,
              child: _buildToolChip(
                mode: ToolMode.placePanel,
                label: _tr(context, 'Panels', 'ألوح شمسية'),
                icon: Iconsax.sun_1_bold,
                activeColor: Colors.amber,
              ),
            ),
            SizedBox(width: 4.w),
            SizedBox(
              width: 90.w,
              child: _buildToolChip(
                mode: ToolMode.placeObstacle,
                label: _tr(context, 'Obstacle', 'عائق'),
                icon: Icons.warning_amber_rounded,
                activeColor: Colors.redAccent,
              ),
            ),
            SizedBox(width: 4.w),
            SizedBox(
              width: 90.w,
              child: _buildToolChip(
                mode: ToolMode.placeShadow,
                label: _tr(context, 'Shadow', 'ظلال'),
                icon: Icons.nights_stay_rounded,
                activeColor: Colors.blueGrey,
              ),
            ),
            SizedBox(width: 4.w),
            SizedBox(
              width: 90.w,
              child: _buildToolChip(
                mode: ToolMode.placeTree,
                label: _tr(context, 'Tree', 'أشجار'),
                icon: Icons.park_rounded,
                activeColor: Colors.green,
              ),
            ),
            SizedBox(width: 4.w),
            SizedBox(
              width: 90.w,
              child: _buildToolChip(
                mode: ToolMode.erase,
                label: _tr(context, 'Eraser', 'ممحاة'),
                icon: Icons.cleaning_services_rounded,
                activeColor: Colors.blueGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolChip({required ToolMode mode, required String label, required IconData icon, required Color activeColor}) {
    final isSelected = _activeTool == mode;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        setState(() {
          _activeTool = mode;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? (isDark ? activeColor.withValues(alpha: 0.15) : activeColor.withValues(alpha: 0.12)) : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: isSelected ? activeColor.withValues(alpha: 0.3) : Colors.transparent, width: 1.2),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? activeColor : (isDark ? Colors.white60 : Colors.grey[600]), size: 18.sp),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
                color: isSelected ? activeColor : (isDark ? Colors.white70 : Colors.grey[700]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisualGridCanvas() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width - 32;

    return Container(
      width: screenWidth,
      height: screenWidth,
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161E1C) : Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 16, offset: Offset(0, 8))],
        border: Border.all(color: Colors.grey.withValues(alpha: isDark ? 0.08 : 0.12), width: 1.4),
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: _cols, crossAxisSpacing: 6.r, mainAxisSpacing: 6.r),
        itemCount: _cols * _rows,
        itemBuilder: (context, index) {
          final cell = _grid[index];
          return GestureDetector(
            onTap: () => _onCellTapped(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: _buildCellDecoration(cell, index),
              child: Center(child: _buildCellIcon(cell, index)),
            ),
          );
        },
      ),
    );
  }

  BoxDecoration _buildCellDecoration(CellType type, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (type) {
      case CellType.empty:
        return BoxDecoration(
          color: isDark ? Colors.grey[900]?.withValues(alpha: 0.4) : Colors.grey[50],
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: Colors.grey.withValues(alpha: isDark ? 0.15 : 0.25),
            width: 1,
            style: BorderStyle.solid,
          ),
        );
      case CellType.panel:
        final isShaded = _isCellShaded(index);
        if (isShaded) {
          return BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF90A4AE), Color(0xFF607D8B)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(8.r),
            boxShadow: [BoxShadow(color: Colors.orange.withValues(alpha: 0.25), blurRadius: 6, offset: const Offset(0, 2))],
            border: Border.all(color: Colors.orange, width: 2.0),
          );
        }
        return BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFFFD54F), Color(0xFFFFB300)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [BoxShadow(color: Colors.amber.withValues(alpha: 0.3), blurRadius: 6, offset: const Offset(0, 2))],
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
    }
  }

  Widget? _buildCellIcon(CellType type, int index) {
    switch (type) {
      case CellType.empty:
        return null;
      case CellType.panel:
        final isShaded = _isCellShaded(index);
        if (isShaded) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Icon(Iconsax.sun_1_bold, color: Colors.white.withValues(alpha: 0.4), size: (180.w / _cols).clamp(12.0, 24.0)),
              Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent, size: (180.w / _cols).clamp(10.0, 20.0)),
            ],
          );
        }
        return Icon(Iconsax.sun_1_bold, color: Colors.white, size: (180.w / _cols).clamp(12.0, 24.0));
      case CellType.obstacle:
        return Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: (180.w / _cols).clamp(12.0, 24.0));
      case CellType.shadow:
        return Icon(Icons.nights_stay_rounded, color: Colors.blueGrey, size: (180.w / _cols).clamp(12.0, 24.0));
      case CellType.tree:
        return Icon(Icons.park_rounded, color: Colors.green, size: (180.w / _cols).clamp(12.0, 24.0));
    }
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                  side: const BorderSide(color: Colors.redAccent, width: 1.2),
                  foregroundColor: Colors.redAccent,
                ),
                onPressed: _clearAll,
                icon: const Icon(Icons.refresh),
                label: Text(_tr(context, 'Reset Grid', 'إعادة تعيين')),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.12),
                  foregroundColor: AppTheme.primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                  elevation: 0,
                ),
                onPressed: _autofillRoof,
                icon: const Icon(Iconsax.magic_star_bold),
                label: Text(_tr(context, 'Smart Autofill', 'ملء تلقائي ذكي')),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
              elevation: 4,
              shadowColor: AppTheme.primaryColor.withValues(alpha: 0.3),
            ),
            onPressed: _panelsCount > 0
                ? _showExportDialog
                : () {
                    ToastService.warning(
                      context,
                      _tr(context, 'No Panels', 'لا توجد ألواح'),
                      _tr(context, 'Please place at least one panel first!', 'يرجى وضع لوح شمسي واحد على الأقل أولًا!'),
                    );
                  },
            icon: const Icon(Iconsax.export_bold),
            label: Text(
              _tr(context, 'Export Proposal Mockup', 'تصدير ملخص المقترح البصري'),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp),
            ),
          ),
        ),
      ],
    );
  }
}
