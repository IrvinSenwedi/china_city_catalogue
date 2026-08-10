import 'package:flutter/material.dart';

class CatalogueHeader extends StatelessWidget {
  const CatalogueHeader({
    super.key,
    required this.onReservationsPressed,
    required this.onSignOutPressed,
  });

  final VoidCallback onReservationsPressed;
  final VoidCallback onSignOutPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 12, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'China City',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Find what you need, nearby.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            tooltip: 'My Reservations',
            onPressed: onReservationsPressed,
            icon: const Icon(Icons.receipt_long_outlined),
          ),
          const SizedBox(width: 4),
          PopupMenuButton<String>(
            tooltip: 'Account',
            icon: const Icon(Icons.account_circle_outlined),
            onSelected: (value) {
              if (value == 'reservations') {
                onReservationsPressed();
              }

              if (value == 'logout') {
                onSignOutPressed();
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'reservations',
                child: ListTile(
                  leading: Icon(Icons.receipt_long_outlined),
                  title: Text('My Reservations'),
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Sign Out'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
