import 'package:supabase_flutter/supabase_flutter.dart';

import '../../catalogue/models/product.dart';

class RetailerRepository {
  RetailerRepository(this._client);

  final SupabaseClient _client;

  Future<String> getMyStoreId() async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception('You must be signed in.');
    }

    final response = await _client
        .from('stores')
        .select('id')
        .eq('owner_id', user.id)
        .maybeSingle();

    if (response == null) {
      throw Exception('No store is assigned to this retailer.');
    }

    return response['id'] as String;
  }

  Future<List<Product>> getMyProducts() async {
    final storeId = await getMyStoreId();

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
        .eq('store_id', storeId)
        .order('name');

    return (response as List)
        .map((item) => Product.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> updateStock({
    required String productId,
    required int stockQuantity,
  }) async {
    await _client
        .from('products')
        .update({
          'stock_quantity': stockQuantity,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', productId);
  }

  Future<void> updateProduct({
    required String productId,
    required String name,
    required String description,
    required double price,
    required int stockQuantity,
  }) async {
    await _client
        .from('products')
        .update({
          'name': name,
          'description': description,
          'price': price,
          'stock_quantity': stockQuantity,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', productId);
  }

  Future<void> addProduct({
    required String name,
    required String description,
    required double price,
    required int stockQuantity,
    required String categoryId,
  }) async {
    final storeId = await getMyStoreId();

    await _client.from('products').insert({
      'store_id': storeId,
      'category_id': categoryId,
      'name': name,
      'description': description,
      'price': price,
      'stock_quantity': stockQuantity,
    });
  }

  Future<List<Map<String, dynamic>>> getStoreReservations() async {
    final storeId = await getMyStoreId();

    final response = await _client
        .from('reservations')
        .select('''
        id,
        quantity,
        status,
        created_at,
        products!inner(
          id,
          name,
          store_id
        ),
        profiles!reservations_customer_id_fkey(
          full_name
        )
      ''')
        .eq('products.store_id', storeId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> updateReservationStatus({
    required String reservationId,
    required String status,
  }) async {
    await _client
        .from('reservations')
        .update({'status': status})
        .eq('id', reservationId);
  }
}
