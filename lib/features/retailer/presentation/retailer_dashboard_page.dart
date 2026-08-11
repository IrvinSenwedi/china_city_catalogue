import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_providers.dart';
import '../providers/retailer_providers.dart';
import 'retailer_products_page.dart';
import 'retailer_reservations_page.dart';
import 'widgets/retailer_action_card.dart';
import 'widgets/retailer_dashboard_header.dart';
import 'widgets/retailer_summary_card.dart';

class RetailerDashboardPage extends ConsumerWidget {
  const RetailerDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(retailerProductsProvider);

    final reservationsAsync = ref.watch(retailerReservationsProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(retailerProductsProvider);

            ref.invalidate(retailerReservationsProvider);

            await Future.wait([
              ref.read(retailerProductsProvider.future),
              ref.read(retailerReservationsProvider.future),
            ]);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              RetailerDashboardHeader(
                onSignOut: () async {
                  await ref.read(authRepositoryProvider).signOut();
                },
              ),

              const SizedBox(height: 28),

              Text(
                'Overview',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              productsAsync.when(
                loading: () => const _SummaryLoading(),
                error: (_, __) => const _SummaryError(),
                data: (products) {
                  final lowStockCount = products.where((product) {
                    return product.stockQuantity > 0 &&
                        product.stockQuantity <= 5;
                  }).length;

                  final pendingCount = reservationsAsync.maybeWhen(
                    data: (reservations) {
                      return reservations
                          .where(
                            (reservation) => reservation['status'] == 'PENDING',
                          )
                          .length;
                    },
                    orElse: () => 0,
                  );

                  return Row(
                    children: [
                      RetailerSummaryCard(
                        title: 'Products',
                        value: '${products.length}',
                        icon: Icons.inventory_2_outlined,
                      ),

                      const SizedBox(width: 10),

                      RetailerSummaryCard(
                        title: 'Pending',
                        value: '$pendingCount',
                        icon: Icons.schedule_outlined,
                      ),

                      const SizedBox(width: 10),

                      RetailerSummaryCard(
                        title: 'Low Stock',
                        value: '$lowStockCount',
                        icon: Icons.warning_amber_rounded,
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 32),

              Text(
                'Store Management',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              RetailerActionCard(
                title: 'Products',
                description: 'Add products, edit details and update stock.',
                icon: Icons.inventory_2_outlined,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RetailerProductsPage(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              RetailerActionCard(
                title: 'Reservations',
                description: 'Review and manage customer reservations.',
                icon: Icons.receipt_long_outlined,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RetailerReservationsPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryLoading extends StatelessWidget {
  const _SummaryLoading();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 120,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _SummaryError extends StatelessWidget {
  const _SummaryError();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.error_outline),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Unable to load store overview.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
