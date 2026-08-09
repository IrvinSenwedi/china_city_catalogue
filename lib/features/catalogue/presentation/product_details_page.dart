import 'package:flutter/material.dart';

import '../models/product.dart';

class ProductDetailsPage extends StatelessWidget {
  const ProductDetailsPage({
    super.key,
    required this.product,
  });

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.4,
              child: Container(
                width: double.infinity,
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,
                child: product.imageUrl != null
                    ? Image.network(
                        product.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, error, stackTrace) =>
                            const Icon(
                          Icons.shopping_bag_outlined,
                          size: 80,
                        ),
                      )
                    : const Icon(
                        Icons.shopping_bag_outlined,
                        size: 80,
                      ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    product.categoryName,
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    product.name,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium,
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'R${product.price.toStringAsFixed(2)}',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      const Icon(
                        Icons.storefront_outlined,
                      ),
                      const SizedBox(width: 8),
                      Text(product.storeName),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      const Icon(
                        Icons.inventory_2_outlined,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${product.stockLabel} '
                        '(${product.stockQuantity} available)',
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Description',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium,
                  ),

                  const SizedBox(height: 8),

                  Text(product.description),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: product.isAvailable
                          ? () {
                              // Reservation comes next.
                            }
                          : null,
                      child: Text(
                        product.isAvailable
                            ? 'Reserve Product'
                            : 'Out of Stock',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}