import 'package:china_city_catalogue/features/catalogue/presentation/widgets/collection_time_sheet.dart';
import 'package:china_city_catalogue/features/recommendations/providers/recommendation_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../reservations/providers/reservation_providers.dart';
import '../models/product.dart';
import '../providers/catalogue_providers.dart';
import 'widgets/product_image_header.dart';
import 'widgets/product_info_section.dart';
import 'widgets/reserve_product_button.dart';
import 'widgets/similar_products_section.dart';

class ProductDetailsPage extends ConsumerStatefulWidget {
  const ProductDetailsPage({super.key, required this.product});

  final Product product;

  @override
  ConsumerState<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends ConsumerState<ProductDetailsPage> {
  bool isReserving = false;

  Product get product => widget.product;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      try {
        await ref.read(interactionRepositoryProvider).recordView(product.id);

        ref.invalidate(userRecommendationsProvider);
      } catch (error) {
        debugPrint('Failed to record product view: $error');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final recommendationsAsync = ref.watch(
      productRecommendationsProvider(product.id),
    );
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Product Details')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProductImageHeader(product: product),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProductInfoSection(product: product),

                  const SizedBox(height: 36),

                  productsAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => SimilarProductsSection(
                      recommendationsAsync: recommendationsAsync,
                      products: const [],
                    ),
                    data: (products) => SimilarProductsSection(
                      recommendationsAsync: recommendationsAsync,
                      products: products,
                    ),
                  ),

                  const SizedBox(height: 36),

                  ReserveProductButton(
                    isAvailable: product.isAvailable,
                    isReserving: isReserving,
                    onPressed: _reserveProduct,
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _reserveProduct() async {
    final collectionAt = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const CollectionTimeSheet(),
    );

    if (collectionAt == null) return;

    final expiry = collectionAt.add(const Duration(minutes: 30));

    String formatTime(DateTime value) {
      return '${value.hour.toString().padLeft(2, '0')}:'
          '${value.minute.toString().padLeft(2, '0')}';
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Reservation'),
          content: Text(
            'Reserve ${product.name} for collection '
            'at ${formatTime(collectionAt)}?\n\n'
            'The product will be held until '
            '${formatTime(expiry)}.',
          ),
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
              child: const Text('Reserve'),
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
          .createReservation(
            productId: product.id,
            quantity: 1,
            collectionAt: collectionAt,
          );

      try {
        await ref
            .read(interactionRepositoryProvider)
            .recordReservation(product.id);

        ref.invalidate(userRecommendationsProvider);
      } catch (error) {
        debugPrint(
          'Failed to record reservation '
          'interaction: $error',
        );
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
