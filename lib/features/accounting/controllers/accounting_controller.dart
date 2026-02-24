import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_hub/controllers/company_controller.dart';
import 'package:solar_hub/models/expense_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class AccountingController extends GetxController {
  final _supabase = Supabase.instance.client;
  final CompanyController _companyController = Get.find<CompanyController>();

  var expenses = <ExpenseModel>[].obs;
  var filteredExpenses = <ExpenseModel>[].obs;
  var unpaidCustomers = <Map<String, dynamic>>[].obs;
  var paidOrders = <Map<String, dynamic>>[].obs; // {id, created_at, total_amount, ...}

  var totalIncome = 0.0.obs;
  var totalExpenses = 0.0.obs;
  var netProfit = 0.0.obs;
  var totalDebts = 0.0.obs;

  var isLoading = false.obs;

  // Filters
  var selectedDateRange = Rxn<DateTimeRange>();
  var searchQuery = ''.obs;

  // Detail Page Filters
  var detailSearchQuery = ''.obs;
  var detailFilterType = 'total'.obs; // total, month, week, year

  @override
  void onInit() {
    super.onInit();
    fetchAccountingData();

    // Listen to search query changes
    debounce(searchQuery, (_) => _filterExpenses(), time: const Duration(milliseconds: 500));
  }

  void _filterExpenses() {
    if (searchQuery.isEmpty) {
      filteredExpenses.assignAll(expenses);
    } else {
      final query = searchQuery.value.toLowerCase();
      filteredExpenses.assignAll(
        expenses.where((e) {
          return (e.category.toLowerCase().contains(query)) || (e.description?.toLowerCase().contains(query) ?? false);
        }).toList(),
      );
    }
  }

  void setDateRange(DateTimeRange? range) {
    selectedDateRange.value = range;
    fetchAccountingData();
  }

  Future<void> fetchAccountingData() async {
    isLoading.value = true;
    try {
      final companyId = _companyController.company.value?.id;
      if (companyId == null) return;

      // Prepare date filter
      String? startDate;
      String? endDate;
      if (selectedDateRange.value != null) {
        startDate = selectedDateRange.value!.start.toIso8601String();
        endDate = selectedDateRange.value!.end.toIso8601String();
      }

      // 1. Fetch Expenses (Full is okay as it's the main list)
      var expensesQuery = _supabase.from('expenses').select();
      expensesQuery = expensesQuery.eq('company_id', companyId);

      if (startDate != null && endDate != null) {
        expensesQuery = expensesQuery.gte('date', startDate).lte('date', endDate);
      }

      final expensesResponse = await expensesQuery.order('date', ascending: false);
      expenses.assignAll((expensesResponse as List).map((e) => ExpenseModel.fromJson(e)).toList());
      _filterExpenses();

      totalExpenses.value = expenses.fold(0.0, (sum, item) => sum + item.amount);

      // 2. Fetch Income (Lightweight - Only Amount & Date)
      // optimization: we need order items for COGS and delivery info for delivery costs
      // to avoid fetching EVERYTHING, let's try to be smart.
      // But for COGS we essentially need "all paid order items" + "product cost prices".
      // This is heavy. For a dashboard, maybe we can fetch a "summary" if backend supported it,
      // but here we must do it client side as per instructions.

      var incomeQuery = _supabase
          .from('orders')
          .select('id, total_amount, created_at, shipping_method, shipping_cost, order_items(product_id, quantity), seller_company_id');
      incomeQuery = incomeQuery.eq('seller_company_id', companyId).eq('payment_status', 'paid');

      if (startDate != null && endDate != null) {
        incomeQuery = incomeQuery.gte('created_at', startDate).lte('created_at', endDate);
      }

      final incomeListRaw = await incomeQuery.order('created_at', ascending: false) as List;
      // Store data. Note: 'order_items' is now included.
      paidOrders.assignAll(incomeListRaw.map((e) => e as Map<String, dynamic>).toList());

      totalIncome.value = paidOrders.fold(0.0, (sum, item) => sum + (item['total_amount'] as num).toDouble());

      // --- Calculate COGS (Cost of Goods Sold) ---
      // We need cost_price for all products involved.
      // 1. Collect all product IDs from paid orders
      final Set<String> productIds = {};
      for (var order in paidOrders) {
        final items = order['order_items'] as List<dynamic>?;
        if (items != null) {
          for (var item in items) {
            if (item['product_id'] != null) {
              productIds.add(item['product_id'] as String);
            }
          }
        }
      }

      // 2. Fetch cost prices for these products
      final Map<String, double> productCosts = {};
      if (productIds.isNotEmpty) {
        final productsRes = await _supabase.from('products').select('id, cost_price').filter('id', 'in', productIds.toList());
        for (var p in productsRes) {
          productCosts[p['id'] as String] = (p['cost_price'] as num?)?.toDouble() ?? 0.0;
        }
      }

      // 3. Sum up COGS
      double totalCOGS = 0.0;
      for (var order in paidOrders) {
        final items = order['order_items'] as List<dynamic>?;
        if (items != null) {
          for (var item in items) {
            final pid = item['product_id'];
            final qty = (item['quantity'] as num?)?.toInt() ?? 0;
            final cost = productCosts[pid] ?? 0.0;
            totalCOGS += (cost * qty);
          }
        }
      }

      // --- Calculate Delivery Costs ---
      // We need to know the cost of the delivery method used.
      // Either we trust 'shipping_cost' column in order (if it tracks cost TO COMPANY),
      // OR we look up the delivery_option table.
      // Usually 'shipping_cost' in order table is what the CUSTOMER paid.
      // We want to know what the COMPANY paid (expense).
      // If the company fulfills it using own fleet, maybe there is a fixed cost per 'delivery_option'.
      // Assumption: 'delivery_options' table has a 'cost' field representing cost to company.
      // If 'shipping_cost' in order is what customer paid, that is Income (already in total_amount).
      // We need to subtract the cost associated with that delivery method.

      // 1. Fetch all delivery options for this company
      final deliveryOptionsRes = await _supabase.from('delivery_options').select('name, cost').eq('company_id', companyId);
      final Map<String, double> deliveryOptionCosts = {};
      for (var opt in deliveryOptionsRes) {
        deliveryOptionCosts[opt['name'] as String] = (opt['cost'] as num).toDouble();
      }

      // 2. Sum up Delivery Costs
      double totalDeliveryCost = 0.0;
      for (var order in paidOrders) {
        final method = order['shipping_method'] as String?;
        if (method != null && deliveryOptionCosts.containsKey(method)) {
          totalDeliveryCost += deliveryOptionCosts[method]!;
        }
      }

      // 3. Fetch Debts (Sum of Customer Balances - Very Fast)
      final customerBalancesRes = await _supabase.from('customers').select('balance').eq('company_id', companyId);
      final customerBalances = List<Map<String, dynamic>>.from(customerBalancesRes);
      totalDebts.value = customerBalances.fold(0.0, (sum, item) => sum + (item['balance'] as num).toDouble());

      // 4. Calculate Net Profit
      // Net Profit = Revenue - Expenses - COGS - Delivery Costs
      netProfit.value = totalIncome.value - totalExpenses.value - totalCOGS - totalDeliveryCost;

      debugPrint('Accounting Stats: Income=$totalIncome, Exp=$totalExpenses, COGS=$totalCOGS, Deliv=$totalDeliveryCost, Net=$netProfit');
    } catch (e, stack) {
      debugPrint('[ACCOUNTING_ERROR] Failed to fetch accounting data: $e');
      debugPrintStack(stackTrace: stack);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchIncomeDetails() async {
    isLoading.value = true;
    try {
      final companyId = _companyController.company.value?.id;
      if (companyId == null) return;

      // Prepare date filter (same as main)
      String? startDate;
      String? endDate;
      if (selectedDateRange.value != null) {
        startDate = selectedDateRange.value!.start.toIso8601String();
        endDate = selectedDateRange.value!.end.toIso8601String();
      }

      var incomeQuery = _supabase.from('orders').select('*, customers(*), order_items(*)');
      incomeQuery = incomeQuery.eq('seller_company_id', companyId).eq('payment_status', 'paid');

      if (startDate != null && endDate != null) {
        incomeQuery = incomeQuery.gte('created_at', startDate).lte('created_at', endDate);
      }

      final incomeListRaw = await incomeQuery.order('created_at', ascending: false) as List;
      paidOrders.assignAll(incomeListRaw.map((e) => e as Map<String, dynamic>).toList());
      // Recalculate total just in case
      totalIncome.value = paidOrders.fold(0.0, (sum, item) => sum + (item['total_amount'] as num).toDouble());
    } catch (e) {
      debugPrint("Error fetching income details: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchDebtDetails() async {
    isLoading.value = true;
    try {
      final companyId = _companyController.company.value?.id;
      if (companyId == null) return;

      String? startDate;
      String? endDate;
      if (selectedDateRange.value != null) {
        startDate = selectedDateRange.value!.start.toIso8601String();
        endDate = selectedDateRange.value!.end.toIso8601String();
      }

      var debtsQuery = _supabase.from('orders').select('*, customers(*), order_items(*)');
      debtsQuery = debtsQuery.eq('seller_company_id', companyId).neq('payment_status', 'paid');

      if (startDate != null && endDate != null) {
        debtsQuery = debtsQuery.gte('created_at', startDate).lte('created_at', endDate);
      }

      final debtsList = await debtsQuery as List;

      // Group by Customer for "Unpaid Customers" view
      final Map<String, Map<String, dynamic>> grouped = {};

      for (var order in debtsList) {
        final customer = order['customers'];
        final String customerId = order['customer_id'] ?? 'guest';
        final String customerName = customer != null ? customer['full_name'] : (order['guest_customer_name'] ?? 'guest'.tr);
        final double amount = (order['total_amount'] as num).toDouble();

        if (grouped.containsKey(customerId)) {
          grouped[customerId]!['total_debt'] += amount;
          grouped[customerId]!['order_count'] += 1;
          (grouped[customerId]!['orders'] as List).add(order);
        } else {
          grouped[customerId] = {
            'customer_id': customerId,
            'customer_name': customerName,
            'total_debt': amount,
            'order_count': 1,
            'phone': customer != null ? customer['phone_number'] : '',
            'orders': [order],
          };
        }
      }

      unpaidCustomers.assignAll(grouped.values.toList());
      unpaidCustomers.sort((a, b) => (b['total_debt'] as double).compareTo(a['total_debt'] as double));
    } catch (e) {
      debugPrint("Error fetching debt details: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // --- Detail Page Filter Logic ---
  bool _matchesDetailFilter(DateTime date) {
    final now = DateTime.now();
    switch (detailFilterType.value) {
      case 'week':
        return date.isAfter(now.subtract(const Duration(days: 7)));
      case 'month':
        return date.isAfter(now.subtract(const Duration(days: 30)));
      case 'year':
        return date.isAfter(now.subtract(const Duration(days: 365)));
      default:
        return true;
    }
  }

  List<ExpenseModel> get filteredValuesExpenses {
    return filteredExpenses.where((e) {
      if (!_matchesDetailFilter(e.date)) return false;
      if (detailSearchQuery.value.isNotEmpty) {
        final q = detailSearchQuery.value.toLowerCase();
        return e.category.toLowerCase().contains(q) || (e.description?.toLowerCase().contains(q) ?? false);
      }
      return true;
    }).toList();
  }

  List<Map<String, dynamic>> get filteredValuesIncome {
    return paidOrders.where((order) {
      final date = DateTime.tryParse(order['created_at']) ?? DateTime.now();
      if (!_matchesDetailFilter(date)) return false;

      if (detailSearchQuery.value.isNotEmpty) {
        final q = detailSearchQuery.value.toLowerCase();
        final customer = order['customers'];
        final name = customer != null ? customer['full_name'] : (order['guest_customer_name'] ?? 'guest'.tr);
        return name.toString().toLowerCase().contains(q);
      }
      return true;
    }).toList();
  }

  List<Map<String, dynamic>> get filteredValuesDebts {
    // For debts, we filter the *customers* based on name,
    // AND optionally filter their ORDERS based on date?
    // Usually debts are "current status", but let's apply the date filter to the "Unpaid Orders" themselves if requested.
    // However, unpaidCustomers is pre-grouped.
    // Re-filtering the raw debts list is complex here.
    // Let's simplified: Filter Customers by Name matches.
    // Date filter on "Debts" usually refers to "When the debt was incurred".
    // I will filter the `unpaidCustomers` list based on whether they have ANY order in that range?
    // Or just filter the displayed debt amount?
    // Let's filter the CUSTOMER list by name search.
    // Date filter might be tricky on pre-calculated totals.
    // For now, let's just search by name.

    return unpaidCustomers.where((item) {
      if (detailSearchQuery.value.isNotEmpty) {
        final q = detailSearchQuery.value.toLowerCase();
        final name = item['customer_name'] ?? '';
        return name.toString().toLowerCase().contains(q);
      }
      return true;
    }).toList();
  }

  Future<bool> addExpense(double amount, String category, DateTime date, String? description) async {
    try {
      final companyId = _companyController.company.value?.id;
      if (companyId == null) return false;

      await _supabase.from('expenses').insert({
        'company_id': companyId,
        'amount': amount,
        'category': category,
        'date': date.toIso8601String(),
        'description': description,
      });

      await fetchAccountingData();
      return true;
    } catch (e) {
      Get.snackbar('err_error'.tr, "${'failed_add_expense'.tr}: $e");
      return false;
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      await _supabase.from('expenses').delete().eq('id', id);
      await fetchAccountingData();
      Get.snackbar('success'.tr, 'expense_deleted_success'.tr);
    } catch (e) {
      Get.snackbar('err_error'.tr, "${'failed_deleting_product'.tr}: $e");
    }
  }

  Future<void> generateReport(BuildContext context) async {
    isLoading.value = true;
    try {
      final pdf = pw.Document();
      final company = _companyController.company.value;

      // Load fonts
      final ttf = await PdfGoogleFonts.cairoRegular();
      final boldTtf = await PdfGoogleFonts.cairoBold();

      // Load Logo
      pw.ImageProvider? logoImage;
      if (company?.logoUrl != null && company!.logoUrl!.isNotEmpty) {
        try {
          logoImage = await networkImage(company.logoUrl!);
        } catch (e) {
          debugPrint('Error loading logo for PDF: $e');
        }
      }

      final isArabic = Get.locale?.languageCode == 'ar';

      // Fetch Currency
      String currency = '\$';
      try {
        if (company?.id != null) {
          final res = await _supabase.from('companies').select('currencies(symbol)').eq('id', company!.id).single();
          if (res['currencies'] != null) {
            currency = res['currencies']['symbol'];
          }
        }
      } catch (e) {
        debugPrint('Error fetching currency for report: $e');
      }

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          theme: pw.ThemeData.withFont(base: ttf, bold: boldTtf),
          build: (pw.Context context) {
            return [
              pw.Directionality(
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
                              if (logoImage != null) pw.Image(logoImage, width: 60, height: 60, fit: pw.BoxFit.cover),
                              pw.SizedBox(height: 8),
                              pw.Text(company?.name ?? 'company_name_default'.tr, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                              if (company?.address != null) pw.Text(company!.address!, style: const pw.TextStyle(fontSize: 10)),
                              if (company?.contactPhone != null) pw.Text(company!.contactPhone!, style: const pw.TextStyle(fontSize: 10)),
                            ],
                          ),
                        ),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.Text(
                              'financial_report'.tr,
                              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.grey),
                            ),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              selectedDateRange.value != null
                                  ? "${DateFormat('yyyy-MM-dd').format(selectedDateRange.value!.start)} - ${DateFormat('yyyy-MM-dd').format(selectedDateRange.value!.end)}"
                                  : 'all_time_label'.tr,
                              style: const pw.TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 32),

                    // --- Summary Section ---
                    pw.Text('financial_summary'.tr, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 8),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey300),
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                      ),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          _buildPdfSummaryItem('income'.tr, totalIncome.value, PdfColors.green, currency),
                          _buildPdfSummaryItem('expenses'.tr, totalExpenses.value, PdfColors.red, currency),
                          _buildPdfSummaryItem('net_profit'.tr, netProfit.value, PdfColors.blue, currency),
                          _buildPdfSummaryItem('debts'.tr, totalDebts.value, PdfColors.orange, currency),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 32),

                    // --- Transaction List (Expenses) ---
                    pw.Text("${'recent_transactions'.tr} (${'expenses'.tr})", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 8),

                    pw.Table(
                      border: pw.TableBorder.all(color: PdfColors.grey300),
                      columnWidths: const {
                        0: pw.FlexColumnWidth(2), // Date
                        1: pw.FlexColumnWidth(2), // Category
                        2: pw.FlexColumnWidth(3), // Description
                        3: pw.FlexColumnWidth(1.5), // Amount
                      },
                      children: [
                        pw.TableRow(
                          decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                          children: [
                            _buildPdfHeader('date'.tr),
                            _buildPdfHeader('expense_category'.tr),
                            _buildPdfHeader('notes'.tr),
                            _buildPdfHeader('amount'.tr, align: pw.TextAlign.right),
                          ],
                        ),
                        ...filteredExpenses.map((expense) {
                          return pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(6),
                                child: pw.Text(DateFormat('yyyy-MM-dd').format(expense.date), style: const pw.TextStyle(fontSize: 10)),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(6),
                                child: pw.Text(expense.category.tr, style: const pw.TextStyle(fontSize: 10)),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(6),
                                child: pw.Text(expense.description ?? '-', style: const pw.TextStyle(fontSize: 10)),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(6),
                                child: pw.Text(
                                  "$currency${expense.amount.toStringAsFixed(2)}",
                                  textAlign: pw.TextAlign.right,
                                  style: const pw.TextStyle(fontSize: 10),
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ];
          },
        ),
      );

      await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
    } catch (e) {
      Get.snackbar('err_error'.tr, "${'failed_load_requests'.tr}: $e"); // Or a more specific report error
    } finally {
      isLoading.value = false;
    }
  }

  pw.Widget _buildPdfSummaryItem(String label, double value, PdfColor color, String currency) {
    return pw.Column(
      children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
        pw.SizedBox(height: 4),
        pw.Text(
          "$currency${value.toStringAsFixed(2)}",
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: color),
        ),
      ],
    );
  }

  pw.Widget _buildPdfHeader(String text, {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
        textAlign: align,
      ),
    );
  }
}
