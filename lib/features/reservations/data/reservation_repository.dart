import 'package:china_city_catalogue/features/reservations/models/reservations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReservationRepository {
  ReservationRepository(this._client);

  final SupabaseClient _client;

  Future<void> createReservation({
    required String productId,
    required int quantity,
    required DateTime collectionAt,
  }) async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception('You must be signed in.');
    }

    final expiresAt = collectionAt.add(const Duration(minutes: 30));

    await _client.from('reservations').insert({
      'customer_id': user.id,
      'product_id': productId,
      'quantity': quantity,
      'collection_at': collectionAt.toUtc().toIso8601String(),
      'expires_at': expiresAt.toUtc().toIso8601String(),
    });
  }

  Future<List<Reservation>> getMyReservations() async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception('You must be signed in.');
    }

    // Expire any reservation whose
    // collection window has passed.
    await _client.rpc('expire_reservations');

    final response = await _client
        .from('reservations')
        .select('''
          id,
          quantity,
          status,
          created_at,
          collection_at,
          expires_at,
          products(
            name,
            price
          )
        ''')
        .eq('customer_id', user.id)
        .order('created_at', ascending: false);

    return (response as List)
        .map((item) => Reservation.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
