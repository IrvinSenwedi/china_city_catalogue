import 'package:flutter/material.dart';

import 'retailer_reservation_status_badge.dart';

class RetailerReservationCard extends StatelessWidget {
  const RetailerReservationCard({
    super.key,
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
                  child: const Icon(Icons.receipt_long_outlined),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 6),

                      Row(
                        children: [
                          const Icon(Icons.person_outline, size: 16),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              customerName,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      Text(
                        'Quantity: $quantity',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),

                RetailerReservationStatusBadge(status: status),
              ],
            ),

            if (onConfirm != null ||
                onCancel != null ||
                onCollected != null) ...[
              const SizedBox(height: 18),
              const Divider(),
              const SizedBox(height: 10),

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
                      label: const Text('Mark Collected'),
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
