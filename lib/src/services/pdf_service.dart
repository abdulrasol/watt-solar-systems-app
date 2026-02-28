// import 'dart:typed_data';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
// import 'package:intl/intl.dart';
// import 'package:solar_hub/src/features/store/models/customer_model.dart';

// import 'package:solar_hub/src/utils/price_format_utils.dart';

// class PdfService {
//   Future<Uint8List> generateInvoice({
//     required String orderId,
//     int? orderNumber,
//     required Map<String, dynamic>? sellerInfo,
//     required Map<String, dynamic>? buyerInfo,
//     required List<Map<String, dynamic>> items,
//     required double total,
//     DateTime? date,
//     double? paidAmount,
//     String? paymentMethod,
//     String? currencySymbol,
//   }) async {
//     final invoiceDate = date ?? DateTime.now();
//     final pdf = pw.Document();

//     // Load Fonts via GoogleFonts (Network) to avoid corrupt local files
//     // Use Cairo for excellent Arabic support
//     final ttf = await PdfGoogleFonts.cairoRegular();
//     final ttfBold = await PdfGoogleFonts.cairoBold();

//     final paid = paidAmount ?? total;
//     final due = total - paid;
//     final symbol = currencySymbol ?? '\$';

//     pdf.addPage(
//       pw.Page(
//         pageFormat: PdfPageFormat.a4,
//         theme: pw.ThemeData(
//           defaultTextStyle: pw.TextStyle(font: ttf, fontFallback: [ttf]),
//         ),
//         build: (pw.Context context) {
//           final boldStyle = pw.TextStyle(font: ttfBold, fontWeight: pw.FontWeight.bold, fontFallback: [ttfBold]);

//           return pw.Directionality(
//             textDirection: pw.TextDirection.rtl,
//             child: pw.Column(
//               crossAxisAlignment: pw.CrossAxisAlignment.start,
//               children: [
//                 // 1. Header (Seller & Title)
//                 pw.Row(
//                   mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                   children: [
//                     pw.Column(
//                       crossAxisAlignment: pw.CrossAxisAlignment.start,
//                       children: [
//                         pw.Text(sellerInfo?['name'] ?? 'SolarHub Company', style: boldStyle.copyWith(fontSize: 20), textDirection: pw.TextDirection.rtl),
//                         if (sellerInfo?['address'] != null) pw.Text(sellerInfo!['address'], textDirection: pw.TextDirection.rtl),
//                         if (sellerInfo?['contact_phone'] != null) pw.Text(sellerInfo!['contact_phone'], textDirection: pw.TextDirection.ltr),
//                       ],
//                     ),
//                     pw.Column(
//                       crossAxisAlignment: pw.CrossAxisAlignment.end,
//                       children: [
//                         pw.Text('invoice_upper', style: boldStyle.copyWith(fontSize: 30, color: PdfColors.blue900)),
//                         pw.Text('#${orderNumber ?? orderId.substring(0, 8).toUpperCase()}', style: pw.TextStyle(fontSize: 14)),
//                         pw.Text(DateFormat('yyyy-MM-dd').format(invoiceDate)),
//                       ],
//                     ),
//                   ],
//                 ),
//                 pw.SizedBox(height: 30),

//                 // 2. Bill To
//                 pw.Container(
//                   padding: const pw.EdgeInsets.all(10),
//                   decoration: const pw.BoxDecoration(color: PdfColors.grey100),
//                   width: double.infinity,
//                   child: pw.Column(
//                     crossAxisAlignment: pw.CrossAxisAlignment.start,
//                     children: [
//                       pw.Text('bill_to', style: boldStyle),
//                       pw.Text(buyerInfo?['name'] ?? 'guest', style: boldStyle),
//                       if (buyerInfo?['phone'] != null) pw.Text(buyerInfo!['phone'], textDirection: pw.TextDirection.ltr),
//                       if (buyerInfo?['address'] != null) pw.Text(buyerInfo!['address']),
//                     ],
//                   ),
//                 ),
//                 pw.SizedBox(height: 20),

