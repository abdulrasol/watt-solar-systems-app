import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/src/services/toast_service.dart';
import 'package:solar_hub/src/utils/app_theme.dart';
import 'package:solar_hub/src/features/calculations/presentation/widgets/explanation_button.dart';
import 'package:solar_hub/src/utils/app_explanations.dart';

enum CellType { empty, panel, obstacle, shadow, tree, excluded }

enum ToolMode { placePanel, placeObstacle, placeShadow, placeTree, excludeRoof, erase }

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

  // Setback and orientation specifications
  bool _isPortrait = true;
  double _wallSetbackM = 0.5;

  // Optional Boundary Walls config
  bool _hasNorthWall = false;
  bool _hasSouthWall = false;
  bool _hasEastWall = false;
  bool _hasWestWall = false;

  double _northWallHeight = 1.0;
  double _southWallHeight = 1.0;
  double _eastWallHeight = 1.0;
  double _westWallHeight = 1.0;

  late final TextEditingController _powerController;
  late final TextEditingController _lengthController;
  late final TextEditingController _widthController;
  late final TextEditingController _roofWidthController;
  late final TextEditingController _roofLengthController;
  late final TextEditingController _setbackController;

  late final TextEditingController _northWallController;
  late final TextEditingController _southWallController;
  late final TextEditingController _eastWallController;
  late final TextEditingController _westWallController;

  // FocusNodes for input fields to implement validation guardrails on Focus-Out
  late final FocusNode _powerFocus;
  late final FocusNode _lengthFocus;
  late final FocusNode _widthFocus;
  late final FocusNode _roofWidthFocus;
  late final FocusNode _roofLengthFocus;
  late final FocusNode _setbackFocus;

  late final FocusNode _northWallFocus;
  late final FocusNode _southWallFocus;
  late final FocusNode _eastWallFocus;
  late final FocusNode _westWallFocus;

  // Selected tool mode
  ToolMode _activeTool = ToolMode.placePanel;
  bool _isSafeOverlayActive = false;

  // Custom polygon sketching variables
  final List<Offset> _polygonVertices = [];
  bool _isPolygonSketchMode = false;

  // Grid representation (row-major list)
  List<CellType> _grid = List.filled(27, CellType.empty);

  // Sunlight and Shading Buffer Configuration
  String _panelOrientation = 'South';
  bool _shadeBufferAvoidance = true;

  // History stacks for Undo & Redo transaction tracking
  final List<List<CellType>> _undoStack = [];
  final List<List<CellType>> _redoStack = [];

  // Track processed indices during a single swipe gesture
  final Set<int> _draggedIndices = {};

  @override
  void initState() {
    super.initState();

    _powerController = TextEditingController(text: '620');
    _lengthController = TextEditingController(text: '2.2');
    _widthController = TextEditingController(text: '1.1');
    _roofWidthController = TextEditingController(text: '10.0');
    _roofLengthController = TextEditingController(text: '8.0');
    _setbackController = TextEditingController(text: '0.5');

    _northWallController = TextEditingController(text: '1.0');
    _southWallController = TextEditingController(text: '1.0');
    _eastWallController = TextEditingController(text: '1.0');
    _westWallController = TextEditingController(text: '1.0');

    _powerFocus = FocusNode();
    _lengthFocus = FocusNode();
    _widthFocus = FocusNode();
    _roofWidthFocus = FocusNode();
    _roofLengthFocus = FocusNode();
    _setbackFocus = FocusNode();

    _northWallFocus = FocusNode();
    _southWallFocus = FocusNode();
    _eastWallFocus = FocusNode();
    _westWallFocus = FocusNode();

    // Attach Focus-Out listeners
    _powerFocus.addListener(() => _onFieldFocusChanged(_powerFocus, _powerController, 'power'));
    _lengthFocus.addListener(() => _onFieldFocusChanged(_lengthFocus, _lengthController, 'length'));
    _widthFocus.addListener(() => _onFieldFocusChanged(_widthFocus, _widthController, 'width'));
    _roofWidthFocus.addListener(() => _onFieldFocusChanged(_roofWidthFocus, _roofWidthController, 'roofWidth'));
    _roofLengthFocus.addListener(() => _onFieldFocusChanged(_roofLengthFocus, _roofLengthController, 'roofLength'));
    _setbackFocus.addListener(() => _onFieldFocusChanged(_setbackFocus, _setbackController, 'setback'));

    _northWallFocus.addListener(() => _onFieldFocusChanged(_northWallFocus, _northWallController, 'northWall'));
    _southWallFocus.addListener(() => _onFieldFocusChanged(_southWallFocus, _southWallController, 'southWall'));
    _eastWallFocus.addListener(() => _onFieldFocusChanged(_eastWallFocus, _eastWallController, 'eastWall'));
    _westWallFocus.addListener(() => _onFieldFocusChanged(_westWallFocus, _westWallController, 'westWall'));

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
    _setbackController.dispose();

    _northWallController.dispose();
    _southWallController.dispose();
    _eastWallController.dispose();
    _westWallController.dispose();

    _powerFocus.dispose();
    _lengthFocus.dispose();
    _widthFocus.dispose();
    _roofWidthFocus.dispose();
    _roofLengthFocus.dispose();
    _setbackFocus.dispose();

    _northWallFocus.dispose();
    _southWallFocus.dispose();
    _eastWallFocus.dispose();
    _westWallFocus.dispose();
    super.dispose();
  }

  void _onFieldFocusChanged(FocusNode focusNode, TextEditingController controller, String type) {
    if (!focusNode.hasFocus) {
      _applyFieldValue(controller, type);
    }
  }

  void _applyFieldValue(TextEditingController controller, String type) {
    final text = controller.text.trim();
    final parsed = double.tryParse(text);

    if (parsed == null || parsed < 0 || (parsed == 0 && type != 'setback' && !type.endsWith('Wall'))) {
      double oldVal = 0.0;
      switch (type) {
        case 'power':
          oldVal = _panelPowerW;
          break;
        case 'length':
          oldVal = _panelLengthM;
          break;
        case 'width':
          oldVal = _panelWidthM;
          break;
        case 'roofWidth':
          oldVal = _roofWidthM;
          break;
        case 'roofLength':
          oldVal = _roofLengthM;
          break;
        case 'setback':
          oldVal = _wallSetbackM;
          break;
        case 'northWall':
          oldVal = _northWallHeight;
          break;
        case 'southWall':
          oldVal = _southWallHeight;
          break;
        case 'eastWall':
          oldVal = _eastWallHeight;
          break;
        case 'westWall':
          oldVal = _westWallHeight;
          break;
      }
      controller.text = oldVal.toString();
      ToastService.warning(
        context,
        _tr(context, 'Invalid Input', 'مدخل غير صالح'),
        _tr(context, 'Please enter a valid positive number.', 'يرجى إدخال رقم موجب صالح.'),
      );
      return;
    }

    bool isValid = true;
    String errorMsgEn = '';
    String errorMsgAr = '';

    switch (type) {
      case 'power':
        if (parsed < 10 || parsed > 2000) {
          isValid = false;
          errorMsgEn = 'Power must be between 10W and 2000W.';
          errorMsgAr = 'يجب أن تكون القدرة بين 10 واط و 2000 واط.';
        }
        break;
      case 'length':
        if (parsed < 0.2 || parsed > 5.0) {
          isValid = false;
          errorMsgEn = 'Panel length must be between 0.2m and 5.0m.';
          errorMsgAr = 'يجب أن يكون طول اللوح بين 0.2م و 5.0م.';
        }
        break;
      case 'width':
        if (parsed < 0.2 || parsed > 5.0) {
          isValid = false;
          errorMsgEn = 'Panel width must be between 0.2m and 5.0m.';
          errorMsgAr = 'يجب أن يكون عرض اللوح بين 0.2م و 5.0م.';
        }
        break;
      case 'roofWidth':
        if (parsed < 1.0 || parsed > 100.0) {
          isValid = false;
          errorMsgEn = 'Roof width must be between 1.0m and 100.0m.';
          errorMsgAr = 'يجب أن يكون عرض السطح بين 1.0م و 100.0م.';
        }
        break;
      case 'roofLength':
        if (parsed < 1.0 || parsed > 100.0) {
          isValid = false;
          errorMsgEn = 'Roof length must be between 1.0m and 100.0m.';
          errorMsgAr = 'يجب أن يكون طول السطح بين 1.0م و 100.0م.';
        }
        break;
      case 'setback':
        if (parsed < 0.0 || parsed > 5.0) {
          isValid = false;
          errorMsgEn = 'Safe setback must be between 0.0m and 5.0m.';
          errorMsgAr = 'يجب أن تكون مسافة الأمان بين 0.0م و 5.0م.';
        }
        break;
      case 'northWall':
      case 'southWall':
      case 'eastWall':
      case 'westWall':
        if (parsed < 0.0 || parsed > 10.0) {
          isValid = false;
          errorMsgEn = 'Wall height must be between 0.0m and 10.0m.';
          errorMsgAr = 'يجب أن يكون ارتفاع الجدار بين 0.0م و 10.0م.';
        }
        break;
    }

    if (!isValid) {
      double oldVal = 0.0;
      switch (type) {
        case 'power':
          oldVal = _panelPowerW;
          break;
        case 'length':
          oldVal = _panelLengthM;
          break;
        case 'width':
          oldVal = _panelWidthM;
          break;
        case 'roofWidth':
          oldVal = _roofWidthM;
          break;
        case 'roofLength':
          oldVal = _roofLengthM;
          break;
        case 'setback':
          oldVal = _wallSetbackM;
          break;
        case 'northWall':
          oldVal = _northWallHeight;
          break;
        case 'southWall':
          oldVal = _southWallHeight;
          break;
        case 'eastWall':
          oldVal = _eastWallHeight;
          break;
        case 'westWall':
          oldVal = _westWallHeight;
          break;
      }
      controller.text = oldVal.toString();
      ToastService.warning(context, _tr(context, 'Out of Bounds', 'خارج الحدود المسموحة'), _tr(context, errorMsgEn, errorMsgAr));
      return;
    }

    setState(() {
      _saveStateToHistory(); // Save before mutating layout dimensions!
      switch (type) {
        case 'power':
          _panelPowerW = parsed;
          break;
        case 'length':
          _panelLengthM = parsed;
          _updateGridFromDimensions();
          break;
        case 'width':
          _panelWidthM = parsed;
          _updateGridFromDimensions();
          break;
        case 'roofWidth':
          _roofWidthM = parsed;
          _updateGridFromDimensions();
          break;
        case 'roofLength':
          _roofLengthM = parsed;
          _updateGridFromDimensions();
          break;
        case 'setback':
          _wallSetbackM = parsed;
          _updateGridFromDimensions();
          break;
        case 'northWall':
          _northWallHeight = parsed;
          _updateGridFromDimensions();
          break;
        case 'southWall':
          _southWallHeight = parsed;
          _updateGridFromDimensions();
          break;
        case 'eastWall':
          _eastWallHeight = parsed;
          _updateGridFromDimensions();
          break;
        case 'westWall':
          _westWallHeight = parsed;
          _updateGridFromDimensions();
          break;
      }
    });
  }

  void _saveStateToHistory() {
    _undoStack.add(List.from(_grid));
    _redoStack.clear(); // Clear redo on any new stroke/action
    if (_undoStack.length > 25) {
      _undoStack.removeAt(0); // Cap history at 25 moves
    }
  }

  void _undo() {
    if (_undoStack.isNotEmpty) {
      final prev = _undoStack.removeLast();
      setState(() {
        _redoStack.add(List.from(_grid));
        _grid = prev;
      });
    }
  }

  void _redo() {
    if (_redoStack.isNotEmpty) {
      final next = _redoStack.removeLast();
      setState(() {
        _undoStack.add(List.from(_grid));
        _grid = next;
      });
    }
  }

  void _updateGridFromDimensions() {
    final double cellW = _isPortrait ? _panelWidthM : _panelLengthM;
    final double cellH = _isPortrait ? _panelLengthM : _panelWidthM;
    final computedCols = (_roofWidthM / cellW).floor().clamp(2, 25);
    final computedRows = (_roofLengthM / cellH).floor().clamp(2, 25);
    if (computedCols != _cols || computedRows != _rows) {
      final oldCols = _cols;
      final oldRows = _rows;
      _cols = computedCols;
      _rows = computedRows;
      _recreateGrid(oldCols: oldCols, oldRows: oldRows);
    }
  }

  bool _isInSetbackZone(int r, int c) {
    if (_wallSetbackM <= 0) return false;
    final double cellW = _isPortrait ? _panelWidthM : _panelLengthM;
    final double cellH = _isPortrait ? _panelLengthM : _panelWidthM;

    final double distLeft = c * cellW;
    final double distRight = (_cols - 1 - c) * cellW;
    final double distTop = r * cellH;
    final double distBottom = (_rows - 1 - r) * cellH;

    bool nearLeft = distLeft < _wallSetbackM;
    bool nearRight = distRight < _wallSetbackM;
    bool nearTop = distTop < _wallSetbackM;
    bool nearBottom = distBottom < _wallSetbackM;

    return (_hasWestWall && nearLeft) || (_hasEastWall && nearRight) || (_hasNorthWall && nearTop) || (_hasSouthWall && nearBottom);
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
        final shadeSource = _shadingSourceCell(i);
        if (shadeSource != null) {
          double factor = 1.0;
          if (shadeSource == CellType.tree) {
            factor = 0.60; // 40% yield loss
          } else if (shadeSource == CellType.shadow) {
            factor = 0.25; // 75% yield loss
          } else if (shadeSource == CellType.obstacle) {
            factor = 0.10; // 90% yield loss
          }
          total += (_panelPowerW * factor) / 1000.0;
        } else {
          total += _panelPowerW / 1000.0;
        }
      }
    }
    return total;
  }

  CellType? _shadingSourceCell(int index) {
    int row = index ~/ _cols;
    int col = index % _cols;

    // 1. Calculate physical wall shadows based on active walls, heights, and panel orientation
    final double cellW = _isPortrait ? _panelWidthM : _panelLengthM;
    final double cellH = _isPortrait ? _panelLengthM : _panelWidthM;

    final double distToNorth = (row + 0.5) * cellH;
    final double distToSouth = (_rows - 0.5 - row) * cellH;
    final double distToWest = (col + 0.5) * cellW;
    final double distToEast = (_cols - 0.5 - col) * cellW;

    bool isShadedByWall = false;

    // Shadow factor: standard multiplier for low-altitude sun angles is 1.25
    if (_panelOrientation == 'South') {
      // South wall is in the front (blocks sun); North wall is in the back (does not shade panels)
      if (_hasSouthWall && distToSouth < _southWallHeight * 1.25) isShadedByWall = true;
      if (_hasEastWall && distToEast < _eastWallHeight * 1.25) isShadedByWall = true;
      if (_hasWestWall && distToWest < _westWallHeight * 1.25) isShadedByWall = true;
    } else if (_panelOrientation == 'North') {
      // North wall is in the front (blocks sun); South wall is in the back (does not shade panels)
      if (_hasNorthWall && distToNorth < _northWallHeight * 1.25) isShadedByWall = true;
      if (_hasEastWall && distToEast < _eastWallHeight * 1.25) isShadedByWall = true;
      if (_hasWestWall && distToWest < _westWallHeight * 1.25) isShadedByWall = true;
    } else if (_panelOrientation == 'East') {
      // East wall is in the front; West wall is in the back
      if (_hasEastWall && distToEast < _eastWallHeight * 1.25) isShadedByWall = true;
      if (_hasNorthWall && distToNorth < _northWallHeight * 1.25) isShadedByWall = true;
      if (_hasSouthWall && distToSouth < _southWallHeight * 1.25) isShadedByWall = true;
    } else if (_panelOrientation == 'West') {
      // West wall is in the front; East wall is in the back
      if (_hasWestWall && distToWest < _westWallHeight * 1.25) isShadedByWall = true;
      if (_hasNorthWall && distToNorth < _northWallHeight * 1.25) isShadedByWall = true;
      if (_hasSouthWall && distToSouth < _southWallHeight * 1.25) isShadedByWall = true;
    }

    if (isShadedByWall) {
      return CellType.shadow;
    }

    // 2. Calculate shading from adjacent custom objects (trees, chimneys, etc.)
    CellType? getBlockerType(int r, int c) {
      if (r < 0 || r >= _rows || c < 0 || c >= _cols) return null;
      final type = _grid[r * _cols + c];
      if (type == CellType.obstacle || type == CellType.shadow || type == CellType.tree) {
        return type;
      }
      return null;
    }

    if (_panelOrientation == 'South') {
      return getBlockerType(row + 1, col) ?? getBlockerType(row + 1, col - 1) ?? getBlockerType(row + 1, col + 1);
    } else if (_panelOrientation == 'North') {
      return getBlockerType(row - 1, col) ?? getBlockerType(row - 1, col - 1) ?? getBlockerType(row - 1, col + 1);
    } else if (_panelOrientation == 'East') {
      return getBlockerType(row, col + 1) ?? getBlockerType(row - 1, col + 1) ?? getBlockerType(row + 1, col + 1);
    } else if (_panelOrientation == 'West') {
      return getBlockerType(row, col - 1) ?? getBlockerType(row - 1, col - 1) ?? getBlockerType(row + 1, col - 1);
    }
    return null;
  }

  bool _isCellShaded(int index) {
    return _shadingSourceCell(index) != null;
  }

  double get _totalArea => _panelsCount * _panelAreaM2;
  double get _totalWeight => _panelsCount * _panelWeightKg;

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
          final int r = i ~/ _cols;
          final int c = i % _cols;
          if (_isInSetbackZone(r, c)) {
            continue; // Skip wall setback zone during autofill!
          }
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

  void _autofillSafeSpacesOnly() {
    _saveStateToHistory();
    int addedCount = 0;
    setState(() {
      for (int i = 0; i < _grid.length; i++) {
        if (_grid[i] == CellType.empty) {
          final int r = i ~/ _cols;
          final int c = i % _cols;
          if (_isInSetbackZone(r, c)) {
            continue; // Skip wall setback zone!
          }
          if (_isCellShaded(i)) {
            continue; // Skip shaded cells!
          }
          _grid[i] = CellType.panel;
          addedCount++;
        }
      }
    });

    if (addedCount > 0) {
      ToastService.success(
        context,
        _tr(context, 'Safe Autofill Complete', 'اكتمل الملء التلقائي الآمن'),
        _tr(
          context,
          'Placed $addedCount panels exclusively in verified shade-free safe zones.',
          'تم وضع $addedCount ألواح حصرياً في المناطق الآمنة الخالية من الظلال.',
        ),
      );
    } else {
      ToastService.warning(
        context,
        _tr(context, 'No Safe Spaces Available', 'لا توجد مساحات آمنة متاحة'),
        _tr(
          context,
          'Could not find any empty shade-free zones on the current layout.',
          'لم نتمكن من العثور على أي مناطق فارغة خالية من الظلال في المخطط الحالي.',
        ),
      );
    }
  }

  void _rotateGrid90Clockwise() {
    _saveStateToHistory();
    final int oldRows = _rows;
    final int oldCols = _cols;
    final int newRows = oldCols;
    final int newCols = oldRows;

    final List<CellType> newGrid = List.filled(newRows * newCols, CellType.empty);

    for (int r = 0; r < oldRows; r++) {
      for (int c = 0; c < oldCols; c++) {
        final oldIndex = r * oldCols + c;
        final newRow = c;
        final newCol = oldRows - 1 - r;
        final newIndex = newRow * newCols + newCol;
        newGrid[newIndex] = _grid[oldIndex];
      }
    }

    // Rotate border walls configuration clockwise:
    // Old West (left) -> New North (top)
    // Old North (top) -> New East (right)
    // Old East (right) -> New South (bottom)
    // Old South (bottom) -> New West (left)
    final bool newHasNorth = _hasWestWall;
    final bool newHasEast = _hasNorthWall;
    final bool newHasSouth = _hasEastWall;
    final bool newHasWest = _hasSouthWall;

    final String oldNorthHeight = _northWallController.text;
    final String oldEastHeight = _eastWallController.text;
    final String oldSouthHeight = _southWallController.text;
    final String oldWestHeight = _westWallController.text;

    setState(() {
      _rows = newRows;
      _cols = newCols;
      _grid = newGrid;

      _hasNorthWall = newHasNorth;
      _hasEastWall = newHasEast;
      _hasSouthWall = newHasSouth;
      _hasWestWall = newHasWest;

      _northWallController.text = oldWestHeight;
      _eastWallController.text = oldNorthHeight;
      _southWallController.text = oldEastHeight;
      _westWallController.text = oldSouthHeight;

      // Update actual doubles from controllers
      _northWallHeight = double.tryParse(oldWestHeight) ?? 0.0;
      _eastWallHeight = double.tryParse(oldNorthHeight) ?? 0.0;
      _southWallHeight = double.tryParse(oldEastHeight) ?? 0.0;
      _westWallHeight = double.tryParse(oldSouthHeight) ?? 0.0;
    });

    ToastService.success(
      context,
      _tr(context, 'Layout Rotated 90°', 'تم تدوير المخطط 90 درجة'),
      _tr(context, 'Entire roof grid rotated. Sun ray reflections updated!', 'تم تدوير شبكة السطح بأكملها. تم تحديث انعكاسات أشعة الشمس!'),
    );
  }

  bool _isPointInPolygon(double x, double y, List<Offset> polygon) {
    if (polygon.length < 3) return false;
    bool inside = false;
    int j = polygon.length - 1;
    for (int i = 0; i < polygon.length; i++) {
      if ((polygon[i].dy > y) != (polygon[j].dy > y) &&
          (x < (polygon[j].dx - polygon[i].dx) * (y - polygon[i].dy) / (polygon[j].dy - polygon[i].dy) + polygon[i].dx)) {
        inside = !inside;
      }
      j = i;
    }
    return inside;
  }

  void _applyPolygonSketch() {
    if (_polygonVertices.length < 3) {
      ToastService.warning(
        context,
        _tr(context, 'Incomplete Polygon', 'مضلع غير مكتمل'),
        _tr(context, 'Please sketch at least 3 vertices to define a closed custom roof perimeter.', 'يرجى تحديد 3 نقاط على الأقل لتشكيل حدود سطح مغلقة.'),
      );
      return;
    }

    _saveStateToHistory();

    setState(() {
      for (int r = 0; r < _rows; r++) {
        for (int c = 0; c < _cols; c++) {
          final index = r * _cols + c;
          final inside = _isPointInPolygon(c.toDouble(), r.toDouble(), _polygonVertices);
          if (!inside) {
            _grid[index] = CellType.excluded;
          } else {
            if (_grid[index] == CellType.excluded) {
              _grid[index] = CellType.empty;
            }
          }
        }
      }
      _isPolygonSketchMode = false;
      _polygonVertices.clear();
    });

    ToastService.success(
      context,
      _tr(context, 'Polygon Perimeter Applied', 'تم تطبيق حدود المضلع'),
      _tr(
        context,
        'Custom roof boundary applied! All cells outside your sketched area have been excluded.',
        'تم تطبيق حدود السطح المخصصة! تم استبعاد جميع الخلايا خارج المنطقة المرسومة.',
      ),
    );
  }

  void _clearPolygonSketch() {
    setState(() {
      _polygonVertices.clear();
    });
    ToastService.info(
      context,
      _tr(context, 'Sketch Cleared', 'تم مسح الرسم'),
      _tr(context, 'All sketched vertices have been cleared.', 'تم مسح جميع النقاط المرسومة.'),
    );
  }

  void _cancelPolygonSketchMode() {
    setState(() {
      _isPolygonSketchMode = false;
      _polygonVertices.clear();
    });
  }

  void _alignLayoutToSouth() {
    _saveStateToHistory();
    setState(() {
      _panelOrientation = 'South';
    });
    ToastService.success(
      context,
      _tr(context, 'Oriented to Solar South', 'تم التوجيه نحو الجنوب الشمسي'),
      _tr(
        context,
        'Panel facing direction optimized to true South! Sun ray angles and shadows updated.',
        'تم تحسين اتجاه الألواح نحو الجنوب الحقيقي! تم تحديث زوايا أشعة الشمس والظلال.',
      ),
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
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Column(
            children: [
              _buildLiveStatsRow(),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  child: Column(
                    children: [
                      // Grid dimensions controller
                      _buildDimensionsControl(),

                      SizedBox(height: 14.h),

                      // Boundary Walls & Shading simulation
                      _buildBoundaryWallsControl(),

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

                      SizedBox(height: 14.h),

                      // Premium Layout Sketch & Shading Safety Card
                      _buildLayoutSketchCard(),

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
                    focusNode: _roofWidthFocus,
                    onSubmitted: (_) => _applyFieldValue(_roofWidthController, 'roofWidth'),
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
                    focusNode: _roofLengthFocus,
                    onSubmitted: (_) => _applyFieldValue(_roofLengthController, 'roofLength'),
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

          SizedBox(height: 8.h),

          // Safe Wall Setback clearance boundary input row
          Padding(
            padding: EdgeInsets.symmetric(vertical: 4.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _setbackController,
                    focusNode: _setbackFocus,
                    onSubmitted: (_) => _applyFieldValue(_setbackController, 'setback'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: _tr(context, 'Wall Safe Setback (meters)', 'مسافة الأمان عن الجدار (متر)'),
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
                      title: _tr(context, 'Safe Distance from Roof Borders', 'مسافة الأمان عن أطراف السطح'),
                      description: _tr(
                        context,
                        'Define a safe offset distance (e.g., 0.5m) to keep solar panels away from the roof walls or edges. This safe border zone is highlighted in light amber on the simulator, and the autofill tool will automatically avoid placing panels inside this area to ensure safe maintenance access and prevent high wind loads near parapets.',
                        'حدد مسافة أمان (مثال: 0.5م) لإبقاء الألواح الشمسية بعيدة عن جدران أو حواف السطح. تظهر هذه المنطقة بلون أصفر خفيف في المحاكاة، وسيقوم الملء التلقائي بتجنب وضع ألواح بداخلها لضمان سهولة الصيانة وحماية الألواح من الرياح العاتية.',
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
            decoration: BoxDecoration(color: isDark ? const Color(0xFF1E2624) : const Color(0xFFF0F7F4), borderRadius: BorderRadius.circular(10.r)),
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

  Widget _buildBoundaryWallsControl() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget buildWallItem({
      required String titleEn,
      required String titleAr,
      required bool hasWall,
      required ValueChanged<bool?> onToggle,
      required TextEditingController controller,
      required FocusNode focusNode,
      required String type,
    }) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2624) : const Color(0xFFF7F9F8),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: hasWall ? AppTheme.primaryColor.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: isDark ? 0.08 : 0.12), width: 1.2),
        ),
        child: Row(
          children: [
            Checkbox(
              value: hasWall,
              activeColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
              onChanged: onToggle,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _tr(context, titleEn, titleAr),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11.5.sp,
                      color: hasWall ? AppTheme.primaryColor : (isDark ? Colors.white70 : Colors.black87),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    hasWall ? _tr(context, 'Active & Shading', 'نشط ومظلل') : _tr(context, 'No Wall / Flush mount', 'بدون جدار / تركيب مسطح'),
                    style: TextStyle(fontSize: 9.sp, color: hasWall ? Colors.amber : Colors.grey, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            SizedBox(
              width: 75.w,
              child: TextField(
                enabled: hasWall,
                controller: controller,
                focusNode: focusNode,
                onSubmitted: (_) => _applyFieldValue(controller, type),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: hasWall ? (isDark ? Colors.white : Colors.black87) : Colors.grey),
                decoration: InputDecoration(
                  labelText: _tr(context, 'Height', 'الارتفاع'),
                  labelStyle: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.bold),
                  suffixText: 'm',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h),
                ),
              ),
            ),
          ],
        ),
      );
    }

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
                _tr(context, 'Roof Boundary Walls & Shading Simulation', 'جدران السطح ومحاكاة الظلال'),
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.sp),
              ),
              ExplanationButton(
                explanations: [
                  ExplanationItem(
                    title: _tr(context, 'Optional Walls & Solar Shading', 'الجدران الاختيارية وظلال الشمس'),
                    description: _tr(
                      context,
                      'Toggle boundary walls (North, South, East, West) depending on your roof. Unchecked boundaries will have 0.0 setback clearance (for houses with flush roof mounts). Checked walls simulate physical shadows depending on their height and the panel orientation. Front walls block sun striking face, while back walls cast shadows behind panels and are ignored.',
                      'قم بتفعيل جدران السطح (شمال، جنوب، شرق، غرب) حسب الرغبة. سيتم تطبيق مسافة أمان قدرها 0.0م للحدود غير المفعلة (للمنازل ذات تركيب الألواح المسطح). تحاكي الجدران المفعلة الظلال الفيزيائية للسطح بناءً على ارتفاعها واتجاه الألواح. تحجب الجدران الأمامية أشعة الشمس، بينما تسقط الجدران الخلفية ظلالها خلف الألواح ويتم تجاهلها.',
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12.h),

          Column(
            children: [
              buildWallItem(
                titleEn: 'North Wall (Top Edge)',
                titleAr: 'الجدار الشمالي (الحافة العلوية)',
                hasWall: _hasNorthWall,
                onToggle: (val) {
                  setState(() {
                    _hasNorthWall = val ?? false;
                    _updateGridFromDimensions();
                  });
                },
                controller: _northWallController,
                focusNode: _northWallFocus,
                type: 'northWall',
              ),
              SizedBox(height: 8.h),
              buildWallItem(
                titleEn: 'South Wall (Bottom Edge)',
                titleAr: 'الجدار الجنوبي (الحافة السفلية)',
                hasWall: _hasSouthWall,
                onToggle: (val) {
                  setState(() {
                    _hasSouthWall = val ?? false;
                    _updateGridFromDimensions();
                  });
                },
                controller: _southWallController,
                focusNode: _southWallFocus,
                type: 'southWall',
              ),
              SizedBox(height: 8.h),
              buildWallItem(
                titleEn: 'East Wall (Right Edge)',
                titleAr: 'الجدار الشرقي (الحافة اليمنى)',
                hasWall: _hasEastWall,
                onToggle: (val) {
                  setState(() {
                    _hasEastWall = val ?? false;
                    _updateGridFromDimensions();
                  });
                },
                controller: _eastWallController,
                focusNode: _eastWallFocus,
                type: 'eastWall',
              ),
              SizedBox(height: 8.h),
              buildWallItem(
                titleEn: 'West Wall (Left Edge)',
                titleAr: 'الجدار الغربي (الحافة اليسرى)',
                hasWall: _hasWestWall,
                onToggle: (val) {
                  setState(() {
                    _hasWestWall = val ?? false;
                    _updateGridFromDimensions();
                  });
                },
                controller: _westWallController,
                focusNode: _westWallFocus,
                type: 'westWall',
              ),
            ],
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
              focusNode: _powerFocus,
              onSubmitted: (_) => _applyFieldValue(_powerController, 'power'),
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
                    focusNode: _lengthFocus,
                    onSubmitted: (_) => _applyFieldValue(_lengthController, 'length'),
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
                    focusNode: _widthFocus,
                    onSubmitted: (_) => _applyFieldValue(_widthController, 'width'),
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

          // Panel Orientation Segmented Switch
          Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _tr(context, 'Panel Placement Orientation', 'اتجاه ترتيب الألواح'),
                      style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 4.w),
                    ExplanationButton(
                      explanations: [
                        ExplanationItem(
                          title: _tr(context, 'Panel Layout Placement', 'اتجاه ترتيب الألواح'),
                          description: _tr(
                            context,
                            'Choose how panels are oriented on the roof:\n• Portrait (Vertical): Default vertical orientation.\n• Landscape (Horizontal): Swaps width and height on the grid, perfect to maximize usage of specific roof layouts.',
                            'اختر كيفية توجيه الألواح على السطح:\n• رأسي (Portrait): التوجيه الرأسي الافتراضي.\n• أفقي (Landscape): يعكس العرض والارتفاع على الشبكة، وهو مثالي للاستفادة القصوى من بعض أبعاد الأسطح.',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          if (!_isPortrait) {
                            setState(() {
                              _saveStateToHistory();
                              _isPortrait = true;
                              _updateGridFromDimensions();
                            });
                          }
                        },
                        borderRadius: BorderRadius.circular(10.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          decoration: BoxDecoration(
                            color: _isPortrait ? AppTheme.primaryColor : (isDark ? const Color(0xFF1E2624) : const Color(0xFFF0F7F4)),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(color: _isPortrait ? AppTheme.primaryColor : Colors.grey.withValues(alpha: 0.1)),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Iconsax.document_bold, color: _isPortrait ? Colors.white : (isDark ? Colors.grey : Colors.black87), size: 13.sp),
                                SizedBox(width: 6.w),
                                Text(
                                  _tr(context, 'Portrait (Vertical)', 'رأسي (طولي)'),
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.bold,
                                    color: _isPortrait ? Colors.white : (isDark ? Colors.grey : Colors.black87),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          if (_isPortrait) {
                            setState(() {
                              _saveStateToHistory();
                              _isPortrait = false;
                              _updateGridFromDimensions();
                            });
                          }
                        },
                        borderRadius: BorderRadius.circular(10.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          decoration: BoxDecoration(
                            color: !_isPortrait ? AppTheme.primaryColor : (isDark ? const Color(0xFF1E2624) : const Color(0xFFF0F7F4)),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(color: !_isPortrait ? AppTheme.primaryColor : Colors.grey.withValues(alpha: 0.1)),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                RotatedBox(
                                  quarterTurns: 1,
                                  child: Icon(Iconsax.document_bold, color: !_isPortrait ? Colors.white : (isDark ? Colors.grey : Colors.black87), size: 13.sp),
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  _tr(context, 'Landscape (Horizontal)', 'أفقي (عرضي)'),
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.bold,
                                    color: !_isPortrait ? Colors.white : (isDark ? Colors.grey : Colors.black87),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
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
                  isExpanded: true,
                  initialValue: _panelOrientation,
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
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'North',
                      child: Text(
                        _tr(context, 'North (الشمال)', 'الشمال'),
                        style: TextStyle(fontSize: 11.sp),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'East',
                      child: Text(
                        _tr(context, 'East (الشرق)', 'الشرق'),
                        style: TextStyle(fontSize: 11.sp),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'West',
                      child: Text(
                        _tr(context, 'West (الغرب)', 'الغرب'),
                        style: TextStyle(fontSize: 11.sp),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
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
                      activeThumbColor: AppTheme.primaryColor,
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
              child: _buildToolChip(mode: ToolMode.placeTree, label: _tr(context, 'Tree', 'أشجار'), icon: Icons.park_rounded, activeColor: Colors.green),
            ),
            SizedBox(width: 4.w),
            SizedBox(
              width: 90.w,
              child: _buildToolChip(
                mode: ToolMode.excludeRoof,
                label: _tr(context, 'Exclude', 'حدود السقف'),
                icon: Icons.grid_off_rounded,
                activeColor: Colors.redAccent,
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

    // Calculate actual aspect ratio
    final aspect = _roofLengthM / _roofWidthM;
    final clampedAspect = aspect.clamp(0.4, 1.5);
    final canvasHeight = screenWidth * clampedAspect;

    final gridWidth = screenWidth - 24.r;
    final gridHeight = canvasHeight - 24.r;
    final childAspectRatio = (gridWidth * _rows) / (gridHeight * _cols);

    final canUndo = _undoStack.isNotEmpty;
    final canRedo = _redoStack.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Elegant Canvas control strip with Undo, Redo, and instructions
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
                  _buildCompassOverlayInline(),
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
                        icon: Icon(Icons.draw_rounded, size: 18.sp, color: _isPolygonSketchMode ? Colors.blueAccent : null),
                        tooltip: _tr(context, 'Sketch Custom Roof', 'رسم سقف مخصص'),
                        onPressed: () {
                          setState(() {
                            _isPolygonSketchMode = !_isPolygonSketchMode;
                            if (_isPolygonSketchMode) {
                              _polygonVertices.clear();
                            }
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.explore_rounded, size: 18.sp, color: _panelOrientation == 'South' ? Colors.orangeAccent : null),
                        tooltip: _tr(context, 'Orient South', 'توجيه للجنوب'),
                        onPressed: _alignLayoutToSouth,
                      ),
                      IconButton(
                        icon: Icon(
                          _isSafeOverlayActive ? Icons.wb_sunny_rounded : Icons.wb_sunny_outlined,
                          size: 18.sp,
                          color: _isSafeOverlayActive ? Colors.green : (isDark ? Colors.white60 : Colors.grey[700]),
                        ),
                        tooltip: _tr(context, 'Toggle Safety Heatmap', 'تفعيل خريطة المناطق الآمنة'),
                        onPressed: () {
                          setState(() {
                            _isSafeOverlayActive = !_isSafeOverlayActive;
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.rotate_90_degrees_cw_rounded, size: 18.sp),
                        tooltip: _tr(context, 'Rotate Layout 90°', 'تدوير المخطط 90 درجة'),
                        onPressed: _rotateGrid90Clockwise,
                      ),
                      IconButton(
                        icon: Icon(Icons.undo_rounded, size: 18.sp),
                        tooltip: _tr(context, 'Undo', 'تراجع'),
                        color: canUndo ? AppTheme.primaryColor : Colors.grey.withValues(alpha: 0.4),
                        onPressed: canUndo ? _undo : null,
                      ),
                      IconButton(
                        icon: Icon(Icons.redo_rounded, size: 18.sp),
                        tooltip: _tr(context, 'Redo', 'إعادة'),
                        color: canRedo ? AppTheme.primaryColor : Colors.grey.withValues(alpha: 0.4),
                        onPressed: canRedo ? _redo : null,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        if (_isPolygonSketchMode)
          Container(
            margin: EdgeInsets.only(bottom: 8.h),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
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
                    _tr(context, '📌 Polygon Sketch: Tap cells to place vertices.', '📌 رسم المضلع: اضغط على الخلايا لتحديد الزوايا.'),
                    style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                  ),
                ),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: _applyPolygonSketch,
                      icon: Icon(Icons.check_circle_rounded, size: 14.sp, color: Colors.green),
                      label: Text(
                        _tr(context, 'Apply', 'تطبيق'),
                        style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _clearPolygonSketch,
                      icon: Icon(Icons.refresh_rounded, size: 14.sp, color: Colors.orange),
                      label: Text(
                        _tr(context, 'Reset', 'إعادة'),
                        style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: Colors.orange),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _cancelPolygonSketchMode,
                      icon: Icon(Icons.cancel_rounded, size: 14.sp, color: Colors.red),
                      label: Text(
                        _tr(context, 'Cancel', 'إلغاء'),
                        style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

        // Interactive Visual Drawing Canvas
        GestureDetector(
          onPanStart: (details) => _handlePanStart(details.localPosition, screenWidth, canvasHeight),
          onPanUpdate: (details) => _handlePanUpdate(details.localPosition, screenWidth, canvasHeight),
          child: Container(
            width: screenWidth,
            height: canvasHeight,
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161E1C) : Colors.white,
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 16, offset: Offset(0, 8))],
              border: Border.all(color: Colors.grey.withValues(alpha: isDark ? 0.08 : 0.12), width: 1.4),
            ),
            child: Stack(
              children: [
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _cols,
                    crossAxisSpacing: 6.r,
                    mainAxisSpacing: 6.r,
                    childAspectRatio: childAspectRatio,
                  ),
                  itemCount: _cols * _rows,
                  itemBuilder: (context, index) {
                    final cell = _grid[index];
                    final r = index ~/ _cols;
                    final c = index % _cols;

                    // Safety space heatmap calculation
                    Widget? safetyOverlay;
                    if (_isSafeOverlayActive) {
                      final bool isExcluded = cell == CellType.excluded;
                      final bool isObstacle = cell == CellType.obstacle || cell == CellType.tree;
                      final bool isShaded = _isCellShaded(index);
                      final bool inSetback = _isInSetbackZone(r, c);

                      if (isExcluded) {
                        safetyOverlay = Container(
                          decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.45), borderRadius: BorderRadius.circular(8.r)),
                          child: Center(
                            child: Icon(Icons.close_rounded, color: Colors.white70, size: (120.w / _cols).clamp(8.0, 16.0)),
                          ),
                        );
                      } else if (isObstacle) {
                        safetyOverlay = Container(
                          decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.35), borderRadius: BorderRadius.circular(8.r)),
                          child: Center(
                            child: Icon(Icons.error_outline_rounded, color: Colors.white, size: (120.w / _cols).clamp(8.0, 16.0)),
                          ),
                        );
                      } else if (isShaded) {
                        safetyOverlay = Container(
                          decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.35), borderRadius: BorderRadius.circular(8.r)),
                          child: Center(
                            child: Icon(Icons.wb_cloudy_rounded, color: Colors.white, size: (120.w / _cols).clamp(8.0, 16.0)),
                          ),
                        );
                      } else if (inSetback) {
                        safetyOverlay = Container(
                          decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.35), borderRadius: BorderRadius.circular(8.r)),
                          child: Center(
                            child: Icon(Icons.space_bar_rounded, color: Colors.white, size: (120.w / _cols).clamp(8.0, 16.0)),
                          ),
                        );
                      } else {
                        safetyOverlay = Container(
                          decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.35), borderRadius: BorderRadius.circular(8.r)),
                          child: Center(
                            child: Icon(Icons.check_circle_rounded, color: Colors.white, size: (120.w / _cols).clamp(8.0, 16.0)),
                          ),
                        );
                      }
                    }

                    return GestureDetector(
                      onTap: () => _handleCellTap(index),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: _buildCellDecoration(cell, index),
                              child: Center(child: _buildCellIcon(cell, index)),
                            ),
                          ),
                          if (safetyOverlay != null) Positioned.fill(child: safetyOverlay),
                        ],
                      ),
                    );
                  },
                ),
                if (_isPolygonSketchMode || _polygonVertices.isNotEmpty)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: _PolygonSketchPainter(vertices: _polygonVertices, rows: _rows, cols: _cols),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _handlePanStart(Offset localPosition, double containerWidth, double containerHeight) {
    if (_isPolygonSketchMode) return;
    _draggedIndices.clear();
    _saveStateToHistory(); // Save the state ONCE at the start of the drag stroke!
    _handlePanPaint(localPosition, containerWidth, containerHeight, isStart: true);
  }

  void _handlePanUpdate(Offset localPosition, double containerWidth, double containerHeight) {
    if (_isPolygonSketchMode) return;
    _handlePanPaint(localPosition, containerWidth, containerHeight, isStart: false);
  }

  void _handlePanPaint(Offset localPosition, double containerWidth, double containerHeight, {required bool isStart}) {
    final padding = 12.r;
    final gridWidth = containerWidth - padding * 2;
    final gridHeight = containerHeight - padding * 2;

    final x = localPosition.dx - padding;
    final y = localPosition.dy - padding;

    // Boundary check
    if (x < 0 || x > gridWidth || y < 0 || y > gridHeight) return;

    final cellWidth = gridWidth / _cols;
    final cellHeight = gridHeight / _rows;

    final col = (x / cellWidth).floor().clamp(0, _cols - 1);
    final row = (y / cellHeight).floor().clamp(0, _rows - 1);
    final index = row * _cols + col;

    if (_draggedIndices.contains(index)) return; // Already processed this cell in this stroke!
    _draggedIndices.add(index);

    final currentType = _grid[index];
    CellType targetType = currentType;
    switch (_activeTool) {
      case ToolMode.placePanel:
        if (currentType == CellType.obstacle || currentType == CellType.shadow || currentType == CellType.tree || currentType == CellType.excluded) {
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
      setState(() {
        _grid[index] = targetType;
      });
    }
  }

  BoxDecoration _buildCellDecoration(CellType type, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (type) {
      case CellType.empty:
        final r = index ~/ _cols;
        final c = index % _cols;
        final inSetback = _isInSetbackZone(r, c);
        if (inSetback) {
          return BoxDecoration(
            color: isDark ? const Color(0xFF2C2415) : const Color(0xFFFEF9EB),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: Colors.amber.withValues(alpha: isDark ? 0.35 : 0.5),
              width: 1,
              style: BorderStyle.solid,
            ),
          );
        }
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
        final r = index ~/ _cols;
        final c = index % _cols;
        final inSetback = _isInSetbackZone(r, c);
        final isShaded = _isCellShaded(index);
        if (isShaded) {
          return BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF90A4AE), Color(0xFF607D8B)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(8.r),
            boxShadow: [BoxShadow(color: Colors.orange.withValues(alpha: 0.25), blurRadius: 6, offset: const Offset(0, 2))],
            border: Border.all(color: Colors.orange, width: 2.0),
          );
        }
        if (inSetback) {
          return BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFFFE082), Color(0xFFFFB300)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(8.r),
            boxShadow: [BoxShadow(color: Colors.amber.withValues(alpha: 0.25), blurRadius: 6, offset: const Offset(0, 2))],
            border: Border.all(color: Colors.orangeAccent, width: 2.0),
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
      case CellType.excluded:
        return BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.redAccent.withValues(alpha: 0.15), width: 1.0),
        );
    }
  }

  Widget? _buildCellIcon(CellType type, int index) {
    switch (type) {
      case CellType.empty:
        return null;
      case CellType.panel:
        final isShaded = _isCellShaded(index);
        final r = index ~/ _cols;
        final c = index % _cols;
        final inSetback = _isInSetbackZone(r, c);
        if (isShaded) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Icon(Iconsax.sun_1_bold, color: Colors.white.withValues(alpha: 0.4), size: (180.w / _cols).clamp(12.0, 24.0)),
              Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent, size: (180.w / _cols).clamp(10.0, 20.0)),
            ],
          );
        }
        if (inSetback) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Icon(Iconsax.sun_1_bold, color: Colors.white, size: (180.w / _cols).clamp(12.0, 24.0)),
              Positioned(
                bottom: 0,
                right: 0,
                child: Icon(Icons.warning_amber_rounded, color: Colors.deepOrangeAccent, size: (180.w / _cols).clamp(8.0, 14.0)),
              ),
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
      case CellType.excluded:
        return Icon(Icons.close_rounded, color: Colors.redAccent.withValues(alpha: 0.5), size: (180.w / _cols).clamp(12.0, 24.0));
    }
  }

  double _getCompassAngle() {
    switch (_panelOrientation) {
      case 'North':
        return 0.0;
      case 'East':
        return 3.141592653589793 / 2.0;
      case 'South':
        return 3.141592653589793;
      case 'West':
        return 3.141592653589793 * 1.5;
      default:
        return 3.141592653589793; // Default South
    }
  }

  Widget _buildCompassOverlayInline() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final double angle = _getCompassAngle();

    return Container(
      width: 42.r,
      height: 42.r,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2624) : Colors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.amber.withValues(alpha: isDark ? 0.1 : 0.2), blurRadius: 6, spreadRadius: 1)],
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3), width: 1.2),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Direction indicators (N, S, E, W)
          Positioned(
            top: 2.r,
            child: Text(
              'N',
              style: TextStyle(fontSize: 6.sp, fontWeight: FontWeight.w900, color: Colors.redAccent),
            ),
          ),
          Positioned(
            bottom: 2.r,
            child: Text(
              'S',
              style: TextStyle(fontSize: 6.sp, fontWeight: FontWeight.w900, color: isDark ? Colors.white70 : Colors.black87),
            ),
          ),
          Positioned(
            left: 3.r,
            child: Text(
              'W',
              style: TextStyle(fontSize: 6.sp, fontWeight: FontWeight.w900, color: isDark ? Colors.white70 : Colors.black87),
            ),
          ),
          Positioned(
            right: 3.r,
            child: Text(
              'E',
              style: TextStyle(fontSize: 6.sp, fontWeight: FontWeight.w900, color: isDark ? Colors.white70 : Colors.black87),
            ),
          ),

          // Rotating active Sunlight Ray pointer arrow
          Transform.rotate(
            angle: angle,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_upward_rounded, color: Colors.amber, size: 10.sp),
                SizedBox(height: 6.h),
              ],
            ),
          ),

          // Sun glowing center
          Icon(Iconsax.sun_1_bold, color: Colors.amber, size: 9.sp),
        ],
      ),
    );
  }

  void _handleCellTap(int index) {
    if (_isPolygonSketchMode) {
      final r = index ~/ _cols;
      final c = index % _cols;
      final vertex = Offset(c.toDouble(), r.toDouble());
      setState(() {
        if (_polygonVertices.contains(vertex)) {
          _polygonVertices.remove(vertex);
        } else {
          _polygonVertices.add(vertex);
        }
      });
      return;
    }

    _saveStateToHistory();
    final currentType = _grid[index];
    CellType targetType = currentType;
    switch (_activeTool) {
      case ToolMode.placePanel:
        if (currentType == CellType.obstacle || currentType == CellType.shadow || currentType == CellType.tree || currentType == CellType.excluded) {
          return;
        }
        if (currentType == CellType.panel) {
          targetType = CellType.empty;
        } else {
          targetType = CellType.panel;
        }
        break;
      case ToolMode.placeObstacle:
        if (currentType == CellType.obstacle) {
          targetType = CellType.empty;
        } else {
          targetType = CellType.obstacle;
        }
        break;
      case ToolMode.placeShadow:
        if (currentType == CellType.shadow) {
          targetType = CellType.empty;
        } else {
          targetType = CellType.shadow;
        }
        break;
      case ToolMode.placeTree:
        if (currentType == CellType.tree) {
          targetType = CellType.empty;
        } else {
          targetType = CellType.tree;
        }
        break;
      case ToolMode.excludeRoof:
        if (currentType == CellType.excluded) {
          targetType = CellType.empty;
        } else {
          targetType = CellType.excluded;
        }
        break;
      case ToolMode.erase:
        targetType = CellType.empty;
        break;
    }

    if (currentType != targetType) {
      setState(() {
        _grid[index] = targetType;
      });
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

  Map<String, dynamic> _getFilledArrayStats() {
    int minCol = _cols;
    int maxCol = -1;
    int minRow = _rows;
    int maxRow = -1;
    int shadedPanelsCount = 0;
    int setbackPanelsCount = 0;
    int excludedCellsCount = 0;
    int obstacleCellsCount = 0;
    int treeCellsCount = 0;
    int safeSpacesCount = 0;

    for (int r = 0; r < _rows; r++) {
      for (int c = 0; c < _cols; c++) {
        final index = r * _cols + c;
        final cell = _grid[index];

        if (cell == CellType.panel) {
          if (c < minCol) minCol = c;
          if (c > maxCol) maxCol = c;
          if (r < minRow) minRow = r;
          if (r > maxRow) maxRow = r;

          // Check if this panel cell is shaded
          if (_isCellShaded(index)) {
            shadedPanelsCount++;
          }
          // Check if this panel cell resides in the safe setback clearance zone
          if (_isInSetbackZone(r, c)) {
            setbackPanelsCount++;
          }
        } else if (cell == CellType.excluded) {
          excludedCellsCount++;
        } else if (cell == CellType.obstacle) {
          obstacleCellsCount++;
        } else if (cell == CellType.tree) {
          treeCellsCount++;
        }

        // Calculate potential safe space
        if (cell == CellType.empty) {
          final bool inSetback = _isInSetbackZone(r, c);
          final bool isShaded = _isCellShaded(index);
          if (!inSetback && !isShaded) {
            safeSpacesCount++;
          }
        }
      }
    }

    if (maxCol == -1 || maxRow == -1) {
      return {
        'hasPanels': false,
        'width': 0.0,
        'length': 0.0,
        'area': 0.0,
        'colsCount': 0,
        'rowsCount': 0,
        'shadedCount': 0,
        'setbackCount': 0,
        'excludedCount': excludedCellsCount,
        'obstacleCount': obstacleCellsCount + treeCellsCount,
        'safeSpacesCount': safeSpacesCount,
      };
    }

    final double cellW = _isPortrait ? _panelWidthM : _panelLengthM;
    final double cellH = _isPortrait ? _panelLengthM : _panelWidthM;

    final int colsCount = maxCol - minCol + 1;
    final int rowsCount = maxRow - minRow + 1;
    final double width = colsCount * cellW;
    final double length = rowsCount * cellH;

    return {
      'hasPanels': true,
      'width': width,
      'length': length,
      'area': width * length,
      'colsCount': colsCount,
      'rowsCount': rowsCount,
      'shadedCount': shadedPanelsCount,
      'setbackCount': setbackPanelsCount,
      'excludedCount': excludedCellsCount,
      'obstacleCount': obstacleCellsCount + treeCellsCount,
      'safeSpacesCount': safeSpacesCount,
    };
  }

  Widget _buildLayoutSketchCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stats = _getFilledArrayStats();
    final bool hasPanels = stats['hasPanels'] as bool;

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
                _tr(context, 'Filled Area Sketch & Safety Inspector', 'مخطط مساحة الألواح وفاحص الأمان'),
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.sp),
              ),
              Icon(Iconsax.map_1_bold, color: AppTheme.primaryColor, size: 16.sp),
            ],
          ),
          SizedBox(height: 12.h),

          if (!hasPanels) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E2624) : const Color(0xFFF7F9F8),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.grey.withValues(alpha: isDark ? 0.08 : 0.12)),
              ),
              child: Column(
                children: [
                  Icon(Iconsax.info_circle_bold, color: Colors.orangeAccent, size: 24.sp),
                  SizedBox(height: 6.h),
                  Text(
                    _tr(context, 'No Active Solar Panels Placed Yet', 'لم يتم وضع ألواح شمسية نشطة بعد'),
                    style: TextStyle(fontSize: 11.5.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _tr(
                      context,
                      'Draw or tap panels on the roof grid above. The simulator will automatically sketch the physical array dimensions and audit safety from shadows.',
                      'قم بالرسم أو الضغط على الألواح في شبكة السطح أعلاه. سيقوم المحاكي تلقائيًا بتخطيط أبعاد الألواح المادية وفحص السلامة من الظلال.',
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 9.5.sp, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Sketch Dimension Layout
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sketch graphic of the array
                Expanded(
                  flex: 5,
                  child: Container(
                    padding: EdgeInsets.all(10.r),
                    height: 110.h,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1B2422) : const Color(0xFFF0F5F2),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
                    ),
                    child: Stack(
                      children: [
                        // Bounding Box visual representation
                        Center(
                          child: Container(
                            width: 80.w,
                            height: 60.h,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: AppTheme.primaryColor, width: 1.5),
                            ),
                            child: Center(
                              child: Text(
                                '${stats['colsCount']} × ${stats['rowsCount']}',
                                style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w900, color: AppTheme.primaryColor),
                              ),
                            ),
                          ),
                        ),

                        // Dimensions label pointers
                        // Width label (horizontal, top)
                        Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: EdgeInsets.only(top: 2.h),
                            child: Text(
                              'W: ${(stats['width'] as double).toStringAsFixed(1)}m',
                              style: TextStyle(fontSize: 9.5.sp, fontWeight: FontWeight.w900, color: Colors.grey[600]),
                            ),
                          ),
                        ),
                        // Length label (vertical, left)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.only(left: 2.w),
                            child: Text(
                              'L: ${(stats['length'] as double).toStringAsFixed(1)}m',
                              style: TextStyle(fontSize: 9.5.sp, fontWeight: FontWeight.w900, color: Colors.grey[600]),
                            ),
                          ),
                        ),
                        // Area label (bottom)
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Text(
                            'Area: ${(stats['area'] as double).toStringAsFixed(1)}m²',
                            style: TextStyle(fontSize: 9.5.sp, fontWeight: FontWeight.w900, color: AppTheme.primaryColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 10.w),

                // Safety Inspector Audit results
                Expanded(
                  flex: 6,
                  child: Builder(
                    builder: (context) {
                      final int shaded = stats['shadedCount'] as int;
                      final int setback = stats['setbackCount'] as int;
                      final bool isSafe = shaded == 0 && setback == 0;

                      return Container(
                        padding: EdgeInsets.all(10.r),
                        height: 110.h,
                        decoration: BoxDecoration(
                          color: isSafe
                              ? (isDark ? const Color(0xFF13251E) : const Color(0xFFEDF7F3))
                              : (isDark ? const Color(0xFF281E15) : const Color(0xFFFDF6ED)),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: isSafe ? Colors.green.withValues(alpha: 0.3) : Colors.amber.withValues(alpha: 0.3)),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(isSafe ? Icons.check_circle_rounded : Icons.warning_rounded, color: isSafe ? Colors.green : Colors.amber, size: 14.sp),
                                  SizedBox(width: 4.w),
                                  Expanded(
                                    child: Text(
                                      isSafe
                                          ? _tr(context, 'Optimal & Safe Layout', 'تخطيط آمن ومثالي')
                                          : _tr(context, 'Safety Warnings Found', 'تم العثور على تنبيهات أمان'),
                                      style: TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.bold, color: isSafe ? Colors.green : Colors.amber[800]),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 6.h),
                              if (isSafe) ...[
                                Text(
                                  _tr(
                                    context,
                                    '100% safe from wall shading & roof edges. Performance yield is maximized!',
                                    'آمن 100% من ظلال الجدران وحواف السطح. تم تعظيم كفاءة الإنتاج!',
                                  ),
                                  style: TextStyle(fontSize: 8.5.sp, height: 1.3, color: isDark ? Colors.white70 : Colors.black87),
                                ),
                              ] else ...[
                                if (shaded > 0) ...[
                                  Text(
                                    '⚠️ ${_tr(context, '$shaded panels in high shadow zones (suffer 75% power loss).', '$shaded من الألواح في مناطق ظل كثيفة (تخسر 75% من الطاقة).')}',
                                    style: TextStyle(fontSize: 8.sp, height: 1.3, color: isDark ? Colors.white70 : Colors.black87, fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 3.h),
                                ],
                                if (setback > 0) ...[
                                  Text(
                                    '⚠️ ${_tr(context, '$setback panels are too close to roof edges/active walls.', '$setback من الألواح قريبة جدًا من حواف السطح/الجدران.')}',
                                    style: TextStyle(fontSize: 8.sp, height: 1.3, color: isDark ? Colors.white70 : Colors.black87, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // Metrics row breakdown
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF13201B) : const Color(0xFFEDF7F3),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.green.withValues(alpha: 0.15)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _tr(context, 'Safe Spaces Available', 'المساحات الآمنة المتاحة'),
                          style: TextStyle(fontSize: 8.5.sp, color: Colors.grey[500], fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          '${stats['safeSpacesCount']} ${_tr(context, 'cells', 'خلايا')}',
                          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF261D1D) : const Color(0xFFFDF2F2),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.redAccent.withValues(alpha: 0.15)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _tr(context, 'Excluded Boundaries', 'الحدود المستبعدة'),
                          style: TextStyle(fontSize: 8.5.sp, color: Colors.grey[500], fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          '${stats['excludedCount']} ${_tr(context, 'cells', 'خلايا')}',
                          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.redAccent),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Yield Index & Safety Analytics Card
            Builder(
              builder: (context) {
                final int totalCells = _rows * _cols;
                final int excluded = stats['excludedCount'] as int;
                final int usableCells = totalCells - excluded;
                final int safeSpaces = stats['safeSpacesCount'] as int;

                final double cellW = _isPortrait ? _panelWidthM : _panelLengthM;
                final double cellH = _isPortrait ? _panelLengthM : _panelWidthM;
                final double cellArea = cellW * cellH;

                final double usableArea = usableCells * cellArea;
                final double safeArea = safeSpaces * cellArea;

                final double yieldPercentage = usableCells > 0 ? (safeSpaces / usableCells) * 100 : 0.0;

                Color yieldColor = Colors.redAccent;
                if (yieldPercentage >= 75) {
                  yieldColor = Colors.green;
                } else if (yieldPercentage >= 40) {
                  yieldColor = Colors.orangeAccent;
                }

                return Container(
                  margin: EdgeInsets.only(top: 10.h, bottom: 4.h),
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E2624) : const Color(0xFFF4F7F6),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.15)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _tr(context, 'Net Effective Roof Space', 'مساحة السطح الفعالة الصافية'),
                            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                            decoration: BoxDecoration(color: yieldColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8.r)),
                            child: Text(
                              '${yieldPercentage.toStringAsFixed(0)}% ${_tr(context, 'Yield', 'إنتاجية')}',
                              style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w900, color: yieldColor),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      // Progress/Yield Bar
                      Stack(
                        children: [
                          Container(
                            height: 6.h,
                            width: double.infinity,
                            decoration: BoxDecoration(color: isDark ? Colors.white10 : Colors.grey[300], borderRadius: BorderRadius.circular(3.r)),
                          ),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 500),
                                height: 6.h,
                                width: constraints.maxWidth * (yieldPercentage / 100),
                                decoration: BoxDecoration(color: yieldColor, borderRadius: BorderRadius.circular(3.r)),
                              );
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _tr(context, 'Sketched Usable Roof', 'السطح الصالح للاستخدام'),
                                style: TextStyle(fontSize: 8.5.sp, color: Colors.grey[500]),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                '${usableArea.toStringAsFixed(1)}m² ($usableCells ${_tr(context, 'cells', 'خلايا')})',
                                style: TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _tr(context, 'Shade-Free Safe Zone', 'المنطقة الآمنة الخالية من الظلال'),
                                style: TextStyle(fontSize: 8.5.sp, color: Colors.grey[500]),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                '${safeArea.toStringAsFixed(1)}m² ($safeSpaces ${_tr(context, 'cells', 'خلايا')})',
                                style: TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.bold, color: Colors.green),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

            SizedBox(height: 12.h),

            // Smart Autofill Safe Zones Only Trigger
            SizedBox(
              width: double.infinity,
              height: 38.h,
              child: ElevatedButton.icon(
                onPressed: _autofillSafeSpacesOnly,
                icon: Icon(Icons.verified_user_rounded, size: 16.sp, color: Colors.white),
                label: Text(
                  _tr(context, 'Autofill Safe Zones Only', 'ملء المناطق الآمنة فقط'),
                  style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PolygonSketchPainter extends CustomPainter {
  final List<Offset> vertices;
  final int rows;
  final int cols;

  _PolygonSketchPainter({required this.vertices, required this.rows, required this.cols});

  @override
  void paint(Canvas canvas, Size size) {
    if (vertices.isEmpty) return;

    final colWidth = size.width / cols;
    final rowHeight = size.height / rows;

    final paintLine = Paint()
      ..color = Colors.blueAccent.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final paintLineClosed = Paint()
      ..color = Colors.blueAccent.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Create Path of vertices
    final path = Path();
    for (int i = 0; i < vertices.length; i++) {
      final c = vertices[i].dx;
      final r = vertices[i].dy;
      final point = Offset((c + 0.5) * colWidth, (r + 0.5) * rowHeight);
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }

    canvas.drawPath(path, paintLine);

    // Draw closed dashed/dotted line back to start
    if (vertices.length > 2) {
      final start = Offset((vertices[0].dx + 0.5) * colWidth, (vertices[0].dy + 0.5) * rowHeight);
      final end = Offset((vertices.last.dx + 0.5) * colWidth, (vertices.last.dy + 0.5) * rowHeight);
      canvas.drawLine(start, end, paintLineClosed);
    }

    // Draw vertex handles
    final paintVertex = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    final paintVertexGlow = Paint()
      ..color = Colors.blue.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < vertices.length; i++) {
      final c = vertices[i].dx;
      final r = vertices[i].dy;
      final point = Offset((c + 0.5) * colWidth, (r + 0.5) * rowHeight);

      // Draw glowing background for each vertex
      canvas.drawCircle(point, 10.0, paintVertexGlow);
      // Draw inner solid circle
      canvas.drawCircle(point, 5.0, paintVertex);

      // Draw text overlay index
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${i + 1}',
          style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, point - Offset(textPainter.width / 2, textPainter.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _PolygonSketchPainter oldDelegate) {
    return oldDelegate.vertices != vertices || oldDelegate.rows != rows || oldDelegate.cols != cols;
  }
}
