import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/product.dart';
import '../product_details_page.dart';

class SimilarProductsSection extends StatelessWidget {
  const SimilarProductsSection({
    super.key,
    required this.recommendationsAsync,
    required this.products,
  });

  final AsyncValue<List<Map<String, dynamic>>> recommendationsAsync;
  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.auto_awesome, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'You May Also Like',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Similar products selected by our '
                    'recommendation system.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        recommendationsAsync.when(
          loading: () => const SizedBox(
            height: 150,
            child: Center(child: CircularProgressIndicator()),
          ),

          error: (_, __) => Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('Similar products are temporarily unavailable.'),
          ),

          data: (recommendations) {
            if (recommendations.isEmpty) {
              return const Text('No similar products available yet.');
            }

            return SizedBox(
              height: 155,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: recommendations.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final item = recommendations[index];

                  final productId = item['id'] as String?;

                  Product? matchedProduct;

                  for (final product in products) {
                    if (product.id == productId) {
                      matchedProduct = product;
                      break;
                    }
                  }

                  return _SimilarProductCard(
                    name: item['name'] ?? 'Product',
                    category: item['category'] ?? '',
                    product: matchedProduct,
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class _SimilarProductCard extends StatelessWidget {
  const _SimilarProductCard({
    required this.name,
    required this.category,
    required this.product,
  });

  final String name;
  final String category;
  final Product? product;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 175,
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: product == null
              ? null
              : () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailsPage(product: product!),
                    ),
                  );
                },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.auto_awesome, size: 17),
                ),

                const SizedBox(height: 12),

                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),

                const Spacer(),

                Text(
                  category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),

                const SizedBox(height: 4),

                Row(
                  children: [
                    Text(
                      'Similar product',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_forward, size: 15),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
