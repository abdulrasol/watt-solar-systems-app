import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:watt/src/features/pv_system_designer/presentation/controllers/pv_system_designer_controller.dart';
import 'package:watt/src/features/pv_system_designer/presentation/widgets/wizard/wizard_intro_card.dart';
import 'package:watt/src/features/pv_system_designer/presentation/widgets/inputs/section_card.dart';
import 'package:watt/src/features/pv_system_designer/presentation/widgets/sketch/combined_sketch_preview.dart';
import 'package:watt/src/features/offers/presentation/providers/offers_provider.dart';
import 'package:watt/src/utils/app_theme.dart';
import 'package:watt/src/services/toast_service.dart';
import 'package:watt/src/services/pdf_service.dart';
import 'package:watt/src/core/di/get_it.dart';
import 'package:printing/printing.dart';

class ExportStep extends ConsumerWidget {
  const ExportStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(pvSystemDesignerProvider.notifier);
    final state = ref.watch(pvSystemDesignerProvider);
    final isAr = Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';
    final panelsCount = controller.panelsCount;
    final peakPower = controller.peakPower;
    final energy = controller.energyEstimate;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WizardIntroCard(
            icon: Iconsax.export,
            titleEn: 'Sketch & Export',
            titleAr: 'الرسم والتصدير',
            descriptionEn: 'View the combined sketch of your PV system with panel layout, shadows, and structure. Save or share your design.',
            descriptionAr: 'اعرض الرسم المجمع لنظامك الشمسي مع توزيع الألواح والظلال والهيكل. احفظ أو شارك تصميمك.',
          ),
          SizedBox(height: 16.h),
          const CombinedSketchPreview(),
          SizedBox(height: 16.h),
          SectionCard(
            titleEn: 'Design Summary',
            titleAr: 'ملخص التصميم',
            icon: Iconsax.document_text,
            child: Column(
              children: [
                _buildSummaryRow(isAr, 'Solar Panels', 'الألواح الشمسية', '$panelsCount panels'),
                _buildSummaryRow(isAr, 'Peak Output', 'القدرة القصوى', '${peakPower.toStringAsFixed(2)} kWp'),
                if (energy != null) _buildSummaryRow(isAr, 'Annual Energy', 'الطاقة السنوية', '${energy.yearlyKwh.toStringAsFixed(0)} kWh'),
                _buildSummaryRow(isAr, 'Location', 'الموقع', '${state.latitude.toStringAsFixed(2)}°, ${state.longitude.toStringAsFixed(2)}°'),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final nameCtrl = TextEditingController();
                final name = await showDialog<String>(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                    title: Text(isAr ? 'حفظ التصميم' : 'Save Design'),
                    content: TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(labelText: isAr ? 'اسم التصميم' : 'Design Name', hintText: isAr ? 'أدخل اسماً' : 'Enter a name'),
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: Text(isAr ? 'إلغاء' : 'Cancel')),
                      ElevatedButton(onPressed: () => Navigator.pop(context, nameCtrl.text), child: Text(isAr ? 'حفظ' : 'Save')),
                    ],
                  ),
                );
                if (name != null && name.isNotEmpty) {
                  await controller.saveDesign(name);
                  if (context.mounted) {
                    ToastService.success(context, isAr ? 'تم الحفظ بنجاح' : 'Saved Successfully', isAr ? 'تم حفظ التصميم' : 'Design has been saved');
                  }
                }
              },
              icon: const Icon(Iconsax.save_2),
              label: Text(isAr ? 'حفظ التصميم' : 'Save Design'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                try {
                  final pdfData = await getIt<PdfService>().generatePvSystemReport(
                    state: state,
                    panelsCount: panelsCount,
                    peakPowerKwp: peakPower,
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
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: Text(isAr ? 'تحميل تقرير PDF' : 'Download PDF Report'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                side: const BorderSide(color: AppTheme.primaryColor),
                foregroundColor: AppTheme.primaryColor,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: panelsCount <= 0
                  ? null
                  : () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                          title: Text(isAr ? 'طلب عروض أسعار' : 'Request Quotes'),
                          content: Text(
                            isAr
                                ? 'سيتم إرسال ملخص هذا التصميم كطلب حقيقي إلى شركات التركيب في السوق. هل تريد المتابعة؟'
                                : 'This will send a real request with a summary of this design to installer companies on the marketplace. Continue?',
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(isAr ? 'إلغاء' : 'Cancel')),
                            ElevatedButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(isAr ? 'إرسال' : 'Send')),
                          ],
                        ),
                      );
                      if (confirmed != true) return;

                      final data = controller.buildOfferRequestData();
                      final success = await ref.read(offersProvider.notifier).createRequest(data);
                      if (!context.mounted) return;
                      if (success) {
                        ToastService.success(
                          context,
                          isAr ? 'تم إرسال المقترح' : 'Proposal Submitted',
                          isAr ? 'تمت مشاركة مقترحك مع الشركات المزودة' : 'Your proposal has been shared with suppliers.',
                        );
                      } else {
                        ToastService.error(
                          context,
                          isAr ? 'فشل الإرسال' : 'Submission Failed',
                          isAr ? 'تعذر إرسال الطلب، حاول مرة أخرى' : 'Could not send the request. Please try again.',
                        );
                      }
                    },
              icon: const Icon(Iconsax.share),
              label: Text(isAr ? 'مشاركة وطلب عروض' : 'Share & Request Quotes'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                side: const BorderSide(color: AppTheme.primaryColor),
                foregroundColor: AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(bool isAr, String en, String ar, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          Container(
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(color: AppTheme.primaryColor, borderRadius: BorderRadius.circular(2.r)),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              isAr ? ar : en,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
            ),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
