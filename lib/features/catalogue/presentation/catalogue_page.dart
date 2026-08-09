import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/catalogue_providers.dart';

class CataloguePage extends ConsumerWidget {
  const CataloguePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('China City')),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Failed to load products.\n$error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (products) {
          if (products.isEmpty) {
            return const Center(child: Text('No products available'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final product = products[index];

              return Card(
                child: ListTile(
                  title: Text(product.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),

                      Text(product.storeName),

                      Text(product.categoryName),

                      const SizedBox(height: 4),

                      Text(product.stockLabel),
                    ],
                  ),
                  trailing: Text(
                    'R${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
