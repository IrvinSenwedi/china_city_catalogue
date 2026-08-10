import 'package:flutter/material.dart';

class ProductPlaceholder extends StatelessWidget {
  const ProductPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.shopping_bag_outlined,
        size: 48,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
