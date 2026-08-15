import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../catalogue/providers/catalogue_providers.dart';
import '../../auth/models/user_profile.dart';
import '../data/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(supabaseProvider));
});

final profileProvider = FutureProvider<UserProfile>((ref) async {
  return ref.watch(profileRepositoryProvider).getProfile();
});
