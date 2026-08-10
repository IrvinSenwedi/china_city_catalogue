import 'package:flutter/material.dart';

import '../../models/product.dart';
import 'product_placeholder.dart';

class ProductImageHeader extends StatelessWidget {
  const ProductImageHeader({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.25,
      child: Container(
        width: double.infinity,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: product.imageUrl != null
            ? Image.network(
                product.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const ProductPlaceholder(),
              )
            : const ProductPlaceholder(),
      ),
    );
  }
}
