import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:solar_hub/core/di/get_it.dart';
import 'package:solar_hub/features/accounting/controllers/accounting_controller.dart';
import 'package:solar_hub/controllers/company_controller.dart';
import 'package:solar_hub/features/accounting/screens/add_expense_dialog.dart';
import 'package:solar_hub/utils/app_theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:solar_hub/features/accounting/screens/add_payment_dialog.dart';

import 'package:solar_hub/features/accounting/screens/financial_details_page.dart';
import 'package:solar_hub/utils/price_format_utils.dart';

class AccountingPage extends StatelessWidget {
  const AccountingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Use GetIt to find the controller
    final AccountingController controller = getIt<AccountingController>();
    // Ensure data is fetched when page opens (idempotent check inside controller or just call it)
    controller.fetchAccountingData();

    return Scaffold(
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'print_btn',
            onPressed: () => controller.generateReport(context),
            backgroundColor: Colors.grey,
            child: const Icon(Icons.print, color: Colors.white),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'add_expense_btn',
            onPressed: () => showDialog(context: context, builder: (_) => const AddExpenseDialog()),
            backgroundColor: AppTheme.primaryColor,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 800;
          return Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // --- Summary Cards ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('financial_summary'.tr, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          // Date Filter Button
                          Obx(() {
                            final range = controller.selectedDateRange.value;
                            String label = 'all_time'.tr;
                            if (range != null) {
                              label = "${DateFormat('MMM dd').format(range.start)} - ${DateFormat('MMM dd').format(range.end)}";
                            }
                            return OutlinedButton.icon(
                              onPressed: () async {
                                final picked = await showDateRangePicker(
                                  context: context,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime.now(),
                                  initialDateRange: controller.selectedDateRange.value,
                                );
                                if (picked != null) {
                                  controller.setDateRange(picked);
                                }
                              },
                              icon: const Icon(Icons.calendar_today, size: 16),
                              label: Text(label),
                            );
                          }),
                        ],
                      ),
                      if (controller.selectedDateRange.value != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(onPressed: () => controller.setDateRange(null), child: Text('clear_filter'.tr)),
                          ),
                        ),

                      const SizedBox(height: 16),

                      GridView.count(
                        crossAxisCount: isDesktop ? 4 : 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        shrinkWrap: true, // Necessary inside SliverList or use SliverGrid
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: isDesktop ? 2.5 : 1.2,
                        children: [
                          _buildSummaryCard(
                            'income'.tr,
                            controller.totalIncome.value,
                            Colors.green,
                            FontAwesomeIcons.arrowUp,
                            isDesktop: isDesktop,
                            onTap: () => Get.to(() => const FinancialDetailsPage(type: FinancialDetailType.income)),
                          ),
                          _buildSummaryCard(
                            'expenses'.tr,
                            controller.totalExpenses.value,
                            Colors.red,
                            FontAwesomeIcons.arrowDown,
                            isDesktop: isDesktop,
                            onTap: () => Get.to(() => const FinancialDetailsPage(type: FinancialDetailType.expenses)),
                          ),
                          _buildSummaryCard(
                            'net_profit'.tr,
                            controller.netProfit.value,
                            Colors.blue,
                            FontAwesomeIcons.scaleBalanced,
                            isDesktop: isDesktop,
                            onTap: () => Get.to(() => const FinancialDetailsPage(type: FinancialDetailType.profit)),
                          ),
                          _buildSummaryCard(
                            'debts'.tr,
                            controller.totalDebts.value,
                            Colors.orange,
                            FontAwesomeIcons.fileInvoiceDollar,
                            isDesktop: isDesktop,
                            onTap: () => Get.to(() => const FinancialDetailsPage(type: FinancialDetailType.debts)),
                          ),
                          _buildActionCard(
                            context,
                            title: 'receive_payment'.tr,
                            icon: Icons.payment,
                            color: Colors.green,
                            onTap: () async {
                              final res = await showDialog(context: context, builder: (_) => const AddPaymentDialog());
                              if (res == true) {
                                controller.fetchAccountingData();
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Recent Transactions Chart
                      if (isDesktop || controller.expenses.isNotEmpty) ...[
                        Text('analytics'.tr, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        Container(
                          height: 300,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16)),
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY:
                                  (controller.totalIncome.value > controller.totalExpenses.value
                                      ? controller.totalIncome.value
                                      : controller.totalExpenses.value) *
                                  1.2,
                              barTouchData: BarTouchData(enabled: false),
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (double value, TitleMeta meta) {
                                      if (value == 0) return Text('income'.tr);
                                      if (value == 1) return Text('expenses'.tr);
                                      return const Text('');
                                    },
                                  ),
                                ),
                                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                              borderData: FlBorderData(show: false),
                              barGroups: [
                                BarChartGroupData(
                                  x: 0,
                                  barRods: [
                                    BarChartRodData(toY: controller.totalIncome.value, color: Colors.green, width: 40, borderRadius: BorderRadius.circular(4)),
                                  ],
                                ),
                                BarChartGroupData(
                                  x: 1,
                                  barRods: [
                                    BarChartRodData(toY: controller.totalExpenses.value, color: Colors.red, width: 40, borderRadius: BorderRadius.circular(4)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],

                      // --- Transactions List Header ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [Text('recent_transactions'.tr, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))],
                      ),
                      const SizedBox(height: 16),

                      // Search Bar
                      TextField(
                        onChanged: (val) => controller.searchQuery.value = val,
                        decoration: InputDecoration(
                          hintText: 'search_expenses'.tr,
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          filled: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ]),
                  ),
                ),
                // Optimized List: SliverList instead of nested ListView
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final expense = controller.filteredExpenses[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.red.withValues(alpha: 0.1),
                            child: const Icon(FontAwesomeIcons.receipt, color: Colors.red, size: 16),
                          ),
                          title: Text(expense.category.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("${DateFormat('yyyy-MM-dd').format(expense.date)} • ${expense.description ?? ''}"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "-${expense.amount.toPriceWithCurrency(Get.find<CompanyController>().effectiveCurrency.symbol)}",
                                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
                                onPressed: () => _confirmDelete(controller, expense.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    }, childCount: controller.filteredExpenses.length),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 80)), // Bottom padding
              ],
            );
          });
        },
      ),
    );
  }

  Widget _buildSummaryCard(String title, double value, Color color, IconData icon, {required bool isDesktop, VoidCallback? onTap}) {
    // Enhanced visual design with Gradient and Shadow
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: isDesktop ? 20 : 12, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(colors: [color.withValues(alpha: 0.8), color], begin: Alignment.topLeft, end: Alignment.bottomRight),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: Colors.white, size: isDesktop ? 28 : 18),
                Text(
                  title.toUpperCase(),
                  style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: isDesktop ? 12 : 10),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Get.locale?.languageCode == 'ar' ? Alignment.centerRight : Alignment.centerLeft,
                child: Text(
                  value.toPriceWithCurrency(Get.find<CompanyController>().effectiveCurrency.symbol),
                  style: TextStyle(fontSize: isDesktop ? 28 : 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, {required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.1),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
