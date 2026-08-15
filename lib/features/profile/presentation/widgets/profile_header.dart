import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.name, required this.role});

  final String name;
  final String role;

  @override
  Widget build(BuildContext context) {
    final initials = name
        .trim()
        .split(' ')
        .where((value) => value.isNotEmpty)
        .take(2)
        .map((value) => value[0].toUpperCase())
        .join();

    return Column(
      children: [
        CircleAvatar(
          radius: 38,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            initials.isEmpty ? 'U' : initials,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),

        const SizedBox(height: 14),

        Text(
          name,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 4),

        Text(
          role == 'RETAILER' ? 'Retailer Account' : 'Customer Account',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
