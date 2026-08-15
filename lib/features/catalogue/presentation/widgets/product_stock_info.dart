import 'package:flutter/material.dart';

import '../../models/product.dart';

class ProductStockInfo extends StatelessWidget {
  const ProductStockInfo({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final IconData icon;
    final Color foreground;
    final Color background;

    if (product.stockQuantity <= 0) {
      icon = Icons.cancel_outlined;
      foreground = const Color(0xFFB42318);
      background = const Color(0xFFFFE9E5);
    } else if (product.stockQuantity <= 5) {
      icon = Icons.warning_amber_rounded;
      foreground = const Color(0xFFB45309);
      background = const Color(0xFFFFF4D6);
    } else {
      icon = Icons.check_circle_outline;
      foreground = const Color(0xFF15803D);
      background = const Color(0xFFEAF8EE);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: foreground.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: foreground),
          const SizedBox(width: 7),
          Text(
            '${product.stockLabel} · '
            '${product.stockQuantity} available',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
