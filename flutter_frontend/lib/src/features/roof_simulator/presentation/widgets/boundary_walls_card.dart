import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watt/src/utils/app_theme.dart';
import 'package:watt/src/services/toast_service.dart';
import 'package:watt/src/features/roof_simulator/presentation/controllers/roof_simulator_controller.dart';

class BoundaryWallsCard extends ConsumerStatefulWidget {
  const BoundaryWallsCard({super.key});

  @override
  ConsumerState<BoundaryWallsCard> createState() => _BoundaryWallsCardState();
}

class _BoundaryWallsCardState extends ConsumerState<BoundaryWallsCard> {
  late TextEditingController _northWallController;
  late TextEditingController _southWallController;
  late TextEditingController _eastWallController;
  late TextEditingController _westWallController;

  late FocusNode _northWallFocus;
  late FocusNode _southWallFocus;
  late FocusNode _eastWallFocus;
  late FocusNode _westWallFocus;

  bool _isArabic(BuildContext context) =>
      Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';

  String _tr(BuildContext context, String en, String ar) {
    return _isArabic(context) ? ar : en;
  }

  @override
  void initState() {
    super.initState();
    final state = ref.read(roofSimulatorProvider);

    _northWallController = TextEditingController(text: state.northWallHeight.toStringAsFixed(1));
    _southWallController = TextEditingController(text: state.southWallHeight.toStringAsFixed(1));
    _eastWallController = TextEditingController(text: state.eastWallHeight.toStringAsFixed(1));
    _westWallController = TextEditingController(text: state.westWallHeight.toStringAsFixed(1));

    _northWallFocus = FocusNode()..addListener(() => _onFocusChanged(_northWallFocus, 'northWall'));
    _southWallFocus = FocusNode()..addListener(() => _onFocusChanged(_southWallFocus, 'southWall'));
    _eastWallFocus = FocusNode()..addListener(() => _onFocusChanged(_eastWallFocus, 'eastWall'));
    _westWallFocus = FocusNode()..addListener(() => _onFocusChanged(_westWallFocus, 'westWall'));
  }

  @override
  void dispose() {
    _northWallController.dispose();
    _southWallController.dispose();
    _eastWallController.dispose();
    _westWallController.dispose();

    _northWallFocus.dispose();
    _southWallFocus.dispose();
    _eastWallFocus.dispose();
    _westWallFocus.dispose();
    super.dispose();
  }

  // Synergize height text inputs with wall updates
  @override
  void didUpdateWidget(covariant BoundaryWallsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final state = ref.read(roofSimulatorProvider);
    _syncTextIfUnfocused(_northWallController, _northWallFocus, state.northWallHeight);
    _syncTextIfUnfocused(_southWallController, _southWallFocus, state.southWallHeight);
    _syncTextIfUnfocused(_eastWallController, _eastWallFocus, state.eastWallHeight);
    _syncTextIfUnfocused(_westWallController, _westWallFocus, state.westWallHeight);
  }

  void _syncTextIfUnfocused(TextEditingController controller, FocusNode node, double val) {
    if (!node.hasFocus) {
      final String formatted = val.toStringAsFixed(1);
      if (controller.text != formatted) {
        controller.text = formatted;
      }
    }
  }

  void _onFocusChanged(FocusNode focus, String type) {
    if (!focus.hasFocus) {
      _applyValue(type);
    }
  }

  void _applyValue(String type) {
    final controller = _getController(type);
    final text = controller.text.trim();
    final parsed = double.tryParse(text);
    final state = ref.read(roofSimulatorProvider);
    final notifier = ref.read(roofSimulatorProvider.notifier);

    if (parsed == null || parsed < 0) {
      double oldVal = 0.0;
      switch (type) {
        case 'northWall': oldVal = state.northWallHeight; break;
        case 'southWall': oldVal = state.southWallHeight; break;
        case 'eastWall': oldVal = state.eastWallHeight; break;
        case 'westWall': oldVal = state.westWallHeight; break;
      }
      controller.text = oldVal.toStringAsFixed(1);
      ToastService.warning(
        context,
        _tr(context, 'Invalid Input', 'مدخل غير صالح'),
        _tr(context, 'Please enter a valid wall height.', 'يرجى إدخال ارتفاع جدار صالح.'),
      );
      return;
    }

    if (parsed > 10.0) {
      double oldVal = 0.0;
      switch (type) {
        case 'northWall': oldVal = state.northWallHeight; break;
        case 'southWall': oldVal = state.southWallHeight; break;
        case 'eastWall': oldVal = state.eastWallHeight; break;
        case 'westWall': oldVal = state.westWallHeight; break;
      }
      controller.text = oldVal.toStringAsFixed(1);
      ToastService.warning(
        context,
        _tr(context, 'Height Exceeded', 'تجاوز الارتفاع الأقصى'),
        _tr(context, 'Maximum shadow wall height is 10.0m.', 'الارتفاع الأقصى لجدران محاكاة الظلال هو 10.0م.'),
      );
      return;
    }

    switch (type) {
      case 'northWall':
        notifier.updateWallHeights(north: parsed);
        break;
      case 'southWall':
        notifier.updateWallHeights(south: parsed);
        break;
      case 'eastWall':
        notifier.updateWallHeights(east: parsed);
        break;
      case 'westWall':
        notifier.updateWallHeights(west: parsed);
        break;
    }
  }

