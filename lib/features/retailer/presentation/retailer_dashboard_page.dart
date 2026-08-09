import 'package:china_city_catalogue/features/retailer/presentation/retailer_products_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_providers.dart';

class RetailerDashboardPage extends ConsumerWidget {
  const RetailerDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Retailer Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Sign Out',
            onPressed: () async {
              await ref.read(authRepositoryProvider).signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('My Store', style: Theme.of(context).textTheme.headlineMedium),

            const SizedBox(height: 8),

            const Text('Manage products, inventory and reservations.'),

            const SizedBox(height: 32),

            _DashboardCard(
              title: 'Products',
              description: 'Manage products and stock.',
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

            _DashboardCard(
              title: 'Reservations',
              description: 'View customer reservations.',
              icon: Icons.receipt_long_outlined,
              onTap: () {
                //todo
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(description),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
