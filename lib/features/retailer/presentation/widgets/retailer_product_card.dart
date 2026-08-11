import 'package:china_city_catalogue/features/catalogue/models/product.dart';
import 'package:flutter/material.dart';
import '../edit_product_page.dart';

class RetailerProductCard extends StatelessWidget {
  const RetailerProductCard({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EditProductPage(product: product),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.inventory_2_outlined),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      product.categoryName,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        _StockIndicator(product: product),

                        const SizedBox(width: 8),

                        Text(
                          '${product.stockQuantity} units',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'R${product.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Icon(Icons.edit_outlined, size: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StockIndicator extends StatelessWidget {
  const _StockIndicator({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    IconData icon;

    if (product.stockQuantity <= 0) {
      icon = Icons.cancel_outlined;
    } else if (product.stockQuantity <= 5) {
      icon = Icons.warning_amber_rounded;
    } else {
      icon = Icons.check_circle_outline;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15),
        const SizedBox(width: 4),
        Text(
          product.stockLabel,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
