import 'package:flutter/material.dart';

import '../../models/product.dart';
import 'product_stock_info.dart';

class ProductInfoSection extends StatelessWidget {
  const ProductInfoSection({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.categoryName.toUpperCase(),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          product.name,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),

        Text(
          'R${product.price.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),

        const SizedBox(height: 22),

        Row(
          children: [
            const Icon(Icons.storefront_outlined, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                product.storeName,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        ProductStockInfo(product: product),

        const SizedBox(height: 28),

        Text(
          'About this product',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 8),

        Text(
          product.description,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            height: 1.5,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
