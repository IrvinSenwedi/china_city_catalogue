import 'package:china_city_catalogue/features/reservations/models/reservations.dart';
import 'package:flutter/material.dart';

import 'reservation_status_badge.dart';

class ReservationCard extends StatelessWidget {
  const ReservationCard({super.key, required this.reservation});

  final Reservation reservation;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.inventory_2_outlined),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reservation.productName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        'Quantity: ${reservation.quantity}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),

                ReservationStatusBadge(status: reservation.status),
              ],
            ),

            const SizedBox(height: 18),

            if (reservation.collectionAt != null) ...[
              _InfoRow(
                icon: Icons.event_outlined,
                label: 'Collection',
                value: _formatDateTime(reservation.collectionAt!),
              ),

              const SizedBox(height: 10),
            ],

            if (reservation.expiresAt != null) ...[
              _InfoRow(
                icon: Icons.timer_outlined,
                label: 'Held until',
                value: _formatTime(reservation.expiresAt!),
              ),

              const SizedBox(height: 18),
            ],

            const Divider(),

            const SizedBox(height: 12),

            _PriceRow(
              label: 'Product price',
              value: 'R${reservation.productPrice.toStringAsFixed(2)}',
            ),

            const SizedBox(height: 8),

            _PriceRow(label: 'Quantity', value: '${reservation.quantity}'),

            const SizedBox(height: 8),

            _PriceRow(
              label: 'Estimated total',
              value:
                  'R${(reservation.productPrice * reservation.quantity).toStringAsFixed(2)}',
              emphasize: true,
            ),

            if (reservation.status == 'PENDING')
              _StatusMessage(
                icon: Icons.schedule_outlined,
                message:
                    'Waiting for the retailer to confirm your reservation.',
              ),

            if (reservation.status == 'CONFIRMED')
              _StatusMessage(
                icon: Icons.storefront_outlined,
                message:
                    'Your reservation is confirmed. Collect it within the selected collection window.',
              ),

            if (reservation.status == 'COLLECTED')
              _StatusMessage(
                icon: Icons.check_circle_outline,
                message: 'This reservation has been collected successfully.',
              ),

            if (reservation.status == 'CANCELLED')
              _StatusMessage(
                icon: Icons.cancel_outlined,
                message: 'This reservation was cancelled.',
              ),

            if (reservation.status == 'EXPIRED')
              _StatusMessage(
                icon: Icons.timer_off_outlined,
                message:
                    'This reservation expired because the collection window passed.',
              ),
          ],
        ),
      ),
    );
  }

  static String _formatDateTime(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');

    final month = value.month.toString().padLeft(2, '0');

    final year = value.year;

    final time = _formatTime(value);

    return '$day/$month/$year · $time';
  }

  static String _formatTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');

    final minute = value.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18),

        const SizedBox(width: 8),

        Text(
          '$label:',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),

        const SizedBox(width: 6),

        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: emphasize ? FontWeight.w600 : null,
            color: emphasize
                ? null
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),

        const Spacer(),

        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _StatusMessage extends StatelessWidget {
  const _StatusMessage({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18),

          const SizedBox(width: 7),

          Expanded(
            child: Text(message, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
