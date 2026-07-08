import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:watt/src/features/accounting/domain/entities/accounting_models.dart';
import 'package:watt/src/utils/price_format_utils.dart';
import 'package:watt/src/features/pv_system_designer/domain/entities/pv_system_design_state.dart';
import 'package:watt/src/features/pv_system_designer/domain/entities/frame_result.dart';
import 'package:watt/src/features/pv_system_designer/domain/entities/energy_estimate.dart';
import 'package:watt/src/features/pv_system_designer/domain/entities/inverter_spec.dart';
import 'package:watt/src/features/pv_system_designer/domain/entities/financial_estimate.dart';

class PdfService {
  Future<Uint8List> generateInvoice({
    required InvoiceRecord invoice,
    Map<String, dynamic>? sellerInfo,
    String? currencySymbol,
  }) async {
    final pdf = pw.Document();

    // Load Fonts via GoogleFonts (Network)
    // Cairo has excellent Arabic and Latin support
    final ttf = await PdfGoogleFonts.cairoRegular();
    final ttfBold = await PdfGoogleFonts.cairoBold();

    final symbol = currencySymbol ?? r'$';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData(
          defaultTextStyle: pw.TextStyle(font: ttf, fontFallback: [ttf]),
        ),
        build: (pw.Context context) {
          final boldStyle = pw.TextStyle(
            font: ttfBold,
            fontWeight: pw.FontWeight.bold,
            fontFallback: [ttfBold],
          );

          return pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // 1. Header (Seller & Title)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          sellerInfo?['name'] ?? 'SolarHub Company',
                          style: boldStyle.copyWith(fontSize: 20),
                        ),
                        if (sellerInfo?['address'] != null)
                          pw.Text(sellerInfo!['address']),
                        if (sellerInfo?['phone'] != null)
                          pw.Text(
                            sellerInfo!['phone'],
                            textDirection: pw.TextDirection.ltr,
                          ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'INVOICE',
                          style: boldStyle.copyWith(
                            fontSize: 30,
                            color: PdfColors.blue900,
                          ),
                        ),
                        pw.Text(
                          '#${invoice.invoiceNumber}',
                          style: const pw.TextStyle(fontSize: 14),
                        ),
                        pw.Text(invoice.issueDate),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 30),

