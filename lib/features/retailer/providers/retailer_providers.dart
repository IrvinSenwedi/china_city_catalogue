import 'package:china_city_catalogue/features/retailer/data/retailer_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../catalogue/models/product.dart';
import '../../catalogue/providers/catalogue_providers.dart';

final retailerRepositoryProvider = Provider<RetailerRepository>((ref) {
  return RetailerRepository(ref.watch(supabaseProvider));
});

final retailerProductsProvider = FutureProvider<List<Product>>((ref) async {
  return ref.watch(retailerRepositoryProvider).getMyProducts();
});

final categoriesProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final client = ref.watch(supabaseProvider);

  final response = await client
      .from('categories')
      .select('id, name')
      .order('name');

  return List<Map<String, dynamic>>.from(response);
});

final retailerReservationsProvider = FutureProvider<List<Map<String, dynamic>>>(
  (ref) async {
    return ref.watch(retailerRepositoryProvider).getStoreReservations();
  },
);

final retailerSearchInsightsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
      return ref.watch(retailerRepositoryProvider).getSearchInsights();
    });
