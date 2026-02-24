import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_hub/features/accounting/controllers/accounting_controller.dart';
import 'package:solar_hub/controllers/company_controller.dart';
import 'package:solar_hub/features/invoices/screens/invoice_details_page.dart';
import 'package:solar_hub/utils/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:solar_hub/features/orders/models/order_model.dart';
import 'package:solar_hub/models/expense_model.dart'; // ExpenseModel import

import 'package:solar_hub/core/di/get_it.dart';
import 'package:solar_hub/utils/price_format_utils.dart';

enum FinancialDetailType { income, expenses, debts, profit }

class FinancialDetailsPage extends StatefulWidget {
  final FinancialDetailType type;

  const FinancialDetailsPage({super.key, required this.type});

  @override
  State<FinancialDetailsPage> createState() => _FinancialDetailsPageState();
}

class _FinancialDetailsPageState extends State<FinancialDetailsPage> {
  late final AccountingController controller;

  @override
  void initState() {
    super.initState();
    controller = getIt<AccountingController>();
    _fetchDataIfNeeded();
  }

  void _fetchDataIfNeeded() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Determine if we need to fetch detailed data based on the type
      if (widget.type == FinancialDetailType.income || widget.type == FinancialDetailType.profit) {
        // Fetch full income details (orders with items)
        controller.fetchIncomeDetails();
      } else if (widget.type == FinancialDetailType.debts) {
        // Fetch full debt details (unpaid orders)
        controller.fetchDebtDetails();
      }
      // Expense details are already fetched in the main controller initialization (fetchAccountingData)
    });
  }

  @override
  Widget build(BuildContext context) {
    String title = '';
    Color themeColor = AppTheme.primaryColor;

    switch (widget.type) {
      case FinancialDetailType.income:
        title = 'income'.tr;
        themeColor = Colors.green;
        break;
      case FinancialDetailType.expenses:
        title = 'expenses'.tr;
        themeColor = Colors.red;
        break;
      case FinancialDetailType.debts:
        title = 'unpaid_customers'.tr;
        themeColor = Colors.orange;
        break;
      case FinancialDetailType.profit:
        title = 'profit_analysis'.tr;
        themeColor = Colors.blue;
        break;
    }

    return Scaffold(
      appBar: AppBar(title: Text(title), backgroundColor: themeColor, foregroundColor: Colors.white),
      body: Column(
        children: [
          _buildFilterHeader(context, themeColor, controller),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (widget.type == FinancialDetailType.expenses) {
                return _buildExpensesList(controller);
              } else if (widget.type == FinancialDetailType.debts) {
                return _buildDebtsList(context, controller);
              } else if (widget.type == FinancialDetailType.income) {
                return _buildIncomeList(context, controller);
              } else {
                return _buildProfitView(context, controller);
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterHeader(BuildContext context, Color color, AccountingController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'search_products'.tr, // Reusing generic search hint or 'search_expenses'
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  ),
                  onChanged: (val) => controller.detailSearchQuery.value = val,
                ),
              ),
              const SizedBox(width: 12),
              Obx(
                () => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: controller.detailFilterType.value,
                      icon: Icon(Icons.filter_list, color: color),
                      items: [
                        DropdownMenuItem(value: 'total', child: Text('all'.tr)), // "total" key maps to "Total/All" logic
                        DropdownMenuItem(value: 'week', child: Text('week'.tr)),
                        DropdownMenuItem(value: 'month', child: Text('month'.tr)),
                        DropdownMenuItem(value: 'year', child: Text('year'.tr)),
                      ],
                      onChanged: (val) {
                        if (val != null) controller.detailFilterType.value = val;
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfitView(BuildContext context, AccountingController controller) {
    final filteredInc = controller.filteredValuesIncome;
    final filteredExp = controller.filteredValuesExpenses;

    final income = filteredInc.fold(0.0, (sum, item) => sum + (item['total_amount'] as num).toDouble());
    final expenses = filteredExp.fold(0.0, (sum, item) => sum + item.amount);
    final profit = income - expenses;
    final margin = income > 0 ? (profit / income) * 100 : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Key Metrics Cards
          Row(
            children: [
              Expanded(child: _buildMetricCard('net_profit'.tr, profit, Colors.blue, Icons.scale)),
              const SizedBox(width: 16),
              Expanded(child: _buildMetricCard('profit_margin'.tr, margin, margin >= 0 ? Colors.green : Colors.red, Icons.percent, isPercent: true)),
            ],
          ),
          const SizedBox(height: 24),

          // 2. Pie Chart: Income vs Expenses
          if (income > 0 || expenses > 0) ...[
            Text('income_vs_expenses'.tr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 1.3,
              child: Row(
                children: [
                  const Spacer(),
                  Expanded(
                    flex: 4,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: [
                          if (income > 0)
                            PieChartSectionData(
                              color: Colors.green,
                              value: income,
                              title: '${((income / (income + expenses)) * 100).toStringAsFixed(1)}%',
                              radius: 50,
                              titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          if (expenses > 0)
                            PieChartSectionData(
                              color: Colors.red,
                              value: expenses,
                              title: '${((expenses / (income + expenses)) * 100).toStringAsFixed(1)}%',
                              radius: 50,
                              titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [_buildLegendItem('income'.tr, Colors.green), const SizedBox(height: 8), _buildLegendItem('expenses'.tr, Colors.red)],
                  ),
                  const Spacer(),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // 3. Top Expense Categories
          Text('top_expenses'.tr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildTopExpensesList(filteredExp, expenses),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, double value, Color color, IconData icon, {bool isPercent = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              isPercent ? "${value.toStringAsFixed(1)}%" : value.toPriceWithCurrency(Get.find<CompanyController>().effectiveCurrency.symbol),
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildTopExpensesList(List<ExpenseModel> expenses, double totalExp) {
    if (expenses.isEmpty) return Text('no_data'.tr);

    final Map<String, double> categoryTotals = {};
    for (var e in expenses) {
      categoryTotals[e.category] = (categoryTotals[e.category] ?? 0) + e.amount;
    }

    final sortedKeys = categoryTotals.keys.toList()..sort((a, b) => categoryTotals[b]!.compareTo(categoryTotals[a]!));

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedKeys.length > 5 ? 5 : sortedKeys.length,
      itemBuilder: (context, index) {
        final cat = sortedKeys[index];
        final total = categoryTotals[cat]!;
        final percent = totalExp > 0 ? (total / totalExp) : 0.0;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(cat.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                  Text("${total.toPriceWithCurrency(Get.find<CompanyController>().effectiveCurrency.symbol)} (${(percent * 100).toStringAsFixed(1)}%)"),
                ],
              ),
              const SizedBox(height: 6),
              LinearProgressIndicator(value: percent, backgroundColor: Colors.grey[200], color: Colors.red, borderRadius: BorderRadius.circular(4)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExpensesList(AccountingController controller) {
    final list = controller.filteredValuesExpenses; // Use getter
    if (list.isEmpty) return Center(child: Text('no_data'.tr));

    return ListView.builder(
      itemCount: list.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final expense = list[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: Colors.red.withValues(alpha: 0.1),
              child: const Icon(Icons.arrow_downward, color: Colors.red),
            ),
            title: Text(expense.category.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (expense.description != null && expense.description!.isNotEmpty) Text(expense.description!, style: const TextStyle(fontSize: 13)),
                Text(DateFormat('MMM dd, yyyy').format(expense.date), style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  expense.amount.toPriceWithCurrency(Get.find<CompanyController>().effectiveCurrency.symbol),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  onPressed: () => _confirmDelete(controller, expense.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDebtsList(BuildContext context, AccountingController controller) {
    final list = controller.filteredValuesDebts; // Use getter
    if (list.isEmpty) return Center(child: Text('no_unpaid_orders'.tr));

    return ListView.builder(
      itemCount: list.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final item = list[index];
        final name = item['customer_name'] ?? 'unknown'.tr;
        final phone = item['phone'];
        final count = item['order_count'];
        final total = (item['total_debt'] as double);

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: Colors.orange.withValues(alpha: 0.1),
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (phone != null && phone.toString().isNotEmpty) Text(phone!.toString(), style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text("${'orders_count'.tr}: $count", style: const TextStyle(fontSize: 12, color: Colors.orange)),
                ),
              ],
            ),
            trailing: Text(
              total.toPriceWithCurrency(Get.find<CompanyController>().effectiveCurrency.symbol),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red),
            ),
            onTap: () => _showUnpaidOrdersDialog(context, item),
          ),
        );
      },
    );
  }

  Widget _buildIncomeList(BuildContext context, AccountingController controller) {
    final list = controller.filteredValuesIncome; // Use getter
    if (list.isEmpty) return Center(child: Text('no_data'.tr));

    return ListView.builder(
      itemCount: list.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final orderMap = list[index];
        final total = (orderMap['total_amount'] as num).toDouble();
        final customer = orderMap['customers'];
        final name = customer != null ? customer['full_name'] : (orderMap['guest_customer_name'] ?? 'guest'.tr);
        final date = DateTime.tryParse(orderMap['created_at']) ?? DateTime.now();

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green.withValues(alpha: 0.1),
              child: const Icon(Icons.arrow_upward, color: Colors.green),
            ),
            title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(DateFormat('MMM dd, yyyy • hh:mm a').format(date)),
            trailing: Text(
              total.toPriceWithCurrency(Get.find<CompanyController>().effectiveCurrency.symbol),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green),
            ),
            onTap: () {
              try {
                final order = OrderModel.fromJson(orderMap);
                Get.to(() => InvoiceDetailsPage(order: order));
              } catch (e) {
                Get.snackbar('err_error'.tr, "${'could_not_open_details'.trParams({'error': e.toString()})}");
              }
            },
          ),
        );
      },
    );
  }

  void _showUnpaidOrdersDialog(BuildContext context, Map<String, dynamic> customerItem) {
    final orders = (customerItem['orders'] as List<dynamic>?) ?? [];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${customerItem['customer_name']} - ${'unpaid_orders'.tr}'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final orderMap = orders[index];
              final total = (orderMap['total_amount'] as num).toDouble();
              final date = DateTime.tryParse(orderMap['created_at']) ?? DateTime.now();

              return ListTile(
                title: Text("${'order_label'.tr} #${orderMap['order_number'] ?? orderMap['id'].toString().substring(0, 8).toUpperCase()}"),
                subtitle: Text(DateFormat('yyyy-MM-dd').format(date)),
                trailing: Text(
                  total.toPriceWithCurrency(Get.find<CompanyController>().effectiveCurrency.symbol),
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  try {
                    final order = OrderModel.fromJson(orderMap);
                    Navigator.pop(context); // Close dialog
                    Get.to(() => InvoiceDetailsPage(order: order));
                  } catch (e) {
                    Get.snackbar('err_error'.tr, "${'could_not_open_details'.trParams({'error': e.toString()})}");
                  }
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('close'.tr)), // Needs 'close' key or generic 'cancel'
        ],
      ),
    );
  }

  void _confirmDelete(AccountingController controller, String id) {
    Get.dialog(
      AlertDialog(
        title: Text('confirm'.tr),
        content: Text('confirm_delete_expense'.tr),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          TextButton(
            onPressed: () {
              controller.deleteExpense(id);
              Get.back();
            },
            child: Text('delete'.tr, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
