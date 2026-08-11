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
}
