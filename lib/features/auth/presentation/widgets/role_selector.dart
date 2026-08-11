import 'package:flutter/material.dart';

class RoleSelector extends StatelessWidget {
  const RoleSelector({
    super.key,
    required this.selectedRole,
    required this.onChanged,
  });

  final String selectedRole;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account Type',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),

        const SizedBox(height: 10),

        SegmentedButton<String>(
          segments: const [
            ButtonSegment(
              value: 'CUSTOMER',
              label: Text('Customer'),
              icon: Icon(Icons.person_outline),
            ),
            ButtonSegment(
              value: 'RETAILER',
              label: Text('Retailer'),
              icon: Icon(Icons.store_outlined),
            ),
          ],
          selected: {selectedRole},
          onSelectionChanged: (selection) {
            onChanged(selection.first);
          },
        ),
      ],
    );
  }
}
