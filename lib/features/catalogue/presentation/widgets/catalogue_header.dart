import 'package:flutter/material.dart';

class CatalogueHeader extends StatelessWidget {
  const CatalogueHeader({
    super.key,
    required this.onReservationsPressed,
    required this.onSignOutPressed,
    required this.onProfilePressed,
  });

  final VoidCallback onReservationsPressed;
  final VoidCallback onSignOutPressed;
  final VoidCallback onProfilePressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFB42318), Color(0xFF7F1D1D)],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFB42318).withValues(alpha: 0.14),
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'China City',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),

                      const SizedBox(height: 7),

                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: Color(0xFFFFD58A),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Shop products available nearby',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.84),
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                PopupMenuButton<String>(
                  tooltip: 'Account',
                  color: colorScheme.surface,
                  onSelected: (value) {
                    if (value == 'reservations') {
                      onReservationsPressed();
                    }

                    if (value == 'profile') {
                      onProfilePressed();
                    }

                    if (value == 'logout') {
                      onSignOutPressed();
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'profile',
                      child: ListTile(
                        leading: Icon(Icons.person_outline),
                        title: Text('Profile'),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'reservations',
                      child: ListTile(
                        leading: Icon(Icons.receipt_long_outlined),
                        title: Text('My Reservations'),
                      ),
                    ),
                    PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'logout',
                      child: ListTile(
                        leading: Icon(Icons.logout),
                        title: Text('Sign Out'),
                      ),
                    ),
                  ],
                  child: _HeaderIconButton(
                    tooltip: 'Account',
                    icon: Icons.person_outline,
                    onPressed: null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onPressed,
        child: Tooltip(
          message: tooltip,
          child: SizedBox(
            width: 42,
            height: 42,
            child: Icon(icon, color: Colors.white, size: 21),
          ),
        ),
      ),
    );
  }
}
