import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/retailer_providers.dart';
import 'add_product_page.dart';
import 'widgets/retailer_product_card.dart';
import 'widgets/retailer_products_empty_state.dart';
import 'widgets/retailer_products_error_view.dart';

class RetailerProductsPage extends ConsumerWidget {
  const RetailerProductsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(retailerProductsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Products')),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddProductPage()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),

      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (_, __) => RetailerProductsErrorView(
          onRetry: () {
            ref.invalidate(retailerProductsProvider);
          },
        ),

        data: (products) {
          if (products.isEmpty) {
            return const RetailerProductsEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(retailerProductsProvider);

              await ref.read(retailerProductsProvider.future);
            },
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: products.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return RetailerProductCard(product: products[index]);
              },
            ),
          );
        },
      ),
    );
  }
}
