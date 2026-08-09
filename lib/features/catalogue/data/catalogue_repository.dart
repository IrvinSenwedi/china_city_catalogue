import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/product.dart';

class CatalogueRepository {
  CatalogueRepository(this._client);

  final SupabaseClient _client;

  Future<List<Product>> getProducts() async {
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
        .order('name');

    return (response as List)
        .map((item) => Product.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
