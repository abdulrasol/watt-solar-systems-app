import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/src/utils/app_theme.dart';
import 'package:solar_hub/src/services/toast_service.dart';
import 'package:solar_hub/src/features/roof_simulator/presentation/controllers/roof_simulator_controller.dart';

class ParameterInputsCard extends ConsumerStatefulWidget {
  const ParameterInputsCard({super.key});

  @override
  ConsumerState<ParameterInputsCard> createState() => _ParameterInputsCardState();
}

class _ParameterInputsCardState extends ConsumerState<ParameterInputsCard> {
  late TextEditingController _powerController;
  late TextEditingController _lengthController;
  late TextEditingController _widthController;
  late TextEditingController _roofWidthController;
  late TextEditingController _roofLengthController;
  late TextEditingController _setbackController;

  late FocusNode _powerFocus;
  late FocusNode _lengthFocus;
  late FocusNode _widthFocus;
  late FocusNode _roofWidthFocus;
  late FocusNode _roofLengthFocus;
  late FocusNode _setbackFocus;

  bool _isArabic(BuildContext context) =>
      Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';

  String _tr(BuildContext context, String en, String ar) {
    return _isArabic(context) ? ar : en;
  }

  @override
  void initState() {
    super.initState();
    final state = ref.read(roofSimulatorProvider);

    _powerController = TextEditingController(text: state.panelPowerW.toStringAsFixed(0));
    _lengthController = TextEditingController(text: state.panelLengthM.toStringAsFixed(2));
    _widthController = TextEditingController(text: state.panelWidthM.toStringAsFixed(2));
    _roofWidthController = TextEditingController(text: state.roofWidthM.toStringAsFixed(1));
    _roofLengthController = TextEditingController(text: state.roofLengthM.toStringAsFixed(1));
    _setbackController = TextEditingController(text: state.wallSetbackM.toStringAsFixed(2));

    _powerFocus = FocusNode()..addListener(() => _onFocusChanged(_powerFocus, 'power'));
    _lengthFocus = FocusNode()..addListener(() => _onFocusChanged(_lengthFocus, 'length'));
    _widthFocus = FocusNode()..addListener(() => _onFocusChanged(_widthFocus, 'width'));
    _roofWidthFocus = FocusNode()..addListener(() => _onFocusChanged(_roofWidthFocus, 'roofWidth'));
    _roofLengthFocus = FocusNode()..addListener(() => _onFocusChanged(_roofLengthFocus, 'roofLength'));
    _setbackFocus = FocusNode()..addListener(() => _onFocusChanged(_setbackFocus, 'setback'));
  }

