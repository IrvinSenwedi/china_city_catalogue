import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/retailer_providers.dart';
import 'widgets/search_insight_card.dart';

class RetailerSearchInsightsPage extends ConsumerWidget {
  const RetailerSearchInsightsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insightsAsync = ref.watch(retailerSearchInsightsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Search Insights')),
      body: insightsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48),

                const SizedBox(height: 12),

                const Text('Unable to load search insights'),

                const SizedBox(height: 16),

                FilledButton.icon(
                  onPressed: () {
                    ref.invalidate(retailerSearchInsightsProvider);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),

        data: (insights) {
          if (insights.isEmpty) {
            return const _EmptyInsights();
          }

          final unmetDemand = insights.where((item) {
            final zeroResultCount =
                (item['zero_result_count'] as num?)?.toInt() ?? 0;

            return zeroResultCount > 0;
          }).toList();

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(retailerSearchInsightsProvider);

              await ref.read(retailerSearchInsightsProvider.future);
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                Text(
                  'Customer Demand',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'See what customers are searching '
                  'for across the catalogue.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),

                if (unmetDemand.isNotEmpty) ...[
                  const SizedBox(height: 28),

                  _SectionHeader(
                    title: 'Stock Opportunities',
                    subtitle:
                        'Searches where customers could not find a matching product.',
                    icon: Icons.lightbulb_outline,
                  ),

                  const SizedBox(height: 12),

                  ...unmetDemand.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: SearchInsightCard(
                        query: item['query'] ?? '',
                        searchCount:
                            (item['search_count'] as num?)?.toInt() ?? 0,
                        zeroResultCount:
                            (item['zero_result_count'] as num?)?.toInt() ?? 0,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                _SectionHeader(
                  title: 'Popular Searches',
                  subtitle:
                      'Products and terms customers search for most often.',
                  icon: Icons.trending_up,
                ),

                const SizedBox(height: 12),

                ...insights.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SearchInsightCard(
                      query: item['query'] ?? '',
                      searchCount: (item['search_count'] as num?)?.toInt() ?? 0,
                      zeroResultCount:
                          (item['zero_result_count'] as num?)?.toInt() ?? 0,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 3),

              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyInsights extends StatelessWidget {
  const _EmptyInsights();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.insights_outlined, size: 48),
            const SizedBox(height: 14),
            Text(
              'No search data yet',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Customer search activity will '
              'appear here.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
