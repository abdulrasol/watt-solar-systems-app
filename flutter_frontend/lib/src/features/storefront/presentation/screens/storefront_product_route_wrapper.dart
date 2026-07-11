import 'package:flutter/material.dart';
import 'package:watt/src/core/di/get_it.dart';
import 'package:watt/src/core/widgets/loading_widgets.dart';
import 'package:watt/src/features/storefront/domain/entities/storefront_models.dart';
import 'package:watt/src/features/storefront/domain/repositories/storefront_repository.dart';
import 'package:watt/src/features/storefront/presentation/screens/storefront_product_details_screen.dart';

class StorefrontProductRouteWrapper extends StatefulWidget {
  final int productId;
  final StorefrontAudience audience;

  const StorefrontProductRouteWrapper({
    super.key,
    required this.productId,
    required this.audience,
  });

  @override
  State<StorefrontProductRouteWrapper> createState() => _StorefrontProductRouteWrapperState();
}

class _StorefrontProductRouteWrapperState extends State<StorefrontProductRouteWrapper> {
  late Future<StorefrontProduct> _future;

  @override
  void initState() {
    super.initState();
    _future = getIt<StorefrontRepository>().getProduct(widget.productId, widget.audience);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StorefrontProduct>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: LoadingWidget.widget(context: context)),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Text(
                'Failed to load product',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          );
        }
        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Text(
                'Product not found',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          );
        }
        return StorefrontProductDetailsScreen(
          product: snapshot.data!,
          audience: widget.audience,
        );
      },
    );
  }
}

