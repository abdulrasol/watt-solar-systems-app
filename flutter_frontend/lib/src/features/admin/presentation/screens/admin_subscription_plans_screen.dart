import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:watt/src/features/admin/domain/models/admin_subscription_plan.dart';
import 'package:watt/src/features/admin/presentation/controllers/admin_subscriptions_controller.dart';
import 'package:watt/src/features/admin/presentation/widgets/admin_page_scaffold.dart';
import 'package:watt/src/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:watt/src/utils/app_theme.dart';
import 'package:watt/src/utils/helper_methods.dart';

class AdminSubscriptionPlansScreen extends ConsumerStatefulWidget {
  const AdminSubscriptionPlansScreen({super.key});

  @override
  ConsumerState<AdminSubscriptionPlansScreen> createState() => _AdminSubscriptionPlansScreenState();
}

class _AdminSubscriptionPlansScreenState extends ConsumerState<AdminSubscriptionPlansScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(adminSubscriptionsProvider.notifier).fetchPlans(isRefresh: true));
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(adminSubscriptionsProvider.notifier).fetchNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminSubscriptionsProvider);

    return AdminPageScaffold(
      actions: [
        ElevatedButton.icon(
          onPressed: () => _showPlanDialog(context, ref),
          icon: const Icon(Icons.add),
          label: const Text('Add Plan'),
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white),
        ),
      ],
      child: state.isLoading
          ? const AdminLoadingState()
          : state.plans.isEmpty
          ? const AdminEmptyState(icon: Iconsax.card, title: 'No subscription plans found', subtitle: 'Add your first pricing tier to get started.')
          : RefreshIndicator(
              onRefresh: () => ref.read(adminSubscriptionsProvider.notifier).fetchPlans(isRefresh: true),
              child: ListView.separated(
                controller: _scrollController,
                padding: EdgeInsets.all(16.w),
                itemCount: state.plans.length + (state.isMoreLoading ? 1 : 0),
                separatorBuilder: (context, index) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  if (index == state.plans.length) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final plan = state.plans[index];
                  return _buildPlanCard(context, ref, plan);
                },
              ),
            ),
    );
  }

  Widget _buildPlanCard(BuildContext context, WidgetRef ref, AdminSubscriptionPlan plan) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        leading: Container(
          width: 48.w,
          height: 48.w,
          decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(Iconsax.medal, color: AppTheme.primaryColor, size: 24.sp),
        ),
        title: Text(
          plan.name,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4.h),
            Text(
              '${plan.price} / ${plan.durationDays} days',
              style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600),
            ),
            if (plan.features.isNotEmpty) ...[
              SizedBox(height: 4.h),
              Text(
                plan.features.entries.map((e) => '${e.key}: ${e.value}').join(', '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12.sp, color: Colors.grey),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Iconsax.edit_2, color: Colors.blue),
              onPressed: () => _showPlanDialog(context, ref, plan: plan),
            ),
            IconButton(
              icon: const Icon(Iconsax.trash, color: Colors.red),
              onPressed: () => _confirmDelete(context, ref, plan),
            ),
          ],
        ),
      ),
    );
  }

  void _showPlanDialog(BuildContext context, WidgetRef ref, {AdminSubscriptionPlan? plan}) {
    final nameController = TextEditingController(text: plan?.name);
    final priceController = TextEditingController(text: plan?.price.toString());
    final durationController = TextEditingController(text: plan?.durationDays.toString() ?? '30');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(plan == null ? 'Add Subscription Plan' : 'Edit Plan'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Plan Name (e.g. Pro)'),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: durationController,
                decoration: const InputDecoration(labelText: 'Duration (days)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final data = {
                'name': nameController.text,
                'price': double.tryParse(priceController.text) ?? 0.0,
                'duration_days': int.tryParse(durationController.text) ?? 30,
                'is_active': true,
                'features': plan?.features ?? {},
              };

              try {
                if (plan == null) {
                  await ref.read(adminSubscriptionsProvider.notifier).createPlan(data);
                } else {
                  await ref.read(adminSubscriptionsProvider.notifier).updatePlan(plan.id, data);
                }
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                if (context.mounted) dPrint('Error saving plan: $e');
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, AdminSubscriptionPlan plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Plan'),
        content: Text('Are you sure you want to delete "${plan.name}"? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await ref.read(adminSubscriptionsProvider.notifier).deletePlan(plan.id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
