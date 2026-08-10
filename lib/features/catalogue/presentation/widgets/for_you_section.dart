import 'package:flutter/material.dart';

import '../../models/product.dart';
import '../product_details_page.dart';
import 'catalogue_section_header.dart';

class ForYouSection extends StatelessWidget {
  const ForYouSection({
    super.key,
    required this.recommendations,
    required this.products,
  });

  final List<Map<String, dynamic>> recommendations;

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    if (recommendations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: CatalogueSectionHeader(
              title: 'For You',
              subtitle: 'Personalised from your activity',
              icon: Icons.auto_awesome,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 190,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: recommendations.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final recommendation = recommendations[index];

                final productId = recommendation['id'] as String?;

                final reason =
                    recommendation['reason'] ??
                    'Recommended based on your activity.';

                Product? product;

                for (final item in products) {
                  if (item.id == productId) {
                    product = item;
                    break;
                  }
                }

                return _RecommendationCard(
                  recommendation: recommendation,
                  reason: reason,
                  product: product,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({
    required this.recommendation,
    required this.reason,
    required this.product,
  });

  final Map<String, dynamic> recommendation;

  final String reason;

  final Product? product;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: product == null
              ? null
              : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailsPage(product: product!),
                    ),
                  );
                },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
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
                    const Spacer(),
                    const Icon(Icons.arrow_forward, size: 18),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  recommendation['name'] ?? 'Product',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  recommendation['category'] ?? '',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Spacer(),
                Text(
                  reason,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
