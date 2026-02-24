import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_hub/controllers/company_controller.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final CompanyController controller = Get.find<CompanyController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Overview', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildSummaryGrid(controller.stats),
          const SizedBox(height: 30),
          const Text('Sales Trend', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Container(
            height: 200,
            decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16)),
            child: const Center(child: Text('Sales Chart Placeholder\n(Install fl_chart for graphs)', textAlign: TextAlign.center)),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryGrid(Map<String, dynamic> stats) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 2;
        if (constraints.maxWidth > 800) crossAxisCount = 4;

        return Obx(
          () => GridView.count(
            crossAxisCount: crossAxisCount,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard('Total Products', '${stats['products'] ?? 0}', Colors.blue, FontAwesomeIcons.boxesStacked),
              _buildStatCard('Pending Orders', '${stats['pending_orders'] ?? 0}', Colors.orange, FontAwesomeIcons.clock),
              _buildStatCard('Open Requests', '${stats['open_requests'] ?? 0}', Colors.purple, FontAwesomeIcons.bullhorn),
              _buildStatCard(
                "Today's Sales",
                "${Get.find<CompanyController>().effectiveCurrency.symbol}${stats['sales_today'] ?? 0}",
                Colors.green,
                FontAwesomeIcons.dollarSign,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const Spacer(),
          Text(
            value,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
          ),
          Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }
}