//                 // 3. Items Table
//                 pw.Table(
//                   border: pw.TableBorder.all(color: PdfColors.grey300),
//                   columnWidths: {
//                     0: const pw.FlexColumnWidth(3),
//                     1: const pw.FlexColumnWidth(1),
//                     2: const pw.FlexColumnWidth(1.5),
//                     3: const pw.FlexColumnWidth(1.5),
//                   },
//                   children: [
//                     // Header
//                     pw.TableRow(
//                       decoration: const pw.BoxDecoration(color: PdfColors.blue50),
//                       children: [
//                         pw.Padding(
//                           padding: const pw.EdgeInsets.all(8),
//                           child: pw.Text('item_description', style: boldStyle),
//                         ),
//                         pw.Padding(
//                           padding: const pw.EdgeInsets.all(8),
//                           child: pw.Text('qty_th', textAlign: pw.TextAlign.center, style: boldStyle),
//                         ),
//                         pw.Padding(
//                           padding: const pw.EdgeInsets.all(8),
//                           child: pw.Text('price_th', textAlign: pw.TextAlign.center, style: boldStyle),
//                         ),
//                         pw.Padding(
//                           padding: const pw.EdgeInsets.all(8),
//                           child: pw.Text('amount_th', textAlign: pw.TextAlign.center, style: boldStyle),
//                         ),
//                       ],
//                     ),
//                     // Item Rows
//                     ...items.map((item) {
//                       final name = item['product_name_snapshot'] ?? 'product_default';
//                       final qty = item['quantity']?.toString() ?? '1';
//                       final unitPrice = (item['unit_price'] as num?)?.toDouble() ?? 0.0;
//                       final lineTotal = (item['total_line_price'] as num?)?.toDouble() ?? 0.0;

//                       return pw.TableRow(
//                         children: [
//                           pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(name)),
//                           pw.Padding(
//                             padding: const pw.EdgeInsets.all(8),
//                             child: pw.Text(qty, textAlign: pw.TextAlign.center),
//                           ),
//                           pw.Padding(
//                             padding: const pw.EdgeInsets.all(8),
//                             child: pw.Text(unitPrice.toPrice(), textAlign: pw.TextAlign.center),
//                           ),
//                           pw.Padding(
//                             padding: const pw.EdgeInsets.all(8),
//                             child: pw.Text(lineTotal.toPrice(), textAlign: pw.TextAlign.center),
//                           ),
//                         ],
//                       );
//                     }),
//                   ],
//                 ),
//                 pw.SizedBox(height: 20),

//                 // 4. Totals
//                 pw.Row(
//                   mainAxisAlignment: pw.MainAxisAlignment.end,
//                   children: [
//                     pw.Container(
//                       width: 200,
//                       child: pw.Column(
//                         children: [
//                           pw.Row(
//                             mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                             children: [
//                               pw.Text('total_amount', style: boldStyle),
//                               pw.Text(total.toPriceWithCurrency(symbol), style: boldStyle),
//                             ],
//                           ),
//                           pw.SizedBox(height: 5),
//                           pw.Row(
//                             mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                             children: [
//                               pw.Text('paid_amount', style: boldStyle),
//                               pw.Text(paid.toPriceWithCurrency(symbol), style: boldStyle),
//                             ],
//                           ),
//                           pw.Divider(),
//                           pw.Row(
//                             mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                             children: [
//                               pw.Text('balance_due', style: boldStyle.copyWith(color: due > 0 ? PdfColors.red : PdfColors.black)),
//                               pw.Text(due.toPriceWithCurrency(symbol), style: boldStyle.copyWith(color: due > 0 ? PdfColors.red : PdfColors.black)),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),

//                 if (paymentMethod != null) ...[pw.SizedBox(height: 20), pw.Text("${'payment_method_label'}: ${paymentMethod}", style: boldStyle)],

//                 pw.Spacer(),
//                 pw.Divider(color: PdfColors.grey300),
//                 pw.Center(
//                   child: pw.Text('thank_you', style: const pw.TextStyle(color: PdfColors.grey600)),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );

//     return pdf.save();
//   }

//   Future<void> printInvoice(Uint8List pdfData) async {
//     await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdfData);
//   }

//   Future<Uint8List> generateStatement({required CustomerModel customer, required List<Map<String, dynamic>> orders, String currencySymbol = '\$'}) async {
//     final pdf = pw.Document();
//     final now = DateTime.now();

//     // Load Fonts via GoogleFonts (Network)
//     final ttf = await PdfGoogleFonts.cairoRegular();
//     final ttfBold = await PdfGoogleFonts.cairoBold();

//     pdf.addPage(
//       pw.Page(
//         pageFormat: PdfPageFormat.a4,
//         theme: pw.ThemeData(
//           defaultTextStyle: pw.TextStyle(font: ttf, fontFallback: [ttf]),
//         ),
//         build: (pw.Context context) {
//           final boldStyle = pw.TextStyle(font: ttfBold, fontWeight: pw.FontWeight.bold, fontFallback: [ttfBold]);

