import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../catalogue/models/product.dart';
import '../../catalogue/presentation/product_details_page.dart';
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

    if (trimmedQuery.isEmpty) return;

    setState(() {
      hasSubmitted = true;
      query = trimmedQuery;
    });

    try {
      await ref
          .read(searchRepositoryProvider)
          .recordSearch(query: trimmedQuery, resultsCount: results.length);
    } catch (error) {
      debugPrint('Failed to record search: $error');
    }
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
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: searchController.text.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            searchController.clear();

                            setState(() {
                              query = '';
                              hasSubmitted = false;
                            });
                          },
                          icon: const Icon(Icons.close),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBody extends StatelessWidget {
  const _SearchBody({
    required this.query,
    required this.hasSubmitted,
    required this.searchAsync,
    required this.onSubmit,
  });

  final String query;
  final bool hasSubmitted;

  final AsyncValue<List<Product>> searchAsync;

  final Future<void> Function(List<Product> results) onSubmit;

  @override
  Widget build(BuildContext context) {
    if (query.trim().isEmpty) {
      return const _SearchStartState();
    }

    return searchAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),

      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 12),
              Text(
                'Search failed',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text('$error', textAlign: TextAlign.center),
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
                    TextButton(
                      onPressed: () async {
                        await onSubmit(products);
                      },
                      child: const Text('Record Search'),
                    ),
                ],
              ),
            ),

            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: products.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
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

class _SearchStartState extends StatelessWidget {
  const _SearchStartState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search, size: 40),
            ),

            const SizedBox(height: 18),

            Text(
              'Search China City',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            Text(
              'Search for products available '
              'across participating stores.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
            const Icon(Icons.search_off, size: 48),

            const SizedBox(height: 14),

            Text(
              'No products found',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            Text(
              'We couldn\'t find anything '
              'matching "$query".',
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
                style: Theme.of(context).textTheme.bodySmall,
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
      margin: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),

        leading: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: product.imageUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    product.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.shopping_bag_outlined),
                  ),
                )
              : const Icon(Icons.shopping_bag_outlined),
        ),

        title: Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 3),

            Text(product.storeName),

            const SizedBox(height: 3),

            Text(product.stockLabel),
          ],
        ),

        trailing: Text(
          'R${product.price.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
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
