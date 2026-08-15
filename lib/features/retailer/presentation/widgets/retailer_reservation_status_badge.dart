import 'package:flutter/material.dart';

class RetailerReservationStatusBadge extends StatelessWidget {
  const RetailerReservationStatusBadge({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color foreground;
    Color background;

    switch (status) {
      case 'CONFIRMED':
        icon = Icons.check_circle_outline;
        foreground = const Color(0xFF2563EB);
        background = const Color(0xFFEFF6FF);
        break;
      case 'COLLECTED':
        icon = Icons.done_all;
        foreground = const Color(0xFF15803D);
        background = const Color(0xFFEAF8EE);
        break;
      case 'CANCELLED':
        icon = Icons.cancel_outlined;
        foreground = const Color(0xFFB42318);
        background = const Color(0xFFFFE9E5);
        break;
      case 'EXPIRED':
        icon = Icons.timer_off_outlined;
        foreground = const Color(0xFF64748B);
        background = const Color(0xFFF1F5F9);
        break;
      default:
        icon = Icons.schedule;
        foreground = const Color(0xFFB45309);
        background = const Color(0xFFFFF4D6);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: foreground.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: foreground),
          const SizedBox(width: 5),
          Text(
            _label(status),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w600,
            ),
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
      case 'EXPIRED':
        return 'Expired';
      default:
        return 'Pending';
    }
  }
}
