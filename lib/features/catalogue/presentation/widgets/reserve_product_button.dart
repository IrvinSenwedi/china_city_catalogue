import 'package:flutter/material.dart';

class ReserveProductButton extends StatelessWidget {
  const ReserveProductButton({
    super.key,
    required this.isAvailable,
    required this.isReserving,
    required this.onPressed,
  });

  final bool isAvailable;
  final bool isReserving;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton.icon(
        onPressed: !isAvailable || isReserving ? null : onPressed,
        icon: isReserving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.bookmark_add_outlined),
        label: Text(
          isAvailable ? 'Reserve for Collection' : 'Currently Unavailable',
        ),
      ),
    );
  }
}
