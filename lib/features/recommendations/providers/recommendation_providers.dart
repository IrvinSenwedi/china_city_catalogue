import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/recommendation_repository.dart';

final recommendationRepositoryProvider = Provider<RecommendationRepository>((
  ref,
) {
  return RecommendationRepository(baseUrl: 'http://192.168.18.6:8000');
});

final productRecommendationsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((
      ref,
      productId,
    ) async {
      return ref
          .watch(recommendationRepositoryProvider)
          .getRecommendations(productId: productId);
    });
