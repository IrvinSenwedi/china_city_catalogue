import 'package:flutter/material.dart';

class ReservationStatusBadge extends StatelessWidget {
  const ReservationStatusBadge({super.key, required this.status});

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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15),
          const SizedBox(width: 5),
          Text(
            _label(status),
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  String _label(String status) {
    switch (status) {
      case 'CONFIRMED':
        return 'Confirmed';

      case 'COLLECTED':
        return 'Collected';

      case 'CANCELLED':
        return 'Cancelled';

      default:
        return 'Pending';
    }
  }
}
