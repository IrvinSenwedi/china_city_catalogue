import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../catalogue/models/product.dart';
import '../../catalogue/providers/catalogue_providers.dart';
import '../data/search_repository.dart';

final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  return SearchRepository(ref.watch(supabaseProvider));
});

final productSearchProvider = FutureProvider.family<List<Product>, String>((
  ref,
  query,
) async {
  if (query.trim().isEmpty) {
    return [];
  }

  return ref.watch(searchRepositoryProvider).searchProducts(query: query);
});
