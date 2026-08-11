import 'package:china_city_catalogue/features/retailer/presentation/widgets/retailer_reservation_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/retailer_providers.dart';
import 'widgets/retailer_reservation_card.dart';

class RetailerReservationsPage extends ConsumerWidget {
  const RetailerReservationsPage({super.key});

  Future<void> _updateStatus({
    required BuildContext context,
    required WidgetRef ref,
    required String reservationId,
    required String status,
  }) async {
    try {
      await ref
          .read(retailerRepositoryProvider)
          .updateReservationStatus(
            reservationId: reservationId,
            status: status,
          );

      ref.invalidate(retailerReservationsProvider);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reservation ${status.toLowerCase()} successfully.'),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update reservation: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reservationsAsync = ref.watch(retailerReservationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Reservations')),

      body: reservationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48),

                const SizedBox(height: 12),

                Text(
                  'Unable to load reservations',
                  style: Theme.of(context).textTheme.titleMedium,
                ),

                const SizedBox(height: 6),

                Text(
                  '$error',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),

                const SizedBox(height: 16),

                FilledButton.icon(
                  onPressed: () {
                    ref.invalidate(retailerReservationsProvider);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),

        data: (reservations) {
          if (reservations.isEmpty) {
            return const RetailerReservationsEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(retailerReservationsProvider);

              await ref.read(retailerReservationsProvider.future);
            },

            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              itemCount: reservations.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),

              itemBuilder: (context, index) {
                final reservation = reservations[index];

                final reservationId = reservation['id'] as String;

                final quantity = reservation['quantity'] ?? 1;

                final status = reservation['status'] ?? 'PENDING';

                final product =
                    reservation['products'] as Map<String, dynamic>?;

                final customer =
                    reservation['profiles'] as Map<String, dynamic>?;

                final productName = product?['name'] ?? 'Unknown Product';

                final customerName =
                    customer?['full_name'] ?? 'Unknown Customer';

                return RetailerReservationCard(
                  productName: productName,
                  customerName: customerName,
                  quantity: quantity,
                  status: status,

                  onConfirm: status == 'PENDING'
                      ? () => _updateStatus(
                          context: context,
                          ref: ref,
                          reservationId: reservationId,
                          status: 'CONFIRMED',
                        )
                      : null,

                  onCollected: status == 'CONFIRMED'
                      ? () => _updateStatus(
                          context: context,
                          ref: ref,
                          reservationId: reservationId,
                          status: 'COLLECTED',
                        )
                      : null,

                  onCancel: status == 'PENDING' || status == 'CONFIRMED'
                      ? () => _updateStatus(
                          context: context,
                          ref: ref,
                          reservationId: reservationId,
                          status: 'CANCELLED',
                        )
                      : null,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
