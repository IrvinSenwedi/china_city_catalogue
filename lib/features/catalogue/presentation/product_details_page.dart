import 'package:china_city_catalogue/features/recommendations/providers/recommendation_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../reservations/providers/reservation_providers.dart';
import '../models/product.dart';

class ProductDetailsPage extends ConsumerStatefulWidget {
  const ProductDetailsPage({super.key, required this.product});

  final Product product;

  @override
  ConsumerState<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends ConsumerState<ProductDetailsPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      try {
        await ref.read(interactionRepositoryProvider).recordView(product.id);
      } catch (error) {
        debugPrint('Failed to record product view: $error');
      }
    });
  }

  bool isReserving = false;

  Product get product => widget.product;

  @override
  Widget build(BuildContext context) {
    final recommendationsAsync = ref.watch(
      productRecommendationsProvider(product.id),
    );

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.4,
              child: Container(
                width: double.infinity,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: product.imageUrl != null
                    ? Image.network(
                        product.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, error, stackTrace) =>
                            const Icon(Icons.shopping_bag_outlined, size: 80),
                      )
                    : const Icon(Icons.shopping_bag_outlined, size: 80),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.categoryName,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'R${product.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      const Icon(Icons.storefront_outlined),
                      const SizedBox(width: 8),
                      Text(product.storeName),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      const Icon(Icons.inventory_2_outlined),
                      const SizedBox(width: 8),
                      Text(
                        '${product.stockLabel} '
                        '(${product.stockQuantity} available)',
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),

                  const SizedBox(height: 8),

                  Text(product.description),

                  const SizedBox(height: 32),

                  Text(
                    'Recommended for You',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'AI-powered recommendations based on product similarity.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),

                  const SizedBox(height: 16),

                  recommendationsAsync.when(
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    ),

                    error: (error, _) => Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text('Recommendations unavailable.\n$error'),
                      ),
                    ),

                    data: (recommendations) {
                      if (recommendations.isEmpty) {
                        return const Text('No recommendations available.');
                      }

                      return SizedBox(
                        height: 170,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: recommendations.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final item = recommendations[index];

                            final name = item['name'] ?? 'Unknown Product';

                            final category = item['category'] ?? '';

                            final score =
                                (item['similarity_score'] as num?)
                                    ?.toDouble() ??
                                0;

                            return SizedBox(
                              width: 180,
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.auto_awesome),

                                      const SizedBox(height: 10),

                                      Text(
                                        name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),

                                      const SizedBox(height: 6),

                                      Text(
                                        category,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                      ),

                                      const Spacer(),

                                      Text(
                                        'Similarity: '
                                        '${(score * 100).toStringAsFixed(0)}%',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: !product.isAvailable || isReserving
                          ? null
                          : () => _reserveProduct(),
                      child: isReserving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Reserve Product'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _reserveProduct() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reserve Product'),
          content: Text('Reserve ${product.name} for collection?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() {
      isReserving = true;
    });

    try {
      await ref
          .read(reservationRepositoryProvider)
          .createReservation(productId: product.id, quantity: 1);

      try {
        await ref
            .read(interactionRepositoryProvider)
            .recordReservation(product.id);
      } catch (error) {
        debugPrint('Failed to record reservation interaction: $error');
      }

      ref.invalidate(myReservationsProvider);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product reserved successfully.')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Reservation failed: $error')));
    } finally {
      if (mounted) {
        setState(() {
          isReserving = false;
        });
      }
    }
  }
}
