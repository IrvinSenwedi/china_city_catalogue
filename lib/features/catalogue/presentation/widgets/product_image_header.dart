import 'package:flutter/material.dart';

import '../../models/product.dart';
import 'product_placeholder.dart';
import 'stock_badge.dart';

class ProductImageHeader extends StatelessWidget {
  const ProductImageHeader({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      child: AspectRatio(
        aspectRatio: 1.12,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(
              color: const Color(0xFFF8F4F2),
              child: product.imageUrl != null
                  ? Image.network(
                      product.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const ProductPlaceholder(),
                    )
                  : const ProductPlaceholder(),
            ),
            Positioned(
              right: 16,
              bottom: 16,
              child: StockBadge(product: product),
            ),
          ],
        ),
      ),
    );
  }
}
