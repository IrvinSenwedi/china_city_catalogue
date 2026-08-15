import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../catalogue/models/product.dart';
import '../../catalogue/presentation/product_details_page.dart';
import '../../catalogue/presentation/widgets/product_placeholder.dart';
import '../../catalogue/presentation/widgets/stock_badge.dart';
import '../providers/search_providers.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final searchController = TextEditingController();

  final focusNode = FocusNode();

  String query = '';
  bool hasSubmitted = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  Future<void> _submitSearch(List<Product> results) async {
    final trimmedQuery = searchController.text.trim();

    if (trimmedQuery.isEmpty) {
      return;
    }

    setState(() {
      query = trimmedQuery;
      hasSubmitted = true;
    });

    try {
      await ref
          .read(searchRepositoryProvider)
          .recordSearch(query: trimmedQuery, resultsCount: results.length);

      ref.invalidate(recentSearchesProvider);

      ref.invalidate(popularSearchesProvider);
    } catch (error) {
      debugPrint('Failed to record search: $error');
    }
  }

  Future<void> _searchSuggestion(String selectedQuery) async {
    searchController.text = selectedQuery;

    searchController.selection = TextSelection.collapsed(
      offset: searchController.text.length,
    );

    setState(() {
      query = selectedQuery;
      hasSubmitted = false;
    });

    final results = await ref.read(productSearchProvider(selectedQuery).future);

    await _submitSearch(results);
  }

  @override
  Widget build(BuildContext context) {
    final searchAsync = ref.watch(productSearchProvider(query));

    return Scaffold(
      appBar: AppBar(title: const Text('Search Products')),

      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: TextField(
                controller: searchController,
                focusNode: focusNode,
                textInputAction: TextInputAction.search,

                onChanged: (value) {
                  setState(() {
                    query = value;
                    hasSubmitted = false;
                  });
                },

                onSubmitted: (_) async {
                  final results = await ref.read(
                    productSearchProvider(query).future,
                  );

                  await _submitSearch(results);
                },

                decoration: InputDecoration(
                  hintText: 'What are you looking for?',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFFB42318),
                  ),

                  suffixIcon: searchController.text.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            searchController.clear();

                            setState(() {
                              query = '';
                              hasSubmitted = false;
                            });

                            focusNode.requestFocus();
                          },
                          icon: const Icon(
                            Icons.close,
                            color: Color(0xFF64748B),
                          ),
                        ),
                ),
              ),
            ),

            Expanded(
              child: _SearchBody(
                query: query,
                hasSubmitted: hasSubmitted,
                searchAsync: searchAsync,
                onSubmit: _submitSearch,
                onSuggestionSelected: _searchSuggestion,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBody extends ConsumerWidget {
  const _SearchBody({
    required this.query,
    required this.hasSubmitted,
    required this.searchAsync,
    required this.onSubmit,
    required this.onSuggestionSelected,
  });

  final String query;
  final bool hasSubmitted;

  final AsyncValue<List<Product>> searchAsync;

  final Future<void> Function(List<Product> results) onSubmit;

  final Future<void> Function(String query) onSuggestionSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (query.trim().isEmpty) {
      return _SearchStartState(onSearchSelected: onSuggestionSelected);
    }

    return searchAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),

      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Color(0xFFB42318),
              ),

              const SizedBox(height: 12),

              Text(
                'Search failed',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF111827),
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                '$error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      ),

      data: (products) {
        if (products.isEmpty) {
          return _NoSearchResults(
            query: query,
            hasSubmitted: hasSubmitted,
            onSubmit: () async {
              await onSubmit(products);
            },
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  Text(
                    '${products.length} '
                    'result${products.length == 1 ? '' : 's'}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const Spacer(),

                  if (!hasSubmitted)
                    TextButton.icon(
                      onPressed: () async {
                        await onSubmit(products);
                      },
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text('Submit Search'),
                    ),
                ],
              ),
            ),

            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: products.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  return _SearchResultCard(product: products[index]);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SearchStartState extends ConsumerWidget {
  const _SearchStartState({required this.onSearchSelected});

  final Future<void> Function(String query) onSearchSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentAsync = ref.watch(recentSearchesProvider);

    final popularAsync = ref.watch(popularSearchesProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
      children: [
        recentAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
          data: (recent) {
            if (recent.isEmpty) {
              return const SizedBox.shrink();
            }

            return _SearchSuggestionsSection(
              title: 'Recent Searches',
              subtitle: 'Quickly search again',
              icon: Icons.history,
              accent: _SearchAccent.information,
              searches: recent,
              onSelected: (value) {
                onSearchSelected(value);
              },
            );
          },
        ),

        const SizedBox(height: 26),

        popularAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
          data: (popular) {
            if (popular.isEmpty) {
              return const SizedBox.shrink();
            }

            return _SearchSuggestionsSection(
              title: 'Popular Searches',
              subtitle: 'What shoppers are looking for',
              icon: Icons.trending_up,
              accent: _SearchAccent.promotional,
              searches: popular,
              onSelected: (value) {
                onSearchSelected(value);
              },
            );
          },
        ),

        const SizedBox(height: 30),

        Center(
          child: Text(
            'Search across products available in China City.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchSuggestionsSection extends StatelessWidget {
  const _SearchSuggestionsSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.searches,
    required this.onSelected,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final _SearchAccent accent;
  final List<String> searches;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final background = accent == _SearchAccent.information
        ? const Color(0xFFEFF6FF)
        : const Color(0xFFFFF1D6);
    final foreground = accent == _SearchAccent.information
        ? const Color(0xFF1D4ED8)
        : const Color(0xFF9A6700);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 19, color: foreground),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: searches.map((search) {
            return ActionChip(
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFFE9E2DF)),
              avatar: Icon(Icons.search, size: 16, color: foreground),
              label: Text(_formatQuery(search)),
              labelStyle: const TextStyle(
                color: Color(0xFF111827),
                fontWeight: FontWeight.w500,
              ),
              onPressed: () {
                onSelected(search);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  String _formatQuery(String value) {
    return value
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map(
          (word) =>
              '${word[0].toUpperCase()}'
              '${word.substring(1)}',
        )
        .join(' ');
  }
}

enum _SearchAccent { information, promotional }

class _NoSearchResults extends StatelessWidget {
  const _NoSearchResults({
    required this.query,
    required this.hasSubmitted,
    required this.onSubmit,
  });

  final String query;
  final bool hasSubmitted;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: Color(0xFFFFF1D6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off,
                size: 34,
                color: Color(0xFF9A6700),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              'No products found',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            Text(
              'We couldn\'t find anything matching "$query".',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            if (!hasSubmitted)
              FilledButton.icon(
                onPressed: onSubmit,
                icon: const Icon(Icons.insights_outlined),
                label: const Text('Submit Search'),
              ),

            if (hasSubmitted)
              Text(
                'Your search has been recorded.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),

        leading: Container(
          width: 64,
          height: 64,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: const Color(0xFFF8F4F2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: product.imageUrl != null
              ? Image.network(
                  product.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const ProductPlaceholder(),
                )
              : const ProductPlaceholder(),
        ),

        title: Text(
          product.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),

            Text(
              product.storeName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF64748B)),
            ),

            const SizedBox(height: 7),

            StockBadge(product: product),
          ],
        ),

        trailing: Text(
          'R${product.price.toStringAsFixed(2)}',
          style: const TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.bold,
          ),
        ),

        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailsPage(product: product),
            ),
          );
        },
      ),
    );
  }
}
