import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:watt/src/features/pv_system_designer/domain/entities/frame_result.dart';
import 'package:watt/src/features/pv_system_designer/domain/entities/pv_system_design_state.dart';
import 'package:watt/src/features/pv_system_designer/presentation/controllers/pv_system_designer_controller.dart';
import 'package:watt/src/features/pv_system_designer/presentation/widgets/sketch/frame_sketch_painter.dart';
import 'package:watt/src/utils/app_theme.dart';
import 'package:watt/src/core/di/get_it.dart';
import 'package:watt/src/services/pdf_service.dart';
import 'package:watt/src/services/toast_service.dart';
import 'package:printing/printing.dart';

class TechnicalSketchPage extends ConsumerStatefulWidget {
  const TechnicalSketchPage({super.key});

  @override
  ConsumerState<TechnicalSketchPage> createState() => _TechnicalSketchPageState();
}

class _TechnicalSketchPageState extends ConsumerState<TechnicalSketchPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool _isArabic(BuildContext context) => Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pvSystemDesignerProvider);
    final controller = ref.read(pvSystemDesignerProvider.notifier);
    final isAr = _isArabic(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final frameResult = controller.frameResult;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isAr ? 'الرسومات التقنية' : 'Technical Drawings',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16.sp),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: isDark ? Colors.white60 : Colors.grey,
          indicatorColor: AppTheme.primaryColor,
          tabs: [
            Tab(text: isAr ? 'علوي' : 'Top'),
            Tab(text: isAr ? 'جانبي' : 'Side'),
            Tab(text: isAr ? 'أمامي' : 'Front'),
            Tab(text: isAr ? 'ثلاثي' : '3D'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.export),
            onPressed: () async {
              try {
                final pdfData = await getIt<PdfService>().generatePvSystemReport(
                  state: state,
                  panelsCount: controller.panelsCount,
                  peakPowerKwp: controller.peakPower,
                  totalAreaM2: controller.totalArea,
                  totalWeightKg: controller.totalWeight,
                  frameResult: controller.frameResult,
                  energyEstimate: controller.energyEstimate,
                  stringSizing: controller.stringSizingResult,
                  financialEstimate: controller.financialEstimate,
                );
                await Printing.layoutPdf(onLayout: (format) async => pdfData, name: 'PV_System_Design_Report.pdf');
              } catch (e) {
                if (context.mounted) {
                  ToastService.error(context, isAr ? 'فشل التصدير' : 'Export Failed', isAr ? 'تعذر إنشاء ملف PDF' : 'Could not generate the PDF report.');
                }
              }
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _SketchView(state: state, frameResult: frameResult, isDark: isDark, viewMode: SketchViewMode.top),
          _SketchView(state: state, frameResult: frameResult, isDark: isDark, viewMode: SketchViewMode.side),
          _SketchView(state: state, frameResult: frameResult, isDark: isDark, viewMode: SketchViewMode.front),
          _SketchView(state: state, frameResult: frameResult, isDark: isDark, viewMode: SketchViewMode.isometric),
        ],
      ),
      bottomNavigationBar: _DimensionsPanel(state: state, frameResult: frameResult, isAr: isAr, isDark: isDark),
    );
  }
}

class _SketchView extends StatelessWidget {
  final PvSystemDesignState state;
  final FrameResult? frameResult;
  final bool isDark;
  final SketchViewMode viewMode;

  const _SketchView({required this.state, required this.frameResult, required this.isDark, required this.viewMode});

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 4.0,
      child: Container(
        color: isDark ? const Color(0xFF1A2220) : const Color(0xFFF8FAF9),
        child: CustomPaint(
          size: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height - 200),
          painter: FrameSketchPainter(state: state, frameResult: frameResult, isDark: isDark, viewMode: viewMode),
        ),
      ),
    );
  }
}

class _DimensionsPanel extends StatelessWidget {
  final PvSystemDesignState state;
  final FrameResult? frameResult;
  final bool isAr;
  final bool isDark;

  const _DimensionsPanel({required this.state, required this.frameResult, required this.isAr, required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (frameResult == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2624) : Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildDimChip(isAr, 'الألواح', 'Panels', '${state.grid.where((c) => c == CellType.panel).length}'),
              SizedBox(width: 8.w),
              _buildDimChip(isAr, 'الصفوف', 'Rows', '${frameResult!.rows}'),
              SizedBox(width: 8.w),
              _buildDimChip(isAr, 'الأعمدة', 'Cols', '${frameResult!.columns}'),
              SizedBox(width: 8.w),
              _buildDimChip(isAr, 'الميل', 'Tilt', '${frameResult!.appliedTiltDegrees.toStringAsFixed(0)}°'),
              SizedBox(width: 8.w),
              _buildDimChip(isAr, 'العرض', 'Width', '${frameResult!.frameWidthMeters.toStringAsFixed(1)}m'),
              SizedBox(width: 8.w),
              _buildDimChip(isAr, 'الحديد', 'Steel', '${frameResult!.totalSteelLengthMeters.toStringAsFixed(0)}m'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDimChip(bool isAr, String arLabel, String enLabel, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$value ',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12.sp, color: AppTheme.primaryColor),
          ),
          Text(
            isAr ? arLabel : enLabel,
            style: TextStyle(fontSize: 10.sp, color: isDark ? Colors.white70 : Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}
