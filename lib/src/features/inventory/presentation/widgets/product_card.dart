import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:solar_hub/src/features/inventory/domain/entities/product.dart';

class ProdcutCard extends StatelessWidget {
  const ProdcutCard({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final bool isOutOfStock = product.stockQuantity == 0;
    final bool isLowStock = product.stockQuantity <= product.minStockAlert && product.stockQuantity > 0;

    Color statusColor = Colors.green;
    String statusText = 'In Stock';
    // String statusText = l10n.in_stock;
    if (isOutOfStock) {
      statusColor = Colors.red;
      statusText = 'Out of Stock';
    } else if (isLowStock) {
      statusColor = Colors.orange;
      statusText = 'Low Stock';
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // TODO: Route to product details
          context.push('/company-dashboard/inventory/product/${product.id}', extra: product);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  image: product.productImages.isNotEmpty
                      ? DecorationImage(image: CachedNetworkImageProvider(product.productImages.first), fit: BoxFit.cover)
                      : null,
                ),
                child: product.productImages.isEmpty ? const Icon(Icons.image, size: 40, color: Colors.grey) : null,
              ),
              const SizedBox(width: 16),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text('SKU: ${product.sku ?? "N/A"}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        Text(
                          'Retail: \$${product.retailPrice.toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green[700]),
                        ),
                        Text('Cost: \$${product.costPrice.toStringAsFixed(2)}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(fontSize: 10, color: statusColor, fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (product.category?.name != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.blue.withValues(alpha: 0.5)),
                            ),
                            child: Text(
                              product.category!.name,
                              style: TextStyle(fontSize: 10, color: Colors.blue[700], fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Qty: ${product.stockQuantity}',
                  style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
