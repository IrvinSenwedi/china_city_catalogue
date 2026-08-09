import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/catalogue_repository.dart';
import '../models/product.dart';

final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final catalogueRepositoryProvider = Provider<CatalogueRepository>((ref) {
  return CatalogueRepository(ref.watch(supabaseProvider));
});

final productsProvider = FutureProvider<List<Product>>((ref) async {
  return ref.watch(catalogueRepositoryProvider).getProducts();
});
