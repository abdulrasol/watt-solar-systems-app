import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_hub/controllers/subscription_controller.dart';
import 'package:solar_hub/utils/app_theme.dart';
import 'package:solar_hub/models/subscription_model.dart';
import 'package:intl/intl.dart';

class SubscriptionPage extends StatelessWidget {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SubscriptionController());

    return Scaffold(
      appBar: AppBar(title: Text('subscription'.tr)),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCurrentStatus(context, controller),
              const SizedBox(height: 32),
              Text("available_plans".tr, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildPlansGrid(context, controller),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCurrentStatus(BuildContext context, SubscriptionController controller) {
    if (!controller.isSubscriptionActive.value || controller.currentSubscription.value == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.redAccent),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 32),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "subscription_inactive".tr,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                    const SizedBox(height: 4),
                    Text("inactive_msg".tr),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    }

    final sub = controller.currentSubscription.value!;
    final dateFormat = DateFormat.yMMMd();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: AppTheme.primaryColor, size: 32),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "active_subscription".tr,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                  ),
                  const SizedBox(height: 4),
                  Text("${'expires_on'.tr}: ${dateFormat.format(sub.endDate)}"),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlansGrid(BuildContext context, SubscriptionController controller) {
    if (controller.plans.isEmpty) {
      return Center(child: Text("no_plans_available".tr));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 900 ? 3 : (constraints.maxWidth > 600 ? 2 : 1);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.8,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: controller.plans.length,
          itemBuilder: (context, index) {
            final plan = controller.plans[index];
            return _buildPlanCard(context, plan, controller);
          },
        );
      },
    );
  }

  Widget _buildPlanCard(BuildContext context, SubscriptionPlanModel plan, SubscriptionController controller) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              plan.name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              "\$${plan.price.toStringAsFixed(2)}",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
            ),
            const SizedBox(height: 8),
            Text("${plan.durationDays} days access", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
            const SizedBox(height: 24),
            Text(plan.description ?? "", textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => _confirmSubscription(context, plan, controller),
                child: Text("subscribe_now".tr),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmSubscription(BuildContext context, SubscriptionPlanModel plan, SubscriptionController controller) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("confirm_subscription".tr),
        content: Text("confirm_sub_msg".tr.replaceAll('@plan', plan.name).replaceAll('@price', "\$${plan.price}")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("cancel".tr)),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              controller.subscribe(plan);
            },
            child: Text("confirm".tr),
          ),
        ],
      ),
    );
  }
}