                // 2. Bill To
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                  width: double.infinity,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('BILL TO', style: boldStyle),
                      pw.Text(invoice.customer.name, style: boldStyle),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // 3. Totals
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Container(
                      width: 250,
                      child: pw.Column(
                        children: [
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('Total Amount', style: boldStyle),
                              pw.Text(
                                invoice.totalAmount.toPriceWithCurrency(symbol),
                                style: boldStyle,
                              ),
                            ],
                          ),
                          pw.SizedBox(height: 5),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('Paid Amount', style: boldStyle),
                              pw.Text(
                                invoice.paidAmount.toPriceWithCurrency(symbol),
                                style: boldStyle,
                              ),
                            ],
                          ),
                          pw.Divider(),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(
                                'Balance Due',
                                style: boldStyle.copyWith(
                                  color:
                                      invoice.balanceDue > 0
                                          ? PdfColors.red
                                          : PdfColors.black,
                                ),
                              ),
                              pw.Text(
                                invoice.balanceDue.toPriceWithCurrency(symbol),
                                style: boldStyle.copyWith(
                                  color:
                                      invoice.balanceDue > 0
                                          ? PdfColors.red
                                          : PdfColors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                pw.Spacer(),
                pw.Divider(color: PdfColors.grey300),
                pw.Center(
                  child: pw.Text(
                    'Thank you for your business!',
                    style: const pw.TextStyle(
                      color: PdfColors.grey600,
                      fontSize: 10,
                    ),
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Center(
                  child: pw.Text(
                    'Generated by SolarHub B2B Platform',
                    style: const pw.TextStyle(
                      color: PdfColors.grey400,
                      fontSize: 8,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  Future<void> printPdf(Uint8List pdfData) async {
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdfData);
  }

  /// Builds a real PDF summary of a PV System Designer design — panel
  /// layout, structural design, energy estimate, loss diagram, string
  /// sizing, and bill of materials. Replaces what was previously a
  /// "Coming soon" placeholder in the technical sketch viewer.
  Future<Uint8List> generatePvSystemReport({
    required PvSystemDesignState state,
    required int panelsCount,
    required double peakPowerKwp,
    required double totalAreaM2,
    required double totalWeightKg,
    FrameResult? frameResult,
    EnergyEstimate? energyEstimate,
    StringSizingResult? stringSizing,
    FinancialEstimate? financialEstimate,
  }) async {
    final pdf = pw.Document();
    final ttf = await PdfGoogleFonts.cairoRegular();
    final ttfBold = await PdfGoogleFonts.cairoBold();
    final boldStyle = pw.TextStyle(font: ttfBold, fontWeight: pw.FontWeight.bold, fontFallback: [ttfBold]);
    const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    pw.Widget kv(String k, String v) => pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 2),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [pw.Text(k, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)), pw.Text(v, style: pw.TextStyle(fontSize: 10, font: ttfBold, fontWeight: pw.FontWeight.bold))],
          ),
        );

    pw.Widget sectionTitle(String title) => pw.Padding(
          padding: const pw.EdgeInsets.only(top: 16, bottom: 6),
          child: pw.Text(title, style: boldStyle.copyWith(fontSize: 13, color: PdfColors.blue900)),
        );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData(defaultTextStyle: pw.TextStyle(font: ttf, fontFallback: [ttf])),
        build: (context) => [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('PV System Design Report', style: boldStyle.copyWith(fontSize: 22, color: PdfColors.blue900)),
              pw.Text('Solar Hub', style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
            ],
          ),
          pw.Text('Generated ${DateTime.now().toIso8601String().split('T').first}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500)),
          pw.Divider(color: PdfColors.grey300),

          sectionTitle('Site'),
          kv('Location', '${state.latitude.toStringAsFixed(4)}, ${state.longitude.toStringAsFixed(4)}'),
          kv('Mount Type', state.mountType.name),
          if (energyEstimate != null) kv('Weather Data Source', energyEstimate.isRealWeatherData ? 'Real historical data (Open-Meteo)' : 'Estimated (no network data available)'),

          sectionTitle('System Summary'),
          kv('Panel Count', '$panelsCount'),
          kv('Peak Power', '${peakPowerKwp.toStringAsFixed(2)} kWp'),
          kv('Array Area', '${totalAreaM2.toStringAsFixed(1)} m²'),
          kv('Array Weight', '${totalWeightKg.toStringAsFixed(0)} kg'),
          kv('Panel Rating', '${state.panelPowerW.toStringAsFixed(0)} W (${state.panelLengthM}m x ${state.panelWidthM}m)'),

          if (frameResult != null) ...[
            sectionTitle('Structural Design'),
            kv('Layout', '${frameResult.rows} rows x ${frameResult.columns} columns'),
            kv('Tilt / Azimuth', '${frameResult.appliedTiltDegrees.toStringAsFixed(1)}° / ${frameResult.appliedAzimuthDegrees.toStringAsFixed(0)}°'),
            kv('Row Spacing', '${frameResult.rowSpacingMeters.toStringAsFixed(2)} m'),
            kv('Front / Rear Leg Height', '${frameResult.frontLegHeightMeters.toStringAsFixed(2)} m / ${frameResult.rearLegHeightMeters.toStringAsFixed(2)} m'),
            kv('Total Steel', '${frameResult.totalSteelLengthMeters.toStringAsFixed(1)} m'),
          ],

          if (energyEstimate != null) ...[
            sectionTitle('Energy Production Estimate'),
            kv('Annual Production', '${energyEstimate.yearlyKwh.toStringAsFixed(0)} kWh/year'),
            kv('Average Daily Production', '${energyEstimate.dailyKwh.toStringAsFixed(1)} kWh/day'),
            kv('Performance Ratio', '${(energyEstimate.performanceRatio * 100).toStringAsFixed(1)}%'),
            kv('Capacity Factor', '${(energyEstimate.capacityFactor * 100).toStringAsFixed(1)}%'),
            kv('Avg. Temperature Loss', '${(energyEstimate.avgTemperatureLossFraction * 100).toStringAsFixed(1)}%'),
            kv('CO2 Offset', '${energyEstimate.annualCo2OffsetKg.toStringAsFixed(0)} kg/year'),
            pw.SizedBox(height: 6),
            pw.Text('Monthly Production (kWh)', style: pw.TextStyle(fontSize: 10, font: ttfBold, fontWeight: pw.FontWeight.bold)),
            pw.Wrap(
              spacing: 10,
              runSpacing: 4,
              children: List.generate(12, (i) {
                final v = i < energyEstimate.monthlyProductionKwh.length ? energyEstimate.monthlyProductionKwh[i] : 0.0;
                return pw.Text('${monthNames[i]}: ${v.toStringAsFixed(0)}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700));
              }),
            ),
            pw.SizedBox(height: 6),
            pw.Text('Loss Diagram', style: pw.TextStyle(fontSize: 10, font: ttfBold, fontWeight: pw.FontWeight.bold)),
            kv('Soiling', '${energyEstimate.losses.soilingLossPercent.toStringAsFixed(1)}%'),
            kv('Mismatch', '${energyEstimate.losses.mismatchLossPercent.toStringAsFixed(1)}%'),
            kv('DC Wiring', '${energyEstimate.losses.dcWiringLossPercent.toStringAsFixed(1)}%'),
            kv('AC Wiring', '${energyEstimate.losses.acWiringLossPercent.toStringAsFixed(1)}%'),
            kv('Inverter Efficiency', '${energyEstimate.losses.inverterEfficiencyPercent.toStringAsFixed(1)}%'),
            kv('Availability', '${(100 - energyEstimate.losses.availabilityLossPercent).toStringAsFixed(1)}%'),
            kv('Annual Degradation', '${energyEstimate.losses.annualDegradationPercent.toStringAsFixed(2)}%/yr'),
          ],

          if (stringSizing != null) ...[
            sectionTitle('Inverter & String Sizing'),
            kv('Inverter', '${stringSizing.inverter.name} (${stringSizing.inverter.ratedAcPowerKw.toStringAsFixed(1)} kW AC)'),
            kv('String Configuration', '${stringSizing.panelsPerString} panels/string x ${stringSizing.parallelStrings} strings'),
            kv('String Voc (cold) / Vmp (hot)', '${stringSizing.stringVocAtColdTemp.toStringAsFixed(0)} V / ${stringSizing.stringVmpAtHotTemp.toStringAsFixed(0)} V'),
            kv('DC:AC Ratio', stringSizing.dcAcRatio.toStringAsFixed(2)),
            kv('Electrically Compliant', stringSizing.isFullyCompliant ? 'Yes' : 'No — see warnings below'),
            if (stringSizing.warnings.isNotEmpty)
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 4),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: stringSizing.warnings
                      .map((w) => pw.Text('• $w', style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.red)))
                      .toList(),
                ),
              ),
          ],

          if (financialEstimate != null && financialEstimate.systemCost > 0) ...[
            sectionTitle('Financial Summary'),
            kv('Estimated System Cost', financialEstimate.systemCost.toStringAsFixed(0)),
            kv('Est. Annual Savings (Year 1)', financialEstimate.annualSavings.toStringAsFixed(0)),
            kv('Simple Payback Period', financialEstimate.paybackYears != null ? '${financialEstimate.paybackYears!.toStringAsFixed(1)} years' : 'N/A'),
            kv('${financialEstimate.lifetimeYears}-Year Net Savings', financialEstimate.lifetimeSavings.toStringAsFixed(0)),
          ],

          if (frameResult != null) ...[
            sectionTitle('Bill of Materials'),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              columnWidths: const {0: pw.FlexColumnWidth(3), 1: pw.FlexColumnWidth(1)},
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Item', style: pw.TextStyle(font: ttfBold, fontWeight: pw.FontWeight.bold, fontSize: 9))),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Quantity', style: pw.TextStyle(font: ttfBold, fontWeight: pw.FontWeight.bold, fontSize: 9))),
                  ],
                ),
                ...frameResult.bomItems.map(
                  (item) => pw.TableRow(
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(item.name, style: const pw.TextStyle(fontSize: 9))),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('${item.quantity.toStringAsFixed(1)} ${item.unit}', style: const pw.TextStyle(fontSize: 9))),
                    ],
                  ),
                ),
              ],
            ),
          ],

          pw.SizedBox(height: 20),
          pw.Divider(color: PdfColors.grey300),
          pw.Center(
            child: pw.Text(
              'This report uses a simplified simulation model (POA transposition, NOCT temperature derate, Erbs diffuse-fraction correlation) '
              'and is intended for preliminary design purposes. Confirm final specifications against manufacturer datasheets before installation.',
              style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey500),
              textAlign: pw.TextAlign.center,
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }
}
