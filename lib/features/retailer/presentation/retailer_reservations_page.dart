import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/retailer_providers.dart';

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
            padding: const EdgeInsets.all(24),
            child: Text(
              'Failed to load reservations.\n$error',
              textAlign: TextAlign.center,
            ),
          ),
        ),

        data: (reservations) {
          if (reservations.isEmpty) {
            return const Center(child: Text('No reservations found.'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(retailerReservationsProvider);

              await ref.read(retailerReservationsProvider.future);
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
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

                return _ReservationCard(
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
                  onCancel: status == 'PENDING' || status == 'CONFIRMED'
                      ? () => _updateStatus(
                          context: context,
                          ref: ref,
                          reservationId: reservationId,
                          status: 'CANCELLED',
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
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  const _ReservationCard({
    required this.productName,
    required this.customerName,
    required this.quantity,
    required this.status,
    required this.onConfirm,
    required this.onCancel,
    required this.onCollected,
  });

  final String productName;
  final String customerName;
  final int quantity;
  final String status;

  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final VoidCallback? onCollected;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(child: Icon(Icons.inventory_2_outlined)),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),

                      const SizedBox(height: 4),

                      Text('Customer: $customerName'),

                      const SizedBox(height: 4),

                      Text('Quantity: $quantity'),
                    ],
                  ),
                ),

                _StatusChip(status: status),
              ],
            ),

            if (onConfirm != null ||
                onCancel != null ||
                onCollected != null) ...[
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 8),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (onConfirm != null)
                    FilledButton.icon(
                      onPressed: onConfirm,
                      icon: const Icon(Icons.check),
                      label: const Text('Confirm'),
                    ),

                  if (onCollected != null)
                    FilledButton.tonalIcon(
                      onPressed: onCollected,
                      icon: const Icon(Icons.done_all),
                      label: const Text('Collected'),
                    ),

                  if (onCancel != null)
                    OutlinedButton.icon(
                      onPressed: onCancel,
                      icon: const Icon(Icons.close),
                      label: const Text('Cancel'),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    IconData icon;

    switch (status) {
      case 'CONFIRMED':
        icon = Icons.check_circle_outline;
        break;

      case 'COLLECTED':
        icon = Icons.done_all;
        break;

      case 'CANCELLED':
        icon = Icons.cancel_outlined;
        break;

      default:
        icon = Icons.schedule;
    }

    return Chip(avatar: Icon(icon, size: 18), label: Text(status));
  }
}