  TextEditingController _getController(String type) {
    switch (type) {
      case 'northWall': return _northWallController;
      case 'southWall': return _southWallController;
      case 'eastWall': return _eastWallController;
      case 'westWall': return _westWallController;
      default: return _northWallController;
    }
  }

  Widget _buildWallItem({
    required String titleEn,
    required String titleAr,
    required bool hasWall,
    required ValueChanged<bool?> onToggle,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String type,
    required bool isDark,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2624) : const Color(0xFFF7F9F8),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: hasWall
              ? AppTheme.primaryColor.withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: isDark ? 0.08 : 0.12),
          width: 1.2,
        ),
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
                    color: hasWall
                        ? AppTheme.primaryColor
                        : (isDark ? Colors.white70 : Colors.black87),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  hasWall
                      ? _tr(context, 'Active & Shading', 'نشط ومظلل')
                      : _tr(context, 'No Wall / Flush mount', 'بدون جدار / تركيب مسطح'),
                  style: TextStyle(
                    fontSize: 9.sp,
                    color: hasWall ? Colors.amber : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
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
              onSubmitted: (_) => _applyValue(type),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: hasWall
                    ? (isDark ? Colors.white : Colors.black87)
                    : Colors.grey,
              ),
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

  void _showExplanationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          _tr(context, 'Optional Walls & Solar Shading', 'الجدران الاختيارية وظلال الشمس'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          _tr(
            context,
            'Toggle boundary walls (North, South, East, West) depending on your roof. Unchecked boundaries will have 0.0 setback clearance (for houses with flush roof mounts). Checked walls simulate physical shadows depending on their height and the panel orientation. Front walls block sun striking face, while back walls cast shadows behind panels and are ignored.',
            'قم بتفعيل جدران السطح (شمال، جنوب، شرق، غرب) حسب الرغبة. سيتم تطبيق مسافة أمان قدرها 0.0م للحدود غير المفعلة (للمنازل ذات تركيب الألواح المسطح). تحاكي الجدران المفعلة الظلال الفيزيائية للسطح بناءً على ارتفاعها واتجاه الألواح. تحجب الجدران الأمامية أشعة الشمس، بينما تسقط الجدران الخلفية ظلالها خلف الألواح ويتم تجاهلها.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_tr(context, 'Close', 'إغلاق')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final simulator = ref.watch(roofSimulatorProvider);
    final notifier = ref.read(roofSimulatorProvider.notifier);

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161E1C) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Colors.grey.withValues(alpha: isDark ? 0.08 : 0.12),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _tr(context, 'Roof Boundary Walls & Shading', 'جدران السطح والظلال'),
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.sp),
              ),
              IconButton(
                icon: const Icon(Icons.info_outline_rounded, color: Colors.blueAccent),
                onPressed: _showExplanationDialog,
              ),
            ],
          ),
          SizedBox(height: 12.h),

          _buildWallItem(
            titleEn: 'North Wall (Top Edge)',
            titleAr: 'الجدار الشمالي (الحافة العلوية)',
            hasWall: simulator.hasNorthWall,
            onToggle: (val) {
              notifier.updateWallToggles(north: val ?? false);
            },
            controller: _northWallController,
            focusNode: _northWallFocus,
            type: 'northWall',
            isDark: isDark,
          ),
          SizedBox(height: 8.h),
          _buildWallItem(
            titleEn: 'South Wall (Bottom Edge)',
            titleAr: 'الجدار الجنوبي (الحافة السفلية)',
            hasWall: simulator.hasSouthWall,
            onToggle: (val) {
              notifier.updateWallToggles(south: val ?? false);
            },
            controller: _southWallController,
            focusNode: _southWallFocus,
            type: 'southWall',
            isDark: isDark,
          ),
          SizedBox(height: 8.h),
          _buildWallItem(
            titleEn: 'East Wall (Right Edge)',
            titleAr: 'الجدار الشرقي (الحافة اليمنى)',
            hasWall: simulator.hasEastWall,
            onToggle: (val) {
              notifier.updateWallToggles(east: val ?? false);
            },
            controller: _eastWallController,
            focusNode: _eastWallFocus,
            type: 'eastWall',
            isDark: isDark,
          ),
          SizedBox(height: 8.h),
          _buildWallItem(
            titleEn: 'West Wall (Left Edge)',
            titleAr: 'الجدار الغربي (الحافة اليسرى)',
            hasWall: simulator.hasWestWall,
            onToggle: (val) {
              notifier.updateWallToggles(west: val ?? false);
            },
            controller: _westWallController,
            focusNode: _westWallFocus,
            type: 'westWall',
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}
