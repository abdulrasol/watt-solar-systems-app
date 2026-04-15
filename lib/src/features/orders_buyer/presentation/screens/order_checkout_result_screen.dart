import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/orders_core/domain/entities/order_models.dart';
import 'package:solar_hub/src/features/orders_core/presentation/widgets/order_widgets.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class OrderCheckoutResultScreen extends StatelessWidget {
  final OrderRecord order;

  const OrderCheckoutResultScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.order_placed)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ResponsiveContent(
            child: SectionCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: AppTheme.successColor,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.order_placed,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text('${l10n.order_number}: #${order.orderNumber}'),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.go(
                        '/storefront/${order.isB2b ? 'b2b' : 'b2c'}/orders',
                      ),
                      child: Text(l10n.my_orders),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
