import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:solar_hub/features/orders/models/order_model.dart';
import 'package:solar_hub/controllers/company_controller.dart';
import 'package:intl/intl.dart';
import 'package:solar_hub/models/enums.dart';
import 'package:solar_hub/utils/app_theme.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:solar_hub/utils/price_format_utils.dart';

class InvoiceDetailsPage extends StatelessWidget {
  final OrderModel order;
  InvoiceDetailsPage({super.key, required this.order});

  final ValueNotifier<bool> _isPrinting = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    final company = Get.find<CompanyController>().company.value;

    return Scaffold(
      appBar: AppBar(
        title: Text('${'invoice'.tr} #${order.orderNumber?.toString() ?? order.id.substring(0, 8).toUpperCase()}'),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: _isPrinting,
            builder: (context, isPrinting, child) {
              if (isPrinting) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: AppTheme.primaryColor, strokeWidth: 2)),
                );
              }
              return IconButton(icon: const Icon(Icons.print), onPressed: () => _printInvoice(context), tooltip: 'print_invoice'.tr);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800), // A4-ish width constraint
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Theme(
              data: AppTheme.lightTheme,
              child: Builder(
                builder: (context) {
                  return DefaultTextStyle(
                    style: AppTheme.lightTheme.textTheme.bodyMedium!,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- Header ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Company Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (company?.logoUrl != null && company!.logoUrl!.isNotEmpty)
                                    CachedNetworkImage(
                                      imageUrl: company.logoUrl!,
                                      height: 60,
                                      width: 60,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => const CircularProgressIndicator(),
                                      errorWidget: (context, url, error) => const Icon(Icons.error),
                                    )
                                  else
                                    const Icon(Icons.business, size: 60, color: AppTheme.primaryColor),
                                  const SizedBox(height: 8),
                                  Text(company?.name ?? 'company_name_default'.tr, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                  if (company?.address != null) Text(company!.address!),
                                  if (company?.contactPhone != null) Text(company!.contactPhone!),
                                ],
                              ),
                            ),
                            // Invoice Meta
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'invoice_upper'.tr,
                                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.grey),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "#${order.orderNumber?.toString() ?? order.id.substring(0, 8).toUpperCase()}",
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text('${'invoice_date'.tr}: ${DateFormat('yyyy-MM-dd').format(order.createdAt ?? DateTime.now())}'),
                                const SizedBox(height: 4),
                                // Due date is usually ~30 days, or same day if POS
                                Text('${'due_date'.tr}: ${DateFormat('yyyy-MM-dd').format(order.createdAt ?? DateTime.now())}'),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 48),

                        // --- Bill To ---
                        Text(
                          'bill_to'.tr,
                          style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(order.effectiveCustomerName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                        // Add customer address/email if available in OrderModel relation
                        const SizedBox(height: 48),

                        // --- Items Table ---
                        Table(
                          columnWidths: const {
                            0: FlexColumnWidth(3), // Description
                            1: FlexColumnWidth(1.5), // Qty
                            2: FlexColumnWidth(2), // Price
                            3: FlexColumnWidth(2.5), // Amount
                          },
                          border: TableBorder(bottom: BorderSide(color: Colors.grey.shade300)),
                          children: [
                            // Header
                            TableRow(
                              decoration: BoxDecoration(color: Colors.grey.shade100),
                              children: [
                                _buildTableHeader('description_th'.tr),
                                _buildTableHeader('qty_th'.tr, align: TextAlign.center),
                                _buildTableHeader('price_th'.tr, align: TextAlign.right),
                                _buildTableHeader('amount_th'.tr, align: TextAlign.right),
                              ],
                            ),
                            // Items
                            ...order.items.map((item) {
                              return TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                    child: item.selectedOptions.isNotEmpty
                                        ? Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(item.productNameSnapshot ?? 'product_default'.tr),
                                              Text(
                                                item.selectedOptions.map((o) => "${o['name']}: ${o['value']}").join(', '),
                                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                              ),
                                            ],
                                          )
                                        : Text(item.productNameSnapshot ?? 'product_default'.tr),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                    child: Text(item.quantity.toString(), textAlign: TextAlign.center),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                    child: Text(item.unitPrice.toPriceWithCurrency(order.currencySymbol), textAlign: TextAlign.right),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                    child: Text(item.totalLinePrice.toPriceWithCurrency(order.currencySymbol), textAlign: TextAlign.right),
                                  ),
                                ],
                              );
                            }),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // --- Totals ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(
                              width: 250,
                              child: Column(
                                children: [
                                  _buildTotalRow(
                                    'subtotal'.tr,
                                    order.totalAmount.toPriceWithCurrency(order.currencySymbol),
                                  ), // Assuming tax inclusive for now if not separate
                                  if (order.taxAmount > 0) _buildTotalRow('tax'.tr, order.taxAmount.toPriceWithCurrency(order.currencySymbol)),
                                  if (order.discountAmount > 0)
                                    _buildTotalRow('discount'.tr, "-${order.discountAmount.toPriceWithCurrency(order.currencySymbol)}", color: Colors.red),
                                  const Divider(),
                                  _buildTotalRow('grand_total'.tr, order.totalAmount.toPriceWithCurrency(order.currencySymbol), isBold: true, fontSize: 18),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 48),

                        // --- Footer ---
                        if (order.paymentStatus != PaymentStatus.paid && order.status != OrderStatus.cancelled) ...[
                          Text("payment_info".tr, style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('bank_info_details'.tr),
                          const SizedBox(height: 24),
                        ],

                        Center(
                          child: Text(
                            'thank_you'.tr,
                            style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTableHeader(String text, {TextAlign align = TextAlign.left}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold),
        textAlign: align,
      ),
    );
  }

  Widget _buildTotalRow(String label, String value, {bool isBold = false, double fontSize = 14, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: fontSize),
          ),
          Text(
            value,
            style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: fontSize, color: color),
          ),
        ],
      ),
    );
  }

  Future<void> _printInvoice(BuildContext context) async {
    _isPrinting.value = true;
    try {
      final pdf = pw.Document();
      final company = Get.find<CompanyController>().company.value;

      // Load Font for Arabic Support using PdfGoogleFonts for better compatibility
      final ttf = await PdfGoogleFonts.cairoRegular();
      final boldTtf = await PdfGoogleFonts.cairoBold();

      // Load Logo if available
      pw.ImageProvider? logoImage;
      if (company?.logoUrl != null && company!.logoUrl!.isNotEmpty) {
        try {
          logoImage = await networkImage(company.logoUrl!);
        } catch (e) {
          debugPrint('Error loading logo for PDF: $e');
        }
      }

      final isArabic = Get.locale?.languageCode == 'ar';

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          theme: pw.ThemeData.withFont(base: ttf, bold: boldTtf),
          build: (pw.Context context) {
            return pw.Directionality(
              textDirection: isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // --- Header ---
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            if (logoImage != null)
                              pw.Image(logoImage, width: 60, height: 60, fit: pw.BoxFit.cover)
                            else
                              pw.Container(width: 60, height: 60, color: PdfColors.grey300),
                            pw.SizedBox(height: 8),
                            pw.Text(company?.name ?? 'company_name_default'.tr, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                            if (company?.address != null) pw.Text(company!.address!),
                            if (company?.contactPhone != null) pw.Text(company!.contactPhone!),
                          ],
                        ),
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            'invoice_upper'.tr,
                            style: pw.TextStyle(fontSize: 32, fontWeight: pw.FontWeight.bold, color: PdfColors.grey),
                          ),
                          pw.SizedBox(height: 8),
                          pw.Text(
                            "#${order.orderNumber?.toString() ?? order.id.substring(0, 8).toUpperCase()}",
                            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text('${'invoice_date'.tr}: ${DateFormat('yyyy-MM-dd').format(order.createdAt ?? DateTime.now())}'),
                          pw.SizedBox(height: 4),
                          pw.Text('${'due_date'.tr}: ${DateFormat('yyyy-MM-dd').format(order.createdAt ?? DateTime.now())}'),
                        ],
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 48),

                  // --- Bill To ---
                  pw.Text(
                    'bill_to'.tr,
                    style: pw.TextStyle(color: PdfColors.grey600, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(order.effectiveCustomerName, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 48),

                  // --- Items Table ---
                  pw.Table(
                    border: pw.TableBorder(bottom: pw.BorderSide(color: PdfColors.grey300)),
                    columnWidths: {
                      0: const pw.FlexColumnWidth(3),
                      1: const pw.FlexColumnWidth(1.5),
                      2: const pw.FlexColumnWidth(2),
                      3: const pw.FlexColumnWidth(2.5),
                    },
                    children: [
                      // Header
                      pw.TableRow(
                        decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                        children: [
                          _buildPdfHeader('description_th'.tr),
                          _buildPdfHeader('qty_th'.tr, align: pw.TextAlign.center),
                          _buildPdfHeader('price_th'.tr, align: pw.TextAlign.right),
                          _buildPdfHeader('amount_th'.tr, align: pw.TextAlign.right),
                        ],
                      ),
                      // Items
                      ...order.items.map((item) {
                        return pw.TableRow(
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(item.productNameSnapshot ?? 'product_default'.tr),
                                  if (item.selectedOptions.isNotEmpty)
                                    pw.Text(
                                      item.selectedOptions.map((o) => "${o['name']}: ${o['value']}").join(', '),
                                      style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                                    ),
                                ],
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                              child: pw.Text(item.quantity.toString(), textAlign: pw.TextAlign.center),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                              child: pw.Text(item.unitPrice.toPriceWithCurrency(order.currencySymbol), textAlign: pw.TextAlign.right),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                              child: pw.Text(item.totalLinePrice.toPriceWithCurrency(order.currencySymbol), textAlign: pw.TextAlign.right),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                  pw.SizedBox(height: 24),

                  // --- Totals ---
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.end,
                    children: [
                      pw.Container(
                        width: 250,
                        child: pw.Column(
                          children: [
                            _buildPdfTotalRow('subtotal'.tr, order.totalAmount.toPriceWithCurrency(order.currencySymbol)),
                            if (order.taxAmount > 0) _buildPdfTotalRow('tax'.tr, order.taxAmount.toPriceWithCurrency(order.currencySymbol)),
                            if (order.discountAmount > 0)
                              _buildPdfTotalRow('discount'.tr, "-${order.discountAmount.toPriceWithCurrency(order.currencySymbol)}", color: PdfColors.red),
                            pw.Divider(),
                            _buildPdfTotalRow('grand_total'.tr, order.totalAmount.toPriceWithCurrency(order.currencySymbol), isBold: true, fontSize: 18),
                          ],
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 48),

                  // --- Footer ---
                  if (order.paymentStatus != PaymentStatus.paid && order.status != OrderStatus.cancelled) ...[
                    pw.Text("payment_info".tr, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 4),
                    pw.Text('bank_info_details'.tr),
                    pw.SizedBox(height: 24),
                  ],

                  pw.Center(
                    child: pw.Text(
                      'thank_you'.tr,
                      style: pw.TextStyle(color: PdfColors.grey600, fontStyle: pw.FontStyle.italic),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );

      await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
    } catch (e) {
      Get.snackbar('err_error'.tr, 'error_pdf'.trParams({'error': e.toString()}), snackPosition: SnackPosition.BOTTOM);
    } finally {
      _isPrinting.value = false;
    }
  }

  pw.Widget _buildPdfHeader(String text, {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        textAlign: align,
      ),
    );
  }

  pw.Widget _buildPdfTotalRow(String label, String value, {bool isBold = false, double fontSize = 14, PdfColor? color}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal, fontSize: fontSize),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal, fontSize: fontSize, color: color),
          ),
        ],
      ),
    );
  }
}
