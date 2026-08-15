import 'package:supabase_flutter/supabase_flutter.dart';

import '../../catalogue/models/product.dart';

class SearchRepository {
  SearchRepository(this._client);

  final SupabaseClient _client;

  Future<List<Product>> searchProducts({required String query}) async {
    final trimmedQuery = query.trim();

    if (trimmedQuery.isEmpty) {
      return [];
    }

    final response = await _client
        .from('products')
        .select('''
          id,
          name,
          description,
          price,
          stock_quantity,
          image_url,
          stores(name),
          categories(name)
        ''')
        .or(
          'name.ilike.%$trimmedQuery%,'
          'description.ilike.%$trimmedQuery%',
        )
        .order('name');

    return (response as List)
        .map((item) => Product.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> recordSearch({
    required String query,
    required int resultsCount,
  }) async {
    final user = _client.auth.currentUser;

    if (user == null) return;

    final trimmedQuery = query.trim();

    if (trimmedQuery.isEmpty) return;

    await _client.from('search_events').insert({
      'user_id': user.id,
      'query': trimmedQuery.toLowerCase(),
      'results_count': resultsCount,
    });
  }

  Future<List<String>> getRecentSearches({int limit = 5}) async {
    final user = _client.auth.currentUser;

    if (user == null) {
      return [];
    }

    final response = await _client
        .from('search_events')
        .select('query, searched_at')
        .eq('user_id', user.id)
        .order('searched_at', ascending: false)
        .limit(20);

    final seen = <String>{};
    final searches = <String>[];

    for (final item in response as List) {
      final query = (item['query'] as String?)?.trim() ?? '';

      if (query.isEmpty) continue;

      final normalized = query.toLowerCase();

      if (seen.add(normalized)) {
        searches.add(query);
      }

      if (searches.length >= limit) {
        break;
      }
    }

    return searches;
  }

  Future<List<String>> getPopularSearches({int limit = 5}) async {
    final response = await _client.rpc(
      'get_search_insights',
      params: {'p_limit': limit},
    );

    return (response as List)
        .map((item) => (item['query'] as String?) ?? '')
        .where((query) => query.isNotEmpty)
        .toList();
  }
}
