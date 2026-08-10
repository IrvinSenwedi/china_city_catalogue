import 'package:flutter/material.dart';

import '../../models/product.dart';

class ProductStockInfo extends StatelessWidget {
  const ProductStockInfo({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final IconData icon;

    if (product.stockQuantity <= 0) {
      icon = Icons.cancel_outlined;
    } else if (product.stockQuantity <= 5) {
      icon = Icons.warning_amber_rounded;
    } else {
      icon = Icons.check_circle_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 7),
          Text(
            '${product.stockLabel} · '
            '${product.stockQuantity} available',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
