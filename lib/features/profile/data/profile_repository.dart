import 'package:supabase_flutter/supabase_flutter.dart';

import '../../auth/models/user_profile.dart';

class ProfileRepository {
  ProfileRepository(this._client);

  final SupabaseClient _client;

  Future<UserProfile> getProfile() async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception('You must be signed in.');
    }

    final response = await _client
        .from('profiles')
        .select('''
          id,
          full_name,
          role,
          phone_number
          ''')
        .eq('id', user.id)
        .single();

    return UserProfile.fromJson(response);
  }

  Future<void> updateProfile({
    required String fullName,
    String? phoneNumber,
  }) async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception('You must be signed in.');
    }

    await _client
        .from('profiles')
        .update({
          'full_name': fullName.trim(),
          'phone_number': phoneNumber?.trim().isEmpty == true
              ? null
              : phoneNumber?.trim(),
        })
        .eq('id', user.id);
  }

  String? get email => _client.auth.currentUser?.email;
}
