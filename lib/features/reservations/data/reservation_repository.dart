import 'package:china_city_catalogue/features/reservations/models/reservations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReservationRepository {
  ReservationRepository(this._client);

  final SupabaseClient _client;

  Future<void> createReservation({
    required String productId,
    required int quantity,
  }) async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception('You must be signed in.');
    }

    await _client.from('reservations').insert({
      'customer_id': user.id,
      'product_id': productId,
      'quantity': quantity,
    });
  }

  Future<List<Reservation>> getMyReservations() async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception('You must be signed in.');
    }

    final response = await _client
        .from('reservations')
        .select('''
          id,
          quantity,
          status,
          created_at,
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
