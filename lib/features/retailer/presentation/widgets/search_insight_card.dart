import 'package:flutter/material.dart';

class SearchInsightCard extends StatelessWidget {
  const SearchInsightCard({
    super.key,
    required this.query,
    required this.searchCount,
    required this.zeroResultCount,
  });

  final String query;
  final int searchCount;
  final int zeroResultCount;

  @override
  Widget build(BuildContext context) {
    final isUnmetDemand = zeroResultCount > 0;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: isUnmetDemand
                    ? Theme.of(context).colorScheme.errorContainer
                    : Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isUnmetDemand ? Icons.trending_up_rounded : Icons.search,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatQuery(query),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    '$searchCount '
                    '${searchCount == 1 ? 'search' : 'searches'}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),

                  if (zeroResultCount > 0) ...[
                    const SizedBox(height: 3),
                    Text(
                      '$zeroResultCount returned no products',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            if (isUnmetDemand)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Opportunity',
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatQuery(String value) {
    if (value.isEmpty) return value;

    return value
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }
}
