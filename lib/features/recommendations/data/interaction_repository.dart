import 'package:supabase_flutter/supabase_flutter.dart';

class InteractionRepository {
  InteractionRepository(this._client);

  final SupabaseClient _client;

  Future<void> recordInteraction({
    required String productId,
    required String interactionType,
  }) async {
    final user = _client.auth.currentUser;

    if (user == null) return;

    await _client.from('product_interactions').insert({
      'user_id': user.id,
      'product_id': productId,
      'interaction_type': interactionType,
      // No weight here.
      // Supabase trigger determines it.
    });
  }

  Future<void> recordView(String productId) async {
    await recordInteraction(productId: productId, interactionType: 'VIEW');
  }

  Future<void> recordReservation(String productId) async {
    await recordInteraction(
      productId: productId,
      interactionType: 'RESERVATION',
    );
  }
}