//           return pw.Directionality(
//             textDirection: pw.TextDirection.rtl,
//             child: pw.Column(
//               crossAxisAlignment: pw.CrossAxisAlignment.start,
//               children: [
//                 // Header
//                 pw.Row(
//                   mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                   children: [
//                     pw.Text('account_statement', style: boldStyle.copyWith(fontSize: 24)),
//                     pw.Text(DateFormat('yyyy-MM-dd').format(now), textDirection: pw.TextDirection.ltr),
//                   ],
//                 ),
//                 pw.SizedBox(height: 20),

//                 // Customer Info
//                 pw.Text('customer_details', style: boldStyle),
//                 pw.Text(customer.fullName),
//                 if (customer.phoneNumber != null) pw.Text(customer.phoneNumber!),
//                 if (customer.email != null) pw.Text(customer.email!),
//                 if (customer.address != null) pw.Text(customer.address!),
//                 pw.SizedBox(height: 20),

//                 // Summary Box
//                 pw.Container(
//                   padding: const pw.EdgeInsets.all(10),
//                   decoration: pw.BoxDecoration(border: pw.Border.all()),
//                   child: pw.Row(
//                     mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                     children: [
//                       pw.Column(
//                         children: [
//                           pw.Text('total_sales'),
//                           pw.Text(customer.totalSales.toPriceWithCurrency(currencySymbol), style: boldStyle),
//                         ],
//                       ),
//                       pw.Column(
//                         children: [
//                           pw.Text('total_paid'),
//                           pw.Text(customer.totalPaid.toPriceWithCurrency(currencySymbol), style: boldStyle),
//                         ],
//                       ),
//                       pw.Column(
//                         children: [
//                           pw.Text('balance_due'),
//                           pw.Text(customer.balance.toPriceWithCurrency(currencySymbol), style: boldStyle.copyWith(color: PdfColors.red)),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 pw.SizedBox(height: 20),

//                 // Transactions Table
//                 pw.Text('transaction_history', style: boldStyle),
//                 pw.SizedBox(height: 10),
//                 pw.Table(
//                   border: pw.TableBorder.all(color: PdfColors.grey),
//                   children: [
//                     // Header
//                     pw.TableRow(
//                       decoration: const pw.BoxDecoration(color: PdfColors.grey200),
//                       children: [
//                         pw.Padding(
//                           padding: const pw.EdgeInsets.all(5),
//                           child: pw.Text('Date', style: boldStyle),
//                         ),
//                         pw.Padding(
//                           padding: const pw.EdgeInsets.all(5),
//                           child: pw.Text('order_label', style: boldStyle),
//                         ),
//                         pw.Padding(
//                           padding: const pw.EdgeInsets.all(5),
//                           child: pw.Text('total', style: boldStyle),
//                         ),
//                         pw.Padding(
//                           padding: const pw.EdgeInsets.all(5),
//                           child: pw.Text('Paid', style: boldStyle),
//                         ),
//                         pw.Padding(
//                           padding: const pw.EdgeInsets.all(5),
//                           child: pw.Text('offer_status', style: boldStyle),
//                         ),
//                       ],
//                     ),
//                     // Rows
//                     ...orders.map((order) {
//                       final date = DateTime.parse(order['created_at']);
//                       final total = (order['total_amount'] as num?)?.toDouble() ?? 0.0;
//                       final paid = (order['paid_amount'] as num?)?.toDouble() ?? 0.0;
//                       final status = order['payment_status'] ?? 'unknown';

//                       return pw.TableRow(
//                         children: [
//                           pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(DateFormat('yyyy-MM-dd').format(date))),
//                           pw.Padding(
//                             padding: const pw.EdgeInsets.all(5),
//                             child: pw.Text(order['order_number']?.toString() ?? "#${order['id'].toString().substring(0, 8).toUpperCase()}"),
//                           ),
//                           pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(total.toPriceWithCurrency(currencySymbol))),
//                           pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(paid.toPriceWithCurrency(currencySymbol))),
//                           pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(status)),
//                         ],
//                       );
//                     }),
//                   ],
//                 ),

//                 pw.Spacer(),
//                 pw.Text('generated_by'Params({'app': 'Solar Hub'}), style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
//               ],
//             ),
//           );
//         },
//       ),
//     );

//     return pdf.save();
//   }
// }