  @override
  void dispose() {
    _powerController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
    _roofWidthController.dispose();
    _roofLengthController.dispose();
    _setbackController.dispose();

    _powerFocus.dispose();
    _lengthFocus.dispose();
    _widthFocus.dispose();
    _roofWidthFocus.dispose();
    _roofLengthFocus.dispose();
    _setbackFocus.dispose();
    super.dispose();
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

    if (parsed == null || parsed < 0 || (parsed == 0 && type != 'setback')) {
      double oldVal = 0.0;
      switch (type) {
        case 'power':
          oldVal = state.panelPowerW;
          break;
        case 'length':
          oldVal = state.panelLengthM;
          break;
        case 'width':
          oldVal = state.panelWidthM;
          break;
        case 'roofWidth':
          oldVal = state.roofWidthM;
          break;
        case 'roofLength':
          oldVal = state.roofLengthM;
          break;
        case 'setback':
          oldVal = state.wallSetbackM;
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
    String errorEn = '';
    String errorAr = '';

    switch (type) {
      case 'power':
        if (parsed < 10 || parsed > 2000) {
          isValid = false;
          errorEn = 'Power must be between 10W and 2000W.';
          errorAr = 'يجب أن تكون القدرة بين 10 واط و 2000 واط.';
        }
        break;
      case 'length':
        if (parsed < 0.2 || parsed > 5.0) {
          isValid = false;
          errorEn = 'Panel length must be between 0.2m and 5.0m.';
          errorAr = 'يجب أن يكون طول اللوح بين 0.2م و 5.0م.';
        }
        break;
      case 'width':
        if (parsed < 0.2 || parsed > 5.0) {
          isValid = false;
          errorEn = 'Panel width must be between 0.2m and 5.0m.';
          errorAr = 'يجب أن يكون عرض اللوح بين 0.2م و 5.0م.';
        }
        break;
      case 'roofWidth':
        if (parsed < 2.0 || parsed > 150.0) {
          isValid = false;
          errorEn = 'Roof width must be between 2.0m and 150.0m.';
          errorAr = 'يجب أن يكون عرض السقف بين 2.0م و 150.0م.';
        }
        break;
      case 'roofLength':
        if (parsed < 2.0 || parsed > 150.0) {
          isValid = false;
          errorEn = 'Roof length must be between 2.0m and 150.0m.';
          errorAr = 'يجب أن يكون طول السقف بين 2.0م و 150.0م.';
        }
        break;
      case 'setback':
        if (parsed < 0.0 || parsed > 5.0) {
          isValid = false;
          errorEn = 'Safety setback must be between 0.0m and 5.0m.';
          errorAr = 'يجب أن يكون الارتداد الجانبي بين 0.0م و 5.0م.';
        }
        break;
    }

    if (!isValid) {
      double oldVal = 0.0;
      switch (type) {
        case 'power':
          oldVal = state.panelPowerW;
          break;
        case 'length':
          oldVal = state.panelLengthM;
          break;
        case 'width':
          oldVal = state.panelWidthM;
          break;
        case 'roofWidth':
          oldVal = state.roofWidthM;
          break;
        case 'roofLength':
          oldVal = state.roofLengthM;
          break;
        case 'setback':
          oldVal = state.wallSetbackM;
          break;
      }
      controller.text = oldVal.toString();
      ToastService.warning(
        context,
        _tr(context, 'Limit Exceeded', 'تجاوز الحدود'),
        _tr(context, errorEn, errorAr),
      );
      return;
    }

    switch (type) {
      case 'power':
        notifier.updatePanelSpecifications(powerW: parsed);
        break;
      case 'length':
        notifier.updatePanelSpecifications(lengthM: parsed);
        break;
      case 'width':
        notifier.updatePanelSpecifications(widthM: parsed);
        break;
      case 'roofWidth':
        notifier.updateRoofDimensions(parsed, state.roofLengthM);
        break;
      case 'roofLength':
        notifier.updateRoofDimensions(state.roofWidthM, parsed);
        break;
      case 'setback':
        notifier.updateWallSetback(parsed);
        break;
    }
  }

  TextEditingController _getController(String type) {
    switch (type) {
      case 'power': return _powerController;
      case 'length': return _lengthController;
      case 'width': return _widthController;
      case 'roofWidth': return _roofWidthController;
      case 'roofLength': return _roofLengthController;
      case 'setback': return _setbackController;
      default: return _powerController;
    }
  }

  void _showExplanationDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(content),
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
          // Elegant Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _tr(context, 'Specifications & Dimensions', 'المواصفات والأبعاد'),
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.sp),
              ),
              Icon(Iconsax.setting_2_bold, color: AppTheme.primaryColor, size: 16.sp),
            ],
          ),
          SizedBox(height: 12.h),

          // 1. Panel Specifications Section
          Text(
            _tr(context, '1. Solar Panel Specifications', '1. مواصفات الألواح الشمسية'),
            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w900, color: AppTheme.primaryColor),
          ),
          SizedBox(height: 8.h),
          TextField(
            controller: _powerController,
            focusNode: _powerFocus,
            onSubmitted: (_) => _applyValue('power'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              labelText: _tr(context, 'Rated Power (Watts)', 'القدرة المقدرة (واط)'),
              labelStyle: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
              suffixText: 'W',
              suffixStyle: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
              contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _lengthController,
                  focusNode: _lengthFocus,
                  onSubmitted: (_) => _applyValue('length'),
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
                  onSubmitted: (_) => _applyValue('width'),
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
              IconButton(
                icon: const Icon(Icons.info_outline_rounded, color: Colors.blueAccent),
                onPressed: () {
                  _showExplanationDialog(
                    _tr(context, 'Solar Panel Dimensions', 'أبعاد اللوح الشمسي'),
                    _tr(
                      context,
                      'Enter the exact physical length and width of a single solar panel in meters. These dimensions are multiplied to calculate the occupied surface area per panel (default: 2.2m x 1.1m = 2.42 m²).',
                      'أدخل الطول والعرض الفعليين للوح الشمسي الواحد بالمتر. يتم ضرب هذه الأبعاد لحساب مساحة السطح التي يشغلها كل لوح تلقائيًا (الافتراضي: 2.2 م × 1.1 م = 2.42 م²).',
                    ),
                  );
                },
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // 2. Roof Specifications Section
          Text(
            _tr(context, '2. Roof Perimeter Dimensions', '2. أبعاد محيط السطح'),
            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w900, color: AppTheme.primaryColor),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _roofWidthController,
                  focusNode: _roofWidthFocus,
                  onSubmitted: (_) => _applyValue('roofWidth'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    labelText: _tr(context, 'Roof Width (E-W)', 'عرض السطح (شرق-غرب)'),
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
                  onSubmitted: (_) => _applyValue('roofLength'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    labelText: _tr(context, 'Roof Length (N-S)', 'طول السطح (شمال-جنوب)'),
                    labelStyle: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                    suffixText: 'm',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.info_outline_rounded, color: Colors.blueAccent),
                onPressed: () {
                  _showExplanationDialog(
                    _tr(context, 'Roof Perimeter Dimensions', 'أبعاد محيط السطح'),
                    _tr(
                      context,
                      'Defines the outer boundaries of the rectangular solar canvas. The simulator auto-tiles standard cells based on active panel orientation.',
                      'يحدد الحدود الخارجية للوحة السقف الشمسية المستطيلة. يقوم جهاز المحاكاة بتقسيم الخلايا تلقائيًا بناءً على اتجاه اللوح النشط.',
                    ),
                  );
                },
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // 3. Setback Clearances
          Text(
            _tr(context, '3. Safety Boundaries Setback', '3. الارتداد الوقائي للحدود'),
            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w900, color: AppTheme.primaryColor),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _setbackController,
                  focusNode: _setbackFocus,
                  onSubmitted: (_) => _applyValue('setback'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    labelText: _tr(context, 'Boundary Clearance Setback', 'ارتداد هامش السلامة للحدود'),
                    labelStyle: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                    suffixText: 'm',
                    contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.info_outline_rounded, color: Colors.blueAccent),
                onPressed: () {
                  _showExplanationDialog(
                    _tr(context, 'Safety Boundaries Setback', 'ارتداد هامش السلامة للحدود'),
                    _tr(
                      context,
                      'Safety distance from the parapet/edge walls (setbacks) where panels should not be installed for maintenance and wind loads safety.',
                      'مسافة الأمان والارتدادات الوقائية الموصى بتركها فارغة من أطراف جدران السطح لضمان سهولة الصيانة ومقاومة الرياح.',
                    ),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Panel Orientation orientation toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _tr(context, 'Orientation Placement', 'اتجاه تركيب الألواح'),
                style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  ChoiceChip(
                    label: Text(_tr(context, 'Portrait', 'رأسي')),
                    selected: simulator.isPortrait,
                    onSelected: (val) {
                      ref.read(roofSimulatorProvider.notifier).updatePortrait(true);
                    },
                  ),
                  SizedBox(width: 8.w),
                  ChoiceChip(
                    label: Text(_tr(context, 'Landscape', 'أفقي')),
                    selected: !simulator.isPortrait,
                    onSelected: (val) {
                      ref.read(roofSimulatorProvider.notifier).updatePortrait(false);
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
