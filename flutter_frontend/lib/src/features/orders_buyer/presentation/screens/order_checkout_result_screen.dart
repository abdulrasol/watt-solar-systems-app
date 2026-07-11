import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:watt/l10n/app_localizations.dart';
import 'package:watt/src/features/orders_core/domain/entities/order_models.dart';
import 'package:watt/src/features/orders_core/presentation/widgets/order_widgets.dart';
import 'package:watt/src/features/storefront/domain/entities/storefront_models.dart';
import 'package:watt/src/utils/app_theme.dart';

class OrderCheckoutResultScreen extends StatelessWidget {
  final OrderRecord order;

  const OrderCheckoutResultScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.order_placed), automaticallyImplyLeading: false),
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
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  // Explains what happens next instead of leaving the user
                  // to guess after the checkmark, per the storefront UX
                  // pass's "clear next steps" goal for order confirmation.
                  Text(
                    l10n.order_placed_subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Theme.of(context).hintColor),
                  ),
                  const SizedBox(height: 16),
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
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => context.go(
                        '/storefront',
                        extra: order.isB2b ? StorefrontAudience.b2b : StorefrontAudience.b2c,
                      ),
                      child: Text(l10n.continue_shopping),
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
