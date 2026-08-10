import 'package:china_city_catalogue/features/catalogue/providers/catalogue_providers.dart';
import 'package:china_city_catalogue/features/recommendations/data/interaction_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/recommendation_repository.dart';

final recommendationRepositoryProvider = Provider<RecommendationRepository>((
  ref,
) {
  return RecommendationRepository(baseUrl: 'http://192.168.18.6:8000');
});

// Provider for product recommendations
final productRecommendationsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((
      ref,
      productId,
    ) async {
      return ref
          .watch(recommendationRepositoryProvider)
          .getRecommendations(productId: productId);
    });

// Provider for interaction repository
final interactionRepositoryProvider = Provider<InteractionRepository>((ref) {
  return InteractionRepository(ref.watch(supabaseProvider));
});

// Provider for user recommendations
final userRecommendationsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((
      ref,
      userId,
    ) async {
      return ref
          .watch(recommendationRepositoryProvider)
          .getUserRecommendations(userId: userId);
    });
