import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:solar_hub/src/features/accounting/domain/entities/accounting_models.dart';
import 'package:solar_hub/src/utils/price_format_utils.dart';

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
}
